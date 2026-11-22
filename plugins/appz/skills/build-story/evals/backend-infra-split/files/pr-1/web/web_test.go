package web_test

import (
	"io"
	"net/http/httptest"
	"net/url"
	"strings"
	"testing"

	"example.com/pinboard/store"
	"example.com/pinboard/web"
)

func pin(t *testing.T, srv *httptest.Server, text string) string {
	t.Helper()
	res, err := srv.Client().PostForm(srv.URL+"/pin", url.Values{"text": {text}})
	if err != nil {
		t.Fatal(err)
	}
	defer res.Body.Close()
	body, _ := io.ReadAll(res.Body)
	return string(body)
}

func newServer(t *testing.T) *httptest.Server {
	t.Helper()
	s, err := store.Open(t.TempDir() + "/notes.json")
	if err != nil {
		t.Fatal(err)
	}
	srv := httptest.NewServer(web.Handler(s))
	t.Cleanup(srv.Close)
	return srv
}

func TestPinShowsNote(t *testing.T) {
	srv := newServer(t)
	if body := pin(t, srv, "buy milk"); !strings.Contains(body, "<li>1. buy milk</li>") {
		t.Fatalf("board does not show the note:\n%s", body)
	}
}

func TestPinBlankSaysEmpty(t *testing.T) {
	srv := newServer(t)
	body := pin(t, srv, "   ")
	if !strings.Contains(body, "Note is empty") || strings.Contains(body, "<li>") {
		t.Fatalf("blank note not refused:\n%s", body)
	}
}
