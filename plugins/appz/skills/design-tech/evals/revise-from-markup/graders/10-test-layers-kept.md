---
type: llm
focus: trace
weight: 1
---

The revised design keeps its test layers: `## Tests` still has its Unit, Integration and E2E groups; the Integration line now names plants.Store.Update where it named Rename and keeps its three tests with their scenario numbers; PR 2 still says it holds the plants unit tests, the integration tests and the E2E tests; and no Perf or Chaos layer or test is added (the story gives no speed or load number and no failure of a dependency).
