# Show the book count: technical design

Status: Approved

## Packages and functions
- `store`: add `func (s *Shelf) Count() int`, the number of titles on the shelf. Scenarios 1, 2, 3, 4.
- `web`: `Handler` renders a line `<p class="count">N books</p>` above the list, using `Count`, with "book" when N is 1 and "books" otherwise. Scenarios 1, 2, 3, 4.
- `e2e` (new, package `e2e_test`): a test helper that writes the titles to a books file in a temp dir, starts the app with `task serve` on a free port, waits for it to answer, and stops it when the test ends. Scenarios 1, 2, 3, 4.
- `Taskfile.yml`: new task `serve`, running `go run ./cmd/shelf -addr={{.ADDR}} -books={{.BOOKS}}` (ADDR defaults to `:8080`, BOOKS to no file). `check` already runs `go test -count=1 ./...`, which holds the E2E and perf tests. Scenarios 1, 2, 3, 4.

## Schema, routes, commands and events
- No schema, route or event added or changed; the page at `/` gains the count line. Scenarios 1, 2, 3, 4.
- Command `task serve ADDR=<host:port> BOOKS=<file>` (new): starts the shelf server on ADDR with the titles in BOOKS, one per line. Scenarios 1, 2, 3, 4.

## Libraries
- `github.com/chromedp/chromedp`: picked v0.24.0, newest v0.24.0; drives a real Chrome for the E2E tests, with no Node toolchain. It needs Go 1.25 or later; `go.mod` and CI already use 1.26. Scenarios 1, 2, 3.

## PRs
- PR 1, about 170 changed lines, tests included: `store.Count`, the count line in `web`, the `serve` task, the `e2e` helper, and their tests. Tests: unit, E2E and perf. Front end and back end in one PR; the only infra change is the `serve` task. Builds on nothing.

## Tests
Unit:
- `store` (package `store_test`): `TestCount`: a new shelf counts 0; after adding Dune, Emma and Ulysses it counts 3. Scenarios 1, 2.
- `web` (package `web_test`, through `web.Handler` and `httptest`): `TestPageShowsCount`, a table of shelves with 0, 1 and 3 books, checking the page holds `<p class="count">0 books</p>`, `<p class="count">1 book</p>` and `<p class="count">3 books</p>`. Scenarios 1, 2, 3.

Integration: none; `store` and `web` talk to no database, API or file.

E2E (package `e2e_test`, in Chrome through chromedp, against the app started by `task serve`; needs Chrome and `task` on the PATH and a free port; run with `go test -count=1 ./e2e/...`):
- `TestJourney`: with Dune on the shelf, open the page: the count line reads "1 book" and stands above the list, before the list's first title. Scenario 3.
- `TestEmptyShelf`: with an empty books file, the count line reads "0 books". Scenario 1.
- `TestThreeBooks`: with Dune, Emma and Ulysses, the count line reads "3 books". Scenario 2.
- `TestOneBook`: with only Dune, the count line reads "1 book". Scenario 3.

Perf (package `e2e_test`, over HTTP against the app started by `task serve`):
- `TestPageSpeed`: with 1000 titles in the books file, `GET /` returns a page holding `<p class="count">1000 books</p>` within 100 ms, the number scenario 4 gives. Scenario 4.

Chaos: none; the shelf is in memory, and the story's parts depend on nothing that can fail.
