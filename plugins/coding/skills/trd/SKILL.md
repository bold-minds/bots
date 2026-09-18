---
name: trd
description: The Design stop. Input a story: writes its TRD (Flow, Solution, Observed, References) from the story and the code, has seven technical lenses and a pre-mortem review the draft, folds every finding into the TRD so the owner reads one cohesive draft, checks it, and puts it in front of them with only the lines that need their word. Input an existing TRD: review and resolve only. Never edits the story; a behaviour the review wants is proposed as a scenario for the owner to accept or refuse. Use when a story is approved and has no approved TRD, or when a TRD needs its review.
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
--reviewed` — one cohesive draft with the review's findings folded in and
nothing of the review on it; the ADR for every References item that has
none yet, at `<root>/docs/adr/NNNN-<slug>.md`, written from the ruling
behind it (an item with no ruling anywhere is a question to the owner, not
a pending line); plus the trail at
`<root>/.claude/pipeline/reviews/<nn>-<name>-<date>.md`, which the owner
never reads. Shown to the owner whole, the new ADRs with it. Nothing is
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
   back into a fresh dispatch as a ruling. One BLOCKED is the **size stop**:
   the Flow adds more than one participant or more than two connections
   (Claire, 17 Sept 2026), and the agent has written nothing below the Flow.
   Relay the count and the proposed cut — mechanics with a stand-in output,
   the real behaviour, the negative cases — and wait: no lens reads a story
   the owner has not sized. The owner may say "go anyway"; then the write
   continues as a ruling. `check.sh trd` says the same two lines on a TRD
   that was written over the cap, so a draft that slipped past is caught
   before the review is dispatched, not after eight lenses have read it.

2. **Review** — first `bash ${HIL}/check.sh trd ${TRD}` (not `--reviewed`):
   a `Flow:` line is the size stop and the review does not run; relay it as
   in step 1. Then eight lenses in parallel, one `coding:lens` dispatch each:
   `architecture`, `sre`, `security`, `qa`, `staff`, `practitioner` on opus;
   `performance`, `database` on sonnet. The practitioner reads the TRD as a
   working developer who has read none of the repo's documents: a thing in
   a place their language would not put it, or a test of tooling rather
   than behaviour, is a finding whatever the story or standard says. Each gets: its name; `TRD`; the story; the checklist
   `${P}/shared/pipeline/lenses/<lens>.md`; `<root>/.claude/pipeline/lenses/<lens>.md`
   if it exists; the return format `${P}/shared/pipeline/templates/lens.md`;
   the triage rules; and, when config has a `rules` line, that file's "Asked
   on every slice" list, each of whose lines a TRD that leaves it unanswered
   turns into a finding. Each returns its findings as text and writes
   nothing. Then one `coding:premortem` dispatch with `TRD`, the story, the
   eight lens texts verbatim, the return format
   `${P}/shared/pipeline/templates/premortem.md` and the triage rules; it
   returns its table as text.

3. **Resolve** — dispatch `coding:trd` with `TRD`, the story, the nine review
   texts verbatim, the template, the checker, the triage rules, the trail
   path `<root>/.claude/pipeline/reviews/<nn>-<name>-<YYYY-MM-DD>.md`, and
   the word **resolve**. It folds every finding into the TRD's sections so
   the draft reads as one piece, adds the `Reviewed:` line, writes the trail,
   runs the checker with `--reviewed`, and returns only the lines for the
   owner: proposed scenarios and refused findings, or "nothing".

4. **Check and show.** Run `bash ${HIL}/check.sh trd ${TRD} --reviewed`
   yourself; a line printed is a defect, and the file is not shown until it
   prints none. Then show the owner the whole TRD in the chat, and under it
   the lines the resolve returned — nothing else about the review — and wait.
   Their reads of it:
   - an edit — apply it, run the checker again, show again;
   - a proposed scenario accepted — append it to the story's Scenarios, next
     number, with its requirement id, and one dated line in the story's
     Changelog; then `check.sh story --approved` on the story;
   - a proposed scenario refused — one line in the trail; nothing changes;
   - a refusal overruled — fold that finding into the TRD, run the checker,
     show again;
   - **go** — commit the TRD, its new ADRs, the trail, and the story if it
     changed, on the branch the story is on, `docs/product: <nn>-<name> TRD
     approved`, and report the stop moved to Design: done.

A TRD is never shown with a failing checker, never shown twice for one
finding, never carries a word about its own review, and is never written for
a story the owner has not approved.

## Cost

One write, nine reviews, one resolve: eleven dispatches, nine of them opus.
Say so when asked what it cost; count a resume's re-dispatches too.
