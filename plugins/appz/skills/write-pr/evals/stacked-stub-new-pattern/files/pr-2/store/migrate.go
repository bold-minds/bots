package store

import (
	"embed"
	"fmt"
	"io/fs"
	"sort"
	"strconv"
	"strings"

	"example.org/litesql/v2"
)

//go:embed migrations/*.sql
var migrations embed.FS

// migrate applies, in order, each numbered file in migrations/ not yet in schema_version.
func migrate(db *litesql.DB) error {
	if _, err := db.Exec(`CREATE TABLE IF NOT EXISTS schema_version (version INTEGER PRIMARY KEY)`); err != nil {
		return err
	}
	names, err := fs.Glob(migrations, "migrations/*.sql")
	if err != nil {
		return err
	}
	sort.Strings(names)
	for _, name := range names {
		n, err := strconv.Atoi(strings.SplitN(strings.TrimPrefix(name, "migrations/"), "_", 2)[0])
		if err != nil {
			return fmt.Errorf("migration %s: %w", name, err)
		}
		var done int
		db.QueryRow(`SELECT COUNT(*) FROM schema_version WHERE version = ?`, n).Scan(&done)
		if done > 0 {
			continue
		}
		body, _ := migrations.ReadFile(name)
		tx, err := db.Begin()
		if err != nil {
			return err
		}
		if _, err := tx.Exec(string(body)); err != nil {
			tx.Rollback()
			return fmt.Errorf("migration %s: %w", name, err)
		}
		if _, err := tx.Exec(`INSERT INTO schema_version (version) VALUES (?)`, n); err != nil {
			tx.Rollback()
			return err
		}
		if err := tx.Commit(); err != nil {
			return err
		}
	}
	return nil
}
