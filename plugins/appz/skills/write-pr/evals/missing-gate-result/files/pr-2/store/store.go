package store

import (
	"database/sql"
	"errors"
	"time"

	"example.org/litesql/v2"
)

// Store keeps the chore list in a litesql file.
type Store struct{ db *litesql.DB }

// Open opens the chore file at path, creating it if needed, and runs the migrations.
func Open(path string) (*Store, error) {
	db, err := litesql.Open(path)
	if err != nil {
		return nil, err
	}
	if err := migrate(db); err != nil {
		db.Close()
		return nil, err
	}
	return &Store{db: db}, nil
}

// Close closes the chore file.
func (s *Store) Close() error { return s.db.Close() }

// Chores returns the chores in ID order.
func (s *Store) Chores() ([]Chore, error) {
	rows, err := s.db.Query(`SELECT id, name, done_at FROM chores ORDER BY id`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []Chore
	for rows.Next() {
		var c Chore
		var done sql.NullString
		if err := rows.Scan(&c.ID, &c.Name, &done); err != nil {
			return nil, err
		}
		if done.Valid {
			t, _ := time.Parse(time.RFC3339Nano, done.String)
			c.DoneAt = &t
		}
		out = append(out, c)
	}
	return out, rows.Err()
}

// MarkDone sets the chore's done time once and returns the chore.
func (s *Store) MarkDone(id int, at time.Time) (Chore, error) {
	res, err := s.db.Exec(`UPDATE chores SET done_at = ? WHERE id = ? AND done_at IS NULL`, at.UTC().Format(time.RFC3339Nano), id)
	if err != nil {
		return Chore{}, ErrCantSave
	}
	if n, _ := res.RowsAffected(); n == 0 {
		var c Chore
		var done sql.NullString
		err := s.db.QueryRow(`SELECT id, name, done_at FROM chores WHERE id = ?`, id).Scan(&c.ID, &c.Name, &done)
		if errors.Is(err, sql.ErrNoRows) {
			return Chore{}, ErrNoChore
		}
		t, _ := time.Parse(time.RFC3339Nano, done.String)
		c.DoneAt = &t
		return c, nil
	}
	cs, err := s.Chores()
	if err != nil {
		return Chore{}, err
	}
	for _, c := range cs {
		if c.ID == id {
			return c, nil
		}
	}
	return Chore{}, ErrNoChore
}
