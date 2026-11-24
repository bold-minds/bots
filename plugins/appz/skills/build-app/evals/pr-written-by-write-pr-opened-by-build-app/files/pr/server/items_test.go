package server_test

import (
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"pantry/list"
	"pantry/server"
)

func TestPostItemsStoresItem(t *testing.T) {
	list.Items = nil
	rec := httptest.NewRecorder()
	server.Items(rec, httptest.NewRequest(http.MethodPost, "/items", strings.NewReader(`{"item":"eggs"}`)))
	if rec.Code != http.StatusCreated || len(list.Items) != 1 {
		t.Fatalf("code %d, items %v; want 201 and [eggs]", rec.Code, list.Items)
	}
}
