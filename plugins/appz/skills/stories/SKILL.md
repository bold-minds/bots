---
name: stories
description: Turn requirements into one story per user action. Use when drafting or revising a chunk's stories.
---

# Stories

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
- Include what the owner said, what's needed for it to work, and what they'd plainly expect.
- Title: the action, in the owner's words.
- `Shows:` one line, the happy path.
- `Design:` a link to the design board(s), kept for the life of the ticket.
- `## Journey`: the happy path as Given/When/Then.
- `## Scenarios`: numbered, with requirement id(s), ` *` if inferred, behaviour only.
- `## Changelog`: empty until approved.
- `Defaults taken:` under the story, if any.
