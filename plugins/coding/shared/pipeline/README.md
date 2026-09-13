# The pipeline

The owner approves a story — `docs/product/stories/<nn>-<name>.md`, written
by `/feature` §1 in their words. The pipeline turns that story into tested,
reviewed code with no one watching. They are asked only when a step genuinely
cannot decide.

## The story and the TRD are the input

Every step reads them where they live; nothing copies them. The story
(`<nn>-<name>.md`, the owner's words) and its TRD (`<nn>-<name>.trd.md`,
engineering's design, reviewed by the seven lenses and the pre-mortem before
the owner read it) — both in the shapes `shared/hil/` checks:

- **Scenarios** (story), numbered, each naming its requirement id: the rules.
  The breakdown maps them to tasks by number; `redtest` copies each one's
  Given/When/Then verbatim into the feature file; the verifier diffs the two.
- **Journey** (story): the feature's definition of done. No task carries it;
  the feature verify walks it once every task has merged.
- **Solution**, **Observed**, **References** (TRD): whitelists. Only the
  packages, endpoints and envs Solution lists may be added; only the log
  lines, events and alerts Observed lists may be written; no vendor outside
  References appears, and every vendor inside it is ruled. The verifier holds
  every task's diff to all three; the feature verify holds the whole
  feature's files to Solution.
- **Review** (TRD): every finding the lenses and the pre-mortem raised and
  what became of it; its "Story:" outcomes were accepted or refused by the
  owner before the run.
- **Changelog** (story): every change after approval, one dated line —
  including an owner's answer to a BLOCKED.
- **The survey** (`docs/product/survey.md`, optional): one row per
  requirement, what exists on main and in the attic; read where present.

## Roles

- **The owner**: business decisions; what counts as success; top-level
  technical direction; merge; deploy. They are the only human here, and they
  are involved only when something is completely failing or when no automated
  process exists. A design that needs them on the normal path is a wrong
  design.
- **`/feature`**: the story, its check, the owner's read of it; after launch,
  QA against it (`--qa`).
- **`/software`**: the session the owner types in. It fires the `pipeline`
  skill on an approved story when it has the owner's go, relays what comes
  back, and never does the pipeline's work.
- **`pipeline`**: everything else. Each step is one agent, one fresh session,
  one short input file, one short output file.

## Steps

| # | step | agent | model | writes |
|---|------|-------|-------|--------|
| 1 | story | `/feature` §1 | — | `docs/product/stories/<nn>-<name>.md`, approved by the owner (their first read) |
| 2 | design | `trd` — the writer, then seven lenses and the pre-mortem on the draft, then the writer resolving their findings | opus | `docs/product/stories/<nn>-<name>.trd.md` — Flow, Solution, Observed, References, Review; approved by the owner (their second read). The caller then creates branch `pipeline/<f>` **and a worktree on it** |
| 3 | break down | `breakdown` | opus | `features/<f>/tasks/<t>/criteria.md` — the scenario numbers it carries and its success sentence — `design.md` beside each, and `tasks/coverage.md`, one row per scenario, checked. Reads the story, the TRD, the survey if any, and the code |
| — | **stop** | the caller | — | shows the owner the coverage table with each task's success sentence, one message (their third read); resumes on their go |
| 4 | design | `planner` | opus | cuts the task worktree from `pipeline/<f>`; `tasks/<t>/design.md`, one row per case, committed there |
| 5 | design review | `designreview` | opus | numbered findings, SOUND or GAPS; GAPS sends the design back once |
| 6 | red tests | `redtest` | opus | rules each scenario TRUE or FALSE against the code; the feature file with the scenarios verbatim, the step definitions, `tasks/<t>/tests.md`, committed on the task branch |
| 7 | plan | `planner` | opus | `tasks/<t>/plan.md`, committed |
| 8 | build | `builder` | opus | the task branch `pipeline/<f>--<t>`, gate green |
| 9 | review | `code-reviewer` (fix-code's nine lenses) ∥ `verifier` (mutations, gate, rulings, touched files, the TRD's three whitelists) | opus ×2 | `tasks/<t>/verdict.md`; PASS needs both; a BLOCK that is rework goes back to `builder` and both reviews run again, twice at most; **neither merges** |
| 10 | merge | `merger` | haiku | merges every passed task branch into `pipeline/<f>`, one at a time, in landing order |
| 11 | feature | `featureverify` | sonnet | `features/<f>/verdict.md` — the story's Journey walked end to end, every fitness test, every task's tests together, the gate, the files held to the TRD's Solution; on PASS, the one push if config permits |
| 12 | clean | `cleaner` | haiku | after the merge: deletes the feature directory, the worktrees and the branches; one index line. The story and TRD stay where they live |
| 13 | prove | the caller runs config's `live:` command | — | pass/fail |

