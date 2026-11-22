// Package web serves the shelf page.
package web

import (
	"html/template"
	"net/http"

	"example.com/shelf/store"
)

var page = template.Must(template.New("shelf").Parse(`<!doctype html>
<title>Shelf</title>
<h1>Shelf</h1>
<ul>{{range .Titles}}<li>{{.}}</li>{{end}}</ul>
`))

type view struct {
	Titles []string
}

// Handler serves the shelf page at /.
func Handler(s *store.Shelf) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "text/html; charset=utf-8")
		_ = page.Execute(w, view{Titles: s.Titles()})
	})
}
