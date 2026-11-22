// Package slugkit makes URL slugs.
package slugkit

import "errors"

// ErrEmpty is returned by Make when nothing is left after cleaning the title.
var ErrEmpty = errors.New("slugkit: title leaves no letters or digits")

// Make turns title into a slug: lower case, every run of characters that are
// not letters or digits becomes one hyphen, leading and trailing hyphens are
// removed. If maxLen > 0 the slug is cut at the last hyphen that keeps it within
// maxLen; a single word longer than maxLen is cut at maxLen. maxLen <= 0 means
// no limit. Returns ErrEmpty when the result is empty.
func Make(title string, maxLen int) (string, error)

// Unique returns slug if taken(slug) is false. Otherwise it tries slug-2, slug-3,
// and so on, and returns the first one taken reports as free.
func Unique(slug string, taken func(string) bool) string
