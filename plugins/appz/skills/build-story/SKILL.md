---
name: build-story
description: Build one PR of a story from its approved technical design, in its own git worktree: every test the design lists for that PR first, in every layer it names (unit and integration at each package's exported surface, end-to-end through the real interface with the design's start command made real, perf against the design's number, chaos breaking a dependency for real), each seen failing, then the code until they pass and the full gate, running every layer, is green, committed locally and never pushed. Works for any interface: screens, endpoints, commands or library functions, and for a PR holding front end, back end, infra or any mix. Use once per PR the story's design lists, after the design is approved, whenever a designed story or one of its PRs is to be built.
---

# Build story

## In
- The story's technical design, marked approved: its packages and functions, its schema, routes, commands and events, its libraries, its `## PRs` with what each PR holds and, when it is split, the stub's contract (what each stubbed call takes and returns), and its `## Tests`: each layer's tests, and the command that starts the app or the program that calls it for the E2E tests.
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
- The questions from `skillz:settle-question`, each with its pick, and each default taken below the design, with the design line it falls under.
- This skill's Think answers, one line per question in step 8's form: the verdict, then only quotes, each with where it is. Kept apart from the work, and followed by the command that checked them and what it printed.

## Think
- Does each test serve a scenario?
- Does each test check what its scenario says?
- Does the code do only what the design lists?
- Does this PR build and test on its own?
- Did anything need a design change?
- Does every quote and claim in these answers check out by command?

## Act
1. Check each input against `## In` before anything else. If the design isn't marked approved, return to the caller that it must be marked approved before it is built, and build nothing. If another input is missing or falls short, return to the caller exactly what's missing and what it must contain.
2. Read the design's `## PRs` entry for this PR: what it holds, which PR it builds on, and the stub's contract when the design is split. Read its `## Tests` for this PR's tests in every layer, the scenarios each serves, and the command that starts the app or the program that calls it.
3. Throughout the build, when the work needs any line of the design changed (a package, function, schema, route, command, event, library, or the stub's contract), settle it with `skillz:settle-question` and return it to the caller as a question with its pick. Stop any work that fixes or uses the line in question; go on only with work that holds for every answer, then with steps 8 to 12, which run in full on a stopped build too. Below that level, decide yourself.
4. Make the PR's branch in its own git worktree: from the main branch for the first PR, from the branch of the PR it builds on otherwise.
5. Write every test `## Tests` lists for this PR, in every layer it names. Put each unit and integration test at its package's exported surface, each package a black box at its own surface. When this PR holds the design's start command or calling program, make it real first (for example a Taskfile task), so the E2E tests run the app as people or code use it and fail on what they check. Before writing any other code, run every test this PR adds, in every layer, and see each one fail on its own check in the output; for a test the stub already passes or that stops at its setup, see it fail on its own check against a stub changed for that run, the app still starting (for example one that returns wrong data, or creates what the setup needs but keeps nothing).
   - Perf: check against the number the design quotes.
   - Chaos: break the dependency for real (stop the database, revoke the sign-in, fill the disk, or the nearest real way in the repo), and check what the person or caller gets.
6. If the repo has no CI or gate and this PR holds the infra, add them, with a Taskfile (`Taskfile.yml`) as the task runner. Make the gate run every test layer this PR adds.
7. Write the code until the tests pass. When the design is split, build the front end against the stubbed back end, to the stub's contract; in the back-end PR, replace the stub with the real back end. Run the gate's fast checks (such as build, lint and the tests of the packages touched) while working.
8. Evaluate the work against each `## Think` question, and fix what fails one. Write the answers to a file beside the worktree, one line per question, in this form only: `<question> <verdict>: «<quote>» (<where>); «<quote>» (<where>)`, the verdict `Yes`, `No`, `Not reached` or `Changed <what>`. Every other word is a quote, so the answer claims only what its quotes show. A quote is one whole line of a file, where `<path>:<line>`, or of a command's output saved with the command as its first line, where ``<saved file>: `<command>` `` (for example `{ echo '<command>'; <command>; } > out.txt 2>&1; cat out.txt`); a where may end `, <test name>`. Quote:
   - Serve a scenario: each added test's `## Tests` line.
   - Check its scenario: each scenario's story line, then the test lines (assertions or comparisons) checking each step it names.
   - Only the design: each file changed against the base, committed or not, from a saved file list, beside the design line naming what it builds (a test file: its `## Tests` line; a dependency file such as `go.mod` or a lockfile: the Libraries line naming its library, its where ending `, <file> records <library>`). Remove a file with no such line, or settle it through step 3.
   - On its own: output lines showing the branch's base (for example `git merge-base --is-ancestor <base> HEAD && echo ancestor`), the build and each added test layer passing.
   - Design change: this PR's `## PRs` line, with an output line measuring each number it sets (such as a size); each design line not built as written, with the story or output line it can't meet. A number not met makes the verdict `Yes`, settled through step 3; questions and defaults go to step 12.
   - Not reached: what was checked and what stopped it.
   - The last question: `«FAILS: 0»` from step 9's final run.
9. Check the answers by command, whether or not the build was finished. Write a tests file beside them, one name per line of each test this PR adds, from a command against the base (for example `git diff <base> -- '*_test.go' | sed -n 's/^+func \(Test[A-Za-z0-9_]*\).*/\1/p'`). Run `python3 <the folder holding this SKILL.md>/scripts/check-answers.py <answers file> <tests file> <base> <worktree>`, saved as step 8 shows, which fails any text outside the form, any quote that isn't a whole line found where it says, any added test missing from either test answer and any changed file missing from the design-scope answer. Fix each FAIL and run it again until it prints `FAILS: 0`. Then confirm what a script can't judge: each test line checks the step of the scenario it is beside, and each design line names what its file builds.
10. Commit locally and leave the branch unpushed; opening the PR is a separate step.
11. Run the full gate once, at the end, with every test layer in it, and time it, its whole output printed and saved to a file beside the worktree. Run it in one command that starts with `test -z "$(git status --short)" && git rev-parse HEAD`, which stops when anything is uncommitted, and confirm the HEAD it prints is the last commit you return, so the gate ran on what was committed. At the same time, take the line counts from a command run against the branch it was cut from, for example `git diff --numstat <base>...HEAD`: split its rows into code files, test files and config files (the Taskfile, the CI workflow and any other build or CI config), and sum added and removed per group with a command (for example `awk` over the rows). Keep the commands and the numbers they gave; config is left out of the returned counts.
12. Return to the caller only what `## Out` lists. Start with the Think answers, apart from the work: the checked file's text copied in whole and unchanged into a fenced code block, so what is returned is what was checked, then step 9's last run of the check, command and output as printed, in a second block. Then give the branch and worktree, its commits, the gate result and how long it took, the code and test line counts as summed from the command's rows (config left out), with the command, each question with its pick, and each default taken below the design with the design line it falls under.
