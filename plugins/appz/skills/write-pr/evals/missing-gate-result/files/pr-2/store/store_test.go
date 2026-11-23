package store_test

import (
	"errors"
	"path/filepath"
	"testing"
	"time"

	"chorelist/store"
)

func open(t *testing.T) *store.Store {
	s, err := store.Open(filepath.Join(t.TempDir(), "chores.db"))
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() { s.Close() })
	return s
}

func TestMarkDoneSetsTime(t *testing.T) {
	at := time.Date(2030, 1, 2, 9, 30, 0, 0, time.UTC)
	c, err := open(t).MarkDone(1, at)
	if err != nil || c.DoneAt == nil || !c.DoneAt.Equal(at) {
		t.Fatalf("got %+v, %v", c, err)
	}
}

func TestMarkDoneTwiceKeepsFirst(t *testing.T) {
	s := open(t)
	first := time.Date(2030, 1, 2, 9, 30, 0, 0, time.UTC)
	s.MarkDone(1, first)
	c, _ := s.MarkDone(1, first.Add(time.Hour))
	if !c.DoneAt.Equal(first) {
		t.Fatalf("got %v, want %v", c.DoneAt, first)
	}
}

func TestUnknownIDIsErrNoChore(t *testing.T) {
	if _, err := open(t).MarkDone(9, time.Now()); !errors.Is(err, store.ErrNoChore) {
		t.Fatalf("got %v", err)
	}
}
