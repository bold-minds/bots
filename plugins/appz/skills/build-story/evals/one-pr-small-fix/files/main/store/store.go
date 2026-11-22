// Package store holds the books on the shelf, in memory.
package store

// Shelf is an ordered list of book titles.
type Shelf struct {
	titles []string
}

// New returns an empty shelf.
func New() *Shelf { return &Shelf{} }

// Add puts a title on the end of the shelf.
func (s *Shelf) Add(title string) { s.titles = append(s.titles, title) }

// Titles returns the titles in the order they were added.
func (s *Shelf) Titles() []string {
	out := make([]string, len(s.titles))
	copy(out, s.titles)
	return out
}
