---
name: write-pr
description: Write the title and description of each PR of one story from what is known about it (the story, its approved technical design, and each PR's branch, base, diff, gate result and line counts), so a reviewer gets a clear, accurate picture of what the PR does, what it holds and how long its checks take, grouped by area, every claim taken from those inputs. Writes only; pushing the branches and opening the PRs stay with the caller. Works for any interface (screens, endpoints, commands, library functions) and for a PR holding front end, back end, infra or any mix. Use once per story after its PRs are built and their gates have run, whenever a PR's title or description is to be written or rewritten.
---

# Write PR

## In
- The story: its Journey and its numbered scenarios.
- The story's technical design, marked approved: its packages and functions; its schema, routes, commands and events; its libraries, each with its version; its `## PRs`, with what each PR holds and, when it is split, the stub's contract (what each stubbed call takes and returns); its `## Tests`, by layer, each test with its scenario numbers.
- For each PR the design's `## PRs` lists:
  - its branch, and the branch it builds on;
  - its diff against that branch;
  - its gate result: the gate's output, pass or fail, and how long the full gate took;
  - its code lines and test lines, counted apart, with the command that gave them.

## Out
Returned to the caller; nothing is pushed or opened:
- Per PR, in the design's `## PRs` order: its branch, the branch it builds on, a title, and a description in Markdown, ready to paste.
- Each place the diff and the design differ (a version, a route, a name), as a question with both lines and a pick.
- This skill's Think answers, one line per question, each saying what it led the skill to do and, in quotes with where it is, the input text it rests on; where nothing was written, what was checked and what stopped the work. Kept apart from the work.

## Think
- Can a reviewer tell from the description what the PR does, what it holds and how long its checks take?
- Does every claim come from the story, the design, the diff, the gate output or the line counts?
- What would a reviewer assume this PR does that it doesn't?
- What does this PR make new: versions, routes, commands, docs, a pattern?
- Does each bullet change how the reviewer reads the PR?

## Act
1. Check each input against `## In` before anything else. If the design isn't marked approved, return to the caller that it must be marked approved, and write nothing. If another input is missing or falls short for any PR, return to the caller exactly what's missing, for which PR, and what it must contain, and write no description. Each fact comes from the inputs as given, so a missing one goes back to the caller rather than being made here. Return the Think answers with it, every question answered, a question about the description too, each in this form: `<question> Wrote nothing; stopped by <the missing input>. Checked: "<quoted line>" (<where it is>).` Quote, for example, the design's status line or the list of inputs given.
2. Read the design's `## PRs`: the order, what each PR holds, which PR it builds on, and the stub's contract when it is split. Read `## Tests` for each PR's tests: their layers and their scenario numbers. Take the scenarios a PR serves from the design lines for the parts and tests it holds.
3. Read each PR's diff. Sort its files into areas: front end, back end, data (schema, migrations), infra and CI (build, deploy, CI workflows, task runner), docs; test files go under `## Tests`. Where the interface isn't a front end (for example a library's functions or a tool's commands), that interface takes the front end's place. Only an area with changed files gets a section.
4. Write the title: what the PR adds, in a few words, under about 70 characters. For a split story, add the part and its place, for example `(1 of 2)`.
5. Write the description under these headings, each a few bullets, in this order:
   - `## What this does`: one or two sentences on what the PR does for the story, and `Scenarios:` with the numbers it serves, digits only.
   - `## Builds on`, for a PR that builds on another PR's branch: that branch and what it gave this PR. For a front end on a stub: the stub stands in for the back end, each stubbed call briefly, and the later PR that replaces it, by its title. For the PR that replaces the stub: the stub it replaces and that the contract is kept.
   - One section per area from step 3, named for it: what changed and what it does. Name each new route, command, event, schema change, exported function and doc, marked new.
   - `## Tests`: the layers it holds (unit, integration, E2E, perf, chaos), each with the scenario numbers it covers.
   - `## CI`: what triggers it, one line of what it checks, the result, the total time, and the one slow part, each as the diff or the gate output gives it. Copy the slow part word for word from its gate output line.
   - `## Dependencies`, when the diff adds, removes or changes one: grouped (for example runtime, dev and test, CI), naming only what's notable: each new one with its version, one pinned for a reason, one behind the newest and why, and what ships to users. Take versions from the diff: it is what ships.
   - A section named for each pattern the design or the diff shows is new to the repo, the first time it appears: what it is, why it was chosen, how it works here, and where to look (paths).
   - `## Not in this PR`, when a reviewer would assume something it doesn't do: what it doesn't do, and where that comes, if a later PR holds it.
   - `Size:` the code lines and test lines, with the command that gave them.
6. Check every statement in each description against the inputs: find the line in the story, the design, the diff, the gate output or the line counts that says it. Reword a statement to what its line says, with no share, cause, consequence or absence the line doesn't give; cut one with no line. A statement that something has or hasn't happened or been used (a CI run, a deploy, what ships to users) needs its own line too. Where the diff and the design differ, write the diff's version of it, and return the difference to the caller as a question with both lines and the pick: the diff's.
7. Check the level of detail: CI in one line of what it checks, with one total time; dependencies grouped, naming only the notable; each section a few bullets. Fold or cut what goes past that. A reviewer wants the picture, not every check.
8. Evaluate the work against each `## Think` question, and fix what fails one. Answer each in one line: what it led you to do, then the input text it rests on, in quotes with where it is (a design line, a diff line with its path, or a line of the gate output or the line counts). Give every answer at least one quote; for a question about the description's own detail, quote an input line you folded or cut, or one a section kept. Copy each quote from one line as it stands.
9. Return to the caller, per PR in the design's order, the branch, the branch it builds on, the title and the description; each difference between the diff and the design as a question with its pick; and the Think answers apart from the work.
