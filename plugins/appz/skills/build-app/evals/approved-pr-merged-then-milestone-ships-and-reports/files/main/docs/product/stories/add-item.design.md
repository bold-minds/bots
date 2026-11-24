# Add an item: technical design

Status: approved

## Packages and functions
- `list.Add(item string) error` in `list/`: puts the item at the end of the list; an empty item returns `list.ErrEmpty`. 1, 2, 3
- `server.Items` in `server/`: the handler for `POST /items`. 1, 2, 3

## Schema, routes, commands and events
- `POST /items` with `{"item": "eggs"}`: 201 with the whole list; 400 with `{"error": "Type an item to add it."}` for an empty item. 1, 2

## Libraries
- None new.

## PRs
- `add-item/pr-1`, about 200 changed lines, tests included: the whole story in one PR (front end, back end and infra fit the limit). Holds the unit, integration and E2E tests.

## Tests
### Unit
- `TestAddPutsItemLast` 1
- `TestAddEmptyRejected` 2
### Integration
- `TestPostItemsStoresItem` 1, 3
### E2E
- `TestE2EJourney` 1, 3
- `TestE2EEmptyItem` 2

Start command: `task start` serves the app on port 8080; the E2E tests run against it.
