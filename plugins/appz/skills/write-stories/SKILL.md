---
name: write-stories
description: Turn requirements into one story per action someone or something takes through the interface. Use when drafting or revising a chunk's stories.
---

# Stories

## In
- The requirements the chunk's stories build: each with its id, in the terms people used, with lines added by AI marked ` *`.
- What people said the app should do, in their own wording, in the order it was said. What people said is marked apart from anything AI added.
- The design of what's being built, for the parts those stories touch: the interface, in whatever form people or code use it (screens, endpoints, commands, functions), each part at a link or path a story can point to, and the rules, numbers and limits behind it. An interface that already runs, live or in code, counts.
- The story being revised, if there is one.

## Out
- The chunk's stories, one per action someone or something takes through the interface, each in the form below, and any questions they raise, each with a pick, returned to the caller.
- The Think answers, one line per question, kept apart from the work, returned to the caller.

## Think
- What single action is this?
- What's the happy path?
- What else does it obviously need?
- What will obviously go wrong, given those? Where several causes lead to the same trouble, write one broad rule.
- Does it behave differently the first time, the next time, or after something else?
- Which other stories affect this one?
- Is any of it how the interface looks or is shaped?
- Over about ten scenarios: is it still one action?

## Act
1. Check each input against `## In` before anything else. If one falls short, or one other than the story being revised is missing, return to the caller exactly what's missing and what it must contain.
2. Include what people said, what's needed for it to work, and what they'd plainly expect.
3. Title: the action, in the words people used.
4. `Shows:` one line, the happy path.
5. `Design:` a link or path to the part of the interface the story touches, kept for the life of the ticket. Put how the interface looks or is shaped in the design.
6. `## Journey`: the happy path as Given/When/Then.
7. `## Scenarios`: numbered, with requirement id(s), ` *` if added by AI, behaviour only.
8. `## Changelog`: empty until approved.
9. `Defaults taken:` under the story, if any.
10. Return the stories, and each question that needs deciding with a pick, to the caller, and the Think answers apart from the stories.
