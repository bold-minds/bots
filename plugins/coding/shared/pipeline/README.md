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
- **Reviewed: <date>** (TRD): the seven lenses and the pre-mortem have
  reviewed it and their findings are folded into the sections; the TRD
  carries nothing else of its review. The trail is
  `.claude/pipeline/reviews/<nn>-<name>-<date>.md`.
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
| 9 | review | `verifier` — mutations, gate, rulings, touched files, the TRD's three whitelists, and fix-code's lens list on the diff | opus | `tasks/<t>/verdict.md`; a BLOCK that is rework goes back to `builder` and the review runs again, twice at most; **never merges** |
| 10 | merge | `merger` | haiku | merges every passed task branch into `pipeline/<f>`, one at a time, in landing order |
| 10b | merge check | `builder` | opus | the gate on the merged branch; a red that is only the tasks' tests not building together (a helper two tasks both declared) is a merge rework — test files only, no assertion touched, committed as `merge rework:` — at most twice; any other red is BLOCKED |
| 10c | practitioner | `lens` with `lenses/practitioner.md` alone | opus | a working developer in the language reads the merged diff with no TRD, standard or CLAUDE.md in hand: "would I be embarrassed to have my name on this?" — a gate in a .md, a test of a script, a fake repo under testdata, one test file per task, a 200-line helper. `# REFUSE` with one-line rewrites goes to a `builder` rework on the feature branch, twice at most across runs; the third refusal is BLOCKED. The rework records what moved under a `## Rework` heading in each affected `tests.md`, one line per change, and leaves the table as written; the feature verify runs the names that heading gives |
| 11 | feature | `featureverify` | sonnet | `features/<f>/verdict.md` — the story's Journey walked end to end (through the stub where it names an address; by the gate and the tests where it is those), every fitness test, every task's tests together, the gate, the files held to the TRD's Solution; on PASS, the one push if config permits |
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
a barrier, so nothing inside a wave waits for anything. One task may say
`After: all` — a threshold or a total that only holds over every other task's
work; it runs in a final wave after step 10 and 10b have merged and checked
the others, cut from the feature branch that holds them, and is then merged
and checked in a second round before step 11. The builder of a task
with an `After:` merges the named branch into its own as its first act and says
so in its commit message — by then that branch has passed its review, because
a wave does not start until the wave before it has finished — and the review
at step 9 is diffed against the named branch's tip instead of the feature
branch, or every file the named task changed would read as this task's: the
touched-files check would BLOCK it for work already reviewed, and the lenses
would hand its builder a rework pass over code it did not write. The gate is the one thing that does not move — `GATE_BASE` stays the
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

Planner, redtest, breakdown and the verifier sit on the strongest model on
purpose: the planner is the only gate that interrupts the owner, redtest is the
only guard against a test that proves nothing, and breakdown holds the one-way
doors — it maps every scenario to a task, writes the coverage table the owner
reads, from the story and the code alone. `featureverify` and `merger` are
cheap because neither has a judgement to make: one re-runs five things that are
green or not, the other merges a named list in a named order.

## One file per repo

`.claude/pipeline/config.md` in the repo, plain `key: value` lines:

```
release: <the release file, docs/product/<release>.md — the board's written form; pm reads it first>
requirements: <the requirements file, one id per requirement>
decisions: <the ADR directory, docs/adr>
attic: <optional — the attic survey reads, with include/ and defer/ under it>
gate: <the command that must be green before anything ships>
test: <the command that runs one named test, with any env it needs. Write the
       test's name in it as the literal <TestName>, and if this repo has more
       than one module write the directory as the literal <module dir> — every
       step that runs it is told to substitute both and change nothing else.
       Anchor the name so a prefix cannot match a neighbour.>
size: <optional — the file-size limit in lines the gate's size arm holds
       every file to. Passed to redtest as the number to stay under; when the
       line is absent, redtest is told the repo has none and looks nowhere>
entry: <the program's entry points, comma-separated>
stub: <where the local end-to-end environment lives, if any>
live: <a command that asks production whether it is healthy, if any>
test_address: <the test environment's public address; qa walks the story there at the Test stop>
prod_address: <production's public address; qa walks the story there at the Launched stop>
test_phone: <the phone qa texts from for the texting scenarios; without it they are blocked, never skipped>
push: not confirmed
```

`pm` (or `/software`) reads it and hands every value to the skills as
arguments; a relative path is resolved against the repo root before it is
passed, so one file is right in every worktree. No agent knows a path of its
own. The board's artifact URL is the release file's `Board:` line, not a
config key.

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

