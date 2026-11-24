---
type: llm
focus: trace
weight: 1
---

On the new branch, TestChaosFileReadOnly makes the notes file or its folder unwritable for real (for example by chmod) while the app started by `task serve` runs, pins a note in Chrome, and checks that the page says "could not save note" and that the board then shows only the note pinned before. Run from the branch, the app started by `task serve` answers a pin made after its notes file and folder are made read-only with "could not save note", and its board still shows only the earlier note.
