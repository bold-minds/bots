# Save a link: technical design

Status: approved

## Packages and functions
- `store`: `Link{Name, Slug, URL string}`, `New() *Store`, `(*Store).Save(name, url string) (Link, error)`, `(*Store).List() []Link`, `(*Store).Find(slug string) (Link, bool)`, `ErrNotWebAddress`. In memory; slugs from `tinyslug.Make`. 1, 2, 3
- `web`: `Handler(s *store.Store) http.Handler`, serving the routes below with the template `templates/links.html`. 1, 2, 3
- `cmd/linkshelf`: builds the store and serves `web.Handler` on :8080. 1

## Schema, routes, commands and events
- `GET /links`: the shelf page, every link with its name and short address. 1
- `POST /links`: form fields `name` and `url`; saves and redirects (303) to `/links`, or answers 400 with the page and "Enter a web address". 1, 3
- `GET /l/{slug}`: redirects (302) to the saved address; 404 when no link has that slug. 1, 2

## Libraries
- `example.org/tinyslug`: picked v0.9.2; newest v1.0.0. Turns names into URL-safe slugs and adds `-2`, `-3` for repeats. v1.0.0 needs Go 1.24 and the repo is on Go 1.22, so the 0.9 line stays until the Go upgrade story.
- Task (go-task) v3, as the task runner for the gate, installed in CI only.

## PRs
- PR 1 (about 220 changed lines, tests included): the whole story, front end, back end and infra in one PR. Holds `store`, `web` with its template, the wiring in `cmd/linkshelf`, and the repo's first gate: `Taskfile.yml` with `task check` (gofmt, go vet, staticcheck, go test -race) and `.github/workflows/ci.yml`, which runs `task check` on every push and pull request. The workflow runs the gate only; deploying is not part of this story. Tests: unit and E2E.

## Tests
### Unit
- `store`: TestSaveMakesSlugFromName 1; TestSameNameGetsNextSuffix 2; TestRefusesNonWebAddress 3.
- `web`: TestPostWithoutWebAddressShowsMessage 3.
### E2E
Over HTTP against the app started in the test with `httptest.NewServer(web.Handler(store.New()))`; run with `task check`.
- TestJourneySaveAndOpen 1; TestSaveListsShortAddress 1; TestRepeatNameGetsSuffix 2; TestNonWebAddressRefused 3.

Defaults taken: none.
