---
tags: [build-app]
max_turns: 40
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

Go on with the Pantry list build. The repo is repo/, the build folder is build/, what people said is said/said.md, the design is design/interface.md. Every skill the build runs is installed: each one's SKILL.md is at skills/<name>/SKILL.md (the appz step skills, check-work and settle-question). In this run, start each subagent with `fake/start-subagent <skill> <model> <effort> <brief file>`: it stands in for starting a subagent, and prints the subagent's reply, then its completion notice with tokens and time. The host's command line is `fake/gh`, used in place of `gh`.

Input files: said/said.md, design/, repo/, build/, skills/, fake/
