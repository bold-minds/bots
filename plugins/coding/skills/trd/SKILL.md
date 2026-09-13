---
name: trd
description: The Design stop. Input a story: writes its TRD (Flow, Solution, Observed, References) from the story and the code, has seven technical lenses and a pre-mortem review the draft, resolves every finding into the TRD's Review table, checks it, and puts it in front of the owner. Input an existing TRD: review and resolve only. Never edits the story; a behaviour the review wants is proposed as a scenario for the owner to accept or refuse. Use when a story is approved and has no approved TRD, or when a TRD needs its review.
argument-hint: <story.md | story.trd.md>
allowed-tools: Agent, Read, Glob, Grep, Bash, Write
---

# trd

**Input**, one file, and the input decides the job:

- `docs/product/stories/<nn>-<name>.md` — a story that passes
  `shared/hil/check.sh story` (approved). Job: write, review, resolve, check,
  show.
- `docs/product/stories/<nn>-<name>.trd.md` — a TRD, reviewed or not. Job:
  review, resolve, check, show.

Nothing else is required to have run first. Optional inputs, read when they
exist beside the story: `docs/product/survey.md` (one row per requirement,
what exists on main and in the attic) and the repo's
`.claude/pipeline/lenses/<lens>.md` history files. Project specifics come
from `<root>/.claude/pipeline/config.md`: `decisions`, `entry`, and `rules`
when the line is there.

**Output**: `docs/product/stories/<nn>-<name>.trd.md` in the shape
`shared/hil/templates/trd.md` gives, passing `shared/hil/check.sh trd <file>
--reviewed`, shown to the owner whole, Review section last. Nothing is
committed until they say go.

## The run

Let `P` be `${CLAUDE_PLUGIN_ROOT}`, `HIL` be `${P}/shared/hil`, `root` be
`git rev-parse --show-toplevel`, and `TRD` the output path.

1. **Write** — story input only. Dispatch `coding:trd` with: the story's
   path; `TRD`; the template `${HIL}/templates/trd.md`; the checker
   `${HIL}/check.sh trd`; `decisions` and `entry` from config; the survey
   path if the file exists; the triage rules
   `${P}/shared/pipeline/triage.md`; and the word **write**. It returns the
   TRD's first line. If it returns a line beginning `BLOCKED:`, stop and relay
   the three lines of the question to the owner; their one-line answer goes
   back into a fresh dispatch as a ruling.

2. **Review** — seven lenses in parallel, one `coding:lens` dispatch each:
   `architecture`, `sre`, `security`, `qa`, `staff` on opus; `performance`,
   `database` on sonnet. Each gets: its name; `TRD`; the story; the checklist
   `${P}/shared/pipeline/lenses/<lens>.md`; `<root>/.claude/pipeline/lenses/<lens>.md`
   if it exists; the return format `${P}/shared/pipeline/templates/lens.md`;
   the triage rules; and, when config has a `rules` line, that file's "Asked
   on every slice" list, each of whose lines a TRD that leaves it unanswered
   turns into a finding. Each returns its findings as text and writes
   nothing. Then one `coding:premortem` dispatch with `TRD`, the story, the
   seven lens texts verbatim, the return format
   `${P}/shared/pipeline/templates/premortem.md` and the triage rules; it
   returns its table as text.

3. **Resolve** — dispatch `coding:trd` with `TRD`, the story, the eight review
   texts verbatim, the template, the checker, the triage rules, and the word
   **resolve**. It rewrites the Review section — one row per finding, each
   `TRD:`, `Story:` or `Dismissed:` — makes every `TRD:` change in the
   sections above, runs the checker with `--reviewed`, and returns the row
   count and the number of `Story:` rows.

4. **Check and show.** Run `bash ${HIL}/check.sh trd ${TRD} --reviewed`
   yourself; a line printed is a defect, and the file is not shown until it
   prints none. Then show the owner the whole TRD in the chat, Review last,
   and wait. Their reads of it:
   - an edit — apply it, run the checker again, show again;
   - a `Story:` row accepted — append the proposed scenario to the story's
     Scenarios, next number, with its requirement id, and one dated line in
     the story's Changelog; then `check.sh story --approved` on the story;
   - a `Story:` row refused — leave the row, note `refused <date>` after it;
   - **go** — commit the TRD (and the story if it changed) on the branch the
     story is on, `docs/product: <nn>-<name> TRD approved`, and report the
     stop moved to Design: done.

A TRD is never shown with a failing checker, never shown twice for one
finding, and never written for a story the owner has not approved.

## Cost

One write, eight reviews, one resolve: ten dispatches, eight of them opus.
Say so when asked what it cost; count a resume's re-dispatches too.
