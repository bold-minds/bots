---
name: design-tech
description: Write and evaluate the technical design of one story, before any of its code is built, as a one-page draft kept beside the story for approval: the packages, functions, schema, routes, commands, events and libraries it adds or changes, how it is cut into PRs and what each holds, and the tests for every layer the story needs (unit, integration, end-to-end, performance, chaos), with how the app is started or called for them. Works for any interface: screens, endpoints, commands or library functions. Use once per story, after the story is written and before it is built, and when revising a story's design from the caller's markup.
---

# Design tech

## In
- The story: its Journey and its numbered scenarios, each with its requirement ids.
- The requirements the story builds: each with its id.
- The parts of the interface the story touches, in whatever form people or code use them (screens, endpoints, commands, library functions), designed or already running.
- The app's repo: its code, and its approved decisions (for example ADRs).
- The `skillz:settle-question` skill.
- Optional: the changed lines a PR aims to stay under, tests included. Default 400.
- Optional, when revising: the earlier design, and the caller's markup or answers on it.

## Out
- The design at `<story>.design.md`, in the story's folder with the story's base name: one page, in the form in `## Act`. Returned to the caller as a draft for approval, with where it is and the questions from `skillz:settle-question`, each with its pick.
- When revising, the change list: each line added or changed, each word or phrase it adds, drops or rewords against the earlier line, and the quote that asks for it, returned to the caller apart from the design.
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
3. Read the repo's code for what the story can reuse, and its decisions. Take the approved decisions as they are. Return a decision the repo marks proposed as a question via `skillz:settle-question`, never as a default; where the design rests on its pick, say so on that line (for example "pick for question 1").
4. Settle the other questions with `skillz:settle-question`. Write in what the sources settle. Mark each default. Return only what's left, each with its pick.
5. Write the design on one page, under these headings.
   - `## Packages and functions`: each package, function, type, test helper and piece of wiring it adds or changes, each with the scenario numbers it serves: digits only (for example `1, 3`), listing each scenario a part serves. No word such as Journey or all stands in place of numbers or beside them; a part that serves the Journey lists the numbered scenarios the Journey walks.
   - `## Schema, routes, commands and events`: each it adds or changes, each with the scenario numbers it serves, as digits only, by the same rule.
   - `## Libraries`: each, with the version picked, the newest available, and why.
   - `## PRs`: estimate the changed lines, tests included, for the front end, the back end with its data, and the infra (CI, build, deploy). When the repo has no CI or gate, the infra holds the standard checks, named so: about 10 lines, as only a few spots in their copied files are written. Only a part with changed lines gets a PR, so a part with none gets none. Cut by size: one PR when the whole story fits the limit; otherwise the front end in one PR and the back end with the infra in another; when one of those is still over, front end, back end and infra each in its own; a part still over stays one PR. List each PR with its estimate and what it holds. When it is split, the front end is built on a stubbed back end and comes before the back end that replaces it, and the design always gives the stub's contract: each stubbed call, what it takes and returns. The PR holding the infra goes first if the others need it. Where the interface isn't a front end (for example a library's functions or a tool's commands), that interface takes the front end's place. Say in each PR which layers' tests it holds. The E2E tests through the real interface go in the PR that makes the whole path real, the last one when the story is split; the front end's E2E tests against the stub may go in the front-end PR.
   - `## Tests`: the tests of each layer the story needs, under the layer's name, each test with the scenario numbers it serves, as digits only, by the same rule.
     - Unit, every story: for each package, the tests at its exported surface, each package a black box at that surface.
     - Integration, when the story's parts talk to each other or to a database, API or file: tests that run those parts together against the real one.
     - E2E, every story: through the real interface as people or code use it (a browser for screens, HTTP for an API, the command for a tool, a small calling program for a library), one test per numbered scenario and one for the Journey. Name the command that starts the app or the program that calls it (for example a Taskfile task) and what it needs to run, so it can be built and anyone can run it.
     - Perf, only when a requirement or the design gives a speed or load number: a test against each such number, quoting it.
     - Chaos, for each scenario where something the story depends on fails (a dependency down, signed out, a full disk): a test that breaks that dependency for real and checks what the person or caller gets.
   - `Defaults taken:`, if any.
6. Evaluate the design against each `## Think` question, and change any part that fails one. Check that every part and test under `## Packages and functions`, `## Schema, routes, commands and events` and `## Tests` ends with scenario numbers only, no Journey or all; give each the numbers it serves, and when writing a new design drop a part no scenario needs. Answer each question in one line that starts with what it led you to change, or with "Nothing changed", then says why. When revising, evaluate only the parts the markup changed, and change only lines the markup touches or those changes force.
7. Write the design to its file and run `python3 <the folder holding this SKILL.md>/scripts/check-design.py <design>` (when revising, copy the earlier design aside before changing it, add `--earlier <the copy>` so only the lines added or changed are checked, and delete the copy once done, so the repo holds only the revised design). Fix each FAIL as it says (a line's own scenario numbers go at its end, any note before them, in place of any Journey or all), and run it again until it prints `FAILS: 0`.
8. Check that each unit and integration test the design adds or changes reaches only what its packages export, and rewrite one that doesn't to go through the exported part that uses it. In a new design, check that `## Tests` holds each layer step 5 calls for: an E2E test for each numbered scenario and for the Journey, each through the real interface step 5 names (a browser for screens) in the PR that makes the whole path real, with the command that starts the app or the program that calls it; a chaos test for each scenario where a dependency fails; and a perf test for each speed or load number a requirement or the design gives.
9. When revising, set each line of the earlier design beside its line in the revision, if it has one. For each earlier line that named a replaced part, make that line in the revision name the part that takes its place where the replaced part stood (when the line is gone, another line in the same section), new or already in the repo, as the repo or the markup gives it, keeping the earlier line's other words where they still hold. A PR line names it too, even when the part adds no changed lines: the PR is where its use is built.
10. When revising, for each word or phrase an added or changed line adds, drops or rewords (the `words` lines step 7's run printed list them), quote what asks for that word: the markup's or an answer's words for it, the replacing part as step 9 named it, or earlier words that would be false or name a replaced part if kept, which cover only the fewest words that correct them. Undo each word with no such quote; the rest, each with its quote, is the change list.
11. Write the design as `<story>.design.md` beside the story. Return where it is, as a draft for approval, each question with its pick, the change list when revising, and the Think answers apart from it.
