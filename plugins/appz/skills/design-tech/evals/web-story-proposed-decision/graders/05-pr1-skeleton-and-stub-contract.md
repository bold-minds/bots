---
type: llm
focus: trace
weight: 1
---

PR 1 holds CI (keeping the existing workflow counts), a stub front end and a stub back end (a part that answers fixed values counts as a stub, whether or not it is called one), and states the stub's contract: what each stubbed call takes and returns. The stubbed calls may be POST /plants/{id}/waterings, the plants.Store watering methods, or both.
