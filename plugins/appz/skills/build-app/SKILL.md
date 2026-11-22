---
name: build-app
description: Take an app's design to shipped code by running each delivery step in order, one subagent per step. "App" means any software people or code use: an app, a service, a library. Use when asked to build an app, continue a build, start the next milestone, ship it, or say where a build stands or what's next.
---

# Build app

## In
- What people said the app should do, in their own wording, in the order it was said, with the date and time of each thing. What people said is marked apart from anything AI added.
- The design of what's being built: its interface, in whatever form people or code use it (screens, endpoints, commands, functions), each part at a link or path a story can point to, and the rules, numbers and limits behind it. An interface that already runs, live or in code, counts.
- The app's repo: where the code and the approved requirements go.
- A folder for the build's own files: one the build can read and write.
- The build state: the current milestone, each story's current step and its status, and what each step produced. On the first run there is none.
- The caller's answers and approvals since the last run. May be empty.
- The skills the build runs: the step skills named in `## Steps`, `skillz:check-work` and `skillz:settle-question`.

## Out
- The shipped app in the repo, milestone by milestone.
- The approved requirements file at the repo's `docs/product/requirements.md` by default, or where the caller says.
- The build state at `data/build-state.json` in the build folder, current after every step.
- The build log at `data/build-log.jsonl` in the build folder: one record per step, holding that step's Think answers and this skill's own for that step.
- Where the build stands, when asked: the current milestone, each story's step and status, and what waits on the caller.
- The questions, each with its pick, and the drafts that need approval, returned to the caller.
- This skill's Think answers, one line per question, each saying what it led the skill to do: kept in the build log and returned to the caller with each return.
- That the app is done, when the last milestone ships.

## Steps
Each step runs in one subagent, on the model and effort named here.
1. `appz:write-requirements`: Opus, high. Per app.
2. `appz:plan-milestones`: Sonnet, medium. Per app.
3. `appz:write-stories`: Sonnet, high. Per milestone.
4. `appz:design-tech`: Opus, high. Per story.
5. `appz:build-story`: Sonnet, high. Per story.
6. `appz:verify-story`: Sonnet, medium. Per story.
7. `appz:open-pr`: Haiku, low. Per story.
8. `appz:ship-milestone`: Sonnet, medium. Per milestone.

The plan cuts the requirements into milestones. Steps 1 and 2 run once for the app. For each milestone, step 3 runs, then steps 4 to 7 run for each of its stories, then step 8 runs; the next milestone starts at step 3.

## Think
- What does the build state say is current?
- Does this step have everything its skill needs as input?
- What can run at the same time?
- Does anything need the caller?

## Act
1. Check every input against `## In` before anything else. If the repo or the build folder is missing, return to the caller which one, and that it must be a place the build can read and write. If a skill from `## In` isn't installed, return to the caller each one that is missing and the work it must do. If what people said is missing or falls short, return to the caller exactly what to provide and what it must contain. If there is no design and no interface already running, live or in code, run `appz:design-app`, or, if it isn't installed, return to the caller exactly what to provide and what it must contain; otherwise read the interface from what runs. Once the other inputs pass, read the build state for the current milestone, each story's step, and what each step produced; if there is none yet, create it. If it is there but doesn't hold those, return to the caller what it lacks.
2. Record the caller's answers and approvals in the build state. When they approve the requirements draft, move it to the repo's requirements file. This run carries the approval; build-app never waits for it.
3. When asked where the build stands or what's next, return from the build state the current milestone, each story's step and status, and what waits on the caller. Then stop.
4. Load the step's skill, and any installed skill for that kind of work.
5. Update the build state when a step starts and when it ends: the step, the story, its status, and what it produced. When a step ends, append one record to the build log: the step, the story, the Think answers its subagent returned, and this skill's own Think answers for that step, one line per question.
6. Brief one subagent per step, on the model and effort `## Steps` names for it: only the inputs its step skill's `## In` lists, the skills to follow (including `skillz:settle-question`), where its skill says to write, and to return its Think answers apart from the work. Start independent steps at the same time: steps for different stories in a milestone can run side by side, and so can the parts of one story's build once its skeleton is in. Leave each step's work to its subagent. If a subagent returns that an input is missing, return that to the caller with what it must contain.
7. Run `skillz:check-work` at each handoff between steps, with the step's Think answers. Send the misses back to the step's subagent to fix once, check once more, and return any misses still left to the caller with the work, instead of looping.
8. Return to the caller each question `skillz:settle-question` returns with its pick, and each draft that needs approval, such as write-requirements' draft. Return this skill's Think answers apart from them, as with every return. Stop work that depends on the answers; the next run picks up from the build state.
9. Go to the next step that doesn't wait on the caller.
10. When the last milestone ships, return to the caller that the app is done.
