// Package web serves the shelf's pages.
package web

import (
	"embed"
	"html/template"
	"net/http"

	"linkshelf/store"
)

//go:embed templates/links.html
var files embed.FS

var page = template.Must(template.ParseFS(files, "templates/links.html"))

type view struct {
	Links   []store.Link
	Message string
}

// Handler serves GET /links, POST /links and GET /l/{slug}.
func Handler(s *store.Store) http.Handler {
	mux := http.NewServeMux()
	mux.HandleFunc("GET /links", func(w http.ResponseWriter, r *http.Request) {
		page.Execute(w, view{Links: s.List()})
	})
	mux.HandleFunc("POST /links", func(w http.ResponseWriter, r *http.Request) {
		if _, err := s.Save(r.FormValue("name"), r.FormValue("url")); err != nil {
			w.WriteHeader(http.StatusBadRequest)
			page.Execute(w, view{Links: s.List(), Message: err.Error()})
			return
		}
		http.Redirect(w, r, "/links", http.StatusSeeOther)
	})
	mux.HandleFunc("GET /l/{slug}", func(w http.ResponseWriter, r *http.Request) {
		l, ok := s.Find(r.PathValue("slug"))
		if !ok {
			http.NotFound(w, r)
			return
		}
		http.Redirect(w, r, l.URL, http.StatusFound)
	})
	return mux
}
