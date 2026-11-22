package web_test

import (
	"io"
	"net/http/httptest"
	"strings"
	"testing"

	"example.com/shelf/store"
	"example.com/shelf/web"
)

func TestPageListsTitles(t *testing.T) {
	s := store.New()
	s.Add("Dune")
	srv := httptest.NewServer(web.Handler(s))
	defer srv.Close()
	res, err := srv.Client().Get(srv.URL + "/")
	if err != nil {
		t.Fatal(err)
	}
	body, _ := io.ReadAll(res.Body)
	if !strings.Contains(string(body), "<li>Dune</li>") {
		t.Fatalf("page does not list Dune:\n%s", body)
	}
}
