package tagset_test

import (
	"errors"
	"testing"

	"example.com/tagset/tagset"
)

func TestNormalize(t *testing.T) {
	got, err := tagset.Normalize("  Web   Dev ")
	if err != nil || got != "web-dev" {
		t.Fatalf("Normalize = %q, %v; want web-dev, nil", got, err)
	}
}

func TestNormalizeEmpty(t *testing.T) {
	if _, err := tagset.Normalize(" -- "); !errors.Is(err, tagset.ErrEmpty) {
		t.Fatalf("err = %v; want ErrEmpty", err)
	}
}
