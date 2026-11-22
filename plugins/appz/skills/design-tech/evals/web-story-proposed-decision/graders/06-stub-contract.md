---
type: llm
focus: trace
weight: 1
---

The design says the front-end PR is built against a stubbed back end (a part that answers fixed values counts as a stub, whether or not it is called one), and states the stub's contract: what each stubbed call takes and returns. The stubbed calls may be POST /plants/{id}/waterings, the plants.Store watering methods, or both. If the infra is in a PR of its own and the others need it, that PR comes first.
