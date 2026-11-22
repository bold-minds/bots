---
name: write-stories
description: Turn requirements into one story per user action. Use when drafting or revising a chunk's stories.
---

# Stories

## In
- The requirements the chunk's stories build: each with its id, in the terms people used, with lines added by AI marked ` *`.
- What people said the app should do, in their own wording, in the order it was said. What people said is marked apart from anything AI added.
- The app's design boards for the screens those stories touch, each at a link a story can keep.
- The story being revised, if there is one.

## Out
- The chunk's stories, one per user action, each in the form below, and any questions they raise, each with a pick, returned to the caller.

## Think
- What single action is this?
- What's the happy path?
- What else does it obviously need?
- What will obviously go wrong, given those? Where several causes lead to the same trouble, write one broad rule.
- Does it behave differently the first time, the next time, or after something else?
- Which other stories affect this one?
- Is any of it look and feel? Put that in the design.
- Over about ten scenarios: is it still one action?

## Act
- Check each input against `## In` before anything else. If one falls short, or one other than the story being revised is missing, return to the caller exactly what's missing and what it must contain.
- Include what people said, what's needed for it to work, and what they'd plainly expect.
- Title: the action, in the words people used.
- `Shows:` one line, the happy path.
- `Design:` a link to the design board(s), kept for the life of the ticket.
- `## Journey`: the happy path as Given/When/Then.
- `## Scenarios`: numbered, with requirement id(s), ` *` if added by AI, behaviour only.
- `## Changelog`: empty until approved.
- `Defaults taken:` under the story, if any.
- Return the stories, and each question that needs deciding with a pick, to the caller.
