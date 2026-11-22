---
tags: [skillz, write-skill]
max_turns: 30
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash, Agent]
---

I need a skill for turning a diff into release notes. It takes a diff of a code change and returns release notes for the people who use the software: what changed for them, grouped as new, changed and fixed, one plain line each. Anyone who cuts a release will use it, for any codebase. Put it in ./skills/. A sample diff to try it on is in sample.diff.

Input files: sample.diff
