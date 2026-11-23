---
name: check-work
description: Check work against the skill or skills it followed, from a fresh subagent, and return every miss to the caller to fix before the work is handed on. Use whenever work done under a skill is about to go back to its caller or on to the next piece of work.
---

# Check work

## In
- The text of each skill the work followed: the whole skill, every section, not a summary of it.
- The work: the whole of what was made under the skill, as it stands now, not a description of it.
- The work's Think-answers record: what each Think question of the skill was answered with, one line per question, kept apart from the work.
- Optional, on a re-check: the misses from the last check and what changed to fix them.

## Out
- The list of misses, each with where it is and what the skill asks for, returned to the caller.
- This skill's own Think answers, one line per question, each saying what it led the skill to do, kept apart from the list.

## Think
- Do I have the skill's text, the work and the work's Think-answers record?
- Does the work break a line the skill states, or is the miss something the skill doesn't say?

## Act
1. Check the inputs against `## In`: each skill's full text, the work itself, whole, and the work's Think-answers record. If one is missing or falls short, return to the caller exactly which one is needed and what it must contain.
2. Start one fresh subagent on Sonnet at medium effort. If a fresh subagent can't be started, return that to the caller and check nothing yourself. Give it only the skill's text, the work and the work's Think-answers record (on a re-check, also the earlier misses and what changed), so it judges the work and the answers against the skill and not against the reasoning that made them.
3. Set what the checker returns:
   - On a re-check, have it check only the earlier misses and the lines changed to fix them. For each earlier miss, have it run a literal search (for example grep) on the work as it stands now and return the search command and its output. What the checker or the fixer says doesn't count.
     - A miss that is a wrong line: search for the wrong line's own words. A hit is the line still there: quote it, and the miss is open. The miss is fixed when the search comes back empty.
     - A miss that is something absent (a missing answer, section or number): search for the text the fix added. The miss is fixed when the search finds that text: quote it with the command and output. An empty search leaves the miss open.
   - Otherwise, have it list every place the work doesn't follow the skill, and check that every Think question of the skill has an answer in the record and that the work matches each answer.
   - Be skeptical: where an answer says the skill did something, such as cutting lines, confirm the work shows it was done. A missing answer, or work that doesn't match its answer, is a miss.
4. Keep a miss only when the work breaks a line the skill states. Drop anything the skill doesn't say.
5. Return the remaining misses to the caller, for the skill that made the work to fix before it is handed on. On a re-check, speak only of the earlier misses and the lines changed to fix them: list the earlier misses still open and misses in the changed lines. Leave out whatever the checker said about any other line of the work. Each Think answer holds to the same: it names only the earlier misses and the changed lines, and no other line of the work appears in it.
