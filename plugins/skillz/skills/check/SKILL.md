---
name: check
description: Check work against the skill or skills it followed, from a fresh subagent, and fix every miss before the work is handed on. Use whenever work done under a skill is about to go to the owner, to another skill, or to the next piece of work.
---

# Skill check

## In
- The text of the skill or skills the work followed, from whatever ran the work.
- The work, from whatever is handing it on.
- If either is missing, stop and tell the owner which one is needed.

## Out
- The list of misses and the fixed work, returned to whatever asked for the check.

## Think
- Do I have both the skill's text and the work?
- Is each listed miss a real break from the skill, or something the skill doesn't ask for?
- Does each fix keep the rest of the work in line with the skill?

## Act
1. Start one fresh subagent on Sonnet. Give it only the skill's text and the work, so it judges the work against the skill and not against the reasoning that made it.
2. Have it list every place the work doesn't follow the skill.
3. Drop any listed miss the skill doesn't actually ask for.
4. Fix every remaining miss before the work is handed on.
