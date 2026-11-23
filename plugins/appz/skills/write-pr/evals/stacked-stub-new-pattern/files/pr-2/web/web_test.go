package web_test

import (
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"chorelist/store"
	"chorelist/web"
)

// fake is the page's view of the store, kept in the test now that the stub is gone.
type fake struct {
	chores []store.Chore
	fail   bool
}

func newFake() *fake {
	return &fake{chores: []store.Chore{{ID: 1, Name: "Water the ferns"}, {ID: 2, Name: "Take out the bins"}}}
}

func (f *fake) Chores() ([]store.Chore, error) { return append([]store.Chore(nil), f.chores...), nil }

func (f *fake) MarkDone(id int, at time.Time) (store.Chore, error) {
	if f.fail {
		return store.Chore{}, store.ErrCantSave
	}
	for i := range f.chores {
		if f.chores[i].ID == id {
			if f.chores[i].DoneAt == nil {
				f.chores[i].DoneAt = &at
			}
			return f.chores[i], nil
		}
	}
	return store.Chore{}, store.ErrNoChore
}

func post(h http.Handler, path string) *httptest.ResponseRecorder {
	rec := httptest.NewRecorder()
	h.ServeHTTP(rec, httptest.NewRequest(http.MethodPost, path, nil))
	return rec
}

func get(h http.Handler) string {
	rec := httptest.NewRecorder()
	h.ServeHTTP(rec, httptest.NewRequest(http.MethodGet, "/chores", nil))
	return rec.Body.String()
}

func TestTickShowsDoneTime(t *testing.T) {
	h := web.Handler(newFake())
	if rec := post(h, "/chores/1/done"); rec.Code != http.StatusSeeOther {
		t.Fatalf("got %d", rec.Code)
	}
	if !strings.Contains(get(h), "<time>") {
		t.Fatal("no done time shown")
	}
}

func TestTickTwiceKeepsFirstTime(t *testing.T) {
	f := newFake()
	h := web.Handler(f)
	post(h, "/chores/1/done")
	first, _ := f.Chores()
	post(h, "/chores/1/done")
	again, _ := f.Chores()
	if !first[0].DoneAt.Equal(*again[0].DoneAt) {
		t.Fatal("second tick changed the time")
	}
}

func TestUnknownChoreShowsNoSuchChore(t *testing.T) {
	rec := post(web.Handler(newFake()), "/chores/9/done")
	if rec.Code != http.StatusNotFound || !strings.Contains(rec.Body.String(), "No such chore") {
		t.Fatalf("got %d %q", rec.Code, rec.Body.String())
	}
}

func TestCantSaveShowsTryAgain(t *testing.T) {
	rec := post(web.Handler(&fake{fail: true}), "/chores/1/done")
	if rec.Code != http.StatusServiceUnavailable || !strings.Contains(rec.Body.String(), "try again") {
		t.Fatalf("got %d %q", rec.Code, rec.Body.String())
	}
}