When more than one ruling is pending, `answerStep` is an object keyed like
`answers` — `{ "<feature>/<task>": "review-1", "<feature>": "merge" }` — one
step per key. **`"*"` is for a task key in a fresh session only**, where no
cache exists and every step of that task re-runs anyway; it never reaches a
feature-level key. On 15 Sept a feature-level `"*"` put the owner's
merge-conflict ruling into the first prompt of the run — the haiku agent
that lists the task directories — which then merged four task branches,
resolved conflicts with `checkout --theirs`, rewrote three test files and
committed them on the feature branch, where no verifier reads test history.
A feature-level ruling names its step, as every feature-level halt returns
it, or reaches nothing.

**A review BLOCK usually does not halt.** Most of what the review at step 9
returns is rework — test files over the size cap, lint findings the change
added, a mutation that survived — and that is the builder's work, not the
owner's. So when the review comes back BLOCK, its text goes back to `builder`
as "fix these, then re-run the gate", in the same task worktree on the same
branch, and the review then runs again on the branch as it stands. Twice at
most (`REWORK_MAX`); after that the run halts to the owner carrying the last
review text in the block record — `blocks[].verify` — which is the whole
account of it, because a rework block writes no `BLOCKED.md`.
`blocks[].blockedPath` is `null` there, and that null is how the two halts
are told apart: a path means there is a file to read, and its absence beside
a path means the agent died.

**That halt's `answerStep` is `rounds`**: when the rework passes run out
with neither side asking the owner anything, one agent reads every round and
writes `rounds.md` — why so many, and the one change that reduces them
without dropping a check — and the task halts until the operator applies
it; each "## Change applied" heading buys three more rounds. (A rework
builder that itself blocks halts at its own step, `rework-1` or `rework-2`,
and the ruling goes there; the review then runs again, live, on the branch
as the builder leaves it.) The exception is a block only the owner can settle: the reviewer puts
`BLOCKED:` on its **first** line, `triage.md`'s shape, and that one skips the
loop and halts at once — no build pass answers a question about a promise to
a customer. A dead agent halts too; there is nothing to hand back. Each
round's dispatches carry their own step names — `review-1`, `rework-1` — so
an answer keyed to one round re-runs that round alone and every call before
it stays cached.

**What a resume does not repeat.** A task whose review passed leaves an
untracked `passed` file in its worktree naming the tip; the design step
reads it, returns the word `passed`, and every step after hands that word
on without a dispatch. The feature's tail has the same marks in the feature
directory — `mergecheck.passed`, `practitioner.passed`, `feature.passed`
(with the pushed ref on its second line) — each naming the tip it passed,
so a resume after a halt at `feature`, or a fresh run, does not run the
gate, the practitioner and the feature verify again on a tip already
judged. The practitioner's three passes are per feature across runs,
counted from the "practitioner pass" lines its rework appends to the
feature's `rounds.md`; an owner's answer to a practitioner block starts the
count over. The verifier records each break it makes as a patch under the
task's `mutations/`, untracked; a re-review replays them and chooses new
breaks only for the rows the rework reached.

**A halt whose `blockedPath` is set, with no `BLOCKED.md` and no `verdict.md`
at those paths, means the agent died.** The runner says so, and names the paths
where those files would have been. A halt whose `blockedPath` is `null` is the
rework halt above — nothing died, nothing wrote a file, and the record is the
review text.

## Rules every agent follows

`triage.md`, beside this file. In one line: decide everything you can; ask the
owner only what changes a promise, costs money, contradicts a ruling, or sets
top-level technical direction; and before writing anything, ask whether the
next step gets quality or rework from it.

**Nothing outlives its usefulness.** A file dies the moment its successor
exists: the lens and pre-mortem findings live on as TRD lines and in the
review trail, and the whole feature directory dies at the cleaner. There is exactly one deliberate
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

## Driving a run

What the room that fires `pipeline` — `pm`, or `/software` — does around it. Moved here from `commands/software.md` on 13 Sept 2026 (REWORK C12); the room file stays short and this is the runbook.

**Set up.** Create the feature branch and a worktree on it, once, before the
first run — every feature-level file is written and committed in that
worktree, and each task cuts its own worktree from that branch:

```
git -C <root> worktree add <root>/../wt-<name> -b pipeline/<name> <default branch>
```

if `pipeline/<name>` does not already exist. The story is the feature's
spec: `/feature` §1 writes it at `<root>/docs/product/stories/<nn>-<name>.md`,
runs `shared/hil/check.sh story`, shows the owner the whole story and waits
for their edit or go. Then the Design stop: the `trd` skill
(`${CLAUDE_PLUGIN_ROOT}/skills/trd/SKILL.md`) writes the TRD beside it,
has the seven lenses and the pre-mortem review it, and shows the owner;
they accept or refuse each proposed scenario and say go. Nothing copies
either file: every step of the run reads them at those paths, passed as
`story` and `trd`, and a word the owner changes there changes the tests.

