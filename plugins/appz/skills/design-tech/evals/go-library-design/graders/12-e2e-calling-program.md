---
type: llm
focus: trace
weight: 1
---

The design plans end-to-end tests through a small calling program: a program outside package tagset that imports it and calls tagset.Merge as a caller would. There is one such test for each of scenarios 1, 2, 3 and 4 (a perf test of scenario 4 run through that program counts as its end-to-end test) and one for the Journey, each with scenario numbers as digits. The design names the command that runs that program or its tests (for example a `go run` or `go test` command, or a Taskfile task) and what it needs to run.
