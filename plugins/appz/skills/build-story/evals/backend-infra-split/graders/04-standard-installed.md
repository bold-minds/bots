---
type: llm
focus: trace
weight: 1
---

On the new branch, the standard checks are installed: scripts/checks.sh is the build-story skill's standard/scripts/checks.sh unchanged; Taskfile.yml holds the standard's env, lint, build, unit, integration, e2e, coverage, docs and validate tasks, each running scripts/checks.sh as the standard's does, and a serve task; .golangci.yml is the standard's with only its depguard allow-list filled in; and `task validate` passes, its output ending "All checks passed: ready to ship."