Fire the pipeline when three things are true: the story is approved (it
is listed in `docs/product/<release>.md` with its approval), its TRD is
approved (committed, carrying its `Reviewed:` line), and they said go —
or said earlier not to ask. Otherwise show three lines (the feature, its
Shows line, its scenario count) and wait for one word.

When the run stops at the task list, show the owner the coverage table
(`tasks/coverage.md`, one row per scenario on the story and the task that
carries it) with the Success lines, never the Success lines alone. Claire,
8 Sept: "I'm not going to approve any slice without seeing the mapping of
tasks to requirements/rules."

**What it does.** It runs on its own from an approved story and its
approved TRD: a breakdown into small tasks with the coverage table, then
for each task a design and its adversarial review, tests that fail first,
a short plan, the build, and one review. Then it merges the tasks
together, one at a time, and checks the whole feature. It comes back with
one branch to merge, or one question in plain language. The design and its
review — the seven lenses and the pre-mortem — happened before, on the TRD,
at the Design stop.

**Pass, as a JSON object:** `feature`; `root` (`git rev-parse
--show-toplevel`); `plugin` (`${CLAUDE_PLUGIN_ROOT}`); `featureTree` (the
worktree path above); `story` (the approved story's absolute path); `trd`
(its approved TRD's absolute path); `survey` when
`docs/product/survey.md` exists; `defaultBranch`; and from
`<root>/.claude/pipeline/config.md`: `decisions`, `requirements`, `gate`,
`test`, `entry`, `stub`, `size` when the line is there (the file-size limit
redtest stays under; without it redtest is told there is none), and `rules`
when the line is there (the owner's cross-cutting file, whose "Asked on
every slice" list every feature answers). A relative path in `config.md` is resolved against `root` before
it is passed — every agent runs in its own worktree, and a relative path
handed through would resolve somewhere else in each. Keep the `runId` and
`scriptPath` from every result.

**It stops twice on purpose.** After the breakdown it comes back with the
task list: show the owner `tasks/coverage.md` with each task's `criteria.md`
**`Success:` line** beside its rows, in their words, in one message — that
is their second read, and it is the only time they see the tasks.
Then, on their word, a new run with the same args plus `startAt: "tasks"`:
it skips the front half and builds the task list already committed on the
feature branch. (A resume with `resumeFromRunId` and `confirmTasks: false`
also works inside the session that ran the front half; it cannot cross
sessions.) If they said earlier not to be asked, pass `confirmTasks: false`
from the start.

**On a block** it comes back with the question. Where the question is is
what `blocks[].blockedPath` tells you, and there are two kinds:

- **An owner block** — a step asked the owner something. `blockedPath` names
  the file. Relay its three lines verbatim.
- **A rework halt** — the review ran out of rework passes without asking
  the owner anything. `blockedPath` is `null` because **no step wrote a
  `BLOCKED.md`**; the whole record is `blocks[].verify`, the last review
  text. Relay what it says the builder could not settle, in the owner's
  terms, and ask the one question that decides it. Never send them looking
  for a file that was never written.

A rework halt's `answerStep` is `rounds` — the evaluation step that wrote
`rounds.md` — unless the rework builder itself blocked, when it is that
builder's step (`rework-1`, `rework-2`). Pass the `answerStep` back exactly
as the result gave it and the right step re-runs on its own.

Either way, relay the question and pass their one-line answer back on the
next run as an argument — `answers: { "<feature>": "<their line>" }`, or
`answers: { "<feature>/<task>": "<their line>" }` for a task-level block —
**plus `answerStep`, copied from the `answerStep` the result returned beside
that key**, alongside the same args and the same run id. Both, every time:
the key alone reaches every step at that level and re-runs the lot, and the
runner ignores an answer whose step is missing, so the cached block comes
straight back. With the step, exactly one prompt changes, that step re-runs
with the ruling in front of it — deleting its `BLOCKED.md` if there was one
— and everything before it stays cached. Never write the
answer into `BLOCKED.md`: a finished step is cached by its prompt, so an
answer that is not in the prompt never re-runs the step that asked. Record
the ruling as one dated line in the story's Changelog — the story is the
record of every change after approval. Never start a fresh run — that
re-runs every step that had finished.

One halt is a restart, not an answer: a case redtest left out of a task's
tests. No step after the plan commit may touch a test, so no answer can
add one, and a ruling on the `answers` line reaches only the step it names
— redtest would re-run reading the same criteria and could leave the same
case out. With the owner's word, three things by hand. Write the missing
cases into that task's `criteria.md` in the feature worktree and commit it
on `pipeline/<feature>`; the fresh task branch is cut from there and every
step reads that file. Remove the task's worktree and branch —
`git -C <feature worktree> worktree remove --force ../wt-<feature>-<task>`,
then `git -C <feature worktree> branch -D pipeline/<feature>--<task>`.
Then resume with `answerStep: "design"` for that task — not the `review`
or `review-N` step the result returned, which would re-run the verifier
on the same frozen tests and block again — with the `answers` line saying
the criteria now carry the cases. The design step's prompt changes, and
every step after it runs live again on a branch cut fresh from the
feature branch. The other tasks in that wave re-run live too. One that
had passed: its design, red-tests, plan and build steps each see their
work already on the branch, return it and change nothing, and its
reviews run again on the finished branch, diffing in the merge-base form
so the criteria commit on the feature branch is not charged to it. One
that was itself halted: every step finds its BLOCKED.md still there with
no ruling naming it, returns the first line, and it halts again as it
did, costing one dispatch per step.

**When a task is added after the run first listed the tasks** — a
final-wave task written once the merged tree showed a number the first
cut never measured — the listing step's prompt has not changed, so a
resume replays its cached five names and never sees the sixth. Pass
`tasksVersion: "<the feature branch's commit after the change>"` on every
resume from then on: it is written into the listing prompt, so the
directory is read live once per version and stays cached under it, and an
`answers` line for some other step does not undo it (an `answers` line on
the `tasklist` step works once and is lost the moment the next resume
answers a different step — 02, 15 Sept).

**When it passes** it returns the feature branch and, if the config's
`push:` line permits, the remote ref — one push per feature. Then the
`pr` skill (`${CLAUDE_PLUGIN_ROOT}/skills/pr/SKILL.md`): it opens the PR
with the tests in the owner's words at the top and the verdict as the
body, waits for CI — the absolute-mode run on the whole repo, the first
that judges it — merges on green (ruled 13 Sept 10:54), runs `live:`,
writes the card and republishes the board. The owner's PR read is a skim.
A red check is the backlog's, not this feature's; nothing merges, and the
merge waits for the story that owns the red.

After the merge, `pr` dispatches `coding:cleaner` with five things: the **feature
name** `<name>`, the feature directory
`<root>/.claude/pipeline/features/<name>`, the pipeline directory
`<root>/.claude/pipeline`, the **worktree directory** `<root>/..` — the one
the worktrees sit in — and **every** worktree path to remove:
`<root>/../wt-<name>`, every `<root>/../wt-<name>-<task>`, and every
`<root>/../vf-<name>-<task>`, the detached worktree each task's verifier
cuts. Name the `vf-` ones explicitly: nothing else removes them, `git
worktree prune` leaves a directory that still exists, and the next run's
`worktree add` on that path is fatal. The name and the directory are what
the cleaner's own sweep is made of — it then sweeps
`<root>/../vf-<name>-*` and `<root>/../wt-<name>-*`, anchored on the name
and never `*<name>*`, for any tree a run left under a path nobody passed it,
and prints what the sweep found — including that it found nothing, which is
the only thing that says the sweep ran. The whole feature directory goes —
the story was never in it and stays at `docs/product/stories/`. **Then it
deletes the branches** — `pipeline/<name>` and every
`pipeline/<name>--<task>` — which is why it runs only after the merge: the
work is on the default branch by then, and nothing else in the pipeline ever
deletes a branch, so without this the same feature name is fatal on its
second run at the first `worktree add -b`. The merge is the deploy (a
merge to main deploys, story 04); `pr` runs the config's `live:` command
after it, and `qa` takes the story from there.

Report a run in three lines: done / ready to merge / waiting on you. Add a
fourth line — the run's `dispatches` count by model — only when they ask
what it cost. The whole of it:
`${CLAUDE_PLUGIN_ROOT}/shared/pipeline/README.md`.

**The owner does not have to describe features one by one.** The stories
are listed in order in `docs/product/<release>.md`, each approved before it
is fired. "Run story 01", "run the next one that isn't live" — fire
`pipeline` on that story and its TRD. Where a requirement has no story
yet, `/feature` §1 writes one first and the owner reads it, then `trd`
writes the design and the owner reads that. The red-test step rules what
is already true (it gets a guarding test, no build) and what is not (it
gets built). A few at a time; each run costs
real money and the first ones find the pipeline's own defects.