Steps 1–2 are the Story and Design stops, outside this script. Steps 4–9 run
per task, in order. Tasks in a feature run in parallel within a wave, each in
**its own worktree** on its own branch off the feature branch — one working
tree per agent is the only thing that stops two tasks eating each other's
commits. 10 runs once, after every task has passed, and merges serially. 11
runs once after that. 12 and 13 run after the merge and the deploy.

**A task may come `After` one other, and then the tasks run in waves.** Most
tasks cannot: every task's worktree is cut from the feature branch, so a task
whose work sits on top of another task's has nothing to build on. That task's
`criteria.md` carries one line — `After: <the other task's directory name>`,
one name at most, because a task that needs two others is two tasks — and the
run reads those lines before it starts anything. Tasks with no `After:` are
wave 1, tasks whose `After:` is in wave 1 are wave 2, and so on; each wave is
the same parallel `pipeline` as before, and only the boundary between waves is
a barrier, so nothing inside a wave waits for anything. The builder of a task
with an `After:` merges the named branch into its own as its first act and says
so in its commit message — by then that branch has passed both reviews, because
a wave does not start until the wave before it has finished — and both reviews
at step 9 are diffed against the named branch's tip instead of the feature
branch, or every file the named task changed would read as this task's: the
verifier's touched-files check would BLOCK it for work already reviewed, and
the code review would hand its builder a rework pass over code it did not
write. The gate is the one thing that does not move — `GATE_BASE` stays the
feature branch — because a delta gate asks only whether anything got worse
since that base, and the named task already ran the same gate green against
that same base, so its files carry no worse verdict here; a review asks a
different question, an allow-list and a judgement, and both of those answer
differently depending on whose work is in front of them. Landing order, the
order step 10 is given, is wave order and then task number inside a wave. A
name that is not one of the feature's tasks, or a set of names that loops,
halts the run before any task starts — the reason is in `blocks[]` with step
`after` and a `null` `blockedPath`, because the script found it before any
agent could write a file — and a task whose `After:` halted never runs,
recorded in `blocks[]` as `waiting on <task>`.

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
already passed. The one exception is a task with an `After:`, above: its branch
already holds the named task's commits, so both of its reviews are diffed
against the named branch's tip instead.

The seven lenses and the pre-mortem at step 2 review the *TRD*, before the
owner approves it and before code exists. `fix-code`'s nine lenses at step 9
review the *code*. Different stage, different questions.

Planner, redtest, breakdown and the code review sit on the strongest model on
purpose: the planner is the only gate that interrupts the owner, redtest is the
only guard against a test that proves nothing, and breakdown holds the one-way
doors — it maps every scenario to a task, writes the coverage table the owner
reads, from the story and the code alone. `featureverify` and `merger` are
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
list. `/software` shows the owner the coverage table — one row per scenario on
the story, naming the task that carries it — with each task's success
sentence, in their words, in a single message; never the success sentences
alone. That is their second read, and their check that nothing fell between
the story and the tasks. They say go, and a new run with `startAt:
"tasks"` builds the committed task list (inside the same session, a resume with
`confirmTasks: false` also works; it cannot cross sessions).

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
exists: the lens and pre-mortem findings live on in the TRD's Review section
and nowhere else, and the whole feature directory dies at the cleaner. There is exactly one deliberate
exception. `features/_shipped.md`, one line per shipped feature, is the index
from a feature to the tests that guard it — the map you need after everything
else is gone, and a line, not a document. What the feature was for is the
story, and the story was never in the feature directory: it lives at
`docs/product/stories/<nn>-<name>.md` before the run and after it. (History:
until 13 Sept 2026 the owner-read file was a `spec.md` copied into the
feature directory and moved to `spec/<f>.md` by the cleaner; the story
replaced it, and nothing is copied or moved now.)

Inputs are not outputs and are never deleted: the story, the lens checklists
(generic and this repo's overlay), `triage.md`, the templates, and `config.md`
are what the pipeline is made of, not what it produced.

Language: business terms in every file the owner might read — the story,
`criteria.md`, `coverage.md`, `BLOCKED.md`. Files that only feed the next step —
`design.md`, `plan.md`, `tests.md`, `verdict.md`
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
