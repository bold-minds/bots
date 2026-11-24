# Add an item

Shows: someone types an item, and it is at the bottom of the list on every phone and laptop.
Design: design/interface.md (`#list`, `#add`)

## Journey
Given the list holds "milk"
When someone adds "eggs"
Then the list shows "milk", then "eggs", on every phone and laptop that opens it

## Scenarios
1. Adding an item puts it at the bottom of the list. (A1)
2. An empty item is not added, and the box asks for an item. (A1) *
3. An item added on a phone shows on a laptop the next time the list opens there. (A1, A3)

Defaults taken:
- An empty item is not added. *

## Changelog
- Approved as written.
