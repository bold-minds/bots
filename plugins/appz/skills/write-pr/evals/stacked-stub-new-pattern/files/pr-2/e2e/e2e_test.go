package e2e_test

import (
	"io"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"chorelist/store"
	"chorelist/web"
)

func client() *http.Client {
	return &http.Client{CheckRedirect: func(*http.Request, []*http.Request) error { return http.ErrUseLastResponse }}
}

func serve(t *testing.T, path string) (*httptest.Server, *store.Store) {
	s, err := store.Open(path)
	if err != nil {
		t.Fatal(err)
	}
	srv := httptest.NewServer(web.Handler(s))
	t.Cleanup(func() { srv.Close(); s.Close() })
	return srv, s
}

func page(t *testing.T, url string) string {
	r, err := http.Get(url + "/chores")
	if err != nil {
		t.Fatal(err)
	}
	b, _ := io.ReadAll(r.Body)
	return string(b)
}

func file(t *testing.T) string { return filepath.Join(t.TempDir(), "chores.db") }

func TestJourney(t *testing.T) {
	srv, _ := serve(t, file(t))
	client().Post(srv.URL+"/chores/1/done", "", nil)
	if !strings.Contains(page(t, srv.URL), "&#10003; Water the ferns") {
		t.Fatal("not ticked")
	}
}

func TestScenario1(t *testing.T) {
	srv, _ := serve(t, file(t))
	r, _ := client().Post(srv.URL+"/chores/2/done", "", nil)
	if r.StatusCode != http.StatusSeeOther || !strings.Contains(page(t, srv.URL), "<time>") {
		t.Fatalf("got %d", r.StatusCode)
	}
}

func TestScenario2(t *testing.T) {
	srv, _ := serve(t, file(t))
	client().Post(srv.URL+"/chores/1/done", "", nil)
	client().Post(srv.URL+"/chores/1/done", "", nil)
	if n := strings.Count(page(t, srv.URL), "&#10003;"); n != 1 {
		t.Fatalf("%d ticks", n)
	}
}

func TestScenario3(t *testing.T) {
	srv, _ := serve(t, file(t))
	r, _ := client().Post(srv.URL+"/chores/9/done", "", nil)
	if r.StatusCode != http.StatusNotFound {
		t.Fatalf("got %d", r.StatusCode)
	}
}

func TestScenario4Restart(t *testing.T) {
	path := file(t)
	srv, s := serve(t, path)
	client().Post(srv.URL+"/chores/1/done", "", nil)
	srv.Close()
	s.Close()
	srv, _ = serve(t, path)
	if !strings.Contains(page(t, srv.URL), "&#10003; Water the ferns") {
		t.Fatal("done lost on restart")
	}
}

func TestReadOnlyFileGivesTryAgain(t *testing.T) {
	path := file(t)
	srv, _ := serve(t, path)
	os.Chmod(path, 0o444)
	r, _ := client().Post(srv.URL+"/chores/1/done", "", nil)
	b, _ := io.ReadAll(r.Body)
	if r.StatusCode != http.StatusServiceUnavailable || !strings.Contains(string(b), "Couldn't save that, try again") {
		t.Fatalf("got %d %q", r.StatusCode, b)
	}
	if strings.Contains(page(t, srv.URL), "&#10003;") {
		t.Fatal("chore marked done")
	}
}
