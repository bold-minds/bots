---
name: check-work
description: Check work against the skill or skills it followed, from a fresh subagent, and return every miss to the caller to fix before the work is handed on. Use whenever work done under a skill is about to go back to its caller or on to the next piece of work.
---

# Check work

## In
- The text of each skill the work followed: the whole skill, every section, not a summary of it.
- The work: the whole of what was made under the skill, as it stands now, not a description of it.
- The work's Think-answers record: what each Think question of the skill was answered with, one line per question, kept apart from the work.

## Out
- The list of misses, each with where it is and what the skill asks for, returned to the caller.
- This skill's own Think answers, one line per question, kept apart from the list.

## Think
- Do I have the skill's text, the work and the work's Think-answers record?
- Is each listed miss a real break from the skill, or something the skill doesn't ask for?

## Act
1. Check the inputs against `## In`: each skill's full text, the work itself, whole, and the work's Think-answers record. If one is missing or falls short, return to the caller exactly which one is needed and what it lacks.
2. Start one fresh subagent on Sonnet at medium effort. Give it only the skill's text, the work and the work's Think-answers record, so it judges the work and the answers against the skill and not against the reasoning that made them.
3. Have it list every place the work doesn't follow the skill, and check that every Think question of the skill has an answer in the record and that the work matches each answer. Be skeptical: where an answer says the skill did something, such as cutting lines, confirm the work shows it was done. A missing answer, or work that doesn't match its answer, is a miss.
4. Drop any listed miss the skill doesn't actually ask for.
5. Return the remaining misses to the caller, for the skill that made the work to fix before it is handed on.
