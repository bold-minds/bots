---
type: llm
focus: trace
weight: 1
---

The transcript shows the new store tests run before the file-backed store code was written, with TestNotesSurviveReopen and TestAddBlankIsEmpty failing (a compile failure counting), and all three passing at the end. TestAddGivesNextID, which the stub already passes, is seen failing with the stub's behaviour removed (any way of removing it counts) before the file-backed store is written.
