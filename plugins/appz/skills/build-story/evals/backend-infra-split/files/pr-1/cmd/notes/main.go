// Command notes serves the pinboard.
//
// Flags: -addr, where to listen (default :8080); -file, the notes file
// (default notes.json).
package main

import (
	"flag"
	"log"
	"net/http"

	"example.com/pinboard/store"
	"example.com/pinboard/web"
)

func main() {
	addr := flag.String("addr", ":8080", "address to listen on")
	file := flag.String("file", "notes.json", "the notes file")
	flag.Parse()
	s, err := store.Open(*file)
	if err != nil {
		log.Fatal(err)
	}
	log.Fatal(http.ListenAndServe(*addr, web.Handler(s)))
}
