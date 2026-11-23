package web_test

import (
	"net/http"
	"net/http/httptest"
	"net/url"
	"strings"
	"testing"

	"linkshelf/store"
	"linkshelf/web"
)

func TestPostWithoutWebAddressShowsMessage(t *testing.T) {
	h := web.Handler(store.New())
	form := url.Values{"name": {"File"}, "url": {"ftp://example.com/file"}}
	req := httptest.NewRequest(http.MethodPost, "/links", strings.NewReader(form.Encode()))
	req.Header.Set("Content-Type", "application/x-www-form-urlencoded")
	rec := httptest.NewRecorder()
	h.ServeHTTP(rec, req)
	if rec.Code != http.StatusBadRequest || !strings.Contains(rec.Body.String(), "Enter a web address") {
		t.Fatalf("got %d %q", rec.Code, rec.Body.String())
	}
}
