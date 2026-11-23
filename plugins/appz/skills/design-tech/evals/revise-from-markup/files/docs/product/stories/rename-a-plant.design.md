# Rename a plant: design

Story: rename-a-plant.md

## Packages and functions
- `plants.Store.Rename(ctx, id int64, name string) (Plant, error)`: new; sets a plant's name, returns ErrNotFound when no plant has id. (1, 3)
- `plants.ValidName(name string) error`: new; returns ErrBadName when the trimmed name is empty or over 40 characters, using the validator library. (2)
- `web.RenamePlant(s *plants.Store) http.HandlerFunc`: new; serves PATCH /plants/{id}. (1, 2, 3)
- `web/templates/plant.html`: changed; adds the rename field and its message. (1, 2)
- `Taskfile.yml`: new; task `serve` makes a fresh sprout.db from migrations/ and runs `go run ./cmd/server` on port 8080; task `e2e` starts `serve` and runs the browser tests in e2e/ against it. (1, 2, 3)

## Schema, routes, commands and events
- Schema: none; a rename updates plants.name. (1)
- Route: `PATCH /plants/{id}` with form field `name`; 200 with the name fragment, 400 "Give the plant a name of 1 to 40 characters", 404 "That plant is gone". (1, 2, 3)

## Libraries
- `github.com/go-playground/validator/v10`: picked v10.22.1, newest v10.22.1; checks the name's length. (2)
- `github.com/chromedp/chromedp`: picked v0.13.6, newest v0.13.6; drives a real browser for the E2E tests, with no Node toolchain. (1, 2, 3)

## PRs
Estimates, tests included: front end 180 lines, back end 340, infra 30 (the Taskfile; CI is already in .github/workflows/ci.yml). The whole story is over the 400-line limit, so it is cut in two.
1. Front end, about 180 lines: the rename field on plant.html, the new heading after a rename, and the refusal message, built against a stubbed `web.RenamePlant`. Stub contract: PATCH /plants/{id} takes form field `name`; returns 200 with the name sent, 400 with the refusal text when name is "bad", 404 "That plant is gone" when id is 0. Tests: the web unit tests, against the stub. (1, 2, 3)
2. Back end and infra, about 370 lines: `plants.Store.Rename`, `plants.ValidName` with the validator library, the real `web.RenamePlant`, and the Taskfile. Tests: the plants unit tests, the integration tests, and the E2E tests through the real app. (1, 2, 3)

## Tests
Unit:
- plants (package plants_test): Rename changes the name and Get returns it (1); Rename on a missing id returns ErrNotFound (3); ValidName refuses "" and a 41-character name and takes a 40-character one (2).
- web (package web_test, through httptest against the mux): PATCH with a good name returns 200 and the new name (1); with "" returns 400 and the refusal text (2); with a missing id returns 404 "That plant is gone" (3).

Integration (web.RenamePlant with plants.Store.Rename on a real SQLite file made from migrations/):
- PATCH with a good name keeps it, and Get and List return it (1); a refused name leaves the old name in the database (2); PATCH on a deleted plant returns 404 and changes no row (3).

E2E (in a browser through chromedp, against the app started by `task serve`; run with `task e2e`):
- Journey: open Fern, rename it "Boston fern", and see "Boston fern" as the heading, also after a reload (1).
- After a rename, the new name shows on the plant's page and in the list of plants (1).
- An empty name and a 41-character name each show "Give the plant a name of 1 to 40 characters", and the old name stays after a reload (2).
- Renaming a plant deleted in another tab shows "That plant is gone" (3).
