---
name: write-stories
description: Turn requirements into one story per action someone or something takes through the interface. Use when drafting or revising a milestone's stories.
---

# Write stories

## In
- The requirements the milestone's stories build: each with its id, in the terms people used, with lines added by AI marked ` *`.
- What people said the app should do, in their own wording, in the order it was said. What people said is marked apart from anything AI added.
- The design of what's being built, for the parts those stories touch: the interface, in whatever form people or code use it (screens, endpoints, commands, functions), each part at a link or path a story can point to, and the rules, numbers and limits behind it. An interface that already runs, live or in code, counts.
- A folder it can write the stories in.
- The `skillz:settle-question` skill.
- The story being revised, if there is one.
- Optional, when revising: the caller's answers or changes.

## Out
- The milestone's stories, one per action someone or something takes through the interface, each written as its own file in that folder, each in the form in `## Act`. The questions the sources didn't settle, each with a pick, returned to the caller.
- The Think answers, one line per question, each saying what it led the skill to do, kept apart from the work, returned to the caller.

## Think
- What single action is this?
- What's the happy path?
- What else does it obviously need?
- What will obviously go wrong, given those? Do several causes lead to the same trouble?
- Does it behave differently the first time, the next time, or after something else?
- Which other stories affect this one?
- Is any of it how the interface looks or is shaped?
- Over about ten scenarios: is it still one action?
- Did a number, limit or rule come from no one?

## Act
1. Check each input against `## In` before anything else. If one falls short, or one other than the story being revised is missing, return to the caller exactly what's missing and what it must contain.
2. Include what people said, what's needed for it to work, and what they'd plainly expect. Take every number, limit and rule from what people said or the design, or as a marked default.
3. When revising an approved story, apply the caller's answers, keep its scenario numbers, and add one Changelog line saying what changed.
4. Settle questions with `skillz:settle-question`. Write in what the sources settle. Mark each default. Return only what's left, each with its pick.
5. Title: the action, in the words people used.
6. `Shows:` one line, the happy path.
7. `Design:` a link or path to the part of the interface the story touches, kept for the life of the story. Put how the interface looks or is shaped in the design.
8. `## Journey`: the happy path as Given/When/Then.
9. `## Scenarios`: numbered, with requirement id(s), ` *` if added by AI, behaviour only.
   - For each thing that will obviously go wrong, write a scenario saying what they see and what to do (for example, sign in, or wait for the reset).
   - Where several causes lead to the same trouble, write one broad rule, in the words people used.
   - Account for the other stories that affect this one, keeping the story self-contained.
   - Over about ten scenarios, if it is no longer one action, split it into stories.
10. `## Changelog`: empty until approved.
11. `Defaults taken:` under the story, if any.
12. Write each story as its own file in the folder. Return where they are, each question that needs deciding with a pick, and the Think answers apart from the stories.
