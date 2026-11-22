package store_test

import (
	"reflect"
	"testing"

	"example.com/shelf/store"
)

func TestTitlesInAddOrder(t *testing.T) {
	s := store.New()
	s.Add("Dune")
	s.Add("Emma")
	if got, want := s.Titles(), []string{"Dune", "Emma"}; !reflect.DeepEqual(got, want) {
		t.Fatalf("Titles() = %v, want %v", got, want)
	}
}
