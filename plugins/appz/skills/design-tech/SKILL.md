---
name: design-tech
description: Write and evaluate the technical design of one story, before any of its code is built, as a one-page draft kept beside the story for approval: the packages, functions, schema, routes, commands, events and libraries it adds or changes, how it is cut into PRs and what each holds, and the tests at each package's exported surface. Works for any interface: screens, endpoints, commands or library functions. Use once per story, after the story is written and before it is built, and when revising a story's design from the caller's markup.
---

# Design tech

## In
- The story: its Journey and its numbered scenarios, each with its requirement ids.
- The requirements the story builds: each with its id.
- The parts of the interface the story touches, in whatever form people or code use them (screens, endpoints, commands, library functions), designed or already running.
- The app's repo: its code, and its approved decisions (for example ADRs).
- The `skillz:settle-question` skill.
- Optional: the most changed lines one PR may hold, tests included. Default 400.
- Optional, when revising: the earlier design, and the caller's markup or answers on it.

## Out
- The design at `<story>.design.md`, in the story's folder with the story's base name: one page, in the form in `## Act`. Returned to the caller as a draft for approval, with where it is and the questions from `skillz:settle-question`, each with its pick.
- The Think answers, one line per question, each saying what it led the skill to do, kept apart from the work, returned to the caller.

## Think
- Does each part have one job?
- Does it reuse what the repo already has?
- Does a scenario need each part?
- Can each PR be built and tested on its own?
- Is it cut into as few PRs as fit the limit?

## Act
1. Check each input against `## In` before anything else. If one other than the optional ones is missing or falls short, return to the caller exactly what's missing and what it must contain.
2. When revising, apply the caller's markup and answers to the earlier design. Change only the lines they touch and the lines those changes force (for example a PR's estimate), and keep every other line as it is: the caller has already read it. When the markup replaces, removes or renames a part, go through every section that held the old part (packages, PRs, tests): rewrite each line and test that held it around the part that takes its place, one the repo already has or a new one, with the scenario numbers it had, so the design names the old part nowhere (the design is the current plan, not its history); a test is deleted only when the markup says so. Write each change from what the markup, the answers, the earlier design and the repo already say, and leave a detail they don't settle as the markup left it. Take a question to `skillz:settle-question` only when the change can't be written without its answer. Then go to step 6.
3. Read the repo's code for what the story can reuse, and its decisions. Take the approved decisions as they are. Return a decision the repo marks proposed as a question via `skillz:settle-question`, never as a default.
4. Settle the other questions with `skillz:settle-question`. Write in what the sources settle. Mark each default. Return only what's left, each with its pick.
5. Write the design on one page, under these headings.
   - `## Packages and functions`: each package, function, type, test helper and piece of wiring it adds or changes, each with the scenario numbers it serves: the numbers themselves, listing each scenario a part serves.
   - `## Schema, routes, commands and events`: each it adds or changes, each with the scenario numbers it serves, as numbers.
   - `## Libraries`: each, with the version picked, the newest available, and why.
   - `## PRs`: estimate the changed lines, tests included, for the front end, the back end with its data, and the infra (CI, build, deploy). Only a part with changed lines gets a PR, so a part with none gets none. Cut by size: one PR when the whole story fits the limit; otherwise the front end in one PR and the back end with the infra in another; when one of those is still over, front end, back end and infra each in its own. List each PR with its estimate and what it holds. When it is split, the front end is built on a stubbed back end and comes before the back end that replaces it, and the design always gives the stub's contract: each stubbed call, what it takes and returns. The PR holding the infra goes first if the others need it. Where the interface isn't a front end (for example a library's functions or a tool's commands), that interface takes the front end's place.
   - `## Tests`: for each package, the tests at its exported surface, each package a black box at that surface, each test with the scenario numbers it serves, as numbers.
   - `Defaults taken:`, if any.
6. Evaluate the design against each `## Think` question, and change any part that fails one. Check that every line under `## Packages and functions`, `## Schema, routes, commands and events` and `## Tests` ends with scenario numbers; give each the numbers it serves, and when writing a new design drop a part no scenario needs. Answer each question in one line that says what it led you to change, or that nothing changed. When revising, evaluate only the parts the markup changed, and change only lines the markup touches or those changes force.
7. Write the design as `<story>.design.md` beside the story. Return where it is, as a draft for approval, each question with its pick, and the Think answers apart from it.
