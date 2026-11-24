package server

import (
	"encoding/json"
	"net/http"

	"pantry/list"
)

// Items handles POST /items.
func Items(w http.ResponseWriter, r *http.Request) {
	var in struct{ Item string `json:"item"` }
	_ = json.NewDecoder(r.Body).Decode(&in)
	if err := list.Add(in.Item); err != nil {
		w.WriteHeader(http.StatusBadRequest)
		_ = json.NewEncoder(w).Encode(map[string]string{"error": err.Error()})
		return
	}
	w.WriteHeader(http.StatusCreated)
	_ = json.NewEncoder(w).Encode(list.Items)
}
