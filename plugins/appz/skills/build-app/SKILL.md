---
name: build-app
description: Take an app's designs to shipped code by running each delivery step in order, one subagent per step. Use when asked to build an app, continue a build, start the next chunk, ship it, or say where a build stands or what's next.
---

# Build app

## In
- What people said the app should do, in their own wording, in the order it was said, with the date and time of each thing. What people said is marked apart from anything AI added.
- The app's design boards: every screen the app shows, as drawn, each at a link a story can point to.
- The app's design doc: what the screens do, and the rules, numbers and limits behind them.
- The build's state: the current chunk, each story's current step and its status, and what each step produced. On the first run there is none.

## Out
- The shipped app, chunk by chunk.
- The approved requirements file at the repo's `docs/product/requirements.md`.
- The build's state at `<project>/data/build-state.json`, current after every step.
- The build log at `<project>/data/build-log.jsonl`: one record per step, holding that step's Think answers and this skill's own for that step.
- The questions and drafts that need the caller, returned to the caller.

## Steps
Each step runs in one subagent, on the model and effort named here.
1. write-requirements: Opus, high
2. plan-chunks: Sonnet, medium
3. write-stories: Sonnet, high
4. design-tech: Opus, high
5. build-story: Sonnet, high
6. verify-story: Sonnet, medium
7. open-pr: Haiku, low
8. ship-chunk: Sonnet, medium

The plan cuts the requirements into chunks. Steps 3 to 8 run for one chunk, then the next chunk starts at step 3.

## Think
- What does the state file say is current?
- Does this step have everything its skill needs as input?
- What can run at the same time? Steps for different stories in a chunk can run side by side, and so can the parts of one story's build once its skeleton is in.
- Does anything need the caller?

## Act
1. Check every input against `## In` before anything else. Read the build's state for the current chunk, each story's step, and what each step produced; if there is none yet, create it. If the state is there but doesn't hold those, return to the caller what it lacks. If what people said, the boards or the doc are missing or fall short, run `appz:design-app` for them. If `appz:design-app` isn't installed, return to the caller exactly what to provide and what each must contain.
2. Load the step's skill, and any installed skill for that kind of work.
3. Brief one subagent per step, on the model and effort `## Steps` names for it: the inputs, the skills to follow (including `skillz:settle-question`), where its skill says to write, and to return its Think answers apart from the work. Start independent steps at the same time. Leave each step's work to its subagent.
4. Run `skillz:check-work` at each handoff between steps, with the step's Think answers. Send any misses back to the step's subagent to fix, then check again.
5. Return to the caller only the questions `skillz:settle-question` returns, each with its pick.
6. When write-requirements returns its draft and questions, return them to the caller. Once the caller approves the file, move it from `<project>/data/requirements.md` to the repo's `docs/product/requirements.md`.
7. Update `build-state.json` when a step starts and when it ends: the step, the story, its status, and what it produced. When a step ends, append one record to `build-log.jsonl`: the step, the story, the Think answers its subagent returned, and this skill's own Think answers for that step, one line per question.
8. Go to the next step. After ship-chunk, start the next chunk at write-stories.
9. When the last chunk ships, return to the caller that the app is done.
