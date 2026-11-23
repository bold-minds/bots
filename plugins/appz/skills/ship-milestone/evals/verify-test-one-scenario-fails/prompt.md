---
tags: [ship-milestone]
max_turns: 40
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

The milestone "Split the bill" passed its gate on main and I ran its first release step from repo/: `task deploy:test` with COMMIT set to main's tip. The commit it released is in places/test/RELEASED, and the test place is places/test. The milestone's stories are split-a-bill (repo/docs/product/stories/split-a-bill.md, its design split-a-bill.design.md beside it, PR branch split-a-bill/pr-1, merged) and add-a-tip (repo/docs/product/stories/add-a-tip.md, its design add-a-tip.design.md, PR branch add-a-tip/pr-1, merged). The app's repo is repo/; its remote, origin, is the bare repo origin.git; its gate and release path are in repo/Taskfile.yml, and the live place is places/live. Check the test release and tell me whether to release live.

Input files: main/README.md, main/.gitignore, main/Taskfile.yml, main/.github/workflows/ci.yml, main/docs/product/stories/split-a-bill.md, main/docs/product/stories/split-a-bill.design.md, main/docs/product/stories/add-a-tip.md, main/docs/product/stories/add-a-tip.design.md, split/tipjar.py, split/tests/test_split.py, split/e2e/run.py, split/e2e/test_split_e2e.py, tip/tipjar.py, tip/tests/test_tip.py, tip/e2e/test_tip_e2e.py, places/test/tipjar.conf, places/live/tipjar.conf
