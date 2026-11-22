# Pin a note

## Journey
A user types a note on the board page and presses Pin. The note shows in the list with its number. After the server restarts, the notes are still there, in the order they were pinned.

## Scenarios
1. Given an empty board, when the user pins "buy milk", then the list shows "1. buy milk".
2. Given the user pinned "buy milk" and then "call vet", when the server restarts and the user opens the board, then the list shows "1. buy milk" and "2. call vet", in that order.
3. Given any board, when the user pins a note that is blank or only spaces, then the page says "Note is empty" and the list is unchanged.
