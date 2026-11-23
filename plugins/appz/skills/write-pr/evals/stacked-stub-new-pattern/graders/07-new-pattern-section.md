---
type: llm
focus: trace
weight: 1
---

PR 2's description has a section on the schema migrations that says what they are (numbered SQL files applied in order), why they were chosen (one reviewable file per schema change, or an existing chore file upgraded in place), how they work here (embedded and applied at Open, recorded in schema_version), and where to look (store/migrations/ or store/migrate.go). PR 1's description has no such section.
