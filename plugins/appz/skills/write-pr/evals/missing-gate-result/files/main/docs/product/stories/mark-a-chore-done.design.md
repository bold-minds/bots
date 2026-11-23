# Mark a chore done: technical design

Status: approved

## Packages and functions
- `store`: `Chore{ID int; Name string; DoneAt *time.Time}`, `ErrNoChore`, `ErrCantSave`, `(*Store).Chores() ([]Chore, error)`, `(*Store).MarkDone(id int, at time.Time) (Chore, error)`. 1, 2, 3, 4, 5
- `store.Open(path string) (*Store, error)`: opens the chore file with litesql and runs the migrations; `cmd/chorelist` opens it at `CHORES_FILE` (default `chores.db`). 4, 5
- `store/migrations`: numbered SQL files, embedded with `embed.FS` and applied in order at `Open`, each recorded in a `schema_version` table. The repo's first schema migrations; chosen over creating tables in Go code so each schema change is one reviewable file and an existing chore file is upgraded in place. 4
- `web`: `Handler(s Chores) http.Handler`, where `Chores` is the interface of the two store methods above; the list page and its tick button. 1, 2, 3, 5
- `cmd/chorelist`: serves `web.Handler` on :8090 over the store (over the stub until PR 2). 1

## Schema, routes, commands and events
- Table `chores(id INTEGER PRIMARY KEY, name TEXT NOT NULL, done_at TEXT)`, in `store/migrations/0001_chores.sql`. 1, 2, 4
- `GET /chores`: the list page. 1, 2, 4
- `POST /chores/{id}/done`: marks the chore done and redirects (303) to `/chores`; 404 with "No such chore"; 503 with "Couldn't save that, try again". 1, 2, 3, 5

## Libraries
- `example.org/litesql/v2`: picked v2.3.1; newest v2.4.0. An embedded SQL database in pure Go, so the app stays one binary. v2.4.0 opens files in WAL mode by default, which leaves recent writes outside the main file; v2.3.1 keeps the single-file journal until that is settled.

## PRs
- PR 1, front end (about 170 changed lines, tests included): `web` and the wiring in `cmd/chorelist`, built on a stubbed store, `store/stub.go`. Tests: unit (web) and E2E against the stub. It builds on main.
- PR 2, back end with its data (about 240 changed lines, tests included): `store.Open`, the migrations and the real store, replacing `store/stub.go`. Tests: unit (store), integration, E2E through the real app, chaos. It builds on PR 1.
- Stub contract: `Chores() ([]Chore, error)` returns the chores in ID order, seeded with "Water the ferns" (1) and "Take out the bins" (2), held in memory; `MarkDone(id int, at time.Time) (Chore, error)` sets `DoneAt` once and returns the chore, or `ErrNoChore` for an unknown id. The stub never returns `ErrCantSave`.
- CI runs `task check` (gofmt, go vet, go test -race) on every pull request; this story leaves CI unchanged.

## Tests
### Unit
- `web` (PR 1): TestTickShowsDoneTime 1; TestTickTwiceKeepsFirstTime 2; TestUnknownChoreShowsNoSuchChore 3; TestCantSaveShowsTryAgain 5.
- `store` (PR 2): TestMarkDoneSetsTime 1; TestMarkDoneTwiceKeepsFirst 2; TestUnknownIDIsErrNoChore 3.
### Integration (PR 2)
- Against a real chore file in a temp dir: TestDoneSurvivesReopen 4; TestMigrationsRunOnceOnReopen 4.
### E2E
Over HTTP against `web.Handler` in `httptest.NewServer`; run with `task check`.
- PR 1, against the stub: TestJourneyAgainstStub 1; TestScenario2AgainstStub 2; TestScenario3AgainstStub 3.
- PR 2, through the real store on a temp file: TestJourney 1; TestScenario1 1; TestScenario2 2; TestScenario3 3; TestScenario4Restart 4.
### Chaos (PR 2)
- TestReadOnlyFileGivesTryAgain 5: the chore file is made read-only before the tick; the page shows "Couldn't save that, try again" and the chore stays not done.

Defaults taken: `CHORES_FILE` defaults to `chores.db`.
