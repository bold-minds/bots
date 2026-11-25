---
name: plan-milestones
description: Cut approved requirements into milestones that each leave the software working and able to do more, in an order, returned to the caller as a milestones file. "App" means any software people or code use, such as an app, a service or a library. Use when asked to plan or revise how a build is cut and ordered, once per app after the requirements are approved, whether the ask says milestones, phases, releases or a build order.
---

# Plan milestones

## In
- The approved requirements: each with its id, in the terms people used, with lines added by AI marked ` *`.
- What people said the app should do, in their own wording, in the order it was said, with the date and time of each thing. What people said is marked apart from anything AI added.
- The design of what's being built: its interface, in whatever form people or code use it (screens, endpoints, commands, functions), each part at a link or path a story can point to, and the rules, numbers and limits behind it. An interface that already runs, live or in code, counts.
- A folder it can write the milestones in.
- The `skillz:settle-question` skill.
- Optional, when revising: the current milestones, and the caller's answers.

## Out
- The milestones file at `data/milestones.md` in that folder, with where it is, the defaults taken, and the questions from `skillz:settle-question`, each with its pick, returned to the caller. Not the whole file.
- The Think answers, one line per question, each saying what it led the skill to do, kept apart from the work, returned to the caller.

## Think
- After this milestone, what can people do that they couldn't before?
- Does the app still work, and help, with only the milestones up to this one?
- What must already be there for this milestone to work?
- Did people say this comes later, or is only a thought?
- Is every requirement in a milestone, or named as left out?
- Does a requirement name several parts, or hold everywhere?
- Did an order or a cut come from no one?

## Act
1. Check each input against `## In` before anything else. If one is missing or falls short, return to the caller exactly what's missing and what it must contain.
2. Read what people said for anything on order, what comes first, or what comes later. Take what they said as it is.
3. Cut the requirements into milestones that each leave the app working and let people do more than the milestone before.
4. Put the part everything else is made or reached through first, and a part after the parts it needs. Where nothing forces the order, pick one and write it as a default with its reason.
5. Place each requirement in one milestone. An id that names several parts sits in the milestone that makes it true for all of them; earlier milestones build the part they need. A standing rule sits where it first applies, and every later milestone keeps it.
6. Leave out what people called later or only a thought. List each under `Not in any milestone yet` with its id and what they said.
7. When revising, apply the caller's answers to the current milestones and keep each milestone's number and requirement ids that the answers don't touch: stories point to them. When an answer moves a milestone, say so.
8. Settle questions with `skillz:settle-question`. Write in what the sources settle. Mark each default. Return only what's left, each with its pick.
9. Write each milestone as `## Milestone N: <name in the terms people used>`, then:
   - `After it, <who> can: <what they can do now>`, using the interface's own words.
   - `Requirements: <ids>`.
10. End the file with `Not in any milestone yet` and `Defaults taken`, each with its reasons.
11. Check that every requirement id appears in one milestone or under `Not in any milestone yet`.
12. Return to the caller where the file is, the defaults taken, and the questions from step 8, each with its pick, and the Think answers apart from them. Not the whole file.
