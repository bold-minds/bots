// Package store keeps the shelf's links in memory.
package store

import (
	"errors"
	"net/url"
	"sync"

	"example.org/tinyslug"
)

// ErrNotWebAddress is returned when a link's address is not http or https.
var ErrNotWebAddress = errors.New("Enter a web address")

// Link is one saved link.
type Link struct {
	Name string
	Slug string
	URL  string
}

// Store holds links in the order they were saved.
type Store struct {
	mu    sync.Mutex
	links []Link
	taken map[string]bool
}

// New returns an empty store.
func New() *Store {
	return &Store{taken: map[string]bool{}}
}

// Save keeps a link under name and gives it a slug made from the name.
func (s *Store) Save(name, address string) (Link, error) {
	u, err := url.Parse(address)
	if err != nil || (u.Scheme != "http" && u.Scheme != "https") || u.Host == "" {
		return Link{}, ErrNotWebAddress
	}
	s.mu.Lock()
	defer s.mu.Unlock()
	slug := tinyslug.Make(name, func(c string) bool { return s.taken[c] })
	s.taken[slug] = true
	l := Link{Name: name, Slug: slug, URL: address}
	s.links = append(s.links, l)
	return l, nil
}

// List returns every link, oldest first.
func (s *Store) List() []Link {
	s.mu.Lock()
	defer s.mu.Unlock()
	return append([]Link(nil), s.links...)
}

// Find returns the link with the given slug.
func (s *Store) Find(slug string) (Link, bool) {
	s.mu.Lock()
	defer s.mu.Unlock()
	for _, l := range s.links {
		if l.Slug == slug {
			return l, true
		}
	}
	return Link{}, false
}
