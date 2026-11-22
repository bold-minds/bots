---
name: build-app
description: Take an app's designs to shipped code by running each delivery step in order, one subagent per step. Use when asked to build an app, continue a build, start the next chunk, ship it, or say where a build stands or what's next.
---

# Build app

## In
- The owner's words about the app: what they want it to do, in their own wording, with the date and time they said each thing.
- The app's design boards: every screen the app shows, as drawn, each at a link a story can point to.
- The app's design doc: what the screens do, and the rules, numbers and limits behind them.
- The build's state: the current chunk, each story's current step and its status, and what each step produced. build-app makes and keeps it at `<project>/data/build-state.json`; on the first run there is none.

## Out
- The shipped app, chunk by chunk.
- `build-state.json`, current after every step.

## Steps
1. write-requirements
2. plan-chunks
3. write-stories
4. design-tech
5. build-story
6. verify-story
7. open-pr
8. ship-chunk

The plan cuts the requirements into chunks. Steps 3 to 8 run for one chunk, then the next chunk starts at step 3.

## Think
- What does the state file say is current?
- Does this step have everything its skill needs as input?
- What can run at the same time? Steps for different stories in a chunk can run side by side, and so can the parts of one story's build once its skeleton is in.
- Does anything need the owner?

## Act
1. Check every input against `## In` before anything else. Read the build's state for the current chunk, each story's step, and what each step produced; if there is none yet, create it. If the state is there but doesn't hold those, stop and tell the owner what it lacks. If the owner's words, the boards or the doc are missing or fall short, run `appz:design-app` for them. If `appz:design-app` isn't installed, stop and tell the owner exactly what to provide and what each must contain. Inputs come only from `appz:design-app` or the owner.
2. Load the step's skill, and any installed skill for that kind of work.
3. Brief one subagent per step: the inputs, the skills to follow (including `skillz:settle-question`), and where its skill says to write. Start independent steps at the same time. Leave each step's work to its subagent.
4. Run `skillz:check-work` at each handoff between steps.
5. Bring the owner only what `skillz:settle-question` sends them.
6. Update `build-state.json` when a step starts and when it ends: the step, the story, its status, and what it produced.
7. Go to the next step. After ship-chunk, start the next chunk at write-stories.
8. When the last chunk ships, tell the owner the app is done.
