// Command shelf serves the shelf page on :8080.
package main

import (
	"log"
	"net/http"

	"example.com/shelf/store"
	"example.com/shelf/web"
)

func main() {
	s := store.New()
	log.Fatal(http.ListenAndServe(":8080", web.Handler(s)))
}
