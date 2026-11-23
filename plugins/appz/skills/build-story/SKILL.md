---
name: build-story
description: Build one PR of a story from its approved technical design, in its own git worktree: the tests the design lists for that PR first, at each package's exported surface, seen failing, then the code until they pass and the gate is green, committed locally and never pushed. Works for any interface: screens, endpoints, commands or library functions, and for a PR holding front end, back end, infra or any mix. Use once per PR the story's design lists, after the design is approved, whenever a designed story or one of its PRs is to be built.
---

# Build story

## In
- The story's technical design, marked approved: its packages and functions, its schema, routes, commands and events, its libraries, its `## PRs` with what each PR holds and, when it is split, the stub's contract (what each stubbed call takes and returns), and its `## Tests`.
- The story: its Journey and its numbered scenarios.
- The app's repo, with its gate (the checks every change must pass, such as CI) if it has one.
- Which PR to build, named as in the design's `## PRs`. One PR may hold the front end, the back end and the infra; a PR of a split design holds its part.
- For a PR that builds on another: that PR's branch.
- The `skillz:settle-question` skill.

## Out
Returned to the caller:
- The PR's branch and the git worktree it was built in, with its commits, committed locally and not pushed.
- The gate result, and how long the full gate took.
- The code lines and the test lines changed in this PR, counted apart, config left out (the Taskfile, the CI workflow and any other build or CI config), summed from the rows the counting command gives, with the command.
- The questions from `skillz:settle-question`, each with its pick.
- This skill's Think answers, one line per question, each naming what it looked at (the test, file, function or line) and what it found, or the change it made; where nothing was built, each names what was checked and what stopped the work. Kept apart from the work.

## Think
- Does each test serve a scenario?
- Does the code do only what the design lists?
- Does this PR build and test on its own?
- Did anything need a design change?

## Act
1. Check each input against `## In` before anything else. If the design isn't marked approved, return to the caller that it must be marked approved before it is built, and build nothing. If another input is missing or falls short, return to the caller exactly what's missing and what it must contain.
2. Read the design's `## PRs` entry for this PR: what it holds, which PR it builds on, and the stub's contract when the design is split. Read its `## Tests` for this PR's tests, and the scenarios each serves.
3. Throughout the build, when the work needs any line of the design changed (a package, function, schema, route, command, event, library, or the stub's contract), settle it with `skillz:settle-question` and return it to the caller as a question with its pick. Stop any work that fixes or uses the line in question; go on only with work that holds for every answer. Below that level, decide yourself.
4. Make the PR's branch in its own git worktree: from the main branch for the first PR, from the branch of the PR it builds on otherwise.
5. Write the tests `## Tests` lists for this PR, each at its package's exported surface, each package a black box at its own surface. Before writing any code, run them and see each one fail; for a test the stub already passes, see it fail with the stub's behaviour removed.
6. If the repo has no CI or gate and this PR holds the infra, add them, with a Taskfile (`Taskfile.yml`) as the task runner.
7. Write the code until the tests pass. When the design is split, build the front end against the stubbed back end, to the stub's contract; in the back-end PR, replace the stub with the real back end. Run the gate's fast checks (such as build, lint and the tests of the packages touched) while working.
8. Evaluate the work against each `## Think` question, and fix what fails one. Answer each in one line that names what you looked at (the test, file, function or line) and what you found, or the change you made. Where nothing was built, name what you checked and what stopped the work.
9. Commit locally. Never push; opening the PR is a separate step.
10. Run the full gate once, at the end, and time it. At the same time, take the line counts from a command run against the branch it was cut from, for example `git diff --numstat <base>...HEAD`: split its rows into code files, test files and config files (the Taskfile, the CI workflow and any other build or CI config), and sum added and removed per group. Keep the command and the numbers it gave; config is left out of the returned counts.
11. Return to the caller the branch and worktree, its commits, the gate result and how long it took, the code and test line counts as summed from the command's rows (config left out), with the command, each question with its pick, and the Think answers, each naming what it looked at and found, or its change, apart from the work.
