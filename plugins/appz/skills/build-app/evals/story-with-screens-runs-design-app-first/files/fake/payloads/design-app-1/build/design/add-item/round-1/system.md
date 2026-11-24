# Pantry list: add an item, round 1

## Parts
- The page (screens.html), on phones and laptops, sends each new item to the server and shows the list it gets back.
- The server keeps the one list and sends it to every page that opens it.

## Interface
- `#list`: screens.html#list
- `#add`: screens.html#add
- `#added`: screens.html#added
- `#empty-item`: screens.html#empty-item

## Decisions
| Decision | Why | Status | From |
|---|---|---|---|
| I type an item and it is on the list | What the story is for | proposed | "I type an item and it is on the list" (said.md, 2026-05-04 18:02) |
| A new item goes at the bottom of the list | Matches the order people add in | proposed | * |
| The add box sits above the list | Close to the thumb on a phone | proposed | * |
| An empty item is not added; the page shows "Type an item to add it." | The story's scenario 2 | proposed | * |
| Saving shows "Saving…" until the server answers | People see the item is on its way | proposed | * |

## Gaps and questions
- How long an item can be: no limit in this round, as no one gave one (default). *
