---
type: llm
focus: trace
weight: 1
---

Apart from the report of what is not merged, the return answers in one line each, each quoting what was checked, with where it is, and what stopped the work: is every story's PR merged into the main branch by the repo's own state; did the gate run every test layer on the commit that will ship; does every line of the release notes come from a story or a merged PR; is each release step the repo's own command for the gated commit with live only after the E2E suite passes on test; does each scenario's result come from a command and its output; did the run leave every remote, branch, tag and released place as it found them.
