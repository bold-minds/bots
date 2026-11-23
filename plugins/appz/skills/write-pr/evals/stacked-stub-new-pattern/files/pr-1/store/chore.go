// Package store keeps the chore list.
package store

import (
	"errors"
	"time"
)

// Chore is one chore on the list. DoneAt is nil until it is marked done.
type Chore struct {
	ID     int
	Name   string
	DoneAt *time.Time
}

// ErrNoChore is returned for an id no chore has.
var ErrNoChore = errors.New("No such chore")

// ErrCantSave is returned when the list can't be saved.
var ErrCantSave = errors.New("Couldn't save that, try again")
