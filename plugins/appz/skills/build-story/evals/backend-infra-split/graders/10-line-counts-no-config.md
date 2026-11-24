---
type: llm
focus: trace
weight: 1
---

The returned message gives the code lines and the test lines changed in this PR as two separate numbers (each either one total, or an added and a removed figure that sum to the total the diff gives), with config files (Taskfile.yml, the CI workflow and the standard's other files, such as scripts/checks.sh, .golangci.yml and .gitignore) left out, names the command that gave them (for example `git diff --numstat <base>...HEAD`), and states the gate result and how long it took.
