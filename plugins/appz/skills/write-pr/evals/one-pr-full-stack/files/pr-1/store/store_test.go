package store_test

import (
	"errors"
	"testing"

	"linkshelf/store"
)

func TestSaveMakesSlugFromName(t *testing.T) {
	s := store.New()
	l, err := s.Save("Bread", "https://example.com/recipes/bread")
	if err != nil || l.Slug != "bread" {
		t.Fatalf("got %+v, %v; want slug bread", l, err)
	}
}

func TestSameNameGetsNextSuffix(t *testing.T) {
	s := store.New()
	s.Save("Bread", "https://example.com/a")
	l, _ := s.Save("Bread", "https://example.com/b")
	if l.Slug != "bread-2" {
		t.Fatalf("got %q, want bread-2", l.Slug)
	}
}

func TestRefusesNonWebAddress(t *testing.T) {
	s := store.New()
	if _, err := s.Save("File", "ftp://example.com/file"); !errors.Is(err, store.ErrNotWebAddress) {
		t.Fatalf("got %v, want ErrNotWebAddress", err)
	}
	if n := len(s.List()); n != 0 {
		t.Fatalf("saved %d links, want 0", n)
	}
}
