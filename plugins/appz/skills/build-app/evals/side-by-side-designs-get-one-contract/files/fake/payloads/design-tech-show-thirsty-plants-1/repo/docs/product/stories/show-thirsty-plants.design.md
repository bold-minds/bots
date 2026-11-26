# Show thirsty plants: technical design

Story: docs/product/stories/show-thirsty-plants.md

## Packages and functions
- `plants.WateringEvent{Plant int64; At time.Time}`: one logged watering, as the list reads it. 1, 2, 3
- `plants.Store.LastWatering(ctx, plantID int64) (time.Time, bool, error)`: the time of a plant's last watering, false when never watered. 1, 2, 3
- `plants.Store.Thirsty(ctx, now time.Time, after time.Duration) ([]int64, error)`: the ids of plants last watered longer than `after` before `now`, or never watered. 1, 2, 3
- `web.ListPlants`: reads `Thirsty` and passes the thirsty ids to `plants.html`; on a read error answers 503 with "Couldn't load your plants, try again". 1, 2, 3, 4
- `cmd/server/main.go`: opens the database at `DB_FILE` (default `sprout.db`) and reads `THIRSTY_AFTER_HOURS` (default 168) into the `after` it passes to `web.ListPlants` (pick for question 1). 1, 2, 3, 4
- `testdb.New(t) *sql.DB`: a migrated SQLite file in `t.TempDir()`, for the store and web tests. 1, 2, 3, 4

## Schema, routes, commands and events
- `migrations/002_watering_log.sql`: `CREATE TABLE watering_log (plant INTEGER NOT NULL REFERENCES plants(id), at TEXT NOT NULL)`, `at` as RFC 3339 text in UTC. 1, 2, 3
- `GET /plants`: same path; the list now carries the "Thirsty" mark, swapped in with htmx when the list reloads (pick for question 2). 1, 2, 3, 4
- `web/templates/plants.html`: a `<span class="thirsty">Thirsty</span>` after the name of each thirsty plant. 1, 3

## Libraries
- None added: `modernc.org/sqlite` v1.34.1 is already in go.mod, and the standard library covers the rest.

## PRs
- PR 1, back end with its data and the front end, about 140 lines with tests: the migration, `WateringEvent`, `LastWatering`, `Thirsty`, `testdb.New`, the `web.ListPlants` change, `plants.html`, and the config in `cmd/server/main.go`. Tests: unit, integration, E2E, chaos. The repo's CI runs them, so no standard checks.

## Tests
### Unit
- `plants`: `Thirsty` with a fixed `now` returns a plant watered 8 days ago and one never watered, and not one watered today, through `plants.Store` over `testdb.New`. 1, 2, 3
- `web`: `ListPlants` over a store with one thirsty plant renders "Thirsty" beside that plant only. 1, 2
- `web`: `thirstySet(ids []int64) map[int64]bool` holds each id given. 1, 3
### Integration
- `plants` against a real SQLite file from `testdb.New`: rows written to `watering_log` are read back by `LastWatering` and `Thirsty`. 1, 2, 3
### E2E
- Started with `go run ./cmd/server` with `DB_FILE` pointing at a seeded file; a browser (Playwright) opens `/plants`: one test each for scenarios 1 to 4, and one opening the list with Fern and Ivy seeded. 1, 2, 3, 4
### Chaos
- Remove read access to the file at `DB_FILE` after start; opening `/plants` shows "Couldn't load your plants, try again". 4

Defaults taken:
- Times are kept as RFC 3339 text in UTC. *

Questions:
1. When does a plant count as thirsty? Pick: 168 hours after its last watering, or when never watered, in `THIRSTY_AFTER_HOURS`.
2. Use htmx for the list's update (decision 0002 is proposed)? Pick: yes, accept 0002.
