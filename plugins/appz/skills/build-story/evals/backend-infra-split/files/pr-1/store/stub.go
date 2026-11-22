// Package store holds the pinned notes.
//
// This file is the stub from the design's stub contract: notes live in
// memory only. The back-end PR replaces it with the file-backed store.
package store

import (
	"errors"
	"strings"
)

// Note is one pinned note.
type Note struct {
	ID   int
	Text string
}

// ErrEmpty is returned by Add for a blank note.
var ErrEmpty = errors.New("note is empty")

// Store holds the notes.
type Store struct {
	notes []Note
}

// Open returns an empty in-memory store; the stub ignores path.
func Open(path string) (*Store, error) { return &Store{}, nil }

// Add pins a note.
func (s *Store) Add(text string) (Note, error) {
	text = strings.TrimSpace(text)
	if text == "" {
		return Note{}, ErrEmpty
	}
	n := Note{ID: len(s.notes) + 1, Text: text}
	s.notes = append(s.notes, n)
	return n, nil
}

// List returns the notes in the order they were added.
func (s *Store) List() ([]Note, error) {
	out := make([]Note, len(s.notes))
	copy(out, s.notes)
	return out, nil
}
