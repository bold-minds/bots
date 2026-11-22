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
2. When revising, apply the caller's markup and answers to the earlier design. Change only what they touch, and keep every other line as it is: the caller has already read it. Settle any question a change raises with `skillz:settle-question`, then go to step 6.
3. Read the repo's code for what the story can reuse, and its decisions. Take the approved decisions as they are. Return a decision the repo marks proposed as a question via `skillz:settle-question`, never as a default.
4. Settle the other questions with `skillz:settle-question`. Write in what the sources settle. Mark each default. Return only what's left, each with its pick.
5. Write the design on one page, under these headings.
   - `## Packages and functions`: each package and function it adds or changes, wiring included, each with the scenario numbers it serves.
   - `## Schema, routes, commands and events`: each it adds or changes, each with the scenario numbers it serves.
   - `## Libraries`: each, with the version picked, the newest available, and why.
   - `## PRs`: estimate the changed lines, tests included, for the front end, the back end with its data, and the infra (CI, build, deploy). Cut by size: one PR when the whole story fits the limit; otherwise the front end in one PR and the back end with the infra in another; when one of those is still over, front end, back end and infra each in its own. List each PR with its estimate and what it holds. When it is split, the PR holding the infra goes first if the others need it, and the front end is built against a stubbed back end: give the stub's contract, what each stubbed call takes and returns. Where the interface isn't a front end (for example a library's functions or a tool's commands), that interface takes the front end's place.
   - `## Tests`: for each package, the tests at its exported surface, each package a black box at that surface, each test with the scenario numbers it serves.
   - `Defaults taken:`, if any.
6. Evaluate the design against each `## Think` question, and change any part that fails one. Answer each question in one line that says what it led you to change, or that nothing changed. When revising, evaluate only the parts the markup changed.
7. Write the design as `<story>.design.md` beside the story. Return where it is, as a draft for approval, each question with its pick, and the Think answers apart from it.
