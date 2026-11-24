# Clear ticked items

Shows: someone clears the list, and every ticked item is gone for everyone.
Design: design/interface.md (`#list`, `#cleared`)

## Journey
Given the list holds "milk" and "bread", with "bread" ticked
When someone clears ticked items
Then the list shows only "milk", on every phone and laptop that opens it

## Scenarios
1. Ticking an item crosses it out and keeps it on the list. (A2)
2. Clearing removes every ticked item in one step, with no confirm. (A2)
3. With nothing ticked, clearing changes nothing. (A2) *

## Changelog
- Approved as written.
