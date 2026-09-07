# The pipeline

The owner says what a feature should do, in `/software`. The pipeline turns
that into tested, reviewed code with no one watching. They are asked only when
a step genuinely cannot decide.

## Roles

- **The owner**: business decisions; what counts as success; top-level
  technical direction; merge; deploy.
- **`/software`**: the room. It writes each feature's spec in the owner's words
  and fires `/feature` when it has their definition of success and their go.
  It never does the pipeline's work.
- **`/feature`**: everything else. Each step is one agent, one fresh session,
  one short input file, one short output file.

## Steps

| # | step | agent | model | writes |
|---|------|-------|-------|--------|
| 1 | spec | `/software` | — | `features/<f>/spec.md`; creates branch `pipeline/<f>` |
| 2 | feature plan | `featureplan` | opus | `features/<f>/plan.md` — approach, state, outside calls, the journey, structural rules |
| 3 | lenses | `lens` ×6 — architecture, sre, qa, staff on opus; performance, database on sonnet | mixed | `features/<f>/lens-<x>.md` |
| 4 | pre-mortem | `premortem` | opus | `features/<f>/premortem.md` |
| 5 | break down | `breakdown` | sonnet | `features/<f>/tasks/<t>/criteria.md`; deletes 3–4's files |
| — | **stop** | `/software` | — | shows the owner one line per task; resumes on their go |
| 6 | current state | `state` | sonnet | `tasks/<t>/state.md`, committed on `pipeline/<f>` |
| 7 | red tests | `redtest` | opus | test files, `tasks/<t>/tests.md`, committed |
| 8 | plan | `planner` | opus | `tasks/<t>/plan.md`, committed |
| 9 | build | `builder` | opus | branch `pipeline/<f>/<t>` from the feature branch, gate green |
| 10 | review | `code-reviewer` (fix-code's nine lenses) ∥ `verifier` (mutations, gate, rulings, touched files) | opus ×2 | `tasks/<t>/verdict.md`; PASS needs both; on PASS the verifier merges the task into `pipeline/<f>` |
| 11 | feature | `featureverify` | opus | `features/<f>/verdict.md` — the journey end to end, every fitness test, every task's tests together, the gate; on PASS, the one push if config permits |
| 12 | clean | `cleaner` | haiku | deletes the feature directory; one index line |
| 13 | prove | `/software` runs config's `live:` command | — | pass/fail |

Steps 6–10 run per task, in order. Tasks in a feature run in parallel, each on
its own branch off the feature branch. 11 runs once, after every task has
merged. 12 and 13 run after the owner merges and deploys.

Branches: `main` → `pipeline/<feature>` → `pipeline/<feature>/<task>`. The
feature is the unit that ships and the unit that gets the end-to-end and
fitness tests. Merging the feature to the default branch is the owner's.

The six lenses at step 2 review the *spec*, before code exists. `fix-code`'s
nine lenses at step 9 review the *code*. Different stage, different questions.

Planner, redtest and verifier sit on the strongest model on purpose: the
planner is the only gate that interrupts the owner, redtest is the only guard
against a test that proves nothing, and the verifier is the only one that
re-runs the mutations.

## One file per repo

`.claude/pipeline/config.md` in the repo, plain `key: value` lines:

```
decisions: <absolute path to the rulings file>
requirements: <absolute path to what must be true>
gate: <the command that must be green before anything ships>
test: <the command that runs one test, with any env it needs>
entry: <the program's entry points, comma-separated>
stub: <where the local end-to-end environment lives, if any>
live: <a command that asks production whether it is healthy, if any>
push: not confirmed
```

`/software` reads it and hands every value to the runner as arguments. No
agent knows a path of its own.

`push:` is the owner's switch. `push: feature` (or `confirmed`) and the
feature branch is pushed once, when the whole feature passes — never a task,
never the default branch. Anything else and nothing is pushed; the owner
pushes.

## Repo-specific lens history

`.claude/pipeline/lenses/<lens>.md` in the repo, if present, is appended to
the generic checklist for that lens. Put what has actually gone wrong here.
The generic list stays generic.

## How it halts

A step that cannot proceed writes `BLOCKED.md` in its output directory and
returns its first line. The run stops. `/software` relays the file's three
lines to the owner, writes their one-line answer under `Answer:`, and resumes
the same run by its id; every finished step returns cached.

A halt with no `BLOCKED.md` and no `verdict.md` means the agent died. The
runner says so.

## Rules every agent follows

`triage.md`, beside this file. In one line: decide everything you can; ask the
owner only what changes a promise, costs money, contradicts a ruling, or sets
top-level technical direction; and before writing anything, ask whether the
next step gets quality or rework from it.

Language: business terms in every file the owner might read — `spec.md`,
`criteria.md`, `BLOCKED.md`. Files that only feed the next step —
`lens-*.md`, `premortem.md`, `state.md`, `plan.md`, `tests.md`, `verdict.md`
— may cite code: a finding with a file:line is one the breakdown can act on.
Headings and "why it matters" lines stay in business terms regardless. (The
first live run's lenses cited code freely and were the better for it.)

## Before the first run in a repo

- Write `.claude/pipeline/config.md`.
- `git add .claude && git commit`. Steps 5–7 commit their outputs so the
  builder's worktree contains them; that only works once the directory is
  tracked. If `.claude/` is excluded in that repo, narrow the exclusion.
- Start the session inside the repo. Agent discovery walks up from the
  session's directory to the git root; from outside, nothing is found.
