# Rename a plant: design

Story: rename-a-plant.md

## Packages and functions
- `plants.Store.Rename(ctx, id int64, name string) (Plant, error)`: new; sets a plant's name, returns ErrNotFound when no plant has id. (1, 3)
- `plants.ValidName(name string) error`: new; returns ErrBadName when the trimmed name is empty or over 40 characters, using the validator library. (2)
- `web.RenamePlant(s *plants.Store) http.HandlerFunc`: new; serves PATCH /plants/{id}. (1, 2, 3)
- `web/templates/plant.html`: changed; adds the rename field and its message. (1, 2)

## Schema, routes, commands and events
- Schema: none; a rename updates plants.name. (1)
- Route: `PATCH /plants/{id}` with form field `name`; 200 with the name fragment, 400 "Give the plant a name of 1 to 40 characters", 404 "That plant is gone". (1, 2, 3)

## Libraries
- `github.com/go-playground/validator/v10`: picked v10.22.1, newest v10.22.1; checks the name's length. (2)

## PRs
Estimates, tests included: front end 180 lines, back end 340, infra 0 (CI is already in .github/workflows/ci.yml). The whole story is over the 400-line limit, so it is cut in two.
1. Front end, about 180 lines: the rename field on plant.html, the new heading after a rename, and the refusal message, built against a stubbed `web.RenamePlant`. Stub contract: PATCH /plants/{id} takes form field `name`; returns 200 with the name sent, 400 with the refusal text when name is "bad", 404 "That plant is gone" when id is 0. (1, 2, 3)
2. Back end and infra, about 340 lines: `plants.Store.Rename`, `plants.ValidName` with the validator library, and the real `web.RenamePlant`. (1, 2, 3)

## Tests
- plants (package plants_test): Rename changes the name and Get returns it (1); Rename on a missing id returns ErrNotFound (3); ValidName refuses "" and a 41-character name and takes a 40-character one (2).
- web (package web_test, through httptest against the mux): PATCH with a good name returns 200 and the new name (1); with "" returns 400 and the refusal text (2); with a missing id returns 404 "That plant is gone" (3).
