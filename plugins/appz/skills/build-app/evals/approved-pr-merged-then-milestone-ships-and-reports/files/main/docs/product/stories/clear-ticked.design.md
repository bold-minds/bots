# Clear ticked items: technical design

Status: approved

## Packages and functions
- `list.Tick(item string)` in `list/`: marks an item ticked. 1
- `list.ClearTicked()` in `list/`: removes every ticked item. 2, 3

## Schema, routes, commands and events
- `POST /clear`: 200 with the list left. 2, 3

## Libraries
- None new.

## PRs
- `clear-ticked/pr-1`, about 120 changed lines, tests included: the whole story in one PR. Holds the unit, integration and E2E tests.

## Tests
### Unit
- `TestTickKeepsItem` 1
- `TestClearRemovesTicked` 2
- `TestClearWithNoneTicked` 3
### E2E
- `TestE2EClearJourney` 1, 2
- `TestE2EClearNothingTicked` 3

Start command: `task start` serves the app on port 8080; the E2E tests run against it.
