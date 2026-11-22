---
type: llm
focus: trace
weight: 1
---

On the PR's branch, TestCount is in package store_test and TestPageShowsCount is in package web_test, each calling only exported names (store.New, Add, Count; web.Handler).
