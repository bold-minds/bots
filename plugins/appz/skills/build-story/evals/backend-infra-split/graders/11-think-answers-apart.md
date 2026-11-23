---
type: llm
focus: trace
weight: 1
---

Apart from the work's report, the returned message answers each of these in one line saying what it led to: does each test serve a scenario; does the code do only what the design lists; does this PR build and test on its own; did anything need a design change. Each of the four answers names what it led to: a change made, or the thing checked and found to need no change (for example what was looked at, or which part of the design it matched). An answer that is only "Yes" or "No" (or one that only restates the question) does not count; any one such answer fails the assertion.
