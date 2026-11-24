---
tags: [build-story]
max_turns: 100
timeout_seconds: 2400
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

Build PR 1 of the story repo/docs/product/stories/show-book-count.md. Its technical design is repo/docs/product/stories/show-book-count.design.md. The app's repo is repo/ (main branch, remote origin); its gate is `task check`. Return any questions that need deciding, each with your pick.

Input files: main/go.mod, main/README.md, main/Taskfile.yml, main/.github/workflows/ci.yml, main/store/store.go, main/store/store_test.go, main/web/web.go, main/web/web_test.go, main/cmd/shelf/main.go, main/docs/product/stories/show-book-count.md, main/docs/product/stories/show-book-count.design.md
