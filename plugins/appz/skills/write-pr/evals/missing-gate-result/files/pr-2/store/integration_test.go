package store_test

import (
	"path/filepath"
	"testing"
	"time"

	"chorelist/store"
)

func TestDoneSurvivesReopen(t *testing.T) {
	path := filepath.Join(t.TempDir(), "chores.db")
	s, _ := store.Open(path)
	at := time.Date(2030, 1, 2, 9, 30, 0, 0, time.UTC)
	s.MarkDone(2, at)
	s.Close()
	s, err := store.Open(path)
	if err != nil {
		t.Fatal(err)
	}
	defer s.Close()
	cs, _ := s.Chores()
	if cs[1].DoneAt == nil || !cs[1].DoneAt.Equal(at) {
		t.Fatalf("got %+v", cs[1])
	}
}

func TestMigrationsRunOnceOnReopen(t *testing.T) {
	path := filepath.Join(t.TempDir(), "chores.db")
	for i := 0; i < 2; i++ {
		s, err := store.Open(path)
		if err != nil {
			t.Fatalf("open %d: %v", i+1, err)
		}
		cs, _ := s.Chores()
		if len(cs) != 2 {
			t.Fatalf("open %d: %d chores, want 2", i+1, len(cs))
		}
		s.Close()
	}
}
