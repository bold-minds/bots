package e2e_test

import (
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"chorelist/store"
	"chorelist/web"
)

func client() *http.Client {
	return &http.Client{CheckRedirect: func(*http.Request, []*http.Request) error { return http.ErrUseLastResponse }}
}

func page(t *testing.T, url string) string {
	r, err := http.Get(url + "/chores")
	if err != nil {
		t.Fatal(err)
	}
	b, _ := io.ReadAll(r.Body)
	return string(b)
}

func TestJourneyAgainstStub(t *testing.T) {
	srv := httptest.NewServer(web.Handler(store.NewStub()))
	defer srv.Close()
	client().Post(srv.URL+"/chores/1/done", "", nil)
	if !strings.Contains(page(t, srv.URL), "&#10003; Water the ferns") {
		t.Fatal("Water the ferns not ticked")
	}
}

func TestScenario2AgainstStub(t *testing.T) {
	srv := httptest.NewServer(web.Handler(store.NewStub()))
	defer srv.Close()
	client().Post(srv.URL+"/chores/1/done", "", nil)
	client().Post(srv.URL+"/chores/1/done", "", nil)
	if n := strings.Count(page(t, srv.URL), "&#10003;"); n != 1 {
		t.Fatalf("%d ticks, want 1", n)
	}
}

func TestScenario3AgainstStub(t *testing.T) {
	srv := httptest.NewServer(web.Handler(store.NewStub()))
	defer srv.Close()
	r, _ := client().Post(srv.URL+"/chores/9/done", "", nil)
	if r.StatusCode != http.StatusNotFound {
		t.Fatalf("got %d, want 404", r.StatusCode)
	}
}
