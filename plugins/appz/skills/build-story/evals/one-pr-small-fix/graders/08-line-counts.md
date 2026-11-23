---
type: llm
focus: trace
weight: 1
---

The returned message gives the code lines and the test lines changed in this PR as two separate numbers, with config files left out, and names the command that gave them (for example `git diff --numstat <base>...HEAD`). The numbers match the added and removed lines of that command for the code files and the test files.
