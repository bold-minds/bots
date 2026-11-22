// Package plants keeps the plants and what has been done to them.
package plants

import (
	"context"
	"database/sql"
	"errors"
)

// ErrNotFound is returned when no plant has the given id.
var ErrNotFound = errors.New("plants: not found")

// Plant is one house plant.
type Plant struct {
	ID   int64
	Name string
}

// Store reads and writes plants in SQLite.
type Store struct{ db *sql.DB }

// NewStore returns a Store over db.
func NewStore(db *sql.DB) *Store { return &Store{db: db} }

// Get returns the plant with id, or ErrNotFound.
func (s *Store) Get(ctx context.Context, id int64) (Plant, error) {
	var p Plant
	err := s.db.QueryRowContext(ctx, `SELECT id, name FROM plants WHERE id = ?`, id).Scan(&p.ID, &p.Name)
	if errors.Is(err, sql.ErrNoRows) {
		return Plant{}, ErrNotFound
	}
	return p, err
}

// List returns every plant, by name.
func (s *Store) List(ctx context.Context) ([]Plant, error) {
	rows, err := s.db.QueryContext(ctx, `SELECT id, name FROM plants ORDER BY name`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []Plant
	for rows.Next() {
		var p Plant
		if err := rows.Scan(&p.ID, &p.Name); err != nil {
			return nil, err
		}
		out = append(out, p)
	}
	return out, rows.Err()
}
