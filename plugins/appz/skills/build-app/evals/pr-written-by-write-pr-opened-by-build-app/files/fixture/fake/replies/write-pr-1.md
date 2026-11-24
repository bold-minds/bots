One PR for add-item.

### add-item/pr-1
Branch: add-item/pr-1
Builds on: main
Title: Add an item to the shared list

Description (Markdown, ready to paste):

## What this does
Lets someone type an item and see it at the bottom of the shared list, on every phone and laptop that opens it.
Scenarios: 1, 2, 3

## Back end
- New: `list.Add(item string) error` puts the item at the end of the list; an empty item returns `list.ErrEmpty`.
- New route: `POST /items` returns 201 with the whole list, or 400 with `{"error": "Type an item to add it."}` for an empty item.

## Tests
- Unit: `TestAddPutsItemLast`, `TestAddEmptyRejected` (1, 2).
- Integration: `TestPostItemsStoresItem` (1, 3).
- E2E: `TestE2EJourney`, `TestE2EEmptyItem` (1, 2, 3).

## CI
- `task validate` runs lint, build, unit, integration and E2E: passed, 1m 52s in all; the slow part: "✅ e2e (2 tests, 41s)".

Size: code +36 -0, tests +51 -0 (`git diff --numstat main...add-item/pr-1`).

Differences between the diff and the design: none.

## Think answers
- Can a reviewer tell from the description what the PR does, what it holds and how long its checks take? Wrote What this does, Tests and CI: "real	1m52.004s" (data/gates/add-item-pr-1.txt).
- Does every claim come from the story, the design, the diff, the gate output or the line counts? Each line checked: "`POST /items` with `{"item": "eggs"}`: 201 with the whole list" (add-item.design.md, Schema).
- What would a reviewer assume this PR does that it doesn't? Nothing to add a Not in this PR section for: "the whole story in one PR" (add-item.design.md, PRs).
- What does this PR make new? The route and the function, marked new: "+func Add(item string) error {" (list/add.go).
- Does each bullet change how the reviewer reads the PR? Folded CI to one line: "✅ lint" (data/gates/add-item-pr-1.txt).
