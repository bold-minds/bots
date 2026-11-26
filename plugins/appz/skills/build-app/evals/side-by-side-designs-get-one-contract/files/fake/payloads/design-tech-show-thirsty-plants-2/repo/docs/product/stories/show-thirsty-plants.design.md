# Show thirsty plants: technical design

Story: docs/product/stories/show-thirsty-plants.md

## Packages and functions
- `plants.Watering` and `plants.Store.LastWatered`: log-a-watering's, used as they are. 1, 2, 3
- `plants.Store.Thirsty(ctx, now time.Time, after time.Duration) ([]int64, error)`: the ids of plants last watered longer than `after` before `now`, or never watered, read from `waterings`. 1, 2, 3
- `web.ListPlants`: reads `Thirsty` and passes the thirsty ids to `plants.html`; on a read error answers 503 with "Couldn't load your plants, try again". 1, 2, 3, 4
- `cmd/server/main.go`: reads `SPROUT_THIRSTY_AFTER_DAYS` (days, default 7) into the `after` it passes to `web.ListPlants` (pick for question 2); the database at `SPROUT_DB_PATH` is log-a-watering's. 1, 2, 3, 4
- `plantstest.Water(t, db, plantID int64, at time.Time)`: logs a watering at `at` on a database from log-a-watering's `plantstest.NewDB`. 1, 2, 3

## Schema, routes, commands and events
- `waterings`: log-a-watering's table, read as it is, `watered_at` as RFC 3339 text in UTC (pick for question 3). 1, 2, 3
- `GET /plants`: same path; the list now carries the "Thirsty" mark, swapped in with htmx when the list reloads (pick for question 1). 1, 2, 3, 4
- `web/templates/plants.html`: a `<span class="thirsty">Thirsty</span>` after the name of each thirsty plant. 1, 3

## Libraries
- None added: `modernc.org/sqlite` v1.34.1 is already in go.mod, and the standard library covers the rest.

## PRs
- PR 1, back end with its data and the front end, about 100 lines with tests, built on log-a-watering's PR 2: `Thirsty`, `plantstest.Water`, the `web.ListPlants` change, `plants.html`, and `SPROUT_THIRSTY_AFTER_DAYS` in `cmd/server/main.go`. Tests: unit, integration, E2E, chaos. The repo's CI runs them, so no standard checks.

## Tests
### Unit
- `plants`: `Thirsty` with a fixed `now` returns a plant watered 8 days ago and one never watered, and not one watered today, through `plants.Store` over `plantstest.NewDB` and `plantstest.Water`. 1, 2, 3
- `web`: `ListPlants` over a store with one thirsty plant renders "Thirsty" beside that plant only. 1, 2
### Integration
- `plants` against a real SQLite file from `plantstest.NewDB`: rows written by `plantstest.Water` to `waterings` are read back by `Thirsty`. 1, 2, 3
### E2E
- Started with `go run ./cmd/server` with `SPROUT_DB_PATH` pointing at a seeded file; a browser (Playwright) opens `/plants`: one test each for scenarios 1 to 4, and one opening the list with Fern and Ivy seeded. 1, 2, 3, 4
### Chaos
- Remove read access to the file at `SPROUT_DB_PATH` after start; opening `/plants` shows "Couldn't load your plants, try again". 4

Questions (the milestone contract's numbers):
1. Use htmx for the list's update (decision 0002 is proposed)? Pick: yes, accept 0002.
2. When does a plant count as thirsty? Pick: 7 days after its last watering, or when never watered, in `SPROUT_THIRSTY_AFTER_DAYS`, in days.
3. How are watering times kept? Pick: RFC 3339 text in UTC.
