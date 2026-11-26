---
name: build-app
description: Take an app's design to shipped code by running each delivery step in order, one subagent per step, while taking every outward action itself (pushing branches, opening and merging PRs, running the releases), and write a build report at each milestone's end on where the process worked and where it didn't. "App" means any software people or code use: an app, a service, a library. Use when asked to build an app, continue a build, start the next milestone, ship it, or say where a build stands or what's next.
---

# Build app

## In
- What people said the app should do, in their own wording, in the order it was said, with the date and time of each thing. What people said is marked apart from anything AI added.
- The design of what's being built: its interface, in whatever form people or code use it (screens, endpoints, commands, functions), each part at a link or path a story can point to, and the rules, numbers and limits behind it. An interface that already runs, live or in code, counts.
- The app's repo: where the code and the approved requirements go, and, by the time the first PR is opened, its remote, where branches are pushed and PRs opened.
- A folder for the build's own files: one the build can read and write.
- The build state: the current milestone, each story's current step and its status, and what each step produced. On the first run there is none.
- The caller's answers, approvals, markups and rejections since the last run. May be empty.
- The skills the build runs: the step skills named in `## Steps`, `skillz:check-work` and `skillz:settle-question`.

## Out
- The shipped app in the repo, milestone by milestone: each PR pushed and opened, then merged once the caller approves it, and each milestone released.
- The approved requirements file at the repo's `docs/product/requirements.md` by default, or where the caller says.
- The build state at `data/build-state.json` in the build folder, current after every step, holding who merges PRs.
- The build log at `data/build-log.jsonl` in the build folder: one record per step run and one per reply from the caller on a step's work, holding what steps 2 and 5 list.
- The milestone's contract at `data/contract-<milestone>.md` in the build folder, when its stories ran design-tech side by side.
- The build report at `data/build-report-<milestone>.md` in the build folder, written at each milestone's end, with its questions, each with its pick, returned to the caller.
- Where the build stands, when asked: the current milestone, each story's step and status, and what waits on the caller.
- The questions, each with its pick, the drafts that need approval, and each opened PR with its address for approval, returned to the caller.
- This skill's Think answers, one line per question, each in the form `<question> <what it found>, so <what it led the skill to do>.`, an answer that led to nothing saying so ("so nothing was done"): kept in the build log and returned to the caller with each return.
- That the app is done, when the last milestone ships.

## Steps
Each step runs in one subagent, on the model and effort named here.
1. `appz:write-requirements`: Sonnet, high. Per app.
2. `appz:plan-milestones`: Sonnet, medium. Per app.
3. `appz:write-stories`: Sonnet, high. Per milestone.
4. `appz:design-app`: Sonnet, high. Per story with an interface (screens, endpoints, commands or functions), and once per app before step 1 when there is no design and no interface already running.
5. `appz:design-tech`: Sonnet, high. Per story. When a milestone's stories run it side by side, one more subagent writes the milestone's contract, as Act step 7 says: Sonnet, high. Per milestone.
6. `appz:build-story`: Sonnet, high. Per PR the story's design lists.
7. `appz:write-pr`: Sonnet, medium. Per story, once its PRs are built.
8. `appz:ship-milestone`: Sonnet, medium. Per milestone: before release, and after each release step.

The plan cuts the requirements into milestones. Steps 1 and 2 run once for the app. For each milestone, step 3 runs, then steps 4 to 7 run for each of its stories, then step 8 runs; the next milestone starts at step 3. Subagents write and check only; build-app takes every outward action itself, from the main session: it pushes branches, opens and merges PRs, and runs the release commands.

## Think
- What does the build state say is current?
- Does this step have everything its skill needs as input?
- What can run at the same time?
- Does anything need the caller?
- Is this an outward action (a push, a PR, a merge, a release), and is it taken here rather than by a subagent?
- At a milestone's end: which problems came back more than once, and which skill line would stop each?

## Act
1. If there is no build state, create it empty before recording anything. Check every input against `## In` before anything else. If the repo or the build folder is missing, return to the caller which one, and that it must be a place the build can read and write. If a skill from `## In` isn't installed, first record the caller's answers and approvals in the build state, so a return doesn't lose them, and change nothing else in it, then return to the caller each one that is missing, each with the work it must do in words, not only its step number. If what people said is missing or falls short, return to the caller exactly what to provide and what it must contain. If there is no design and no interface already running, live or in code, run `appz:design-app` for the app before step 1; otherwise read the interface from what runs. Once the other inputs pass, read the build state for the current milestone, each story's step, and what each step produced. If it doesn't hold those, return to the caller what it lacks.
2. Record the caller's answers, approvals, markups and rejections in the build state, and append each to the build log as one JSON line: `"record": "caller"`; `kind` (`answer`, `approval`, `markup` or `rejection`); `step`; `for` (the story, the milestone, or `app`); `round` or `pr` when it is on one; the `question` and `answer`, or the `markup`; and for an answer, `a_source_said_it`: the line of that step's inputs that already said it, quoted, or null. Step 1 does this before any return it makes for a missing skill. This run carries each approval; build-app never waits for it.
   - When they approve the requirements draft, move it to the repo's requirements file.
   - When they approve a technical design, mark it approved at its top (`Status: approved`).
   - When they approve a PR, merge it as step 9 says.
