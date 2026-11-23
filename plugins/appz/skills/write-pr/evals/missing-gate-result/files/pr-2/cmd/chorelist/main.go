package main

import (
	"log"
	"net/http"
	"os"

	"chorelist/store"
	"chorelist/web"
)

func main() {
	path := os.Getenv("CHORES_FILE")
	if path == "" {
		path = "chores.db"
	}
	s, err := store.Open(path)
	if err != nil {
		log.Fatal(err)
	}
	defer s.Close()
	log.Fatal(http.ListenAndServe(":8090", web.Handler(s)))
}
