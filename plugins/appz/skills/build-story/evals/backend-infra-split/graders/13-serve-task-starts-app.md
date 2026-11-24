---
type: llm
focus: trace
weight: 1
---

On the new branch, `task serve ADDR=127.0.0.1:<port> FILE=<a path in a temp dir>` starts the app: a POST /pin of "buy milk" to that port, then GET /, shows "1. buy milk", and the file then holds that note.
