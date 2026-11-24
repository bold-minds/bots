// Command shelf serves the shelf page.
//
// Flags: -addr, where to listen (default :8080); -books, a file of titles,
// one per line, put on the shelf at start (default none: an empty shelf).
package main

import (
	"bufio"
	"flag"
	"log"
	"net/http"
	"os"
	"strings"

	"example.com/shelf/store"
	"example.com/shelf/web"
)

func main() {
	addr := flag.String("addr", ":8080", "address to listen on")
	books := flag.String("books", "", "file of titles, one per line")
	flag.Parse()
	s := store.New()
	if *books != "" {
		f, err := os.Open(*books)
		if err != nil {
			log.Fatal(err)
		}
		sc := bufio.NewScanner(f)
		for sc.Scan() {
			if t := strings.TrimSpace(sc.Text()); t != "" {
				s.Add(t)
			}
		}
		f.Close()
		if err := sc.Err(); err != nil {
			log.Fatal(err)
		}
	}
	log.Fatal(http.ListenAndServe(*addr, web.Handler(s)))
}
