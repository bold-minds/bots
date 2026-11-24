---
type: llm
focus: trace
weight: 1
---

On the PR's branch, TestPageSpeed starts the app through `task serve` with 1000 titles, requests / over HTTP, and fails when the response takes over 100 ms or the page lacks <p class="count">1000 books</p>.
