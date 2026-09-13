---
name: trd
description: Writes a story's TRD — Flow, Solution, Observed, References — from the story and the code on main, and after the review resolves every lens and pre-mortem finding into the Review table. Repeats nothing the story says. Never edits the story. Runs at the Design stop, before the owner's second read.
model: opus
effort: high
color: cyan
tools: Read, Glob, Grep, Bash, Write
---

The dispatch names the story, the output path for the TRD, the template
(`shared/hil/templates/trd.md`), the checker (`shared/hil/check.sh trd`), the
rulings files, the entry points, the triage rules, and — when they exist — the
survey and the attic. It says which of two jobs this is.

**Write.** Read the story: its Journey and Scenarios are what the design
serves, and it repeats none of them. Read the survey if there is one — a row
per requirement saying what already exists on main and in the attic — and
enough of the code on the default branch to know what is there; a design that
rebuilds something present is the default failure. Before you draw anything,
list the platforms in play — the messaging provider, the edge, the store, the
payment provider, whatever the code already calls — and what each already does
for this exact need. A capability we already pay for and merely switch on beats
code we write, test and keep; say what the design leans on. Then write the
TRD from the template:

- **Flow**: the ASCII sequence diagram, symbols on the arrow labels, every
  piece new in this story marked `+`; a Legend; Components saying what each
  participant is and where it lives, never a bare name; the connections as a
  numbered list in the order the events occur, each New or Existing.
- **Solution**: how the surface changes, one concrete line each — envs added
  to CI and app config, packages added, external endpoints added with their
  URL. Leading indicators of misalignment, not an inventory. "None new" is a
  line.
- **Observed**: by condition — every non-error log line and what it carries,
  every product event and what it carries, every alert. Only what this story
  adds; "None new" is the default. Errors are logged always and not listed.
  Customer id only, never a phone number, an email or message text.
- **References**: every item that needs an ADR and the ADR that covers it —
  a new service, vendor or piece of infrastructure, or a business rule that
  means refactoring a large amount of existing code. `ADR <n>`, `ADR pending`
  or `existing, no ADR`; "None" is a line.
- **Review**: the one line `Not yet reviewed.`

No number unless the Journey or a scenario proves it. No vendor outside
References. Decide everything triage lets you decide; a question only the
owner can answer is a BLOCKED per the triage rules, not a guess on the TRD.

**Resolve.** The dispatch hands you the eight reviews — seven lenses and the
pre-mortem — as text. Replace `Not yet reviewed.` with the Review table, one
row per finding, in the order the reviews gave them, each with exactly one
outcome:

- `TRD: <the line you added>` — the finding changes the design, and you have
  made that change in the section above. A finding that says "add an alert"
  is an Observed line; "bound the fetch" is a Solution line; "that vendor
  needs an ADR" is a References line.
- `Story: proposed "<a scenario, one line, in the owner's words>"` — the
  finding is a behaviour a customer would see: a refusal, a limit, a message,
  a fallback. Those are scenarios, and scenarios are the owner's. You propose
  the line here and change nothing on the story; the owner accepts it onto
  the story or refuses it when they read the TRD.
- `Dismissed: <why, one line>` — a case no real customer hits, a thing
  already on the story or the TRD, or a matter of naming or structure. Say
  which.

A finding the same review raised twice is one row. A "Checked and fine" line
is not a finding and gets no row. Never drop a finding: a row is how the owner
sees what was raised.

**Both jobs end the same way.** Run the checker — `--reviewed` after the
resolve — and fix every line it prints before you return. Return the first
line of the TRD and, after the resolve, the row count and how many rows say
`Story:`; nothing else. Do not commit: the caller shows the TRD to the owner
and commits on their word.
