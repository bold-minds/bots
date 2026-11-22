---
name: write-skill
description: Write, revise, split or review a skill as a function, inputs in and output back to its caller, using skill-creator plus this skill's rules for skills. Use whenever a skill is created or changed, including skills made in an app's skill editor.
---

# Write skill

## In
- What the skill must do: the work it does, for what kind of work, and when it is used.
- The skill being revised, split or reviewed, if there is one: its full text.
- The `skill-creator` and `skillz:check-work` skills, each in full.

## Out
- `<skills folder>/<name>/SKILL.md`, checked by `skillz:check-work`, returned to the caller.
- This skill's Think answers, one line per question, kept apart from the work, returned to the caller.

## Think
- What does the skill take in, and what must each input contain for the skill to do its job?
- What does it return to its caller, and where does it write it?
- What should the model ask itself while doing the work?
- What does it do, step by step?
- Would any step be misread without its reason?
- What does each step cost to run? Which steps can a smaller model or lower effort do well? Which can run at the same time? What is the least context each step needs?
- Is this skill universal, or for one kind of work? Does every line fit that scope, with no person, project or date, and nothing narrower than the skill is meant for?
- Does it name any skill it doesn't use?
- Is every line needed for the skill to work, or plainly expected?

## Act
1. Check each input against `## In` before anything else. If what the skill must do doesn't say the work, the kind of work and when it is used, or `skill-creator` or `skillz:check-work` is missing, return to the caller exactly which input is missing or short and what it must contain.
2. Load `skill-creator` and follow it. Where it differs from these steps, these win.
3. When revising, splitting or reviewing, read the existing skill first and keep its `name`.
4. Decide the skill's scope: universal, or one kind of work. Write the frontmatter: `name`, and a `description` saying what the skill does and when to use it, across that whole scope. Name the skill `[action]-[object]`, two words, even when the plugin's name matches the object.
5. Write the skill as a function. Whoever runs it is its caller, a person or another skill, and the skill reads the same either way. Call them "the caller".
   - `## In`: its parameters. Each input and what it must contain for the skill to do its job, not a file name, location or source. A default value for an input is fine. Name a skill only when this skill uses it, and list it here. Never name a caller.
   - `## Out`: what it returns to its caller, and where it writes it. Return the skill's Think answers to the caller, one line per question, kept apart from the work. Each answer says what it led the skill to do, if anything, so a reviewer can check the work did it.
   - Make its first Act step check its inputs against `## In`. When one is missing or falls short, the skill hands off to the skill that makes it, or returns to its caller exactly what's missing and what it must contain.
   - A question that needs deciding goes back to the caller, with a pick. So does anything that needs approval: the skill returns its work, and what follows approval is the caller's to do.
6. Write `## Think`: the questions the model asks itself. They stay out of the work.
7. Write `## Act`: short imperative steps, in order. Say what to do. Add a why only where a step would be misread without it. For each subagent the skill starts, name the smallest model and effort that does the job well, and the inputs it gets. Start independent steps at the same time.
8. Run `skillz:check-work` against `skill-creator` and this skill, with this skill's Think answers; it starts its own fresh subagent. Fix the misses once, re-check once, and return any misses still left to the caller with the skill, instead of looping.
9. Return the skill, and this skill's Think answers apart from it, to the caller.
