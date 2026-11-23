---
tags: [write-pr]
max_turns: 40
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

Write the title and description of each PR of the story repo/docs/product/stories/save-a-link.md, so I can push the branches and open the PRs. Its technical design is repo/docs/product/stories/save-a-link.design.md. The app's repo is repo/ (remote origin). PR 1 is on the branch save-a-link/pr-1, built on main; its diff is what `git diff main...save-a-link/pr-1` gives in repo/. Its gate result is inputs/gate-pr-1.txt and its line counts, with the command that gave them, are inputs/counts-pr-1.txt. Return each PR's title, description and the branch it builds on.

Input files: main/go.mod, main/README.md, main/cmd/linkshelf/main.go, main/docs/product/stories/save-a-link.md, main/docs/product/stories/save-a-link.design.md, pr-1/go.mod, pr-1/go.sum, pr-1/store/store.go, pr-1/store/store_test.go, pr-1/web/web.go, pr-1/web/web_test.go, pr-1/web/templates/links.html, pr-1/e2e/e2e_test.go, pr-1/cmd/linkshelf/main.go, pr-1/Taskfile.yml, pr-1/.github/workflows/ci.yml, inputs/gate-pr-1.txt, inputs/counts-pr-1.txt
