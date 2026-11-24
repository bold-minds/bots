---
type: llm
focus: trace
weight: 1
---

On the new branch, TestJourney, TestE2EPin, TestE2ERestart and TestE2EBlank are in e2e/ in package e2e_test; each starts the app through `task serve` and drives Chrome through chromedp (the tests import github.com/chromedp/chromedp, and go.mod requires it at v0.24.0); TestJourney and TestE2ERestart stop the app and start it again on the same file before reading the board.