3. When asked where the build stands or what's next, return from the build state the current milestone, each story's step and status, and what waits on the caller, and this skill's Think answers apart from it, as with every return; answer the input question with what step 1's check found. Then stop.
4. Load the step's skill, and any installed skill for that kind of work.
5. Update the build state when a step starts and when it ends: the step, the story, its status, and what it produced. Keep its milestones as `milestones`, each with `id`, `name`, `status`, `stories` and, once written, `contract` (its path), each story with `id`, `step`, `status` and `produced`. When a step ends, append one JSON line to the build log: `"record": "step"`; `step` (`contract` for the milestone's contract); `for` (the story, the milestone, or `app`); `round` for design-app, `pr` for build-story; `model` and `effort`; `duration_ms` and `tokens`, as the subagent's completion gives them; `think`, the Think answers its subagent returned; `check_misses_first`, each miss check-work found first, with its `kind` and `where`; `fix_round`, true or false; `misses_left` after it, in the same form; `questions`, each it returned to the caller; for build-story, `estimate_lines` (the design's estimate for the PR) and `lines` (the lines it changed); for ship-milestone, `failing_scenarios` and `released_to`; and `own_think`, this skill's own Think answers for that step, one line per question.
6. Brief one subagent per step, on the model and effort `## Steps` names for it: only the inputs its step skill's `## In` lists, the skills to follow (including `skillz:settle-question`), where its skill says to write, and to return its Think answers apart from the work. Start independent steps at the same time: steps for different stories in a milestone can run side by side, and so can a story's PRs once the PR they build on is in. In a story, start design-tech once the caller approves its design-app round, and write-pr once all its PRs are built. Leave each step's work to its subagent, and every push, PR, merge and release to this skill. If a subagent returns that an input is missing, return that to the caller with what it must contain.
7. Run `skillz:check-work` at each handoff between steps, with the step's Think answers. Send the misses back to the step's subagent to fix once, check once more, and return any misses still left to the caller with the work, instead of looping.
   - When a milestone's stories have run design-tech side by side, once every design has returned and before any is checked, start one subagent to write the milestone's contract at `data/contract-<milestone>.md` in the build folder. Brief it with all the milestone's designs and stories, where to write, and what the contract holds:
     - The stories' build order, by what each needs from the others.
     - For each part more than one design adds, changes or names (package, type, function, store step and table, route, event, config key and its unit, test helper): one name, the story that owns it (the earliest in build order with a scenario that needs it), and what each later story adds.
     - One numbered list of the milestone's questions, each with its pick and the stories whose lines rest on it, in place of each design's own numbering. Anything hard to undo goes in this list, never settled in the contract.
   - Then run check-work on each design, and give each design's subagent the contract with check-work's misses as its one fix round; check once more as this step says.
   - Return the contract's questions to the caller in place of each design's own.
8. When write-pr's work passes check-work, open the story's PRs from the main session, in the design's order. If the repo has no remote, return to the caller that it needs one, and push nothing. For each PR: push its branch to the remote, open the PR on the host against the branch it builds on with write-pr's title and description (for example `gh pr create --base <base> --head <branch> --title <title> --body-file <file>`), and record its address in the build state. Return each PR's address to the caller for approval.
9. Merge each PR the caller approves, from the main session, on the host (for example `gh pr merge <address>`), and record the merge in the build state. Who merges is recorded in the build state: build-app, once the caller approves each PR (default), unless the caller says they merge; then read each merge from the host instead. Once every PR of the milestone's stories is merged, run ship-milestone before release.
10. When ship-milestone returns the release steps, run each from the main session, in order, each followed by the ship-milestone call that checks it: for a service or app, the test release, and the live release only once the call after the test release returns "release live", its word that the E2E suite passed on test; for a library, the tag and the publish. When ship-milestone returns a failure (a PR not merged, the gate red, "do not release live", a failing scenario), release nothing more, and return to the caller what failed, with ship-milestone's output.
11. When ship-milestone's call after the last release step returns, that the milestone shipped or with its failing scenarios, write the build report: run `python3 <the folder holding this SKILL.md>/scripts/build-report.py <build folder> <milestone id>`. It writes `data/build-report-<milestone id>.md` in the build folder from the build log and the build state only:
    - Per step: how many runs, time, tokens, model and effort.
    - Where it worked: steps that passed check-work the first time; designs and stories approved without markup; PR sizes near the design's estimate.
    - Where it didn't: check-work misses per step, and whether the same kind recurs across stories, with one example each; fix rounds; misses left after the one fix round; the caller's markups and rejections per step; the questions sent to the caller, and how many a source could have answered; each PR whose lines are off the design's estimate by more than half, with both numbers; E2E failures on test or live after ship.
    - Last, each recurring problem as a question, its pick left to fill.
    Replace each `Pick: <fill ...>` with the step skill from `## Steps` and the line in it to change, quoted, then run the script again with `--check` until it prints `PICKS LEFT: 0`. Return to the caller where the report is and its questions, each with its pick.
12. Return to the caller each question `skillz:settle-question` returns with its pick, and each draft that needs approval, such as write-requirements' draft. Return this skill's Think answers apart from them, as with every return. Stop work that depends on the answers; the next run picks up from the build state.
13. Go to the next step that doesn't wait on the caller.
14. When the last milestone ships, return to the caller that the app is done.
