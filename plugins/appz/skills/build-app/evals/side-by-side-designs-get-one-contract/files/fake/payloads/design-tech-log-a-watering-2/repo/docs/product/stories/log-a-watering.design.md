# Log a watering: technical design

Story: docs/product/stories/log-a-watering.md

## Packages and functions
- `plants.Watering{ID, PlantID int64; WateredAt time.Time}`: one logged watering. 1, 3
- `plants.Store.LogWatering(ctx, plantID int64) (Watering, error)`: keeps a watering now, `plants.ErrNotFound` when no plant has the id. 1, 4, 5
- `plants.Store.LastWatered(ctx, plantID int64) (time.Time, bool, error)`: the time of the plant's last watering, false when never watered. 2, 3, 5
- `web.LogWatering`: serves the POST, answering 201, 404 "That plant is gone" or 503 "Couldn't save that, try again". 1, 4, 5
- `web.ShowPlant`: shows "Last watered: <when>" or "Not watered yet" from `LastWatered`. 2, 3, 5
- `cmd/server/main.go`: opens the database at `SPROUT_DB_PATH` (default `sprout.db`) and registers the POST route. 1, 2, 3, 4, 5
- `plantstest.NewDB(t) *sql.DB`: a migrated SQLite file in `t.TempDir()`, for the store and web tests. 1, 2, 3, 4, 5

## Schema, routes, commands and events
- `migrations/002_waterings.sql`: `CREATE TABLE waterings (id INTEGER PRIMARY KEY, plant_id INTEGER NOT NULL REFERENCES plants(id), watered_at TEXT NOT NULL)`, `watered_at` as RFC 3339 text in UTC (pick for question 3). 1, 3
- `POST /plants/{id}/waterings`: as design/api.md gives it. 1, 4, 5
- `web/templates/plant.html`: the "Last watered" line and a "Watered it" button that swaps the line with htmx (pick for question 1). 2, 3, 5

## Libraries
- None added: `modernc.org/sqlite` v1.34.1 is already in go.mod; htmx 2.0.4, the newest, vendored as one file, if question 1 is picked yes.

## PRs
- PR 1, front end, about 60 lines with tests: `plant.html` and `web.ShowPlant`, built on a stubbed `web.LogWatering` (stub: takes the plant id, returns 201 with a watering at the request's time). Tests: unit, E2E against the stub.
- PR 2, back end with its data, about 90 lines with tests: the migration, `Watering`, `LogWatering`, `LastWatered`, `plantstest.NewDB`, the real `web.LogWatering` and the config in `cmd/server/main.go`. Tests: unit, integration, E2E, chaos. The repo's CI runs them, so no standard checks.

## Tests
### Unit
- `plants`: `LogWatering` then `LastWatered` returns the logged time, through `plants.Store` over `plantstest.NewDB`. 1, 3
- `plants`: `LastWatered` for a plant never watered returns false. 2
- `plants`: `LogWatering` for a missing plant returns `plants.ErrNotFound` and keeps nothing. 4
### Integration
- `plants` and `web` against a real SQLite file from `plantstest.NewDB`: a POST keeps the row and the page shows it after it is opened again. 1, 3
### E2E
- Started with `go run ./cmd/server` with `SPROUT_DB_PATH` pointing at a seeded file; a browser (Playwright) opens Fern: one test each for scenarios 1 to 5, and one walking Fern from opening to "Last watered: just now". 1, 2, 3, 4, 5
### Chaos
- Make the file at `SPROUT_DB_PATH` read-only after start; pressing "Watered it" shows "Couldn't save that, try again" and the line keeps the last watering. 5

Questions:
1. Use htmx for page updates (decision 0002 is proposed)? Pick: yes, accept 0002.
3. How are watering times kept? Pick: RFC 3339 text in UTC.
