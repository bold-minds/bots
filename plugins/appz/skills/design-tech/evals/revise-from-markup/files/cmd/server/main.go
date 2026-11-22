package main

import (
	"database/sql"
	"log"
	"net/http"

	_ "modernc.org/sqlite"

	"example.com/sprout/internal/plants"
	"example.com/sprout/internal/web"
)

func main() {
	db, err := sql.Open("sqlite", "sprout.db")
	if err != nil {
		log.Fatal(err)
	}
	store := plants.NewStore(db)
	mux := http.NewServeMux()
	mux.HandleFunc("GET /plants", web.ListPlants(store))
	mux.HandleFunc("GET /plants/{id}", web.ShowPlant(store))
	log.Fatal(http.ListenAndServe(":8080", mux))
}
