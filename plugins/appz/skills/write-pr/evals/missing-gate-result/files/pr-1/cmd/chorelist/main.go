package main

import (
	"log"
	"net/http"

	"chorelist/store"
	"chorelist/web"
)

func main() {
	log.Fatal(http.ListenAndServe(":8090", web.Handler(store.NewStub())))
}
