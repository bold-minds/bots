---
name: build
description: Take an app's designs to shipped code by running each delivery step in order, one subagent per step. Use when asked to build an app, continue a build, start the next chunk, ship it, or say where a build stands or what's next.
---

# Build app

## In
- The app's design boards, its design doc, and the owner's words (`<project>/data/owner_words.md`).
- The build's state: `<project>/data/build-state.json`. On the first run there is none; create it.

## Out
- The shipped app, chunk by chunk.
- `build-state.json`, current after every step.

## Steps
1. requirements
2. plan
3. stories
4. tech-design
5. build
6. verify
7. pr
8. ship

The plan cuts the requirements into chunks. Steps 3 to 8 run for one chunk, then the next chunk starts at step 3.

## Think
- What does the state file say is current?
- Does this step have everything its skill needs as input?
- What can run at the same time? Steps for different stories in a chunk can run side by side, and so can the parts of one story's build once its skeleton is in.
- Does anything need the owner?

## Act
1. Read `build-state.json` for the current chunk, the current step of each story, and what each step produced.
2. If an input is missing, run `appz:design` for it. If `appz:design` isn't installed, stop and tell the owner exactly which inputs to provide. Inputs come only from `appz:design` or the owner.
3. Load the step's skill, and any installed skill for that kind of work.
4. Brief one subagent per step: the inputs, the skills to follow (including `skillz:ask-or-decide`), and where its skill says to write. Start independent steps at the same time. Leave each step's work to its subagent.
5. Run `skillz:check` at each handoff between steps.
6. Bring the owner only what `skillz:ask-or-decide` sends them.
7. Update `build-state.json` when a step starts and when it ends: the step, the story, its status, and what it produced.
8. Go to the next step. After step 8, start the next chunk at step 3.
9. When the last chunk ships, tell the owner the app is done.
