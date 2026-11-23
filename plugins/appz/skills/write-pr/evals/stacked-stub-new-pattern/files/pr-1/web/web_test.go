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

type failing struct{ *store.Stub }

func (failing) MarkDone(int, time.Time) (store.Chore, error) { return store.Chore{}, store.ErrCantSave }

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
	h := web.Handler(store.NewStub())
	if rec := post(h, "/chores/1/done"); rec.Code != http.StatusSeeOther {
		t.Fatalf("got %d", rec.Code)
	}
	if !strings.Contains(get(h), "<time>") {
		t.Fatal("no done time shown")
	}
}

func TestTickTwiceKeepsFirstTime(t *testing.T) {
	s := store.NewStub()
	h := web.Handler(s)
	post(h, "/chores/1/done")
	first, _ := s.Chores()
	post(h, "/chores/1/done")
	again, _ := s.Chores()
	if !first[0].DoneAt.Equal(*again[0].DoneAt) {
		t.Fatal("second tick changed the time")
	}
}

func TestUnknownChoreShowsNoSuchChore(t *testing.T) {
	rec := post(web.Handler(store.NewStub()), "/chores/9/done")
	if rec.Code != http.StatusNotFound || !strings.Contains(rec.Body.String(), "No such chore") {
		t.Fatalf("got %d %q", rec.Code, rec.Body.String())
	}
}

func TestCantSaveShowsTryAgain(t *testing.T) {
	rec := post(web.Handler(failing{store.NewStub()}), "/chores/1/done")
	if rec.Code != http.StatusServiceUnavailable || !strings.Contains(rec.Body.String(), "try again") {
		t.Fatalf("got %d %q", rec.Code, rec.Body.String())
	}
}
