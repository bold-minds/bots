---
name: write
description: Write, revise, split or review a skill, using skill-creator plus the owner's rules for skills. Use whenever a skill is created or changed, including skills made in an app's skill editor.
---

# Write skill

## In
- What the skill is for, from the owner or the skill that asked for it. If no one has said, ask the owner.
- The skill being revised, split or reviewed, if there is one.
- The `skill-creator` and `skillz:check` skills. If either is missing, stop and say which.

## Out
- `<skills folder>/<name>/SKILL.md`, checked by `skillz:check`.

## Think
- What does the skill take in, and where does each input come from?
- What does it put out, and where?
- What should the model ask itself while doing the work?
- What does it do, step by step?
- Would any step be misread without its reason?
- What does each step cost to run? Which steps can a smaller model or lower effort do well? Which can run at the same time? What is the least context each step needs?
- Is this skill universal, or for one kind of work? Does every line fit that scope, with no person, project or date, and nothing narrower than the skill is meant for?
- Is every line needed for the skill to work, or plainly expected?

## Act
1. Load `skill-creator` and follow it. Where it differs from these steps, these win.
2. When revising, splitting or reviewing, read the existing skill first and keep its `name`.
3. Decide the skill's scope: universal, or one kind of work. Write the frontmatter: `name`, and a `description` saying what the skill does and when to use it, across that whole scope.
4. Write `## In`: each input and where it comes from. Inputs come only from the sources named there. If one is missing, the skill hands off to the skill that makes it, or stops and says exactly what the owner must provide. A default value for an input is fine.
5. Write `## Out`: what the skill produces, and where.
6. Write `## Think`: the questions the model asks itself. They stay out of the skill's output.
7. Write `## Act`: short imperative steps, in order. Say what to do. Add a why only where a step would be misread without it. For each subagent the skill starts, name the smallest model and effort that does the job well, and the inputs it gets. Start independent steps at the same time.
8. Run `skillz:check` from a fresh subagent, against `skill-creator` and this skill. Fix what it finds.
9. Show the owner the skill.
