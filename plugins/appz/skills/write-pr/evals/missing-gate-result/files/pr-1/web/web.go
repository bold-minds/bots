// Package web serves the chore list page.
package web

import (
	"errors"
	"html/template"
	"net/http"
	"strconv"
	"time"

	"chorelist/store"
)

// Chores is what the page needs from the store.
type Chores interface {
	Chores() ([]store.Chore, error)
	MarkDone(id int, at time.Time) (store.Chore, error)
}

var page = template.Must(template.New("chores").Parse(`<!doctype html>
<title>Chores</title>
<h1>Chores</h1>
{{if .Message}}<p role="alert">{{.Message}}</p>{{end}}
<ul>
{{range .Chores}}<li>{{if .DoneAt}}&#10003; {{.Name}} <time>{{.DoneAt.Format "15:04"}}</time>{{else}}{{.Name}}
<form method="post" action="/chores/{{.ID}}/done"><button>Done</button></form>{{end}}</li>
{{end}}</ul>`))

type view struct {
	Chores  []store.Chore
	Message string
}

// Handler serves GET /chores and POST /chores/{id}/done.
func Handler(s Chores) http.Handler {
	mux := http.NewServeMux()
	show := func(w http.ResponseWriter, code int, msg string) {
		cs, _ := s.Chores()
		w.WriteHeader(code)
		page.Execute(w, view{Chores: cs, Message: msg})
	}
	mux.HandleFunc("GET /chores", func(w http.ResponseWriter, r *http.Request) { show(w, http.StatusOK, "") })
	mux.HandleFunc("POST /chores/{id}/done", func(w http.ResponseWriter, r *http.Request) {
		id, _ := strconv.Atoi(r.PathValue("id"))
		_, err := s.MarkDone(id, time.Now())
		switch {
		case errors.Is(err, store.ErrNoChore):
			show(w, http.StatusNotFound, err.Error())
		case err != nil:
			show(w, http.StatusServiceUnavailable, store.ErrCantSave.Error())
		default:
			http.Redirect(w, r, "/chores", http.StatusSeeOther)
		}
	})
	return mux
}
