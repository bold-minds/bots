---
type: llm
focus: trace
weight: 1
---

The design plans end-to-end tests in a browser against the running app: one for each of scenarios 1, 2, 3, 4 and 5 (a chaos test of scenario 5 run in the browser against the running app counts as its end-to-end test) and one for the Journey, each with scenario numbers as digits. It names the command that starts the app for them (for example a Taskfile task or `go run ./cmd/server`) and what the app needs to run (for example a fresh SQLite file with the migrations applied, or a port).
