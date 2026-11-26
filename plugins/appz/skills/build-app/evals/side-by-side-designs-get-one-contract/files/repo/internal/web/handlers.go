// Package web serves sprout's pages.
package web

import (
	"errors"
	"html/template"
	"net/http"
	"strconv"

	"example.com/sprout/internal/plants"
)

var pages = template.Must(template.ParseGlob("web/templates/*.html"))

// ListPlants serves GET /plants.
func ListPlants(s *plants.Store) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ps, err := s.List(r.Context())
		if err != nil {
			http.Error(w, "Something went wrong", http.StatusInternalServerError)
			return
		}
		pages.ExecuteTemplate(w, "plants.html", ps)
	}
}

// ShowPlant serves GET /plants/{id}.
func ShowPlant(s *plants.Store) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		id, _ := strconv.ParseInt(r.PathValue("id"), 10, 64)
		p, err := s.Get(r.Context(), id)
		if errors.Is(err, plants.ErrNotFound) {
			http.Error(w, "That plant is gone", http.StatusNotFound)
			return
		}
		if err != nil {
			http.Error(w, "Something went wrong", http.StatusInternalServerError)
			return
		}
		pages.ExecuteTemplate(w, "plant.html", p)
	}
}
