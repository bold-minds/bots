// Command notes serves the pinboard on :8080, keeping notes in notes.json.
package main

import (
	"log"
	"net/http"

	"example.com/pinboard/store"
	"example.com/pinboard/web"
)

func main() {
	s, err := store.Open("notes.json")
	if err != nil {
		log.Fatal(err)
	}
	log.Fatal(http.ListenAndServe(":8080", web.Handler(s)))
}
