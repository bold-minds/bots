package main

import (
	"log"
	"net/http"

	"linkshelf/store"
	"linkshelf/web"
)

func main() {
	log.Fatal(http.ListenAndServe(":8080", web.Handler(store.New())))
}
