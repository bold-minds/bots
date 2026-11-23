package store

import (
	"sync"
	"time"
)

// Stub stands in for the real store until it is built. It holds two chores in memory.
type Stub struct {
	mu     sync.Mutex
	chores []Chore
}

// NewStub returns a stub seeded with two chores, not done.
func NewStub() *Stub {
	return &Stub{chores: []Chore{{ID: 1, Name: "Water the ferns"}, {ID: 2, Name: "Take out the bins"}}}
}

// Chores returns the chores in ID order.
func (s *Stub) Chores() ([]Chore, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	return append([]Chore(nil), s.chores...), nil
}

// MarkDone sets DoneAt once and returns the chore.
func (s *Stub) MarkDone(id int, at time.Time) (Chore, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	for i := range s.chores {
		if s.chores[i].ID == id {
			if s.chores[i].DoneAt == nil {
				s.chores[i].DoneAt = &at
			}
			return s.chores[i], nil
		}
	}
	return Chore{}, ErrNoChore
}
