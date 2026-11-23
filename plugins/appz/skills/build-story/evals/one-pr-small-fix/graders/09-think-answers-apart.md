---
type: llm
focus: trace
weight: 1
---

Apart from the work's report, the returned message answers each of these in one line: does each test serve a scenario; does the code do only what the design lists; does this PR build and test on its own; did anything need a design change. Each of the four answers gives its finding and quotes, with where it is, text it rests on: a line or part of a line of the design, of the branch's code or tests (with the path), or of a command's output (with the command). Each quote is found word for word (markdown aside) in that place, in the design, the branch's files or the transcript's tool output, on the line number given when one is given, and backs the finding; every claim in an answer is backed by one of its quotes. The answer on doing only what the design lists names every file that `git diff --name-only main...<the PR's branch>` gives, each beside a quoted design line it builds; a file left out, or set beside a line the design does not hold or one that does not name what the file builds, fails it. An answer that quotes nothing, or that is only "Yes" or "No", fails the assertion; any one such answer fails it.
