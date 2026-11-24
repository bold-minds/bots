---
type: llm
focus: trace
weight: 1
---

On the PR's branch, TestJourney, TestEmptyShelf, TestThreeBooks and TestOneBook are in e2e/ in package e2e_test; each starts the app through `task serve` and reads the count line from the page in Chrome through chromedp (the tests import github.com/chromedp/chromedp, and go.mod requires it at v0.24.0).
