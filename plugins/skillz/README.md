# skillz

How to write skills and run them well.

## Skills

- `write-skill` - write, revise, split or review a skill as a function, inputs in and output back to its caller, using `skill-creator` plus its own rules for skills.
- `check-work` - check work against the skill or skills it followed, from a fresh subagent, and fix every miss before the work is handed on.
- `settle-question` - decide whether to settle a question yourself or return it to the caller with a pick.

`write-skill` also needs Anthropic's `skill-creator` skill, installed separately.

## Install

```
claude plugin install skillz@bots
```
