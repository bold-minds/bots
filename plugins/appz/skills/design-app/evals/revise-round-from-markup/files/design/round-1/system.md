# Found It: system design, round 1

## Parts
- The board page: one web page, opened on a phone or on the front-desk screen. It reads and writes items through the server.
- The server: serves the page and keeps the items. Calls from the page: list items, add an item (with an optional photo), take an item off the board.
- The store: one table of items (what, where found, photo, added at) on the server's disk.

## Interface
- In the box: `screens.html#list`
- One item: `screens.html#item`
- Confirm taking it off: `screens.html#confirm-claim`
- Add a found item: `screens.html#report`

## Decisions
| Decision | Why | From | Status |
|---|---|---|---|
| A board people open on their phones | It is what was asked for | "I want a board on our phones that shows what's in the box." (msg 1) | proposed |
| An item holds what it is, where it was found, and an optional photo | The finder adds these | "Whoever finds something adds it: what it is, where they found it, and a photo if they can." (msg 2) | proposed |
| Taking an item off the board asks to confirm first | So a slip doesn't lose an item | * | proposed |
| The same page fits the front-desk screen | Some read it there | "Some of us will look at it on the big screen at the front desk too." (msg 4) | proposed |
| Newest item first on the list | People look for what was lost lately | * | proposed |

## Gaps and questions
- Who may take an item off the board? Pick: anyone with the page, as with adding. *
