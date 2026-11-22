---
name: check-work
description: Check work against the skill or skills it followed, from a fresh subagent, and fix every miss before the work is handed on. Use whenever work done under a skill is about to go to the owner, to another skill, or to the next piece of work.
---

# Skill check

## In
- The text of each skill the work followed: the whole skill, every section, not a summary of it.
- The work: the whole of what was made under the skill, as it stands now, not a description of it.

## Out
- The list of misses and the fixed work, returned to whatever asked for the check.

## Think
- Do I have both the skill's text and the work?
- Is each listed miss a real break from the skill, or something the skill doesn't ask for?
- Does each fix keep the rest of the work in line with the skill?

## Act
1. Check the inputs against `## In`: each skill's full text, and the work itself, whole. If either is missing or falls short, stop and tell the owner exactly which one is needed and what it lacks.
2. Start one fresh subagent on Sonnet. Give it only the skill's text and the work, so it judges the work against the skill and not against the reasoning that made it.
3. Have it list every place the work doesn't follow the skill.
4. Drop any listed miss the skill doesn't actually ask for.
5. Fix every remaining miss before the work is handed on.
