---
type: llm
focus: trace
weight: 1
---

On the new branch, `task validate` runs every test layer the design lists: its output shows the unit, integration and E2E steps passing, with the store, integration and e2e packages each tested (an `ok` line for each, none skipped), and the e2e package, built with its e2e tag, holds TestChaosFileReadOnly and the four E2E tests.
