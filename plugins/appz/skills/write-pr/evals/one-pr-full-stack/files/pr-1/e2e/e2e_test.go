package e2e_test

import (
	"io"
	"net/http"
	"net/http/httptest"
	"net/url"
	"strings"
	"testing"

	"linkshelf/store"
	"linkshelf/web"
)

func start(t *testing.T) (*httptest.Server, *http.Client) {
	srv := httptest.NewServer(web.Handler(store.New()))
	t.Cleanup(srv.Close)
	c := &http.Client{CheckRedirect: func(*http.Request, []*http.Request) error { return http.ErrUseLastResponse }}
	return srv, c
}

func save(t *testing.T, srv *httptest.Server, c *http.Client, name, addr string) *http.Response {
	r, err := c.PostForm(srv.URL+"/links", url.Values{"name": {name}, "url": {addr}})
	if err != nil {
		t.Fatal(err)
	}
	return r
}

func shelf(t *testing.T, srv *httptest.Server) string {
	r, err := http.Get(srv.URL + "/links")
	if err != nil {
		t.Fatal(err)
	}
	b, _ := io.ReadAll(r.Body)
	return string(b)
}

func TestJourneySaveAndOpen(t *testing.T) {
	srv, c := start(t)
	save(t, srv, c, "Bread", "https://example.com/recipes/bread")
	if !strings.Contains(shelf(t, srv), "/l/bread") {
		t.Fatal("shelf does not list /l/bread")
	}
	r, _ := c.Get(srv.URL + "/l/bread")
	if r.StatusCode != http.StatusFound || r.Header.Get("Location") != "https://example.com/recipes/bread" {
		t.Fatalf("got %d to %q", r.StatusCode, r.Header.Get("Location"))
	}
}

func TestSaveListsShortAddress(t *testing.T) {
	srv, c := start(t)
	if r := save(t, srv, c, "Soup", "https://example.com/soup"); r.StatusCode != http.StatusSeeOther {
		t.Fatalf("got %d, want 303", r.StatusCode)
	}
	if !strings.Contains(shelf(t, srv), "Soup") {
		t.Fatal("shelf does not list Soup")
	}
}

func TestRepeatNameGetsSuffix(t *testing.T) {
	srv, c := start(t)
	save(t, srv, c, "Bread", "https://example.com/a")
	save(t, srv, c, "Bread", "https://example.com/b")
	if !strings.Contains(shelf(t, srv), "/l/bread-2") {
		t.Fatal("shelf does not list /l/bread-2")
	}
}

func TestNonWebAddressRefused(t *testing.T) {
	srv, c := start(t)
	if r := save(t, srv, c, "File", "ftp://example.com/file"); r.StatusCode != http.StatusBadRequest {
		t.Fatalf("got %d, want 400", r.StatusCode)
	}
	if strings.Contains(shelf(t, srv), "File") {
		t.Fatal("refused link was saved")
	}
}
