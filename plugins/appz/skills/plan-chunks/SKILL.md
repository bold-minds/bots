---
name: plan-chunks
description: Cut approved requirements into chunks that each leave the software working and able to do more, in an order, returned to the caller as a chunks file. "App" means any software people or code use, such as an app, a service or a library. Use when asked to plan or revise how a build is cut and ordered, including when `appz:build-app` runs its second step, once per app after the requirements are approved.
---

# Plan chunks

## In
- The approved requirements: each with its id, in the terms people used, with lines added by AI marked ` *`.
- What people said the app should do, in their own wording, in the order it was said, with the date and time of each thing. What people said is marked apart from anything AI added.
- The design of what's being built: its interface, in whatever form people or code use it (screens, endpoints, commands, functions), each part at a link or path a story can point to, and the rules, numbers and limits behind it. An interface that already runs, live or in code, counts.
- A folder it can write the chunks in.
- The `skillz:settle-question` skill.
- Optional, when revising: the current chunks, and the caller's answers.

## Out
- The chunks file at `data/chunks.md` in that folder, with where it is, the defaults taken, and the questions from `skillz:settle-question`, each with its pick, returned to the caller. Not the whole file.
- The Think answers, one line per question, each saying what it led the skill to do, kept apart from the work, returned to the caller.

## Think
- After this chunk, what can people do that they couldn't before?
- Does the app still work, and help, with only the chunks up to this one?
- What must already be there for this chunk to work?
- Did people say this comes later, or is only a thought?
- Is every requirement in a chunk, or named as left out?
- Does a requirement name several parts, or hold everywhere?
- Did an order or a cut come from no one?

## Act
1. Check each input against `## In` before anything else. If one is missing or falls short, return to the caller exactly what's missing and what it must contain.
2. Read what people said for anything on order, what comes first, or what comes later. Take what they said as it is.
3. Cut the requirements into chunks that each leave the app working and let people do more than the chunk before.
4. Put the part everything else is made or reached through first, and a part after the parts it needs. Where nothing forces the order, put first what the app is for, then what lets it act, then what keeps real work from stalling or data from piling up, then the rest. Write each such choice as a default with its reason.
5. Place each requirement in one chunk. An id that names several parts sits in the chunk that makes it true for all of them; earlier chunks build the part they need. A standing rule sits where it first applies, and every later chunk keeps it.
6. Leave out what people called later or only a thought. List each under `Not in any chunk yet` with its id and what they said.
7. When revising, apply the caller's answers to the current chunks and keep each chunk's number and requirement ids that the answers don't touch: stories point to them. When an answer moves a chunk, say so.
8. Settle questions with `skillz:settle-question`. Write in what the sources settle. Mark each default. Return only what's left, each with its pick.
9. Write each chunk as `## Chunk N: <name in the terms people used>`, then:
   - `After it, <who> can: <what they can do now>`, using the interface's own words.
   - `Requirements: <ids>`.
   - `PRs:` the chunk's three, one line each: 1, the skeleton: a stub of what people or code use and a stub of what's behind it (the first chunk's also sets up CI); 2, what people or code use, with what's behind it mocked; 3, what's behind it done, and the data.
10. End the file with `Not in any chunk yet` and `Defaults taken`, each with its reasons.
11. Check that every requirement id appears in one chunk or under `Not in any chunk yet`.
12. Return to the caller where the file is, the defaults taken, and the questions from step 8, each with its pick, and the Think answers apart from them. Not the whole file.
