---
name: write-requirements
description: Turn what people said the app should do and the design of what's being built into a draft of the app's requirements file, returned to the caller with its open questions. Use when `appz:build-app` runs its first step, and whenever an app's requirements are drafted.
---

# App requirements

## In
- What people said the app should do, in their own wording, in the order it was said, with the date and time of each thing. What people said is marked apart from anything AI added.
- The design of what's being built: its interface, in whatever form people or code use it (screens, endpoints, commands, functions), each part at a link or path a story can point to, and the rules, numbers and limits behind it. An interface that already runs, live or in code, counts.
- The `skillz:settle-question` skill.

## Out
- The draft requirements file at `<project>/data/requirements.md`, and the questions from `skillz:settle-question`, each with its pick, returned to the caller.
- The Think answers, one line per question, kept apart from the work, returned to the caller.

## Think
- Where did a person say this?
- If no one said it, would they be surprised it's missing? Then AI adds it.
- Would they ask "why is this here?" Then it's out.

## Act
1. Read what people said and the design, and check each input against `## In` before anything else. If one is missing or falls short, return to the caller exactly what's missing and what it must contain.
2. Include what people said, what's needed for it to work, and what they'd plainly expect. Take every number, limit and rule from what people said or the designs, or as a marked default. Cover the cases and problems people or the designs raise. Write each requirement for the app, not for a test.
3. Settle questions with `skillz:settle-question`. Write in what the sources settle. Mark each default.
4. Group the requirements into sections by area, named in the vocabulary people used. Use technical terms only where people did.
5. Write each requirement as `**A1. <one plain sentence in the terms people used>.**`, then, where a person said it, `Said: "<shortest quote>" (<date, time>)`.
6. End a line added by AI with ` *`. Give its reason in a short list at the bottom.
7. Add a short list of the defaults taken.
8. Leave out Success lines: a requirement's test belongs in the story that builds it.
9. Return the draft and the questions from step 3, each with its pick, to the caller, and the Think answers apart from the draft.
