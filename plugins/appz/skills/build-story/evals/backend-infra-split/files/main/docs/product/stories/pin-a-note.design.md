# Pin a note: technical design

Status: Approved

## Packages and functions
- `store`: the notes, kept in one JSON file. Scenarios 1, 2, 3.
  - `type Note struct { ID int; Text string }`
  - `var ErrEmpty = errors.New("note is empty")`
  - `func Open(path string) (*Store, error)`: opens the file at path, or starts empty when it does not exist.
  - `func (s *Store) Add(text string) (Note, error)`: trims the text; blank gives `ErrEmpty` and adds nothing; otherwise gives the next ID (1, 2, 3, ...) and writes the file before returning.
  - `func (s *Store) List() ([]Note, error)`: the notes in the order they were added.
- `web`: `func Handler(s *store.Store) http.Handler`: GET `/` renders the board; POST `/pin` adds the note and redirects to `/`, or renders the board with "Note is empty" on `ErrEmpty`. Scenarios 1, 2, 3.
- `cmd/notes`: opens `notes.json` and serves `web.Handler` on :8080. Scenario 2.

## Schema, routes, commands and events
- File `notes.json`: a JSON array of `{"id": 1, "text": "buy milk"}`. Scenario 2.
- Routes: GET `/`, POST `/pin` with form field `text`. Scenarios 1, 2, 3.
- Gate: `task check` (gofmt, go vet, go test, build), run by CI on every push and pull request.

## Libraries
- None added; Go standard library only.

## PRs
Estimate: front end about 140 lines, back end about 150, infra about 40; tests included. Over the 300-line limit together, so split in two.
- PR 1, front end (about 140 lines): `web`, `cmd/notes`, and a stubbed `store` in `store/stub.go`, built against the stub contract below. Builds on main.
- PR 2, back end and infra (about 190 lines): the real `store` (file-backed), replacing `store/stub.go`; `Taskfile.yml` with the `check` gate and `.github/workflows/ci.yml` running it. Builds on PR 1.

Stub contract (PR 1's `store/stub.go`; PR 2's real `store` keeps it exactly):
- `Open(path string) (*Store, error)`: the stub ignores path and returns an empty in-memory store, nil.
- `Add(text string) (Note, error)`: blank after trimming gives `Note{}`, `ErrEmpty`; otherwise `Note{ID: next, Text: trimmed}`, nil, IDs from 1.
- `List() ([]Note, error)`: the notes in add order, nil.

## Tests
- `web` (PR 1; package `web_test`, through `web.Handler` and `httptest`, against the stub): `TestPinShowsNote` (scenario 1), `TestPinBlankSaysEmpty` (scenario 3).
- `store` (PR 2; package `store_test`, through `Open`, `Add` and `List` on a temp dir): `TestAddGivesNextID` (scenario 1), `TestNotesSurviveReopen` (scenario 2: add two, open the same path again, `List` gives both in order), `TestAddBlankIsEmpty` (scenario 3: `ErrEmpty`, list unchanged, also after reopen).
