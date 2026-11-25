---
name: write-stories
description: Turn requirements into one story per action someone or something takes through the interface. Use when drafting or revising a milestone's stories, whether the ask says stories, user stories, scenarios or acceptance criteria.
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
- Did a number, limit, rule or behaviour come from no one?

## Act
1. Check each input against `## In` before anything else. If one falls short, or one other than the story being revised and the caller's answers is missing, return to the caller exactly what's missing and what it must contain.
2. Include what people said, what's needed for it to work, and what they'd plainly expect. Take every number, limit, rule or behaviour from what people said or the design, or as a marked default. Write a case near a limit with only the limit's own number, such as "over the limit of 5" rather than "6".
3. When revising an approved story, apply the caller's answers, keep its scenario numbers, and add one Changelog line saying what changed.
4. Settle questions with `skillz:settle-question`. Write in what the sources settle. Mark each default. Return only what's left, each with its pick.
5. Title the story with the action, in the words people used. In the Shows line, Journey and Scenarios, name the action, not the control or gesture: a tap, swipe, button or chip belongs to the design, and so does where a thing sits on screen, such as at the top or on the left. An order, such as newest first, is behaviour.
6. Write `Shows:` as one line, the happy path.
7. Write `Design:` as a link or path to the part of the interface the story touches, kept for the life of the story. Put how the interface looks or is shaped in the design.
8. Write `## Journey` as the happy path in Given/When/Then, behaviour only.
9. Write `## Scenarios` numbered, behaviour only, each with its requirement ids, ` *` after each id whose requirement AI added, and ` *` on a scenario AI added.
   - For each thing that will obviously go wrong, write a scenario saying what they see or get back, and end it with what to do, as `so they <do this>` (for example, so they sign in, wait for the reset, or handle the error).
   - Where several causes lead to the same trouble, write one scenario for them all. Where people named the trouble, open its Given with their words in quotes and the causes after them, such as `Given "the payment didn't go through" (the card is declined, expired or over its limit)`.
   - Account for the other stories that affect this one, keeping the story self-contained.
   - Where it behaves differently the first time, the next time, or after closing, restarting or another change, write a scenario for each difference.
   - Over about ten scenarios, if it is no longer one action, split it into stories.
10. If any defaults were taken, write `Defaults taken:` after `## Scenarios` and before `## Changelog`.
11. Write `## Changelog`, and leave it empty until approved.
12. Write each story as its own file in the folder. Check each with `python3 <the folder holding this SKILL.md>/scripts/check-story.py <story file> <file holding what people said> <the requirements> <the design and any answers from the caller> --wrong <numbers of the scenarios for things that go wrong> --broad <numbers of the scenarios that cover several causes>`, adding `--approved` and giving only the changed scenarios when revising an approved story. Fix each FAIL and run it again until it prints `FAILS: 0`.
13. Return where they are, each question that needs deciding with a pick, and the Think answers apart from the stories.
