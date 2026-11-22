# Show the book count: technical design

Status: Approved

## Packages and functions
- `store`: add `func (s *Shelf) Count() int`, the number of titles on the shelf. Scenarios 1, 2, 3.
- `web`: `Handler` renders a line `<p class="count">N books</p>` above the list, using `Count`, with "book" when N is 1 and "books" otherwise. Scenarios 1, 2, 3.

## Schema, routes, commands and events
- No schema, route, command or event added or changed; the page at `/` gains the count line. Scenarios 1, 2, 3.

## Libraries
- None added; Go standard library only.

## PRs
- PR 1, about 60 changed lines, tests included: `store.Count`, the count line in `web`, and their tests. Front end and back end in one PR; no infra change. Builds on nothing.

## Tests
- `store` (package `store_test`): `TestCount`: a new shelf counts 0; after adding Dune, Emma and Ulysses it counts 3. Scenarios 1, 2.
- `web` (package `web_test`, through `web.Handler` and `httptest`): `TestPageShowsCount`, a table of shelves with 0, 1 and 3 books, checking the page holds `<p class="count">0 books</p>`, `<p class="count">1 book</p>` and `<p class="count">3 books</p>`. Scenarios 1, 2, 3.
