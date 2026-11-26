---
tags: [design-tech]
max_turns: 30
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

The milestone's two stories, docs/product/stories/log-a-watering.md and docs/product/stories/show-thirsty-plants.md, were designed side by side. docs/product/stories/show-thirsty-plants.design.md is the show-thirsty-plants design, written before the milestone's contract existed; no one has read it yet. The milestone's contract is now written, at milestone/contract-M1.md. Fix the show-thirsty-plants design to the contract. The requirements are in docs/product/requirements.md, the interface is in design/, and this folder is the app's repo, with its decisions in docs/decisions/. Return any questions that still need deciding, each with your pick.

Input files: go.mod, README.md, .github/workflows/ci.yml, cmd/server/main.go, internal/plants/store.go, internal/web/handlers.go, migrations/001_plants.sql, web/templates/plant.html, web/templates/plants.html, docs/decisions/0001-sqlite.md, docs/decisions/0002-htmx.md, docs/product/requirements.md, docs/product/stories/log-a-watering.md, docs/product/stories/log-a-watering.design.md, docs/product/stories/show-thirsty-plants.md, docs/product/stories/show-thirsty-plants.design.md, design/screens/plant-detail.md, design/screens/plants-list.md, design/api.md, milestone/contract-M1.md
