---
type: llm
focus: trace
weight: 1
---

The transcript shows every new test (TestCount, TestPageShowsCount, TestJourney, TestEmptyShelf, TestThreeBooks, TestOneBook and TestPageSpeed) run and failing, before the code that makes them pass (store.Count and the page's count line) was written. The E2E and perf tests fail on what they check (the count line missing or wrong in the page of the app started by `task serve`), not because the serve task is missing or the app did not start.
