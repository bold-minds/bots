# What the owner reads

Five files reach the owner per story, and nothing else does. Each has a
template here, a checker that fails on shape, a cap, and plain words; the
skill that writes one runs the checker before showing it, and shows nothing
that fails. (Claire, 13 Sept 2026: "a file requiring HIL needs to be very
standardized, clear, easy to scan, plain language, and short.")

| Read | Stop | Template | Check | Cap |
|---|---|---|---|---|
| the story | Story | `templates/story.md` | `check.sh story <file> [--approved]` | 60 lines, 10 scenarios |
| the TRD | Design | `templates/trd.md` | `check.sh trd <file> [--reviewed]` | 10 group sentences a section; 100 lines with their bullets |
| the coverage table | Tasks | `templates/coverage.md` | `check.sh coverage <file> --story <story>` | 20 rows |
| the PR body | Code Review | `templates/pr.md` | `check.sh pr <file>` | 40 lines |
| the card | Launched | `templates/card.md` | `check.sh card <file>` | one line, two sentences, 40 words |
| an ADR | Design, with the TRD | `templates/adr.md` | `check.sh adr <file>` | 25 lines; Decision, Why, Reopens if — bullets only |

`check.sh` prints one line per defect and exits 0 when clean, 1 when not, 2
when it cannot read the file. The repo root comes from `git rev-parse
--show-toplevel` so it is right inside a linked worktree; the observability
vendor list comes from `<root>/.claude/slice-observability` when present.

`examples/` holds one clean file of each type — the two stories from
`skills/feature/story.md`, split into story and TRD, with a coverage table, a
PR body and a card for the second. `selftest.sh` proves the checker: every
example passes, and one deliberately broken copy per rule fails on that rule.
Run it after any change to `check.sh` or a template.

A template changes only with the owner's approval, and the change lands in
the template, `check.sh`, `selftest.sh` and the rules file that describes it
in one commit. A file that cannot say what it needs inside its template
proposes the change on its face — `Template: proposes <one sentence>` under
its title — and is shown with that line first.

**The TRD's shape, ruled 13 Sept.** Enough detail for the agents, rolled up
for a human to review quickly: in Solution and Observed, a **group** is one
plain sentence with no bullet — that is what the owner reads — and under it
the facts, one per bullet, each short. Code, paths, envs and commands live
only in the bullets. More short bullets beat fewer long ones. The review's
findings are folded into these lines; nothing of the review stays on the TRD.
