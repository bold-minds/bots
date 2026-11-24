// Package web serves the board page.
package web

import (
	"errors"
	"html/template"
	"net/http"

	"example.com/pinboard/store"
)

var page = template.Must(template.New("board").Parse(`<!doctype html>
<title>Pinboard</title>
<h1>Pinboard</h1>
{{if .Msg}}<p class="msg">{{.Msg}}</p>{{end}}
<form method="post" action="/pin"><input name="text"><button>Pin</button></form>
<ol>{{range .Notes}}<li>{{.ID}}. {{.Text}}</li>{{end}}</ol>
`))

type view struct {
	Msg   string
	Notes []store.Note
}

// Handler serves GET / and POST /pin.
func Handler(s *store.Store) http.Handler {
	mux := http.NewServeMux()
	render := func(w http.ResponseWriter, msg string) {
		notes, err := s.List()
		if err != nil {
			http.Error(w, "could not read notes", http.StatusInternalServerError)
			return
		}
		w.Header().Set("Content-Type", "text/html; charset=utf-8")
		_ = page.Execute(w, view{Msg: msg, Notes: notes})
	}
	mux.HandleFunc("GET /", func(w http.ResponseWriter, r *http.Request) { render(w, "") })
	mux.HandleFunc("POST /pin", func(w http.ResponseWriter, r *http.Request) {
		r.Body = http.MaxBytesReader(w, r.Body, 1<<16)
		_, err := s.Add(r.FormValue("text"))
		if errors.Is(err, store.ErrEmpty) {
			render(w, "Note is empty")
			return
		}
		if err != nil {
			http.Error(w, "could not save note", http.StatusInternalServerError)
			return
		}
		http.Redirect(w, r, "/", http.StatusSeeOther)
	})
	return mux
}
