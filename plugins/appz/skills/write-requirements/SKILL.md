---
name: write-requirements
description: Turn the owner's words and an app's designs into the app's requirements file. Use when `appz:build-app` runs its first step, and whenever an app's requirements are drafted.
---

# App requirements

## In
- The owner's words (`<project>/data/owner_words.md`), the app's design boards, and its design doc, from `appz:design-app` or the owner.
- The `skillz:settle-question` skill.
- If one is missing, stop and tell the owner exactly what to provide. Make none of these inputs yourself. A default value inside a requirement is fine.

## Out
- The requirements file, drafted at `<project>/data/requirements.md`, then moved to the repo's `docs/product/requirements.md` once the owner approves it.

## Think
- Where did the owner say this?
- If they didn't say it, would they be surprised it's missing? Then it's inferred.
- Would they ask "why is this here?" Then it's out.

## Act
1. Read the owner's words, the design boards and the design doc.
2. Include what the owner said, what's needed for it to work, and what they'd plainly expect. Take every number, limit and rule from the owner or the designs, or as a marked default. Cover the cases and problems the owner or the designs raise. Write each requirement for the app, not for a test.
3. Settle questions with `skillz:settle-question`. Write in what the sources settle. Mark each default.
4. Group the requirements into sections by area, named in the owner's vocabulary. Use technical terms only where the owner did.
5. Write each requirement as `**A1. <one plain sentence in the owner's terms>.**`, then, where the owner said it, `Owner: "<shortest quote>" (<date, time>)`.
6. End an inferred line with ` *`. Give its reason in a short list at the bottom.
7. Add a short list of the defaults taken.
8. Write no Success lines. A requirement's test belongs in the story that builds it.
9. Show the owner the draft and the questions from step 3.
10. Once the owner approves the file, move it to `docs/product/requirements.md`.
