---
type: llm
focus: trace
weight: 1
---

The transcript shows the new tests run before the file-backed store code was written, with TestNotesSurviveReopen, TestAddBlankIsEmpty, TestPinWritesFile, TestJourney, TestE2ERestart and TestChaosFileReadOnly failing (a compile failure counting), and all of them passing at the end. TestAddGivesNextID, TestE2EPin and TestE2EBlank, which the stub passes, are each seen failing with the stub's behaviour removed (any way of removing it counts) before the file-backed store is written. The E2E and chaos tests fail on what they check in the app started by `task serve`, not because the serve task is missing or the app did not start.
