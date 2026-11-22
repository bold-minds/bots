---
tags: [design-tech]
max_turns: 30
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

Write the technical design for the story docs/product/stories/log-a-watering.md before anything is built. The requirements are in docs/product/requirements.md, the interface is in design/, and this folder is the app's repo, with its decisions in docs/decisions/. One PR may hold at most 200 changed lines, tests included. Return any questions that still need deciding, each with your pick.

Input files: go.mod, README.md, .github/workflows/ci.yml, cmd/server/main.go, internal/plants/store.go, internal/web/handlers.go, migrations/001_plants.sql, web/templates/plant.html, web/templates/plants.html, docs/decisions/0001-sqlite.md, docs/decisions/0002-htmx.md, docs/product/requirements.md, docs/product/stories/log-a-watering.md, design/screens/plant-detail.md, design/api.md
