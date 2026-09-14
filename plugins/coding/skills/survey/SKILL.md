---
name: survey
description: Optional. One row per requirement id — is it true on main, with evidence; what the attic holds for it; which story harvests it. Reads the requirements file, the code on the default branch, the stories, and the attic's include/ and defer/ folders; never a branch, a worktree or an archive. Writes docs/product/survey.md, an input to story and trd, not an owner read. Use once before stories are written on a project with work ahead of main, and again when the owner suspects something already exists; never required.
argument-hint: <requirements.md> [--attic <dir>]
allowed-tools: Agent, Read, Bash, Write
---

# survey

**Input**, typed, nothing required to have run first:

- the requirements file — one bold heading per requirement, `**A1. …**`,
  under `## <letter>. <section>` headings, with a Success line each
- the repo root — `git rev-parse --show-toplevel`; the code is read on the
  default branch as checked out there
- the stories directory beside the requirements file — `stories/`, a
  scenario line `<n>. [<id>]` traces to an id
- optional: an attic — a directory with `include/` and `defer/`, one file
  per source, each opening with its inventory row. Only those two folders
  are read. Without an attic the middle column is `nothing` throughout, and
  that is the whole survey on a project that started with this process.

**Output**: `docs/product/survey.md` beside the requirements file — a header
naming the commit surveyed and the date, then one table, one row per id in
document order: `id | on main | evidence | in the attic | harvest into`.
Re-running replaces the file. Nothing is shown to the owner: the survey is
what the `story` writer and the `trd` writer read, and what the breakdown's
red-test step looks at when it rules a scenario TRUE.

## The run

1. List the sections: every `## <letter>. …` heading in the requirements
   file. Sections with no bold `**<id>. …**` heading under them (Context,
   Backlog, Release) are not sections.
2. Dispatch one `coding:survey` agent per section, in parallel, each with:
   `ROOT`, `REQUIREMENTS`, the `SECTION` heading verbatim, `STORIES`,
   `ATTIC` if given, and `OUT` = `<scratchpad>/survey/<letter>.md`. Each
   writes its rows and returns them.
3. Concatenate in section order under one header:

   ```
   # Survey — <requirements file>, main @ <sha>, <YYYY-MM-DD>

   One row per requirement: true on main today, by its own test; what the attic holds for it; which story harvests it. Never a plan.

   | id | on main | evidence | in the attic | harvest into |
   |---|---|---|---|---|
   ```

   Every id in the file has a row; an id with no row is a dead dispatch,
   and the run stops there rather than writing a survey with a hole.
4. Write `docs/product/survey.md`. Do not commit; the caller commits it with
   whatever it did next, or not at all.

## What it is not

- Not a read for the owner. It is long, dense and technical by design.
- Not a plan: `evidence` says what is, `harvest into` says which story
  carries the id, and nothing says what to do.
- Not a second inventory: the attic is read as it is; the survey never
  looks at a branch to check the attic's word.

Rule: survey reads the attic, never the sources; the attic is built once.
