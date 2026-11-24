# Pin a note: technical design

Status: Approved

## Packages and functions
- `store`: the notes, kept in one JSON file. Scenarios 1, 2, 3, 4.
  - `type Note struct { ID int; Text string }`
  - `var ErrEmpty = errors.New("note is empty")`
  - `func Open(path string) (*Store, error)`: opens the file at path, or starts empty when it does not exist.
  - `func (s *Store) Add(text string) (Note, error)`: trims the text; blank gives `ErrEmpty` and adds nothing; otherwise gives the next ID (1, 2, 3, ...) and writes the file before returning; when the file cannot be written, gives that error and keeps nothing.
  - `func (s *Store) List() ([]Note, error)`: the notes in the order they were added.
- `web`: `func Handler(s *store.Store) http.Handler`: GET `/` renders the board; POST `/pin` adds the note and redirects to `/`, renders the board with "Note is empty" on `ErrEmpty`, or answers "could not save note" on any other error. Scenarios 1, 2, 3, 4.
- `cmd/notes`: opens the file named by `-file` (default `notes.json`) and serves `web.Handler` on `-addr` (default `:8080`). Scenarios 2, 4.
- `integration` (new, package `integration_test`): tests only; `web.Handler` with the real `store` on a temp dir. Scenarios 2, 4.
- `e2e` (new, package `e2e_test`): a test helper that starts the app with `task serve` on a free port with FILE in a temp dir, waits for it to answer, can stop and start it again on the same file, and stops it when the test ends. Scenarios 1, 2, 3, 4.
- `Taskfile.yml` (new): task `check`, the gate (gofmt, go vet, `go test -count=1 ./...` holding every test layer, build); task `serve`, running `go run ./cmd/notes -addr={{.ADDR}} -file={{.FILE}}` (ADDR defaults to `:8080`, FILE to `notes.json`). Scenarios 1, 2, 3, 4.
- `.github/workflows/ci.yml` (new): runs `task check` on every push and pull request. Scenarios 1, 2, 3, 4.

## Schema, routes, commands and events
- File `notes.json`: a JSON array of `{"id": 1, "text": "buy milk"}`. Scenarios 2, 4.
- Routes: GET `/`, POST `/pin` with form field `text`. Scenarios 1, 2, 3, 4.
- Command `task serve ADDR=<host:port> FILE=<path>` (new): starts the board on ADDR, keeping notes in FILE. Scenarios 1, 2, 3, 4.
- Gate: `task check` (gofmt, go vet, go test, build), run by CI on every push and pull request.

## Libraries
- `github.com/chromedp/chromedp`: picked v0.24.0, newest v0.24.0; drives a real Chrome for the E2E and chaos tests, with no Node toolchain. It needs Go 1.25 or later; `go.mod` already uses 1.26, and CI sets up Go 1.26. Scenarios 1, 2, 3, 4.

## PRs
Estimate, tests included: front end about 140 lines, back end about 240 (the store and its unit, integration, E2E and chaos tests), infra about 40. Over the 400-line limit together, so split in two.
- PR 1, front end (about 140 lines): `web`, `cmd/notes`, and a stubbed `store` in `store/stub.go`, built against the stub contract below. Tests: the `web` unit tests, against the stub. Builds on main.
- PR 2, back end and infra (about 280 lines): the real `store` (file-backed), replacing `store/stub.go`; `Taskfile.yml` with the `check` and `serve` tasks and `.github/workflows/ci.yml` running `check`. Tests: the `store` unit tests, the integration test, and the E2E and chaos tests through the real app. Builds on PR 1.

Stub contract (PR 1's `store/stub.go`; PR 2's real `store` keeps it exactly):
- `Open(path string) (*Store, error)`: the stub ignores path and returns an empty in-memory store, nil.
- `Add(text string) (Note, error)`: blank after trimming gives `Note{}`, `ErrEmpty`; otherwise `Note{ID: next, Text: trimmed}`, nil, IDs from 1.
- `List() ([]Note, error)`: the notes in add order, nil.

## Tests
Unit:
- `web` (PR 1; package `web_test`, through `web.Handler` and `httptest`, against the stub): `TestPinShowsNote` (scenario 1), `TestPinBlankSaysEmpty` (scenario 3).
- `store` (PR 2; package `store_test`, through `Open`, `Add` and `List` on a temp dir): `TestAddGivesNextID` (scenario 1), `TestNotesSurviveReopen` (scenario 2: add two, open the same path again, `List` gives both in order), `TestAddBlankIsEmpty` (scenario 3: `ErrEmpty`, list unchanged, also after reopen).

Integration (PR 2; package `integration_test`, `web.Handler` with the real store on `notes.json` in a temp dir, through `httptest`):
- `TestPinWritesFile`: pin "buy milk"; the file holds `[{"id": 1, "text": "buy milk"}]` (compared as JSON), and a store opened again on it lists "buy milk". Scenario 2.

E2E (PR 2; package `e2e_test`, in Chrome through chromedp, against the app started by `task serve ADDR=127.0.0.1:<free port> FILE=<temp dir>/notes.json`; needs Chrome and `task` on the PATH; run with `go test -count=1 ./e2e/...`):
- `TestJourney`: type "buy milk" and press Pin, then "call vet"; the list shows "1. buy milk" and "2. call vet"; stop and start the app; the board still shows both, in that order. Scenarios 1, 2.
- `TestE2EPin`: on an empty board, pin "buy milk"; the list shows "1. buy milk". Scenario 1.
- `TestE2ERestart`: pin "buy milk" and "call vet", stop and start the app, open the board: "1. buy milk" then "2. call vet". Scenario 2.
- `TestE2EBlank`: pin "   "; the page says "Note is empty" and the list is empty. Scenario 3.

Perf: none; no requirement or design line gives a speed or load number.

Chaos (PR 2; package `e2e_test`, in Chrome against the app started by `task serve`):
- `TestChaosFileReadOnly`: pin "buy milk"; then, while the app runs, make `notes.json` and its folder read-only; pin "call vet": the page says "could not save note"; open the board: it shows only "1. buy milk". Scenario 4.
