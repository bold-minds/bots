---
type: llm
focus: trace
weight: 1
---

On the new branch, TestPinWritesFile, in package integration_test outside web/, runs web.Handler with the real store on a notes file in a temp dir through httptest, and checks the file's contents after the pin.
