---
name: write-stories
description: Turn requirements into one story per user action. Use when drafting or revising a chunk's stories.
---

# Stories

## In
- The requirements the chunk's stories build: each with its id, in the owner's terms, with inferred lines marked ` *`.
- The owner's words about the app: what they want it to do, in their own wording.
- The app's design boards for the screens those stories touch, each at a link a story can keep.
- The story being revised, if there is one.
- Make none of these inputs yourself. A default value inside a story is fine.

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
- Check each input against `## In` before anything else. If one falls short, or one other than the story being revised is missing, stop and tell the owner exactly what to provide and what it must contain.
- Include what the owner said, what's needed for it to work, and what they'd plainly expect.
- Title: the action, in the owner's words.
- `Shows:` one line, the happy path.
- `Design:` a link to the design board(s), kept for the life of the ticket.
- `## Journey`: the happy path as Given/When/Then.
- `## Scenarios`: numbered, with requirement id(s), ` *` if inferred, behaviour only.
- `## Changelog`: empty until approved.
- `Defaults taken:` under the story, if any.
