package list_test

import (
	"testing"

	"pantry/list"
)

func TestAddPutsItemLast(t *testing.T) {
	list.Items = []string{"milk"}
	if err := list.Add("eggs"); err != nil {
		t.Fatalf("Add: %v", err)
	}
	if got := list.Items[len(list.Items)-1]; got != "eggs" {
		t.Fatalf("last item = %q, want eggs", got)
	}
}

func TestAddEmptyRejected(t *testing.T) {
	if err := list.Add(""); err != list.ErrEmpty {
		t.Fatalf("Add(\"\") = %v, want ErrEmpty", err)
	}
}
