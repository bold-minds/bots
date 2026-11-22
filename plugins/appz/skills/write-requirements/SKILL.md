---
name: write-requirements
description: Turn what people said the app should do and an app's designs into the app's requirements file. Use when `appz:build-app` runs its first step, and whenever an app's requirements are drafted.
---

# App requirements

## In
- What people said the app should do, in their own wording, in the order it was said, with the date and time of each thing. What people said is marked apart from anything AI added.
- The app's design boards: every screen the app shows, as drawn.
- The app's design doc: what the screens do, and the rules, numbers and limits behind them.
- The `skillz:settle-question` skill.
- Make none of these inputs yourself. A default value inside a requirement is fine.

## Out
- The requirements file, drafted at `<project>/data/requirements.md`, then moved to the repo's `docs/product/requirements.md` once the owner approves it.

## Think
- Where did a person say this?
- If no one said it, would they be surprised it's missing? Then AI adds it.
- Would they ask "why is this here?" Then it's out.

## Act
1. Read what people said, the design boards and the design doc, and check each input against `## In` before anything else. If one is missing or falls short, stop and tell the owner exactly what to provide and what it must contain.
2. Include what people said, what's needed for it to work, and what they'd plainly expect. Take every number, limit and rule from what people said or the designs, or as a marked default. Cover the cases and problems people or the designs raise. Write each requirement for the app, not for a test.
3. Settle questions with `skillz:settle-question`. Write in what the sources settle. Mark each default.
4. Group the requirements into sections by area, named in the vocabulary people used. Use technical terms only where people did.
5. Write each requirement as `**A1. <one plain sentence in the terms people used>.**`, then, where a person said it, `Said: "<shortest quote>" (<date, time>)`.
6. End a line added by AI with ` *`. Give its reason in a short list at the bottom.
7. Add a short list of the defaults taken.
8. Write no Success lines. A requirement's test belongs in the story that builds it.
9. Show the owner the draft and the questions from step 3.
10. Once the owner approves the file, move it to `docs/product/requirements.md`.
