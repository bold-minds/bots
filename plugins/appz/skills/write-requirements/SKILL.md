---
name: write-requirements
description: Turn what people said the app should do and the design of what's being built into a draft of the app's requirements file, returned to the caller with its open questions. Use whenever an app's requirements are drafted or revised.
---

# Write requirements

## In
- What people said the app should do, in their own wording, in the order it was said, with the date and time of each thing. What people said is marked apart from anything AI added.
- The design of what's being built: its interface, in whatever form people or code use it (screens, endpoints, commands, functions), each part at a link or path a story can point to, and the rules, numbers and limits behind it. An interface that already runs, live or in code, counts.
- A folder it can write the draft in.
- The `skillz:settle-question` skill.
- Optional, when revising: the current draft, and the caller's answers to its questions.

## Out
- The draft requirements file at `data/requirements.md` in that folder, with where it is, the ` *` lines with their reasons, the defaults taken, and the questions from `skillz:settle-question`, each with its pick, returned to the caller. Not the whole draft.
- The Think answers, one line per question, each saying what it led the skill to do, kept apart from the work, returned to the caller.

## Think
- Where did a person say this?
- If no one said it, would they be surprised it's missing?
- Would they ask "why is this here?"
- For each thing people make or keep: how is it made, changed, finished and found again, is it still there after closing, and does it need the things it can belong to?

## Act
1. Read what people said and the design, and check each input against `## In` before anything else. If one is missing or falls short, return to the caller exactly what's missing and what it must contain.
2. Include what people said, what's needed for it to work, and what they'd plainly expect. For each thing people make or keep, cover how it is made, changed, finished and found again, whether it is still there after closing or restarting, and whether it can exist without what it can belong to, each marked ` *` when no one said it. Put the ` *` mark last on a line, so a default line ends `(default) *`. When no one said it and they'd be surprised it's missing, add it. When they'd ask "why is this here?", leave it out. Take every number, limit and rule from what people said or the design, or as a marked default. Cover the cases and problems people or the design raise. Write each requirement for the app, not for a test.
   - Write each requirement as what the software does and how it behaves. Keep what people said as a requirement, including what they said about how it looks. Leave only the design's own look-only lines (layout, labels, colours, counts and marks on screen that no person said) in the design, not in requirements.
   - Take only design decisions that are approved. Return a decision the design marks proposed as a question via `skillz:settle-question`, not as a default.
   - Keep what people said should come later as a requirement; planning leaves it out of milestones. List what people called an idea or a thought, not as a requirement, in its own short section, `Not requirements yet`, with what they said.
3. When revising, apply the caller's answers to the current draft and keep each requirement's id: stories point to them.
4. Settle questions with `skillz:settle-question`. Write in what the sources settle. Mark each default.
5. Group the requirements into sections by area, named in the vocabulary people used. Use technical terms only where people did.
6. Write each requirement as `**A1. <one plain sentence in the terms people used>.**`, then, where a person said it, `Said: "<shortest quote>" (<date, time>)`. Where it comes from the design and not from what a person said, write `From: <link or path to that part of the design>` instead. The bold sentence says what its quote says, so each sentence can be confirmed against its quote.
7. End a line added by AI with ` *`. Give its reason in a short list at the bottom.
8. Add a short list of the defaults taken.
9. Return to the caller where the draft is, the ` *` lines with their reasons, the defaults taken, and the questions from step 4, each with its pick, and the Think answers apart from them. Not the whole draft.
