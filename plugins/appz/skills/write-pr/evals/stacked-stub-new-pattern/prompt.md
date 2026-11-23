---
tags: [write-pr]
max_turns: 40
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

Write the title and description of each PR of the story repo/docs/product/stories/mark-a-chore-done.md, so I can push the branches and open the PRs. Its technical design is repo/docs/product/stories/mark-a-chore-done.design.md. The app's repo is repo/ (remote origin). PR 1 is on the branch mark-a-chore-done/pr-1, built on main; PR 2 is on mark-a-chore-done/pr-2, built on mark-a-chore-done/pr-1. Each PR's diff is what `git diff <the branch it builds on>...<its branch>` gives in repo/. The gate results are inputs/gate-pr-1.txt and inputs/gate-pr-2.txt, and the line counts, each with the command that gave them, are inputs/counts-pr-1.txt and inputs/counts-pr-2.txt. Return each PR's title, description and the branch it builds on.

Input files: main/go.mod, main/README.md, main/Taskfile.yml, main/.github/workflows/ci.yml, main/cmd/chorelist/main.go, main/docs/product/stories/mark-a-chore-done.md, main/docs/product/stories/mark-a-chore-done.design.md, pr-1/store/chore.go, pr-1/store/stub.go, pr-1/web/web.go, pr-1/web/web_test.go, pr-1/e2e/stub_test.go, pr-1/cmd/chorelist/main.go, pr-2/go.mod, pr-2/go.sum, pr-2/store/store.go, pr-2/store/migrate.go, pr-2/store/migrations/0001_chores.sql, pr-2/store/store_test.go, pr-2/store/integration_test.go, pr-2/e2e/e2e_test.go, pr-2/web/web_test.go, pr-2/cmd/chorelist/main.go, pr-2.delete, inputs/gate-pr-1.txt, inputs/gate-pr-2.txt, inputs/counts-pr-1.txt, inputs/counts-pr-2.txt
