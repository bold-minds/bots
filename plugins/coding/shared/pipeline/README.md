# The pipeline

The owner says what a feature should do, in `/software`. The pipeline turns
that into tested, reviewed code with no one watching. They are asked only when
a step genuinely cannot decide.

## Roles

- **The owner**: business decisions; what counts as success; top-level
  technical direction; merge; deploy. They are the only human here, and they
  are involved only when something is completely failing or when no automated
  process exists. A design that needs them on the normal path is a wrong
  design.
- **`/software`**: the session the owner types in. It writes each feature's
  spec in their words and fires `/feature` when it has their definition of
  success and their go. It never does the pipeline's work.
- **`/feature`**: everything else. Each step is one agent, one fresh session,
  one short input file, one short output file.

## Steps

| # | step | agent | model | writes |
|---|------|-------|-------|--------|
| 1 | spec | `/software` | — | `features/<f>/spec.md`; creates branch `pipeline/<f>` **and a worktree on it** |
| 2 | feature plan | `featureplan` | opus | `features/<f>/plan.md` — approach, state, outside calls, the journey, structural rules |
| 3 | lenses | `lens` ×7 — architecture, sre, security, qa, staff on opus; performance, database on sonnet | mixed | `features/<f>/lens-<x>.md` |
| 4 | pre-mortem | `premortem` | opus | `features/<f>/premortem.md` |
| 5 | break down | `breakdown` | opus | `features/<f>/tasks/<t>/criteria.md`, each with its success sentence; deletes 3–4's files |
| — | **stop** | `/software` | — | shows the owner each task's success sentence, one line each, one message; resumes on their go |
| 6 | current state | `state` | sonnet | cuts the task worktree from `pipeline/<f>`; `tasks/<t>/state.md`, committed there |
| 7 | red tests | `redtest` | opus | test files, `tasks/<t>/tests.md`, committed on the task branch |
| 8 | plan | `planner` | opus | `tasks/<t>/plan.md`, committed |
| 9 | build | `builder` | opus | the task branch `pipeline/<f>--<t>`, gate green |
| 10 | review | `code-reviewer` (fix-code's nine lenses) ∥ `verifier` (mutations, gate, rulings, touched files) | opus ×2 | `tasks/<t>/verdict.md`; PASS needs both; a BLOCK that is rework goes back to `builder` and both reviews run again, twice at most; **neither merges** |
| 11 | merge | `merger` | haiku | merges every passed task branch into `pipeline/<f>`, one at a time, in landing order |
| 12 | feature | `featureverify` | sonnet | `features/<f>/verdict.md` — the journey end to end, every fitness test, every task's tests together, the gate; on PASS, the one push if config permits |
| 13 | clean | `cleaner` | haiku | after the owner merges: keeps the spec as `spec/<f>.md`, deletes the feature directory and the worktrees; one index line |
| 14 | prove | `/software` runs config's `live:` command | — | pass/fail |

Steps 6–10 run per task, in order. Tasks in a feature run in parallel, each in
**its own worktree** on its own branch off the feature branch — one working
tree per agent is the only thing that stops two tasks eating each other's
commits. 11 runs once, after every task has passed, and merges serially. 12
runs once after that. 13 and 14 run after the owner merges and deploys.

Branches: `main` → `pipeline/<feature>` → `pipeline/<feature>--<task>`. The
task branch sits *beside* the feature branch, not under it: git stores
`refs/heads/pipeline/<feature>` as a file, so a branch named
`pipeline/<feature>/<task>` would need that same path to be a directory, and
`git worktree add -b` refuses with `cannot lock ref … exists`. The `--`
separator is what keeps both alive at once. The feature is the unit that ships
and the unit that gets the end-to-end and fitness tests. Merging the feature to
the default branch is the owner's.

Every review diffs against the branch its work was cut from: a task against
`pipeline/<feature>`, the feature against the default branch. Diffing a task
against the default branch would BLOCK every task after the first for work that
already passed.

The seven lenses at step 3 review the *plan and the spec*, before code exists.
`fix-code`'s nine lenses at step 10 review the *code*. Different stage,
different questions.

Planner, redtest, breakdown and the code review sit on the strongest model on
purpose: the planner is the only gate that interrupts the owner, redtest is the
only guard against a test that proves nothing, and breakdown holds the one-way
doors — it authors every acceptance criterion, picks the one journey task, and
deletes the lens files and the pre-mortem. `featureverify` and `merger` are
cheap because neither has a judgement to make: one re-runs five things that are
green or not, the other merges a named list in a named order.

## One file per repo

`.claude/pipeline/config.md` in the repo, plain `key: value` lines:

```
decisions: <absolute path to the rulings file>
requirements: <absolute path to what must be true>
gate: <the command that must be green before anything ships>
test: <the command that runs one named test, with any env it needs. Write the
       test's name in it as the literal <TestName>, and if this repo has more
       than one module write the directory as the literal <module dir> — every
       step that runs it is told to substitute both and change nothing else.
       Anchor the name so a prefix cannot match a neighbour.>
entry: <the program's entry points, comma-separated>
stub: <where the local end-to-end environment lives, if any>
live: <a command that asks production whether it is healthy, if any>
push: not confirmed
```

`/software` reads it and hands every value to the runner as arguments. No
agent knows a path of its own.

`gate:` stays the plain command. The pipeline prepends `GATE_BASE=<ref>` to it
in the dispatch; nothing about it is written into the repo's own command. A
gate that has a delta mode judges only what changed since that ref — findings
on the changed lines, the files the diff touched, coverage and mutation no
worse than the base. Inside a task the ref is the feature branch, so a task is
done when nothing it touched got worse and nothing it added is red; the repo's
backlog is not that task's, and against a repo with a backlog an absolute gate
makes "gate green" a condition no task can ever meet. `featureverify` uses the
default branch, so the feature is judged on what the feature changed. The
absolute run — everything, backlog included — is the owner's, at the merge to
the default branch. A gate with no delta mode ignores `GATE_BASE` and runs
absolutely; that absolute run is then what the pipeline holds every step to,
and a repo with a backlog needs the delta mode before the pipeline can pass a
task in it.

`push:` is the owner's switch. `push: feature` (or `confirmed`) and the
feature branch is pushed once, when the whole feature passes — never a task,
never the default branch. Anything else and nothing is pushed; the owner
pushes.

## Repo-specific lens history

`.claude/pipeline/lenses/<lens>.md` in the repo, if present, is appended to
the generic checklist for that lens. Put what has actually gone wrong here.
The generic list stays generic.

`spec/cross-cutting.md` at the repo root, if present, is read by the planners
before they design and applied by the reviewers against every diff.

## How it halts

It stops twice on purpose, and once when something is wrong.

**After the breakdown**, the run returns `awaiting: confirm` with the task
list. `/software` shows the owner one line per task — each task's success
sentence, in their words — in a single message. That is their check that what
the pipeline calls success is what they meant. They say go, and the run resumes
with `confirmTasks: false`; every finished step returns cached.

**On BLOCKED**, a step that cannot proceed writes `BLOCKED.md` in its output
directory and returns its first line. The run stops. `/software` relays the
file's three lines to the owner and passes their one-line answer back as an
argument on the next run — `answers: { "<feature>": "<line>" }`, or
`answers: { "<feature>/<task>": "<line>" }` for a task-level block —
**together with `answerStep`, the step name the runner returned beside the
key** (`answerStep: "breakdown"`, `"plan"`, `"merge"`, …). Nobody edits
`BLOCKED.md` to deliver an answer: a finished call is cached by its prompt, so
an answer that is not in the prompt never re-runs the step that asked.

Both halves matter, because a changed prompt re-runs that call *and everything
after it*. The key alone is one per level, and every dispatch at that level
carries it — so a key-only answer would change the level's first prompt and
re-run the whole level behind it. The key **and** the step reach exactly one
dispatch. So: that one step re-runs, it deletes the file, and everything before
it stays cached. Send the key without the step and nothing re-runs at all; the
cached BLOCK comes straight back.

**A review BLOCK usually does not halt.** Most of what the two reviews at step
10 return is rework — test files over the size cap, lint findings the change
added, a mutation that survived — and that is the builder's work, not the
owner's. So when either review comes back BLOCK, both review texts go back to
`builder` as "fix these, then re-run the gate", in the same task worktree on
the same branch, and both reviews then run again on the branch as it stands.
Twice at most (`REWORK_MAX`); after that the run halts to the owner carrying
the last two review texts in the block record — `blocks[].codeReview` and
`blocks[].verify` — which are the whole account of it, because a rework block
writes no `BLOCKED.md`. `blocks[].blockedPath` is `null` there, and that null
is how the two halts are told apart: a path means there is a file to read, and
its absence beside a path means the agent died.

**That halt's `answerStep` is the builder's last rework step**, `rework-2`, not
either review's. Both reviews can be blocking at once, and a review step
carries the owner's ruling to one of them only: the other re-runs unchanged on
the resume, blocks again on what it blocked on before, and the run 2-cycles
forever. The builder is the single place that can fix both halves, so the
ruling goes to its last dispatch — and because a changed prompt re-runs that
call and everything after it, both reviews then run again, live, on the branch
as the builder has just left it. The exception is a block
only the owner can settle: the reviewer puts `BLOCKED:` on its **first** line,
`triage.md`'s shape, and that one skips the loop and halts at once — no build
pass answers a question about a promise to a customer. A dead agent halts too;
there is nothing to hand back. Each round's dispatches carry their own step
names — `code-review-1`, `review-1`, `rework-1` — so an answer keyed to one
round re-runs that round alone and every call before it stays cached.

**A halt whose `blockedPath` is set, with no `BLOCKED.md` and no `verdict.md`
at those paths, means the agent died.** The runner says so, and names the paths
where those files would have been. A halt whose `blockedPath` is `null` is the
rework halt above — nothing died, nothing wrote a file, and the record is the
two review texts.

## Rules every agent follows

`triage.md`, beside this file. In one line: decide everything you can; ask the
owner only what changes a promise, costs money, contradicts a ruling, or sets
top-level technical direction; and before writing anything, ask whether the
next step gets quality or rework from it.

**Nothing outlives its usefulness.** A file dies the moment its successor
exists: the lens files and the pre-mortem die at the breakdown, the whole
feature directory dies at the cleaner. There are exactly two deliberate
exceptions. `features/_shipped.md`, one line per shipped feature, is the index
from a feature to the tests that guard it — the map you need after everything
else is gone, and a line, not a document. And the spec: the cleaner moves
`features/<f>/spec.md` to `spec/<f>.md` at the repo root and commits it before
the directory dies, because what the feature was for outlives the run that
built it.

Inputs are not outputs and are never deleted: the lens checklists (generic and
this repo's overlay), `triage.md`, the templates, and `config.md` are what the
pipeline is made of, not what it produced.

Language: business terms in every file the owner might read — `spec.md`,
`criteria.md`, `BLOCKED.md`. Files that only feed the next step —
`lens-*.md`, `premortem.md`, `state.md`, `plan.md`, `tests.md`, `verdict.md`
— may cite code: a finding with a file:line is one the breakdown can act on.
Headings and "why it matters" lines stay in business terms regardless. (The
first live run's lenses cited code freely and were the better for it.)

## Before the first run in a repo

- **Ask the owner to write `.claude/pipeline/config.md`.** It is theirs, not
  yours — `push:` in particular is the switch that decides whether anything
  reaches the remote, and nobody else flips it.
- `git add .claude && git commit`. Steps 2, 4, 5 commit in the feature
  worktree and 6, 7, 8 commit in each task worktree, so that later worktrees
  contain their inputs; that only works once the directory is tracked. If
  `.claude/` is excluded in that repo, narrow the exclusion.
- Start the session inside the repo. Agent discovery walks up from the
  session's directory to the git root; from outside, nothing is found.
