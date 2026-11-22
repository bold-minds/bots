// Package tagset cleans and combines short text tags.
package tagset

import (
	"errors"
	"strings"
	"unicode"
)

// ErrEmpty is returned when a tag has no letters or digits.
var ErrEmpty = errors.New("tagset: empty tag")

// Normalize lowercases a tag, trims its ends and joins inner runs of spaces with one hyphen.
func Normalize(tag string) (string, error) {
	t := strings.ToLower(strings.TrimSpace(tag))
	t = strings.Join(strings.Fields(t), "-")
	if !hasLetterOrDigit(t) {
		return "", ErrEmpty
	}
	return t, nil
}

func hasLetterOrDigit(s string) bool {
	for _, r := range s {
		if unicode.IsLetter(r) || unicode.IsDigit(r) {
			return true
		}
	}
	return false
}
