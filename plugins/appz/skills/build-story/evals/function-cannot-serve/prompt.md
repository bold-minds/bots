---
tags: [build-story]
max_turns: 60
timeout_seconds: 1500
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

Build PR 1 of the story repo/docs/product/stories/add-amounts.md. Its technical design is repo/docs/product/stories/add-amounts.design.md. The app's repo is repo/ (main branch, remote origin); its gate is `task check`. Return any questions that need deciding, each with your pick.

Input files: main/.gitignore, main/go.mod, main/README.md, main/Taskfile.yml, main/tally/doc.go, main/cmd/tally/main.go, main/docs/product/stories/add-amounts.md, main/docs/product/stories/add-amounts.design.md
