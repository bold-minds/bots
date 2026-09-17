---
name: pipeline
description: The unattended run that takes an approved story and its TRD to one pushed feature branch — breakdown, a stop for the owner to read the coverage table, then the tasks in waves, each task design → design review → red tests → plan → build → review, then one serial merge, then the feature as a whole, then one push. Halts on BLOCKED. Fired by /software (or pm) with arguments from the repo's .claude/pipeline/config.md; never by the owner directly.
allowed-tools: Workflow
---

# pipeline

Input: an approved story and its approved TRD (`shared/hil/` shapes, both
checked). This skill owns the Tasks and Building stops; whoever fires it
relays what it returns.

Call the Workflow tool with this script, verbatim, and `args` as a JSON object
holding: `feature`, `root`, `plugin` (this plugin's root), `featureTree` (the
worktree sitting on the feature branch), `story` (the approved story's
absolute path, `<root>/docs/product/stories/<nn>-<name>.md`), `trd` (its
TRD, `<nn>-<name>.trd.md`, reviewed and approved — every step reads both
where they live; nothing copies them), `decisions`, `requirements`, `gate`,
`test`, and optionally `survey` (the requirement-by-requirement survey of
what already exists), `entry`, `stub`, `defaultBranch`, `answers`,
`answerStep`, `confirmTasks` (default true: the run stops after breakdown
and returns the task list; the owner reads the coverage table) and `startAt`
(`"tasks"`: a new run that skips the breakdown and builds the task list an
earlier run committed on the feature branch, which is how the owner's
approval is acted on from a fresh session).

Before the first run the caller creates the feature branch
`pipeline/<feature>` from the default branch **and a worktree on it**, and
passes that worktree's path as `featureTree`. Every feature-level file is
written and committed there.

`answers` carries the owner's ruling on a `BLOCKED.md`, keyed by `"<feature>"`
for a feature-level block or `"<feature>/<task>"` for a task-level one.
`answerStep` names the step that asked — the runner returns it as `answerStep`
beside the key, and it must be passed back unchanged — except the one restart
/software describes, which answers a review halt at `design` after the task's
worktree and branch are gone. When more than one ruling is pending, pass
`answerStep` as an object keyed like `answers` (`{ "<feature>/<task>":
"review-1", "<feature>": "merge" }`), one step per key; `"*"` is for a task
key in a fresh session only and never reaches a feature-level step. `size` is
the repo's file-size limit in lines when `config.md` has a `size:` line;
without it no step goes looking for one. **Both are required for a resume to work.** A
finished call is cached by its exact prompt, and every call
after a changed prompt re-runs too, so an answer that reaches more than one
prompt re-runs everything from the earliest of them. The key alone reaches
every dispatch at that level; the key *and* the step reach exactly one. That is
what makes only the blocked step run again while every call before it stays
cached.

Keep the `runId` and `scriptPath` from every result. Resume with the **same
args object**, plus `answers` + `answerStep` and `confirmTasks: false` as
needed (the confirm stop itself, from a fresh session, needs a new run with
`startAt: "tasks"`).

```js
export const meta = {
  name: 'pipeline',
  description: 'One feature from an approved story and TRD: breakdown, a stop to read the coverage table, then the tasks in waves — per task design, design review, red tests, plan, build, review; then one serial merge; then the whole feature; then one push. Halts on BLOCKED.',
  phases: [
    { title: 'Break down', detail: 'small tasks carrying the story\'s scenarios, the coverage table, and which of them come After another; stops for the owner to read the table' },
    { title: 'Tasks', detail: 'in waves — every task with no After: first, then the ones that come After those; each task in its own worktree: design → design review → red tests → plan → build → review' },
    { title: 'Merge', detail: 'one agent merges the passed task branches into the feature branch, in landing order, one at a time' },
    { title: 'Merge check', detail: 'the gate on the merged branch; a red that is only the tasks\' tests not building together goes to a builder for a merge rework, at most twice' },
    { title: 'Practitioner', detail: 'a working developer in the language reads the merged diff with no document in hand and refuses what would embarrass them; a refusal is a builder rework on the feature branch, twice at most' },
    { title: 'Feature', detail: 'the whole feature branch: journey, fitness, every test together, the gate; then one push' },
  ],
}

const A = args || {}
for (const k of ['feature', 'root', 'plugin', 'featureTree', 'story', 'trd', 'decisions', 'requirements', 'gate', 'test']) {
  if (!A[k]) throw new Error(`args.${k} is required — /software fills it from .claude/pipeline/config.md`)
}
const f = A.feature, ROOT = A.root, PLUGIN = A.plugin, FT = A.featureTree
const SHARED = `${PLUGIN}/shared/pipeline`
// Inputs the owner maintains are read from their own checkout. Outputs are
// written in the feature worktree, on the feature branch.
const P = `${ROOT}/.claude/pipeline`
const CONFIG = `${P}/config.md`
const FB = `pipeline/${f}`
// Task branches sit BESIDE the feature branch, not under it. Git stores
// refs/heads/pipeline/<f> as a file, so refs/heads/pipeline/<f>/<t> would need
// that same path to be a directory: `worktree add -b pipeline/<f>/<t>` fails
// with "cannot lock ref … 'refs/heads/pipeline/<f>' exists" while the feature
// branch exists, which is always. The `--` separator keeps one flat namespace.
const TB = (t) => `pipeline/${f}--${t}`
const dir = `${FT}/.claude/pipeline/features/${f}`
const WT = (t) => `${FT}/../wt-${f}-${t}`
const T = (t) => `${WT(t)}/.claude/pipeline/features/${f}/tasks/${t}`
// The same task directory as a repo-root-relative path, for git pathspecs:
// an absolute path into the build worktree is "outside repository" to a git
// run in the verifier's own worktree, and a pathspec that matches nothing
// makes every history read print nothing, which is the shape of a clean
// branch.
const TREL = (t) => `.claude/pipeline/features/${f}/tasks/${t}`
const TPL = (n) => `${SHARED}/templates/${n}.md`
// The files the owner reads have their templates and one checker in shared/hil;
// the step that writes one runs the checker before it commits.
const HIL = `${PLUGIN}/shared/hil`
const HTPL = (n) => `${HIL}/templates/${n}.md`
const CHECK = `${HIL}/check.sh`
const TRIAGE = `${SHARED}/triage.md`
// The standards the builder writes to: the plugin's craft and domain
// standards, the test doctrine, and the repo's own under docs/standards/.
const REFS = `${PLUGIN}/skills/write-code/references`
const STANDARDS = `${REFS}/craft/standards.md, ${REFS}/go/standards.md or ${REFS}/frontend/standards.md for the domain the task touches, ${REFS}/gauntlet/bdd.md, and every file under ${ROOT}/docs/standards/`
const ENTRY = A.entry || 'the program\'s main entry points'
const STUB = A.stub || 'the local end-to-end environment, if the repo has one'
// The owner's cross-cutting file, when the repo has one: its "Asked on every
// slice" list is answered inside every feature and is never a task.
const RULES = A.rules || ''
// The story: the owner-approved page at docs/product/stories/<nn>-<name>.md,
// passed as args.story. Its numbered Scenarios are the rules the breakdown
// maps to tasks and redtest copies verbatim; its Journey is what the feature
// verify walks. The TRD beside it (args.trd, <nn>-<name>.trd.md, approved
// after its review): its Solution, Observed and References are the whitelists
// the verifier holds every diff to. A survey (args.survey, optional) says what
// already exists on main and in the attic. Nothing is copied into the feature
// directory: every step reads these where they live.
const SPEC = A.story
const TRD = A.trd
const SURVEY = A.survey ? `, and ${A.survey} — the survey of what already exists on main and in the attic, one row per requirement` : ''
const BASE = A.defaultBranch || 'the branch the feature branch was created from'
const CONFIRM = A.confirmTasks !== false
// The line a runner prints for one passing test. Go's is the default; a repo
// with a second runner passes args.passLine, e.g. '"--- PASS: <name>" from go
// test, or "✓ <name>" from vitest'. Every review reads for that line and
// treats a run that names no test as a failure, whatever the summary says.
const PASS = A.passLine || '"--- PASS: <that test name>"'
const PASS_SUB = A.passSubline || '"--- PASS: <Test>/<case>"'
// A review BLOCK that is rework goes back to the builder, not to the owner.
// Two passes, then the owner: a third is a builder that cannot see what the
// reviewer means, and the owner is cheaper than a fourth.
const REWORK_MAX = 2
// The gate reads GATE_BASE. With it set, the gate judges only what changed
// since that ref — findings on changed lines, the files changed, coverage and
// mutation no worse than the base. Inside a task the base is the feature
// branch: the repo's backlog is not this task's, and a gate that is red on a
// backlog can never go green for one task, so "gate green" would be a
// condition no task could ever meet. The absolute run belongs to the owner, at
// the merge to the default branch. A repo whose gate has no delta mode ignores
// the variable and runs the same absolute command it ran before — which is why
// the config key stays `gate:`: the variable is prepended here, by the
// dispatch, and never written into the repo's own command.
// A subshell, not a prefix assignment: `GATE_BASE=x (cd m && go test …)` is a
// bash syntax error when the gate is an inline command rather than a script,
// and two verifiers on story 01 met it, then ran a gate of their own.
const GATE = (base) => `(export GATE_BASE=${base}; ${A.gate})`
// The test command, said once. Every step that runs a test is handed this
// and nothing else about how to run one. Batching several names into one
// anchored alternation is allowed because the proof is the per-name line, not
// the run; a mutation is still one break, one run, one restore.
const RUNTEST = `${A.test} — run it exactly as written, substituting the test's name for "<TestName>" and the module's directory for "<module dir>" and changing nothing else; never a command of your own. Anchor the name so a prefix cannot match a neighbour: for go test that is -run '^<TestName>$'; for vitest the name is the full "describe > describe > it" path and -t matches that whole path, so substitute the whole path and do not go looking in the runner's source for how it matches. Several names in one module may run as one anchored alternation, -run '^(A|B)$', because a run is green for a name only if its output carries ${PASS} for that name: a name with no such line has not run, and "no tests to run", "no test files", or a summary "ok" without the line is a failure, never a pass`
// The four task files are read one per command. A combined cat over 25 KB is
// truncated, and re-reading the persisted copy truncates again: two dead turns
// in four of the six longest reviews.
const READ_ONE = `Read the task's files one per command — criteria.md, design.md, tests.md, plan.md — never several in one cat: a combined output over 25 KB is truncated, and re-reading the persisted copy truncates again. `
// The repo's file-size limit, from config.md, or the plain statement that
// there is none: without this every redtest went hunting for a number in the
// gate script and the plugin's references (27 of 28, about five turns each).
const SIZE = A.size
  ? `The repo's file-size limit is ${A.size} lines (config.md size:), and the gate's size arm sits behind the tests arm, so a red test hides it from you: keep every test file and every shared setup file under it, split into more files if need be, because nobody after you may touch a test and an oversized one restarts the task from here. `
  : `This repo sets no file-size limit (config.md has no size: line): do not go looking for one in the gate script or the plugin's references. `

// A verdict word may carry markdown emphasis or a heading or a bullet — `**PASS**`,
// `# PASS`, `- PASS` — and nothing else. Not `\W{0,4}`: that also matched `--- `, so
// a verifier's evidence line `--- PASS: TestX (0.4s)` read as its verdict.
const MD = String.raw`(?:\*{1,2}|_|#{1,6}\s*|-\s)?`
const isBlocked = (r) => typeof r === 'string' && new RegExp(`^${MD}BLOCKED:`, 'm').test(r)
const bad = (r) => !r || isBlocked(r)
// A verdict is its FIRST non-empty line and nothing else. Testing the whole
// text with an /m regex lets "# BLOCK: the journey failed" followed by prose
// containing the word PASS read as a PASS — the block's own explanation
// clears the block.
const firstLine = (r) => (String(r || '').split('\n').find(l => l.trim()) || '').trim()
// An owner-level block is triage.md's shape: "BLOCKED:" on the FIRST line.
// Anything else a reviewer returns — "VERDICT: BLOCK: …", "# BLOCK: …" — is
// rework, and rework is the builder's. Testing the whole text with an /m regex
// would turn a reviewer who quotes the word into an owner block, for the same
// reason firstLine exists. The leading \W{0,4} is the same allowance crPass
// makes for a reviewer writing markdown: "**BLOCKED:** …" and "- BLOCKED: …"
// are the owner's question in bold or in a bullet, and a bare ^BLOCKED: reads
// them as rework — which sends a question about a promise to a customer to the
// builder, the one place that cannot answer it.
const ownerBlock = (r) => new RegExp(`^${MD}BLOCKED:`).test(firstLine(r))
// Each rework round gets its own step name. An owner's answer is gated on the
// key AND the step, so an answer to round 2's review must not also match round
// 1's prompt: that would re-run the earliest match and drag every call after it
// along. Round 0 keeps the bare name, so nothing that already ran moves.
const stepAt = (base, attempt) => attempt ? `${base}-${attempt}` : base
const tally = { opus: 0, sonnet: 0, haiku: 0 }
const count = (m) => { tally[m] = (tally[m] || 0) + 1 }
// The owner's answer arrives as an argument, never as an edit to BLOCKED.md.
// Every finished call is cached by its (prompt, opts), and a changed prompt
// re-runs that call AND everything after it. So the answer is gated on the
// step that asked as well as the key: with the key alone it would reach every
// dispatch at that level, the earliest of them would re-run, and the whole
// level after it would re-run behind it. `answerStep` is what the runner
// returned beside the key, passed back unchanged.
//
// Two steps have no BLOCKED.md behind them. A rework step: the review loop ran
// out of passes and neither review asked the owner anything, so no step wrote a
// file. And the `after` step: the wave plan is built from the criteria files by
// the script, and a bad plan halts before any agent could write one. Pointing
// an agent at BLOCKED.md in either case sends it looking for something that was
// never written, and telling it to delete that file is an instruction it cannot
// carry out.
const stepHasNoBlockFile = (step) => /^rework(?:-\d+)?$/.test(String(step || '')) || step === 'after' || step === 'tasklist' || step === 'rounds' || step === 'design' || step === 'designreview' || step === 'practitioner'
// answerStep is one step name for every key, or an object keyed like answers
// — { "<feature>/<task>": "review-1", "<feature>": "merge" } — so two rulings
// pending at once each reach their own step and nobody reaches for "*".
const stepFor = (key) => (A.answerStep && typeof A.answerStep === 'object') ? A.answerStep[key] : A.answerStep
// answerStep "*" reaches every step of that TASK: a run started in a fresh
// session has no cache, so every step re-runs and each one meets the same
// BLOCKED.md; gated on one step, the steps before it halt on the file. It
// never reaches a feature-level key. Every feature-level halt returns its own
// step name, and "*" on the feature key put a merge-conflict ruling into the
// first prompt of the run — the haiku agent that lists the task directories —
// which then merged four task branches, resolved conflicts with `checkout
// --theirs`, rewrote three test files and committed them on the feature
// branch, where no verifier reads test history (pattern-kept, 15 Sept). A
// feature-level ruling names its step or reaches nothing.
const ANSWER = (key, step) => {
  if (!(A.answers && A.answers[key])) return ''
  const s = stepFor(key)
  if (!(s === step || (s === '*' && key.includes('/')))) return ''
  return stepHasNoBlockFile(step)
    ? `The owner has ruled on the question this step raised: "${A.answers[key]}". Apply it as a ruling. Delete BLOCKED.md only if one is actually there — this step writes none. `
    : `The owner has ruled on the question in BLOCKED.md: "${A.answers[key]}". Apply it as a ruling, then delete BLOCKED.md if it is there. `
}
// A read-only probe carries a ruling only so that it re-reads live; the ruling
// is never something for it to act on. Said in the prompt, after the ruling.
const PROBE_ONLY = `Whatever ruling appears above, your only act is the read this prompt asks for: you merge nothing, write nothing, commit nothing, and change no file. `
// The design step's "passed" comes back as the bare word or as a sentence
// about the passed file matching HEAD; the guard reads both, because the
// redtest, plan and build steps skip on it and a sentence that fails the
// regex costs three opus dispatches (20 of 72 in the first four stories).
const isPassed = (r) => typeof r === 'string' && (/^\s*`?passed`?[.!]?\s*$/i.test(r) || /`?passed`? file(?:'s)? first line matches/i.test(firstLine(r)))
// `per` is where the step finds the rule for what is the owner's: triage.md
// for most steps, and "your definition" for the verifier, which carries the
// list so it reads one file fewer at its largest context.
const BLOCK_RULE = (where, per = TRIAGE) =>
  `If ${where}/BLOCKED.md is already there and no ruling above names it, the owner has not answered yet: return its first line and change nothing — a resume re-runs every step after the one that changed, this one included. If you must stop per ${per}, write ${where}/BLOCKED.md — first line "BLOCKED: <one plain sentence>", then your best default in one sentence, drawn from the nearest existing thing in this repo and naming it, then what changes if the owner says otherwise — and return that first line as your whole result.`
const FEATURE_BLOCK = (b, step) => ({ blocked: b, blockedPath: `${dir}/BLOCKED.md`, answerKey: f, answerStep: step, dispatches: tally })

// A run may start at the tasks. The front half stops at the task list for the
// owner, and a resume cannot cross sessions, so the run that builds is a new
// one: startAt: 'tasks' skips the breakdown and reads
// the task directories the earlier run committed on the feature branch.
let tasks
if (A.startAt === 'tasks') {
  count('haiku')
  const listed = await agent(
    `${ANSWER(f, 'tasklist')}${A.tasksVersion ? `Task list as of ${A.tasksVersion}. ` : ''}${PROBE_ONLY}List the directory names under ${dir}/tasks, one bare name per line, nothing else: no bullets, no backticks, no trailing slash. Ignore files such as coverage.md. If the directory does not exist, return the single word NONE.`,
    { agentType: 'coding:breakdown', phase: 'Break down', label: 'tasks: already cut', model: 'haiku' })
  if (bad(listed)) return { halted: 'Break down', ...FEATURE_BLOCK(listed || 'BLOCKED: the agent listing the task directories died before returning them', 'tasklist'), blockedPath: null }
  // Landing order is the number in the name; a directory listing promises no
  // order of its own, and the merge step is handed this order as the truth.
  tasks = listed.split('\n').map(s => s.trim().replace(/^[-*`\s]+|[`/:\s]+$/g, '')).filter(s => /^[0-9]{2}-[a-z0-9-]+$/.test(s)).sort()
  if (!tasks.length) return { halted: 'Break down', ...FEATURE_BLOCK(`BLOCKED: startAt is "tasks" but no task directory names came back from ${dir}/tasks. The listing returned: ${listed.slice(0, 200)}`, 'tasklist'), blockedPath: null }
  log(`tasks: ${tasks.length}, already cut`)
} else {
phase('Break down')
count('opus')
const bdText = await agent(
  `${ANSWER(f, 'breakdown')}Read the story ${SPEC}, its TRD ${TRD} — the approved design: Flow, Solution, Observed, References, one cohesive draft with its review already folded in — ${A.requirements}${RULES ? `, ${RULES}` : ''}, ${A.decisions}${SURVEY}, and the code as it stands in ${FT} — a worktree on ${FB} — traced from ${ENTRY}: those are your only inputs, and nothing else in the feature directory is. The story's numbered Scenarios are the rules, and they are the whole of what gets built: a case not on the story is not a task, not a criterion, not a row. Write one ${dir}/tasks/<nn>-<short-name>/criteria.md per task from ${TPL('criteria')}, in landing order, each with its Success line filled in: at most five tasks, every one a thing the owner or a customer can see working when it is done, none that exists only to serve another task (a harness, a library, a recording, a stand-in, a test environment is part of the task that first needs it, never a task), none whose Success is about a script, a gate, a threshold or a check rather than a behaviour — a gate is proven by running it on the real tree, so a scenario about one goes on the task that makes the number true (After: all), never on a task that tests the gate (story 01, 14 Sept: a task tested a shell line against a fake repo, and a working developer refused it) — the Success line one plain sentence of at most twenty words. Name in each criteria.md, under "Files:", the test file the task writes into: one harness file per module shared by every task, and one table-driven file per behaviour group the tasks add rows to, never one file per task or per scenario — thirteen test files for eight scenarios is the thing to prevent${RULES ? `, and the "Asked on every slice" list in ${RULES} answered inside the tasks it touches, never as a task` : ''}. A task's "Rules:" line names the scenario numbers it carries and criteria.md adds no Given/When/Then of its own — the scenarios' text stays on the story, and every step after you reads it there. Beside every criteria.md write ${dir}/tasks/<that task>/design.md from ${TPL('design')}: one row per case the task makes true, from the scenarios it carries and the code as it stands, every enumeration the scenarios or the code carry as its own rows, each row something a test could check. A design over twenty rows is a task too big for its tests to carry the meaning: split it before you return, into parts each a thing the owner or a customer can see working when it is done, each with its own criteria.md and design.md, with an "After:" line where one part builds on another. The five-task cap counts customer-visible outcomes, not branches, so a split never breaches it. No task carries the Journey: the feature verify walks the story's Journey directly once every task has merged. A task that cannot start until another task's work exists — the package, the file, the table it builds on is created by that one, and a worktree cut from ${FB} does not have it — carries one "After: <that task's directory name>" line, at most one name and always a lower-numbered task; most tasks carry none. A scenario that can only be made true over every other task's work together — a coverage total, a threshold, a count over the whole feature — goes in one task that carries "After: all": it runs alone in a final wave after the others have merged, cut from the feature branch that holds them all, and its design rows are what reaches the number on the real tree, not a fixture (behaviour-tested, 14 Sept: the gate's 80 was designed against a fixture and the merged tree measured 68). At most one task says all. Every scenario must land in a task: each numbered scenario on the story${RULES ? `, and every numbered line of the "Asked on every slice" list in ${RULES} (X<n>),` : ''} is named on the "Rules:" line of the task that satisfies it; write ${dir}/tasks/coverage.md from ${HTPL('coverage')}, one row per scenario keyed by its number and requirement id, plus the Journey row, and a scenario with no task is a BLOCKED, not a row — nothing on the story is deferred, and "plan only" and "note" are not places. The owner reads that table: run bash ${CHECK} coverage ${dir}/tasks/coverage.md --story ${SPEC} and fix every line it prints before you commit; a table the checker rejects is not shown to anyone. Then, in ${FT}, git add the feature directory — the new task files and coverage.md — and commit it. Return ONLY the task directory names, one per line, nothing else. ${BLOCK_RULE(dir)}`,
  { agentType: 'coding:breakdown', phase: 'Break down' })
if (bad(bdText)) return { halted: 'Break down', ...FEATURE_BLOCK(bdText || 'BLOCKED: the breakdown agent died before writing any task', 'breakdown') }
tasks = bdText.split('\n').map(s => s.trim()).filter(s => /^[0-9]{2}-[a-z0-9-]+$/.test(s))
if (!tasks.length) return { halted: 'Break down', ...FEATURE_BLOCK(`BLOCKED: breakdown returned no task names. It returned: ${bdText.slice(0, 200)}`, 'breakdown') }
log(`tasks: ${tasks.length}`)
}

// A task may carry one "After: <task>" line in its criteria.md — it cannot
// start until that task's work exists. This script has no filesystem, so one
// cheap dispatch reads the criteria files themselves rather than trusting a
// second copy of the fact in breakdown's return text. The same names do two
// jobs: they order the waves, and each is handed to a builder as the branch to
// merge first. A graph that disagreed with the files would send a builder to
// merge a branch this run never sequenced — the one thing the waves exist to
// stop — so the graph is read from the files that carry the rule.
count('haiku')
const afterText = await agent(
  `${ANSWER(f, 'after')}${PROBE_ONLY}Read each of these files: ${tasks.map(t => `${dir}/tasks/${t}/criteria.md`).join(', ')}. Each may carry one optional line that begins "After:" and names another task's directory name. Return exactly ${tasks.length} lines and nothing else — no prose, no heading, no code fence — one per task, in this order: ${tasks.join(', ')}. Each line is "<task directory name> after: <the name on that task's After: line>", or "<task directory name> after: none" when that file has no After: line. Copy each name exactly as the file spells it: do not tidy it, do not infer one from the numbering, do not skip a task. Write nothing and change nothing. ${BLOCK_RULE(dir)}`,
  { agentType: 'coding:breakdown', phase: 'Break down', label: 'after: the dependency lines', model: 'haiku' })
if (bad(afterText)) return { halted: 'Break down', ...FEATURE_BLOCK(afterText || 'BLOCKED: the agent reading the After: lines died before returning them', 'after') }

// dep[t] is the one task t must come after, or null. graphBad collects the
// tasks whose line cannot be used — an unknown name, a self-reference, a
// missing answer, or a cycle. Any of them halts the run before a task starts:
// a wave order built on a broken graph runs tasks in an order nothing checked.
const dep = {}, graphBad = []
// A task with "After: all" needs every other task's work under it — a coverage
// total, a threshold, a whole-feature check. It runs in a final wave AFTER the
// merge, cut from the feature branch that holds every other task, so dep[t]
// stays null for it (nothing to merge in, the feature branch is its base).
const final = new Set()
const afterLines = String(afterText).split('\n').map(s => s.trim()).filter(Boolean)
for (const t of tasks) {
  // "^<name>\s" and not a bare prefix: 01-config must not read 01-config-list's
  // line. Task names are /^[0-9]{2}-[a-z0-9-]+$/, so nothing here is a regex
  // metacharacter.
  const line = afterLines.find(l => new RegExp(`^${t}\\s`).test(l))
  const a = line ? ((line.match(/\safter:\s*([^\s.]+)/i) || [])[1] || '') : ''
  if (!a) graphBad.push({ task: t, why: `BLOCKED: no "After:" answer came back for ${t}, so the pipeline cannot tell whether it may start in the first wave. Read ${dir}/tasks/${t}/criteria.md and say whether it carries an After: line and what it names.` })
  else if (/^none$/i.test(a)) dep[t] = null
  else if (/^all$/i.test(a)) { if (tasks.length < 2) graphBad.push({ task: t, why: `BLOCKED: ${t}'s After: line says all, but it is the only task.` }); else { dep[t] = null; final.add(t) } }
  else if (a === t) graphBad.push({ task: t, why: `BLOCKED: ${t}'s After: line names ${t} itself, so nothing can ever start it.` })
  else if (!tasks.includes(a)) graphBad.push({ task: t, why: `BLOCKED: ${t}'s After: line names ${a}, which is not one of this feature's tasks (${tasks.join(', ')}).` })
  else dep[t] = a
}
// Wave 1 is every task with no After:. Wave n+1 is every task whose After:
// landed in a wave already built. A task left over when no further wave can be
// built is in a cycle, or waiting on one.
const waves = []
let unplaced = tasks.filter(t => !graphBad.some(b => b.task === t) && !final.has(t))
const finalWave = tasks.filter(t => final.has(t))
const placed = new Set()
while (unplaced.length) {
  const w = unplaced.filter(t => !dep[t] || placed.has(dep[t]))
  if (!w.length) {
    const loop = unplaced.map(t => `${t} after ${dep[t]}`).join(', ')
    for (const t of unplaced) graphBad.push({ task: t, why: `BLOCKED: the After: lines never reach a task that can start first, so ${t} can never be given a wave. The tasks that cannot be ordered are: ${loop}.` })
    break
  }
  w.forEach(t => placed.add(t))
  waves.push(w)
  unplaced = unplaced.filter(t => !placed.has(t))
}
if (graphBad.length) {
  log(`the wave plan could not be built from the After: lines — no task ran`)
  return {
    feature: f, branch: FB, tasks, waves: [], passed: [], halted: graphBad.map(b => b.task),
    // No BLOCKED.md: the script found this, and it found it before any agent
    // ran that could have written one. The fix is in the criteria files, and
    // because a finished call is cached by its prompt, editing them alone
    // re-runs nothing — the owner's ruling has to reach the `after` step, which
    // is what re-reads them.
    blocks: graphBad.map(b => ({ task: b.task, step: 'after', reason: b.why, blockedPath: null, verdictPath: null, answerKey: f, answerStep: 'after' })),
    dispatches: tally,
  }
}
log(`waves: ${waves.map((w, i) => `${i + 1} — ${w.join(', ')}`).join(' | ')}${finalWave.length ? ` | final, after the merge — ${finalWave.join(', ')}` : ''}`)

if (CONFIRM && A.startAt !== 'tasks') {
  log('stopping for the owner to read the task list — a new run with startAt: "tasks" builds them')
  return { awaiting: 'confirm', feature: f, tasks, waves, taskDir: `${dir}/tasks`, dispatches: tally }
}

phase('Tasks')
// A halt's message dies inside pipeline(), so record which step stopped and
// why before throwing: the step name is what the owner's answer must be keyed
// to on the resume, and without it the run has no way back. Every stage string
// below must be spelled exactly as that step's ANSWER() second argument — a
// mismatch returns an answerStep no dispatch matches, and the resume silently
// returns the cached block.
// haltNoFile records the one halt that leaves no BLOCKED.md behind: the review
// loop out of rework passes with neither review asking the owner anything.
// Every other halt either wrote the file or died trying, and for those the
// file's absence is the signal that the agent died — so a path is worth
// printing. For a rework halt there was never a file, and printing a path to
// one reads as a dead agent when nothing died.
const haltStep = {}, haltWhy = {}, lastReview = {}, haltNoFile = {}
const halt = (t, stage, r) => { haltStep[t] = stage; haltWhy[t] = typeof r === 'string' ? r : 'the agent died'; throw new Error(`${t} halted at ${stage}: ${r || 'the agent died'}`) }
const guard = (t, stage, shape) => (r) => (bad(r) || (shape && !shape.test(r))) ? halt(t, stage, r) : r

// A task with an After: merges that task's branch into its own before it
// builds. Three dispatches need to know:
//   AFTER_MERGE  — the builder, whose first act it is.
//   DIFF_BASE    — both reviews. From the build on, this branch's diff against
//                  the feature branch also holds every file the named task
//                  changed. For the verifier's touched-files check those files
//                  are in none of the three lists it allows, so it would BLOCK
//                  the task for work that already passed its own review. For
//                  the code review they are code this task did not write, and a
//                  P0/P1 on one of them sends THIS builder into a rework pass
//                  over someone else's work. Against the named branch's tip the
//                  diff is this task's own work and nothing else, which is what
//                  both of them are asking about.
//
// The gate is the one that does NOT move: GATE_BASE stays the feature branch.
// A delta gate asks whether anything got worse since a base, and the named task
// already ran the same gate green against that same base — so its files carry
// no worse verdict here. A review is an allow-list and a judgement, and both
// answer differently depending on whose work is in front of them.
const DIFF_BASE = (t) => dep[t] ? TB(dep[t]) : FB
const AFTER_MERGE = (t) => dep[t]
  ? `This task's criteria.md carries "After: ${dep[t]}", so ${dep[t]}'s work must exist before yours can stand on it. Your FIRST act, before you read the plan and before you change a file: git -C ${WT(t)} merge --no-ff ${TB(dep[t])}. That branch has passed its review — this run does not start your wave until the wave holding it has finished — and without the merge your worktree is the feature branch, which does not have what your plan is written against. Say so in your commit message, one line: "Merged ${TB(dep[t])} first: this task comes After ${dep[t]}." If the merge conflicts, stop and write BLOCKED.md asking which behaviour should win where the two changes disagree: that is the owner's, never yours. `
  : ''

const STAGES = [
  // The design: what the task makes true, one row per case, before a test is
  // written. The tests pin the rows, the builder builds to them, both reviews
  // judge against them — so meaning is settled once in a file instead of found
  // one layer per review round. A design over twenty rows says SPLIT, and the
  // run halts for the operator to re-cut the task along the parts it names.
  (_, t) => { count('opus'); return agent(
    `${ANSWER(`${f}/${t}`, 'design')}You are the task's first step, so you cut its worktree: git -C ${FT} worktree add ${WT(t)} -b ${TB(t)} ${FB} — unless ${WT(t)} already exists, in which case use it as it is. The task branch is ${TB(t)}, beside the feature branch and not under it: git cannot hold a branch ${FB} and a branch ${FB}/${t} at the same time.${dep[t] ? ` Then, before you read anything else: git -C ${WT(t)} merge --no-ff ${TB(dep[t])} — this task comes After ${dep[t]}, its design, tests and plan are all written against that work, and the feature branch does not carry it yet; "already up to date" is fine.` : ''} Work in ${WT(t)} from here on. If the file ${T(t)}/passed exists and its first line is exactly the output of git -C ${WT(t)} rev-parse HEAD, this task passed its review in an earlier session: return the single word passed — that word alone, no sentence, no hash, no backticks — and change nothing, commit nothing. If ${T(t)}/design.md is already committed on this branch, return the first line of its "Size" section and change nothing: a resume re-runs this step for every task in the wave. Otherwise read ${T(t)}/criteria.md, the scenarios its "Rules:" line names in the story ${SPEC}, the TRD ${TRD} (its Solution and Observed bound what a row may name), and the code the scenarios reach from ${ENTRY} in ${WT(t)} — branch ${FB}, not the default branch — and write ${T(t)}/design.md from ${TPL('design')}: one row per case this task makes true, every enumeration the criteria or the code carry as its own rows, each row something a test could check, in the customer's terms with the code's place beside it. Then git add and commit it in ${WT(t)}. Return the first line of the "Size" section and nothing else: the row count and either "one task" or "SPLIT" followed by the parts. ${BLOCK_RULE(T(t))}`,
    { agentType: 'coding:planner', phase: 'Tasks', label: `${t}: design` }).then(r => {
      if (bad(r)) return halt(t, 'design', r)
      if (isPassed(r)) return 'passed'
      if (/\bSPLIT\b/.test(r)) { haltNoFile[t] = true; return halt(t, 'design', `SPLIT: ${r.trim()} — re-cut ${t} on ${FB} along the parts ${T(t)}/design.md names, then run again`) }
      return r
    }) },
  // The design is reviewed adversarially by a fresh context before a test is
  // written against it: the planner who wrote it cannot see what it left out,
  // and a gap found here costs one revision, where the same gap found at code
  // review costs a round. GAPS sends the design back to the planner once; a
  // second GAPS halts for the operator.
  async (d, t) => {
    if (isPassed(d)) return d
    const review = async (pass, prev) => {
      count('opus')
      const rv = await agent(
        `${ANSWER(`${f}/${t}`, 'designreview')}${pass ? `Pass ${pass + 1}: the design was revised on the findings of the review below. Judge only two things: whether each of those findings is now addressed by a row, and whether a criterion or a rule on the Rules line is still unmet by any row. A finer point you would raise on a fresh read — wording, a row that could be split, a test-level detail — is advice, not a gap: put it under B and let the verdict be SOUND. A review that finds new gaps on every pass never ends, and the code review still stands behind this design. ` : ''}If ${T(t)}/tests.md is already committed on branch ${TB(t)} in ${WT(t)}, the design was accepted in an earlier session: return "VERDICT: SOUND" and read nothing else. Otherwise review ${T(t)}/design.md in ${WT(t)} adversarially and read-only, as your agent definition says: criteria ${T(t)}/criteria.md, the scenarios the criteria's "Rules:" line names on the story ${SPEC}, which are the task's criteria in full, the TRD ${TRD}${RULES ? `, the "Asked on every slice" and "What the gate cannot check" sections of ${RULES}` : ''}, the code every "Where in the code" cell names, and the entry points ${ENTRY}. Change nothing; run no git command that writes. Return the numbered findings and the one VERDICT line. ${BLOCK_RULE(T(t))}${prev ? `\n\n--- the previous review, whose findings the revision answered ---\n${prev}` : ''}`,
        { agentType: 'coding:designreview', phase: 'Tasks', label: `${t}: design review${pass ? ' (2)' : ''}` })
      if (bad(rv)) return halt(t, 'designreview', rv)
      if (/^\s*[-*# ]*VERDICT:\s*SOUND\b/mi.test(rv)) return rv
      if (pass >= 2) { haltNoFile[t] = true; return halt(t, 'designreview', `the design still has gaps after two revisions: ${(rv.match(/^[-*# ]*VERDICT:.*$/mi) || [firstLine(rv)])[0]} — see the review below and ${TREL(t)}/design.md\n\n${rv}`) }
      count('opus')
      const fx = await agent(
        `${ANSWER(`${f}/${t}`, 'design')}Revise ${T(t)}/design.md in ${WT(t)}, a worktree on branch ${TB(t)}, on the findings of the adversarial review below: add every missing row (A), make every untestable row checkable (B), fix every contradiction (C) and every wrong place (D), each row still one case a test could check, in the customer's terms with the code's place beside it. Update the "Size" section; if the table now passes twenty rows, write SPLIT and name the parts. Commit it in ${WT(t)} as "pipeline: ${t} design revised". Return the first line of the "Size" section and nothing else.\n\n--- the design review ---\n${rv}`,
        { agentType: 'coding:planner', phase: 'Tasks', label: `${t}: design revised` })
      if (bad(fx)) return halt(t, 'design', fx)
      if (/\bSPLIT\b/.test(fx)) { haltNoFile[t] = true; return halt(t, 'design', `SPLIT: ${fx.trim()} — re-cut ${t} on ${FB} along the parts ${T(t)}/design.md names, then run again`) }
      return review(pass + 1, rv)
    }
    return review(0, null)
  },
  (d, t) => { if (isPassed(d)) return d; count('opus'); return agent(
    `${ANSWER(`${f}/${t}`, 'redtest')}Work in ${WT(t)}, a worktree on branch ${TB(t)}. If ${T(t)}/tests.md is already committed on this branch, return its table and change nothing: a resume re-runs this step for every task in the wave, and only the restarted one has a fresh branch. Write every test into the files ${T(t)}/criteria.md names under "Files:" — the module's shared harness and this behaviour group's table file, adding rows and step definitions to what is there — and create no other test file; a helper is written once, in the harness, and is as short as the thing it helps. Read ${T(t)}/criteria.md, the scenarios its "Rules:" line names on the story ${SPEC}, and ${T(t)}/design.md. First rule each scenario TRUE or FALSE against the code in ${WT(t)} — branch ${FB}, not the default branch — with a file:line or a command as evidence, never a document, tracing from ${ENTRY}; that ruling is the "now" column of tests.md, and nobody else makes it. The story's scenario text is the scenario file: copy each scenario's Given/When/Then verbatim, with its number and requirement id, into the feature file the repo's Gherkin runner reads — never re-authored, never paraphrased; a word changed on the story changes the test and nothing else does. Every row of design.md is a case: one ${PASS_SUB} per row in the run's output, the subtest named for the row, under the test of the criterion the row serves; a row with no subtest is a case nobody after you can add. The owner's test rule (11 Sept; your definition carries it${RULES ? `, and ${RULES} restates it for this repo` : ''} — read no plugin file for it): every test is black box, written in an external test package against the module's public surface, never inside the package; every test asserts one scenario or one branch, table-driven where the rows share a shape, so a design's rows are the rows of a table; coverage 80% or more; and the fewest tests that achieve those three — a test that adds no scenario is bloat, and the verifier counts. Write the tests and ${T(t)}/tests.md from ${TPL('tests')}. The test command is: ${RUNTEST}. No task tests the Journey; the feature verify walks it. Every scenario you ruled FALSE has a test that is red now. Every scenario you ruled TRUE has a test that goes red when you break the behaviour on purpose, then is restored. A scenario that enumerates — each of N names, three states — is every case it counts, as subtests, one ${PASS_SUB} line per case in the run's output; nobody after you can add a case, so one you leave out is an owner's halt at review that restarts the task. Your tests are red for one reason only: the behaviour they ask for does not exist yet. Never for the shape of the test itself. ${SIZE}A repeated string literal is the gate's lint arm's to find, never yours to hunt: if the gate reports one, fix it in the lint commit below; if it reports none, leave every literal where it is — a hand-run repeat count hoisted "." and "/" into constants after the linter had printed 0 issues (pattern-kept, 15 Sept), and cost a quarter of the step. Commit the tests first, then check them: the gate's delta arms read the merge base and see nothing in an uncommitted file, so a lint finding in a test you have not committed is invisible until the builder commits, when nobody may touch it. So: git add the test files and tests.md by path and commit "pipeline: ${t} red tests", THEN run the gate in delta mode against the feature branch: ${GATE(FB)}. A RED on the shape of a line you wrote — a formatter, go vet, a linter rule such as a string repeated across test files, an import across a boundary — is yours to fix now, in a second commit "pipeline: ${t} red tests, lint"; commits before the plan may change tests, commits after it may not. It stops at its first RED line. On a FALSE criterion that is usually the missing behaviour showing before the tests arm — "undefined: <symbol>", a new package with no non-test Go files, a package not attached to any component in the architecture file — and it hides every arm behind it: add the smallest uncommitted stub that makes the package compile, run the gate again, delete the stub, and confirm the tests are red again before you commit. A RED on the shape of a line you wrote — a formatter, go vet, a linter rule, an import across a boundary — is yours to fix now and run again; a RED on the stub is fixed in the stub, until the gate reaches the tests arm. The three lines above go under "Gate", never into BLOCKED; any other RED on a file you did not write is BLOCKED naming the arm. Under tests.md's "Gate" heading paste the RED line the committed tests stop at, name the symbol, package or component the builder must add${dep[t] ? ` — unless ${dep[t]}, the task this one comes After, provides it: confirm with git -C ${WT(t)} grep -n <symbol> ${TB(dep[t])}, the one read of another branch you may make, then say so and name nothing for the plan —` : ' — this task has no After: line, so no other task provides it —'} and say the lint and boundary arms between that line and the tests arm, if any, ran green with the stub and that the stub is gone from the commit. A task whose criteria are all TRUE has no red test and the gate may run through; a module the gate has no test arm for cannot show one; say which. Second, write the "Green together" paragraph tests.md asks for: name, in one paragraph, the one implementation that would turn every test green at once — which package gains what, which file changes how — and check each assertion against it in your head, on paper. Do not build it, prototype it, or install anything to try it, in this tree or in a scratch copy anywhere: the uncommitted stub for the gate, above, is the only implementation you ever write, and once — a redtest that built the site's lint setup in /tmp to see its own tests pass spent forty turns doing the builder's job (site-pattern-kept, 15 Sept). Two tests that cannot both be green against one implementation contradict each other, and nobody after you may touch a test; rewrite until they agree. Then in ${WT(t)} git add the test files and tests.md each by path — never -A, never . — check git status --porcelain shows nothing but the staged test files and tests.md, and git commit -m "pipeline: ${t} red tests". Every file you commit besides tests.md is a test file or a path under testdata/, and every one is named under tests.md's "Files" heading, repo-root-relative; the verifier reads that list, and a committed file it does not name, or a named file that is neither, is a BLOCK. Return the tests.md table and nothing else. ${BLOCK_RULE(T(t))}`,
    { agentType: 'coding:redtest', phase: 'Tasks', label: `${t}: red tests` }).then(guard(t, 'redtest', /^\s*\|/m)) },
  (d, t) => { if (isPassed(d)) return d; count('opus'); return agent(
    `${ANSWER(`${f}/${t}`, 'plan')}Work in ${WT(t)}, a worktree on branch ${TB(t)}. If ${T(t)}/plan.md is already committed on this branch, return its Flag line and change nothing: a resume re-runs this step for every task in the wave. Read ${T(t)}/criteria.md, the scenarios its "Rules:" line names on the story ${SPEC}, the TRD ${TRD} — its Solution and References sections above all — ${T(t)}/design.md, ${T(t)}/tests.md, the test files, the code they exercise, and ${A.decisions}; the plan builds to every row of the design. A vendor, service or piece of infrastructure the TRD's References names is ruled — its ADR was approved before the TRD was — and is never a flag; one outside References is. Write ${T(t)}/plan.md from ${TPL('plan')}, then git add and commit it in ${WT(t)}. The Flag line is read by a machine: it is either the four characters "Flag: none" alone on the line, with nothing after them but an optional full stop, or it names the one thing that halts the chain. There is no third shape — a qualifier, a parenthesis or a "none, but …" is a flag. If the line is not exactly "Flag: none", also write ${T(t)}/BLOCKED.md with that flag as its first line, prefixed "BLOCKED: ", then your best default and what changes if the owner says otherwise. Return the Flag line exactly as written and nothing else. ${BLOCK_RULE(T(t))}`,
    { agentType: 'coding:planner', phase: 'Tasks', label: `${t}: plan` }).then(r => {
      if (bad(r)) return halt(t, 'plan', r)
      // Only the first Flag: line, and the whole of it: "Flag: none, but …"
      // and "Flag: none - …" are flags, and a "Flag: none" followed by prose
      // on its own line is not.
      // A planner that quotes the line in backticks ("`Flag: none`") is
      // saying none; the backticks are markdown, not a flag.
      const fl = ((r.match(/^[ \t]*`?Flag:.*$/mi) || [''])[0]).replace(/`/g, '').trim()
      return /^Flag:[ \t]*none[.!]?$/i.test(fl) ? r : halt(t, 'plan', r)
    }) },
  (d, t) => { if (isPassed(d)) return d; count('opus'); return agent(
    `${ANSWER(`${f}/${t}`, 'build')}${AFTER_MERGE(t)}If every test in ${T(t)}/tests.md is already green on this branch and the branch has a commit after the one that added plan.md, return the branch line and change nothing — the merge above, if any, is already in this branch's history: a resume re-runs this step for every task in the wave, and only the restarted one has a fresh branch. ${READ_ONE}Read the standards first and write to them: ${STANDARDS} — the repo's own standard is the pattern the code is built in, and a change that breaks one of its rules fails a fitness test at review. Implement ${T(t)}/plan.md, making every row of ${T(t)}/design.md true. Work in ${WT(t)} — the worktree already on branch ${TB(t)}, cut from ${FB}, holding the criteria, the state, the red tests and the plan. Do not create another worktree. Make every test in ${T(t)}/tests.md green without weakening any test, using: ${RUNTEST}. Then run the gate to green in the task worktree, in delta mode against the feature branch: ${GATE(FB)}. Green means nothing you touched got worse and nothing you added is red — the repo's backlog since before ${FB} is not this task's to clear, and the absolute run is the owner's at the merge. Never touch a test file or tests.md: a gate finding on a test line that only your finished code let the linter see means the test and the plan disagree about a signature, and that is BLOCKED.md, not an edit — the verifier fails every commit after the plan that reaches a test file, whatever its message says. Commit in ${WT(t)}, never with --no-verify: a hook that fails on your change is yours to fix, and a hook you believe is wrong about your change is BLOCKED.md with its exact output, not a flag. Never begin a commit message with the owner's name, and never quote a brief or a ruling as her words: "Claire, <date>:" is reserved for her own rulings, recorded by her operator; a brief that reached you through this pipeline is the pipeline's, and you say so. Do not push. Do not merge${dep[t] ? ` anything but the ${TB(dep[t])} merge above, and that only into ${TB(t)} — never into ${FB}` : ''}. Return exactly one line — "branch: ${TB(t)}" — and nothing else. ${BLOCK_RULE(T(t))}`,
    { agentType: 'coding:builder', phase: 'Tasks', label: `${t}: build` }).then(r => { const m = bad(r) ? null : (r.match(/^branch: (\S+)/m) || [])[1]; return m || halt(t, 'build', r) }) },
  // One fresh context that never saw the builder's reasoning: the verifier,
  // which runs the mechanical checks (tests, mutations, gate, rulings, touched
  // files, the TRD's whitelists) and applies fix-code's lens list to the diff.
  // It never merges — the Merge phase does, after every task has passed, so a
  // BLOCK can never land on an already-merged branch.
  //
  // Most of what it returns on a BLOCK is rework: test files over the size
  // cap, lint findings the change added, a mutation that survived. That is the
  // builder's work, and halting the whole feature to hand the owner a lint
  // count stops a run one more build pass would have finished. So a BLOCK goes
  // back to the builder with the review text, and the review runs again on
  // the branch as it then stands — REWORK_MAX times. Only a block that says the
  // OWNER must decide — "BLOCKED:" on the first line, triage.md's shape —
  // leaves the loop early, because no build pass can answer a question about a
  // promise to a customer. So does a dead agent: there is nothing to fix.
  async (b, t) => {
    let last = null
    // The design step already checked the passed mark against HEAD and said
    // so; every stage since has handed the word through. No probe, no review.
    if (isPassed(b)) { log(`${t}: the review passed this tip in an earlier session`); return { task: t, branch: TB(t), verdict: '# PASS (earlier session)', review: 'VERDICT: PASS (earlier session)', reworks: 0 } }
    // A task that passed both reviews in an earlier session is not reviewed
    // again: a fresh run has no cache, and a re-review of a passed branch costs
    // half an hour and can reopen it. The mark is an untracked file in the task
    // worktree naming the tip both reviews passed; a tip that has moved since is
    // reviewed like any other.
    // One haiku probe answers both questions — was this tip passed, and how
    // many review rounds has the task used — where two ran before (84 and 26
    // dispatches over four stories, always back to back).
    // Three review rounds per task, counted across launches through rounds.md
    // (the rework builder appends a row per round). A fourth round is not a
    // rework: it is an evaluation of why three were not enough, written to
    // rounds.md, and a halt until the operator applies the change it names —
    // each "## Change applied" heading in rounds.md buys three more rounds.
    count('haiku')
    const counted = await agent(
      `${PROBE_ONLY}In ${WT(t)}, return exactly one line, "passed=<PASSED|NONE> prior=<rows> applied=<headings>", and nothing else. passed is PASSED if the file ${T(t)}/passed exists and its first line is exactly the output of git -C ${WT(t)} rev-parse HEAD, else NONE. If ${T(t)}/rounds.md does not exist, prior and applied are 0; otherwise prior is the count of table rows under "## What each round found" (rows whose first cell is a number; not the header, not the divider) and applied is the count of headings that begin "## Change applied".`,
      { agentType: 'coding:breakdown', phase: 'Tasks', label: `${t}: passed before? rounds so far`, model: 'haiku' })
    if (typeof counted === 'string' && /passed=PASSED\b/.test(counted)) { log(`${t}: the review passed this tip in an earlier session`); return { task: t, branch: b, verdict: '# PASS (earlier session)', review: 'VERDICT: PASS (earlier session)', reworks: 0 } }
    const cm = (typeof counted === 'string' ? counted : '').match(/prior=(\d+)\s+applied=(\d+)/)
    const priorRounds = cm ? Number(cm[1]) : 0, applied = cm ? Number(cm[2]) : 0
    const roundsLeft = 3 + 3 * applied - priorRounds
    const maxAttempt = Math.min(REWORK_MAX, Math.max(0, roundsLeft - 1))
    let lastFrom = null
    for (let attempt = 0; attempt <= maxAttempt; attempt++) {
      count('opus')
      // Round 1's prompts have to differ from round 0's or the runner hands
      // back the cached BLOCK on code that has since been fixed: a finished
      // call is cached by its exact (prompt, opts). This line is what makes the
      // re-review a new call, and its absence at round 0 is what leaves round
      // 0 — and every step before it — cached.
      const again = attempt === 0 ? '' : `Rework pass ${attempt} of ${REWORK_MAX}: the builder has been given the previous round's findings and has just fixed them. Review the branch as it stands now, on its own; nothing the previous round said is evidence about this one. ${lastFrom ? `The previous round reviewed the tip ${lastFrom}, and the rework's commits are ${lastFrom}..${b}: read those in full, every hunk, and read the rest of the diff against ${DIFF_BASE(t)} only where a design row the rework touched reaches beyond them — every command you run, you still run over the whole branch. ` : ''}The previous round's own breaks are recorded in ${T(t)}/mutations/ as patches: replay every one — git apply, run that row's test, git checkout — in one loop, one turn; choose a new break of your own only for a design row the rework's commits reached, and re-make by hand any patch that no longer applies. A recorded patch that no longer turns its test red is a BLOCK naming the row. `
      const vfStep = stepAt('review', attempt)
      // One reviewer per task (ruled 13 Sept, REWORK C6): the verifier, which
      // now also applies fix-code's lens list to the diff. fix-code's own
      // code-reviewer is dispatched only by fix-code, for standalone audits.
      const vf = await agent(
        `${ANSWER(`${f}/${t}`, vfStep)}${again}Verify ${b} against ${T(t)}/criteria.md, the story ${SPEC}, the TRD ${TRD}, ${T(t)}/tests.md and ${T(t)}/plan.md. Check it out in a worktree of your own, detached so you do not fight the build worktree — clear any worktree a previous run left at that path first, because "worktree add" onto an existing directory is fatal: git -C ${WT(t)} worktree remove --force ../vf-${f}-${t} 2>/dev/null; git -C ${WT(t)} worktree add --detach ../vf-${f}-${t} ${b}. That path is the only worktree you may create. It is the one the cleaner knows by name; a path you invent for a comparison — ../vf-base-${f}, ../vf-baseline-${f} — is one nothing ever removes, and the next run's "worktree add" onto it is fatal. To compare against another branch, use git diff, git show, git log or git ls-tree against the branch this dispatch names for that comparison, from the worktree you already have — none needs a checkout, and there is no comparison here that needs a second tree. No other worktree, ever, at any path, for any reason. You are the task's one reviewer: the code review is yours as well as the mechanical checks. ${READ_ONE}Read ${T(t)}/design.md first and hold the change to it row by row — a finding is either a row the code does not make true, or a case no row names, and the second kind names the row to add. File manifest: every file the diff touches — read each in full. Your definition carries the lens list, the practitioner's question, the owner's test rule, the verdict's shape and the rule for when a question is the owner's: read no plugin file for any of them — six such reads, at the largest context of the review, were in five of the six longest verifies. Apply the lens list: the always-on three plus the ones its signals select for these files; read every CLAUDE.md in the repo and every standard under docs/standards/ and hold the code to them; then put every document down and ask the practitioner's one question of this diff as a working developer in this language would — a test of a script, a gate, a helper or a fixture, a fake codebase under testdata, a helper longer than what it helps, a test file the task's criteria.md did not name under "Files:", or more than three lines of test per line of production code in this task where the task's production change is over two hundred lines, is a P1 finding whatever a design row asked for — on a smaller task the ratio is a note, not a finding: a fifty-line change with eight table rows is over three to one by arithmetic and right by the owner's rule, and the ratio is judged at the feature by the practitioner (06, 17 Sept: three tasks halted on it for the owner, all three rightly under the cap once the rule was the fewest tests that carry the rows) — and those are the cases already caught, not the boundary: the lens's question covers the approach, the place, the dependencies, the words and the size too, and anything a working developer would refuse is a finding at the severity they would give it. List every finding you see in this pass by severity, not the top one — a round that reports one layer costs a whole round for the next. A P0 or P1 finding is a BLOCK; a finding that asks for a behaviour the story does not carry is not a finding but a proposed scenario, named as such and never a BLOCK. Then, hold the tests to the owner's test rule (11 Sept, in your definition${RULES ? `, and ${RULES} restates it for this repo` : ''}): every test file is an external test package, every test asserts one scenario or one branch, table-driven where rows share a shape, and the set is the fewest tests that achieve that with the coverage the gate asks; a test that adds no scenario another test already asserts is bloat and a BLOCK naming it, and so is a test reaching inside the package. Re-run every test yourself with: ${RUNTEST}. Then the mutations, your own: for each design row, break the behaviour its test guards, run that test, see it red, and before you restore record the break — mkdir -p ${T(t)}/mutations, then git -C ${WT(t)}/../vf-${f}-${t} diff > ${T(t)}/mutations/<row number>.patch — so a re-review after a rework replays your breaks instead of inventing new ones; the directory stays untracked beside the passed mark, and nothing you record here is evidence for you: you watched the red yourself. Then hold the diff to the TRD ${TRD}, section by section, as whitelists: Solution — every package, endpoint, env or file the diff adds is one a Solution line names, and one the diff adds that no line names is a BLOCK naming it; Observed — every non-error log line, product event and alert the diff writes is one Observed lists, and one it does not list is a BLOCK, as is a phone number, an email or message text in any of them; References — no vendor, service or infrastructure appears in the diff that References does not name, where a dependency only test code imports — a test runner, an assertion library, a devDependency, a go.mod line only _test files need — is test tooling, not a vendor, and is not held to References. Then read ${T(t)}/criteria.md and the scenarios its "Rules:" line names on the story against tests.md's table: every scenario has a row and its text is on the story verbatim, and a criterion that enumerates — each of N names, three states — has every case it counts as a subtest line of its test's run, ${PASS_SUB}, one per case criteria.md names or per item the code enumerates where it only counts; a criterion or a case with no test is the owner's BLOCKED.md naming what is missing, with the default that the task is restarted — the owner adds the cases to ${TREL(t)}/criteria.md on ${FB}, removes ${WT(t)} and ${TB(t)}, and answers at the task's design step — because no test may change after the plan commit and no answer can add one. Run the gate the same way the builder was told to, in delta mode against the feature branch: ${GATE(FB)} — green means nothing this task touched got worse and nothing it added is red, not that the repo's backlog is clear, and that backlog is not this task's; read ${A.decisions} and confirm nothing is reversed; diff ${b} against ${DIFF_BASE(t)} in the merge-base form, git diff ${DIFF_BASE(t)}...${b} with three dots and never the two-endpoint form, because the feature branch can gain a commit after this branch was cut and that commit is not this task's — ${dep[t] ? `the tip of ${TB(dep[t])}, the branch this task comes After and whose commits its builder merged in before it started, and NOT ${FB}: against the feature branch this diff would also carry every file ${dep[t]} changed, which is in none of the three lists below and would BLOCK this task for work that has already passed its own review` : `the feature branch, not the default branch`} — and confirm every changed file is one of three things: a file in plan.md's "Touch" list; a file under ${T(t)}/ — this task's own .claude/pipeline/ bookkeeping, design.md and tests.md and plan.md, committed on this branch by the steps before you, which no plan lists because no plan writes it; or a file named under "Files" in ${T(t)}/tests.md — a *_test.go, or whatever this repo's test files are called, or a path under testdata/ — which redtest wrote and committed and which the plan does not list either. Those three are the whole of what may have moved; anything else is a BLOCK. Then the history. Every git command here runs from the root of your own worktree — git -C ${WT(t)}/../vf-${f}-${t} — with repo-root-relative pathspecs; from a module directory a pathspec matches nothing and every read prints nothing, which is the shape of a clean branch. The plan commit is the oldest commit on this branch touching ${TREL(t)}/plan.md: git log --format=%H ${FB}..${b} -- ${TREL(t)}/plan.md | tail -1; none is a BLOCK, and no builder can put a commit before it. The paths are the files tests.md names under "Files" and ${TREL(t)}/tests.md itself; git ls-tree ${b} -- <those paths> must list every one first, and a named path that is not a test file or under testdata/ is a stub with a name and a BLOCK. After the plan commit: git log --no-merges --format=%h --name-only <plan commit>..${b}${dep[t] ? ` ^${TB(dep[t])}` : ''} -- <those paths> must print nothing, and a commit it prints, on the branch or merged in from a side branch, is a weakened test and a BLOCK, whatever its message says — with one exception: a commit whose subject begins "tests under the owner's rule:" may change test files and tests.md and nothing else (git show --stat of it names no other path), because the owner's test rule (11 Sept) trims and reshapes tests after the fact; for such a commit you do not trust the message either: you re-prove every row of design.md yourself — each row still has its subtest, each goes red when its behaviour is broken and green when restored; the breaks are the patches an earlier review recorded in ${T(t)}/mutations/, replayed in one loop, and a patch that no longer applies or a row whose test moved gets a break of your own — and you hold coverage and mutation to the base as the gate does, and any row left without a subtest, or any subtest that no longer goes red, is a BLOCK naming it; then each merge in git log --first-parent --merges --format=%h <plan commit>..${b} gets git show --cc <merge> -- <those paths>, which must show no hunk — git's own merge result shows none, a hand edit inside the merge shows the lines, and a merge that took one side's file whole shows none either, which is what your test re-run catches${dep[t] ? `, so re-run the names in ${TREL(dep[t])}/tests.md in your worktree as well` : ''}. Before the plan commit, git log --format=%h --name-only ${FB}..<plan commit> may print only paths under ${TREL(t)}/ and those files; anything else is a stub redtest forgot to delete, and a BLOCK — with one exception: a commit before the plan that touches only the rule files an owner's ruling above names, carrying the Architecture-Review-Approved trailer for each, is that ruling applied where the step that received it stood, and is not a stub. Record both in the verdict's "Touched only" row. Write ${T(t)}/verdict.md in the shape your definition gives, at that absolute path — your own worktree is discarded. A BLOCK is the builder's to fix unless the owner's list in your definition says the owner must decide it: say what to do about it and return "# BLOCK: <one sentence>", and keep the "BLOCKED:" first line for the owner's questions alone — it stops the feature, where a "# BLOCK" goes back to the builder for a fix pass. Merge nothing: the merge is a separate step after every task has passed. Return the verdict's first line exactly — "# PASS" or "# BLOCK: <one sentence>" — and nothing else. ${BLOCK_RULE(T(t), 'the owner\'s list in your definition')}`,
        { agentType: 'coding:verifier', phase: 'Tasks', label: `${t}: verify${attempt ? ` (rework ${attempt})` : ''}` })
      // Only the first non-empty line: see firstLine above. A verifier writing
      // its verdict as "**PASS**" or "- # PASS" has passed the task, and a bare
      // regex reads it as a block that no rework pass can clear.
      const vfPass = !bad(vf) && new RegExp(`^${MD}PASS\\b`).test(firstLine(vf))
      // A reviewer can hand back BOTH — "BLOCKED:" on the first line for the
      // owner and a PASS verdict — because the two answer different questions.
      // The pass is gated on no owner question having been raised.
      const owner = ownerBlock(vf)
      if (vfPass && !owner) {
        count('haiku')
        await agent(
          `In ${WT(t)}: write the output of git -C ${WT(t)} rev-parse HEAD as the only line of the file ${T(t)}/passed. Do not git add it and do not commit; it stays untracked. Return the single word marked.`,
          { agentType: 'coding:breakdown', phase: 'Tasks', label: `${t}: mark passed`, model: 'haiku' })
        return { task: t, branch: b, verdict: vf, reworks: attempt }
      }
      const why = !vf ? 'verifier died' : (owner ? `verify: ${firstLine(vf)}` : `verify: ${vf}`)
      // The step whose prompt the owner's answer has to change on the resume:
      // after a rework round it is that round's step, not round 0's.
      last = { why, step: vfStep, vf, attempt, rework: false }
      if (!vf || owner) break
      if (attempt === maxAttempt) {
        // Out of rounds with neither side asking the owner anything. A fourth
        // round is not a rework: something about the task, its design or its
        // criteria is making the reviews find one layer per pass, and another
        // pass would find another. One agent reads every round and writes why,
        // and the one change that reduces the rounds without dropping a check;
        // the task halts until the operator applies it. Quality is not traded.
        count('opus')
        const ev = await agent(
          `${ANSWER(`${f}/${t}`, 'rounds')}Task ${t} on ${TB(t)} has used its review rounds (${priorRounds + attempt + 1} so far) and the review still blocks. Do not build and do not touch a test. Read ${T(t)}/rounds.md, ${T(t)}/verdict.md, ${T(t)}/design.md, ${T(t)}/criteria.md and ${T(t)}/tests.md, the branch's history git -C ${WT(t)} log --format='%h %s' ${FB}..${TB(t)}, and the review below. Complete ${T(t)}/rounds.md from ${TPL('rounds')}: fill "Why so many" with the pattern the rounds show, and "The change" with exactly one change that reduces the rounds without dropping, shortening or weakening any test, check, lens or review — a SPLIT of the task into named parts, a REWRITE of design.md naming the rows to add, an AMEND of criteria.md, or a precisely named change to the pipeline — with what it costs and why it cannot lower quality. Commit rounds.md in ${WT(t)}. Return the first line of "The change" and nothing else.

--- the verifier ---
${vf}`,
          { agentType: 'coding:planner', phase: 'Tasks', label: `${t}: why so many rounds` })
        last.why = `out of review rounds; the evaluation says: ${firstLine(ev) || 'the evaluation agent died'} (see ${TREL(t)}/rounds.md)`
        last.step = 'rounds'
        last.rework = true
        haltNoFile[t] = true
        break
      }
      count('opus')
      const reworkStep = stepAt('rework', attempt + 1)
      const rb = await agent(
        `${ANSWER(`${f}/${t}`, reworkStep)}Rework pass ${attempt + 1} of ${REWORK_MAX} on ${TB(t)}. Work in ${WT(t)} — the worktree you already built in, on branch ${TB(t)}. Do not create another worktree. The review of your branch has run and came back BLOCK. ${READ_ONE}Read ${T(t)}/verdict.md — the verifier wrote it, and it carries the detail its one-line result does not — and re-read ${T(t)}/criteria.md and ${T(t)}/plan.md before you change anything: a fix that satisfies a reviewer and misses a criterion comes back next round as a worse block. Every finding below is yours, not the owner's: fix these, then re-run the gate. Fix them by changing the code — never by weakening a test, deleting a test, skipping one, or moving a threshold; a finding answered that way comes back as a worse block next round. Never touch a test file or tests.md — with one exception, and only when the review below names it: a BLOCK that calls tests bloat under the owner's test rule, or asks for a trim, is fixed in a commit whose subject begins "tests under the owner's rule:" and which changes test files and tests.md and nothing else, its --stat naming no other path; the verifier re-proves every design row after such a commit, so a trim that drops a row's subtest comes back as a BLOCK. Any other finding on a test line means the test and the plan disagree, and that is BLOCKED.md, not an edit — the verifier fails every other commit after the plan that reaches a test file. If a finding is one you genuinely must not fix — it contradicts ${T(t)}/plan.md, or ${TRIAGE} makes it the owner's — write ${T(t)}/BLOCKED.md and return its first line instead of building. Keep every test in ${T(t)}/tests.md green with: ${RUNTEST}. Then run the gate green again, in delta mode against the feature branch: ${GATE(FB)}. Commit in ${WT(t)}, never with --no-verify: a hook that fails on your change is yours to fix, and a hook you believe is wrong about your change is BLOCKED.md with its exact output, not a flag. Never begin a commit message with the owner's name, and never quote a brief or a ruling as her words: "Claire, <date>:" is reserved for her own rulings, recorded by her operator; a brief that reached you through this pipeline is the pipeline's, and you say so. Before your first change, run git -C ${WT(t)} rev-parse HEAD and keep that hash. Append one row to ${T(t)}/rounds.md — create it from the heading and table of ${TPL('rounds')} if it is absent, nothing below the table — with the round number, the first line of the review below, and your rework commit's subject, and commit it with your rework. Do not push. Do not merge. Return exactly one line — "branch: ${TB(t)} from: <that hash>" — and nothing else. ${BLOCK_RULE(T(t))}

--- the verifier ---
${vf}`,
        { agentType: 'coding:builder', phase: 'Tasks', label: `${t}: rework ${attempt + 1}` })
      // The rework builder raised its own block, or died. The review text that
      // sent it here is the only account of why it was reworking at all, and
      // nothing else records it — so it goes back with this halt too, exactly
      // as it does when the loop runs out.
      lastFrom = bad(rb) ? null : ((rb.match(/from: ([0-9a-f]{7,40})/) || [])[1] || null)
      if (bad(rb) || !/^branch: \S+/m.test(rb)) {
        lastReview[t] = { reworks: attempt, verify: vf || null }
        return halt(t, reworkStep, rb)
      }
    }
    // Out of rework passes, or a block no build pass can answer. The last two
    // review texts are the whole record of a rework block — it writes no
    // BLOCKED.md — so they go back with the halt.
    lastReview[t] = { reworks: last.attempt, verify: last.vf || null }
    if (last.rework) haltNoFile[t] = true
    return halt(t, last.step, last.why)
  },
]

// Waves, not one pipeline over every task. A task that comes After another
// cannot start until that task's branch exists and has passed both reviews, so
// wave 1 is every task with no After:, wave n+1 is the tasks whose After:
// landed in wave n, and a wave starts only once the wave before it has
// finished. Inside a wave it is the same pipeline() as before — no barrier
// between its stages, so one task can be in review while its neighbour is
// still writing red tests. The barrier is only between waves, which is the
// least it can be and still guarantee the branch a builder merges is a branch
// that passed.
const resultOf = new Map(), waitingOn = new Map()
for (const w of waves) {
  // A task whose After: halted never runs: its branch does not hold the work it
  // was told to build on, and merging a halted branch builds on a failure.
  // Recorded, not silently dropped — and transitively, because a task three
  // waves down finds its own After: missing from resultOf for the same reason.
  const runnable = w.filter(t => !dep[t] || resultOf.has(dep[t]))
  for (const t of w) if (!runnable.includes(t)) waitingOn.set(t, dep[t])
  if (!runnable.length) continue
  const rs = await pipeline(runnable, ...STAGES)
  runnable.forEach((t, i) => { if (rs[i]) resultOf.set(t, rs[i]) })
}

// Landing order is wave order, then task order inside a wave — which is what
// waves.flat() is, because each wave was filtered out of a list already in
// task order. That is the order the merger is given.
const ordered = waves.flat()
let passed = ordered.filter(t => resultOf.has(t)).map(t => resultOf.get(t))
let halted = ordered.filter(t => !resultOf.has(t))
// Name the files that hold the reason, the reason itself, and both halves of
// the key the owner's answer comes back under — the answer only re-runs the
// step when answerStep is passed back with it. blockedPath is null for a
// rework halt: no step wrote that file, and a path printed beside a halt is
// read as "the file is there, or the agent died" — neither is true here, and
// the record is codeReview/verify instead.
// A task that never ran because the task it comes After halted is a third kind
// of entry: nothing dispatched, nothing wrote a file, and no answer of the
// owner's unblocks it — clearing the task it waits on is what does. It carries
// the reason "waiting on <task>" and nulls everywhere a path or a key would
// otherwise be read as something to go and look at.
const blocks = halted.map(t => waitingOn.has(t)
  ? { task: t, step: null, reason: `waiting on ${waitingOn.get(t)}`, blockedPath: null, verdictPath: null, answerKey: null, answerStep: null, waitingOn: waitingOn.get(t) }
  : { task: t, step: haltStep[t] || null, reason: haltWhy[t] || null, blockedPath: haltNoFile[t] ? null : `${T(t)}/BLOCKED.md`, verdictPath: `${T(t)}/verdict.md`, answerKey: `${f}/${t}`, answerStep: haltStep[t] || null, ...(lastReview[t] || {}) })
const blocksOf = (h) => h.map(t => ({ task: t, step: haltStep[t] || null, reason: haltWhy[t] || null, blockedPath: haltNoFile[t] ? null : `${T(t)}/BLOCKED.md`, verdictPath: `${T(t)}/verdict.md`, answerKey: `${f}/${t}`, answerStep: haltStep[t] || null, ...(lastReview[t] || {}) }))
log(`dispatches this run asked for — opus ${tally.opus}, sonnet ${tally.sonnet}, haiku ${tally.haiku}; a resumed run counts cached calls again`)
if (halted.length) {
  const waited = halted.filter(t => waitingOn.has(t))
  log(`halted: ${halted.join(', ')} — where blocks[].blockedPath is set, read that BLOCKED.md or the verdict.md beside it, and neither file means the agent died; where it is null the halt is a rework halt, which writes no BLOCKED.md — read blocks[].codeReview and blocks[].verify, which are the whole record of it${waited.length ? `. ${waited.join(', ')} never ran at all: each comes After a task that halted, and clearing that task is what starts it` : ''}`)
  return { feature: f, branch: FB, waves, passed, halted, blocks, dispatches: tally }
}

// Every task passed its review alone, on its own branch. Merged, they can
// still fail to build: two tasks in one wave each wrote a test helper with
// the same name, or one changed a helper's signature the other calls. Git
// sees no conflict, the feature verify sees a package that does not compile
// (behaviour-tested, 14 Sept: storyFile and copyTree declared twice). So the
// gate runs once on the merged branch before the feature verify, and a red
// goes to a builder for a merge rework — test files and helpers only, no
// assertion weakened, no production code — at most two passes.
// Merge and merge check are one round; a feature with a final wave runs two.
// Feature-level marks, like a task's `passed` file: untracked files in the
// feature directory naming the tip a step passed. Merge check, the
// practitioner and the feature verify had none, so a resume — or a fresh run
// after a halt at `feature` — ran all three live again: over three features
// the feature verify ran nine times and the practitioner fourteen. The
// practitioner's cap reset the same way; the count now lives in the feature's
// rounds.md, one line per pass, appended by the rework builder.
const MARK = (name) => `${dir}/${name}.passed`
const featureState = async (label) => {
  count('haiku')
  const s = await agent(
    `${PROBE_ONLY}In ${FT}, print exactly these lines and nothing else. "tip=<the output of git -C ${FT} rev-parse HEAD>". Then for each of the files ${MARK('mergecheck')}, ${MARK('practitioner')} and ${MARK('feature')}: "<mergecheck|practitioner|feature>=<its first line>", or "=none" when the file is absent. Then "feature_pushed=<the second line of ${MARK('feature')}, or none>". Then "practitioner_passes=<the number of lines in ${dir}/rounds.md that begin with 'practitioner pass', or 0 if the file is absent>". Then "verdict=<the first line of ${dir}/verdict.md, or none>".`,
    { agentType: 'coding:breakdown', phase: 'Merge', label, model: 'haiku' })
  const g = (k) => ((String(s || '').match(new RegExp(`^\\W{0,2}${k}=(.*)$`, 'm')) || [])[1] || '').trim()
  const tip = g('tip')
  const at = (k) => Boolean(tip) && /^[0-9a-f]{40}$/.test(tip) && g(k) === tip
  return { tip, mergecheck: at('mergecheck'), practitioner: at('practitioner'), feature: at('feature'), pushed: g('feature_pushed'), passes: Number(g('practitioner_passes')) || 0, verdict: g('verdict') }
}
const mark = async (name, label, second) => {
  count('haiku')
  await agent(
    `In ${FT}: write the output of git -C ${FT} rev-parse HEAD as the first line of the file ${MARK(name)}${second ? `, and "${second}" as its second line` : ''}, and nothing else. Do not git add it and do not commit; it stays untracked. Return the single word marked.`,
    { agentType: 'coding:breakdown', phase: 'Merge', label, model: 'haiku' })
}
const merged = []
const mergeRound = async (order, round) => {
  phase('Merge')
  count('haiku')
  const mg = await agent(
    `${ANSWER(f, 'merge')}Feature worktree ${FT}, on branch ${FB}. First, if a merge is in progress in ${FT} — a previous run stopped on a conflict and left it that way — run git -C ${FT} merge --abort before anything else. Nothing can be committed in that tree until you do, so every step after you dies if you skip it; check with git -C ${FT} status --porcelain=v1 -b. Then merge these task branches into ${FB}, in this order, one at a time — never two at once: ${order.join(', ')}. That is the landing order: the wave each task ran in first, then its number inside that wave. A task that came After another already merged that task's branch into its own before it built, so it sits behind that task in this list and the two share history. For each, run: git -C ${FT} merge --no-ff <branch>. On the first conflict, stop there: run git -C ${FT} merge --abort so the tree is usable again, then write ${dir}/BLOCKED.md — first line "BLOCKED: <one plain sentence, in business terms, asking which behaviour should win where the two changes disagree>", then in one sentence what you would do by default, then what changes if the owner rules otherwise. Return that first line as your whole result. Otherwise return the branches you merged, one per line, and nothing else.`,
    { agentType: 'coding:merger', phase: 'Merge' })
  if (bad(mg)) return { feature: f, branch: FB, passed, halted, ...FEATURE_BLOCK(mg || 'BLOCKED: the merge agent died before merging every task branch', 'merge') }
  merged.push(String(mg))
  phase('Merge check')
  // The merger is idempotent (an already-merged branch is "Already up to
  // date"), so the tip after it is the tip the last green check marked when
  // nothing new landed; then the gate is not run again.
  const st = await featureState(`merge round ${round}: state`)
  let mergeGreen = st.mergecheck
  if (mergeGreen) log(`merge check: this tip passed in an earlier run`)
  for (let pass = 1; pass <= 2 && !mergeGreen; pass++) {
    count('opus')
    const mc = await agent(
      `${ANSWER(f, 'mergecheck')}Merge round ${round}, check pass ${pass}. Feature worktree ${FT}, on branch ${FB}, every task branch merged into it. Run the gate there, in delta mode against ${BASE}: ${GATE(BASE)}. If it is green, return "# GREEN" and change nothing. If it is red because the merged tests do not build together — a helper declared in two task's files, a signature one task's helper changed and another task's test still calls, a name one file uses that another file was meant to define — reconcile it: keep one declaration, make every caller agree with it, change no test's assertions, no row of any design.md, no production file, nothing outside test files and testdata; read every test file the errors name in full first. Then run the gate again; on green, commit in ${FT} with a message beginning "merge rework:" naming the helpers reconciled, and return "# GREEN". If it is red for any other reason — a production file, a test that fails rather than fails to build, a golden that moved — do not fix it: write ${dir}/BLOCKED.md — first line "BLOCKED: <one plain sentence naming which two tasks disagree and about what>", then your best default in one sentence, then what changes if the owner says otherwise — and return that first line. Never push, never merge, never touch a task branch. ${BLOCK_RULE(dir)}`,
      { agentType: 'coding:builder', phase: 'Merge check', label: `merge round ${round}, check ${pass}` })
    if (bad(mc)) return { feature: f, branch: FB, passed, halted, ...FEATURE_BLOCK(mc || 'BLOCKED: the merge check died before running the gate', 'mergecheck') }
    mergeGreen = /^# GREEN/m.test(String(mc))
    log(`merge check ${pass}: ${mergeGreen ? 'green' : 'red'}`)
    if (mergeGreen) await mark('mergecheck', `merge round ${round}: mark green`)
  }
  if (!mergeGreen) return { feature: f, branch: FB, passed, halted, ...FEATURE_BLOCK('BLOCKED: the merged branch is still red after two merge reworks; the tasks\' tests do not build together and a builder could not reconcile them without changing a test', 'mergecheck') }
  return null
}
const firstRound = await mergeRound(passed.map(p => p.branch), 1)
if (firstRound) return firstRound

// The final wave: every task that said "After: all", cut from the feature
// branch now that it holds every other task, then merged and checked again.
if (finalWave.length) {
  phase('Tasks')
  const rs = await pipeline(finalWave, ...STAGES)
  finalWave.forEach((t, i) => { if (rs[i]) resultOf.set(t, rs[i]) })
  const all = [...ordered, ...finalWave]
  passed = all.filter(t => resultOf.has(t)).map(t => resultOf.get(t))
  halted = all.filter(t => !resultOf.has(t))
  if (halted.some(t => finalWave.includes(t))) return { feature: f, branch: FB, tasks, waves, passed, halted, blocks: blocksOf(halted), pushed: null, dispatches: tally }
  const secondRound = await mergeRound(finalWave.map(t => resultOf.get(t).branch), 2)
  if (secondRound) return secondRound
}

// The one question every review before this one failed to ask on story 01
// (14 Sept): would a working developer in this language be embarrassed to
// have their name on this diff? Every other review holds the code to the
// TRD, the standards and CLAUDE.md — documents the same pipeline wrote — so
// a gate inside a markdown file, a Go test of a shell script against a fake
// repo, thirteen test files for eight scenarios and 250-line helpers all
// passed. This reviewer reads none of those documents. It reads the diff
// as a colleague's PR, with the practitioner lens alone, and a refusal is a
// builder's rework on the feature branch, twice at most, before the push.
phase('Practitioner')
const PRACTITIONER = `${PLUGIN}/shared/pipeline/lenses/practitioner.md`
// Three passes per feature across runs, not per run: the count is the
// "practitioner pass" lines in the feature's rounds.md. An owner's answer to
// a practitioner block starts the count over — they have taken the decision.
const pst = await featureState('practitioner: state')
let practOk = pst.practitioner
if (practOk) log('practitioner: this tip was approved in an earlier run')
const firstPass = ANSWER(f, 'practitioner') ? 1 : pst.passes + 1
if (!practOk && firstPass > 3) return { feature: f, branch: FB, passed, halted, ...FEATURE_BLOCK(`BLOCKED: the practitioner has used its three passes on this feature (see ${dir}/rounds.md); a working developer still refused the diff, and the next pass is the owner's to grant`, 'practitioner'), blockedPath: null }
for (let pass = firstPass; pass <= 3 && !practOk; pass++) {
  count('opus')
  const pr = await agent(
    `${ANSWER(f, 'practitioner')}Pass ${pass}. You are a working developer in this repo's language reviewing a colleague's pull request. Read ${PRACTITIONER} and hold the diff to it — and to nothing else: do not open the TRD, the story, CLAUDE.md, docs/standards or any file under .claude/pipeline; a thing those documents asked for is still a finding if a working developer would not do it. In ${FT}, the feature branch ${FB}: git diff ${BASE}...${FB} --stat, then read every changed file in full, test files and fixtures included. Count lines of test and fixture against lines of production code. Return "# APPROVE" if you would put your name on it as it stands. Otherwise return "# REFUSE" followed by what you would refuse, one line each, most embarrassing first, each with its one-line rewrite — a file to delete, a file to fold into another, a helper to cut to ten lines, a command to move into a script, a test of tooling to drop. Change nothing; you are read-only.`,
    { agentType: 'coding:lens', phase: 'Practitioner', label: `practitioner ${pass}` })
  if (bad(pr)) return { feature: f, branch: FB, passed, halted, ...FEATURE_BLOCK(pr || 'BLOCKED: the practitioner review died before reading the diff', 'practitioner') }
  practOk = /^# APPROVE/m.test(String(pr))
  log(`practitioner ${pass}: ${practOk ? 'approve' : 'refuse'}`)
  if (practOk) { await mark('practitioner', 'practitioner: mark approved'); break }
  if (pass === 3) return { feature: f, branch: FB, passed, halted, ...FEATURE_BLOCK(`BLOCKED: a working developer would still refuse this diff after two reworks; their last refusal: ${String(pr).slice(0, 400)}`, 'practitioner') }
  count('opus')
  const rw = await agent(
    `A working developer reviewed the feature branch ${FB} in ${FT} and refused it; their refusals and the rewrite for each are below, verbatim. Apply every rewrite in ${FT}: delete what they said to delete, fold what they said to fold, cut what they said to cut, move what they said to move. Rules that do not bend: no production file changes beyond a move the refusal names; no log line deleted, whatever the refusal says — a function over a cap is split and its log lines survive in the same order with the same text (Claire, 16 Sept); no golden rewritten; no assertion weakened — a test that goes may only be one whose behaviour another remaining test asserts or that tests tooling; every remaining test file an external package; CLAUDE.md's frozen paths untouched. Then run the gate absolutely — GATE_BASE unset — with: ${A.gate} — and it must be green with every held total still held; a total that drops below the threshold means you cut a test that was carrying it: put back the smallest test that restores it. Then, for each ${dir}/tasks/*/tests.md whose tests or files your rework touched, append one heading "## Rework" (once per file) and under it one line per change — "<old test name> → <its new name>", "<old test name> → gone: <the remaining test that asserts the same behaviour>", "<file> → <new file, or gone>", "<rule> → held by <the linter rule and its config file>" — and leave the table and the "Files" list above it exactly as written: the feature verify reads that heading and runs the new names, and a hand re-sync of the rows and counts cost thirty-four turns in one rework and found nothing the test file did not already say. Where a standard under docs/standards/ says a rule is held by a test that is now a linter rule, its held-by line says so — that one edit is a correctness fix, not paperwork. Append to ${dir}/rounds.md (create it with the heading "# Rounds — ${f}" if absent) one line: "practitioner pass ${pass}: <the first refusal line below>". Commit in ${FT} with a subject beginning "tests under the owner's rule:" naming what went — git add each file by path, never -A and never .: the feature directory holds untracked marks (*.passed) and mutation patches that the pipeline reads and that must never be committed. Return "done" and nothing else.\n\n${pr}`,
    { agentType: 'coding:builder', phase: 'Practitioner', label: `practitioner rework ${pass}` })
  if (bad(rw)) return { feature: f, branch: FB, passed, halted, ...FEATURE_BLOCK(rw || 'BLOCKED: the practitioner rework died', 'practitioner') }
}


phase('Feature')
// A feature verdict already written for this tip is returned, not re-earned:
// the mark carries the pushed ref on its second line, so the push is not
// repeated either. An owner's answer to a feature block re-runs it.
const fst = await featureState('feature: state')
if (fst.feature && !ANSWER(f, 'feature')) {
  log('feature verify: this tip passed in an earlier run')
  log(`dispatches this run asked for — opus ${tally.opus}, sonnet ${tally.sonnet}, haiku ${tally.haiku}; a resumed run counts cached calls again`)
  return {
    feature: f, branch: FB, passed, halted, merged: merged.join('\n'),
    feature_verdict: fst.verdict || '# PASS (earlier run)', feature_verdict_path: `${dir}/verdict.md`,
    blockedPath: `${dir}/BLOCKED.md`, answerKey: f, answerStep: 'feature',
    pushed: /^none$/i.test(fst.pushed || 'none') ? null : fst.pushed, dispatches: tally,
  }
}
count('sonnet')
// The gate line is a command the agent runs, not a sentence it reads. Handing
// it the literal "<that branch>" makes it either run GATE_BASE=<that branch>
// as written — a ref no repo has — or invent a substitute, and a gate base it
// invented judges the feature against the wrong tree. When /software passed a
// defaultBranch, render it; the placeholder and the instruction to substitute
// it survive only for the run that has no branch name to render.
const FV_GATE = A.defaultBranch
  ? `${GATE(A.defaultBranch)} — run it exactly as written`
  : `${GATE('<that branch>')} — substitute that branch's name for "<that branch>" and change nothing else`
const fv = await agent(
  `${ANSWER(f, 'feature')}Feature branch ${FB} in the worktree ${FT}, every task branch already merged into it. Read the story ${SPEC}, the TRD ${TRD}, and every ${dir}/tasks/*/criteria.md and tests.md, one file per command. A tests.md with a "## Rework" heading: the names under that heading are the truth for its table — run a test by the new name it gives, and a test it marks gone is covered by the test it names beside it. Work in ${FT}. Walk the story's Journey yourself, Given, When, Then: where a Given or When names a web address, a page or a message a customer sends, walk it through ${STUB} — every Then asserted against what the environment actually answers, and an environment that is down is a BLOCK, not a skip; where the Journey is the gate and the tests themselves, as a testing or standards story's is, walk it by running them in ${FT} and asserting each Then on their output, and the stub is not consulted; run every fitness test; run every task's tests together with: ${RUNTEST} — every name that should exist must show its line, and a missing one is a BLOCK, never a pass. Run the gate in delta mode against ${BASE}, the branch this feature was cut from: ${FV_GATE}. Green means nothing this feature touched got worse and nothing it added is red; the repo's backlog from before the feature is not this feature's, and the absolute run belongs to the owner's merge to the default branch. Then diff ${FB} against ${BASE} and check the changed files this way: ignore every path under .claude/pipeline/ — that is the pipeline's own bookkeeping, one criteria/state/tests/plan/verdict set per task, and it is on this branch because every task committed its own — and ignore every test file, which redtest wrote, and every path under a testdata/ directory or whatever this repo's tests read their fixtures from — a toy module tree, a golden, a fixture site is a test artefact, named in a task's tests.md and already held there by that task's verifier, and the Solution names the tests, not their props. Every remaining changed file must be accounted for by a line of the TRD's Solution section — a package it names covers the files under that package, a workflow, config or spec file it names covers that file, an endpoint it names covers the handler that serves it, an env it names covers where that env is read and declared — and a Solution line that says "None new" accounts for nothing added. A remaining file no Solution line accounts for is a BLOCK, naming the file and the Solution lines it fits none of. Write ${dir}/verdict.md from ${TPL('verdict')} at that absolute path, filling in the "Feature only" rows. On PASS, and only if ${CONFIG} contains a line "push: feature" or "push: confirmed", push ${FB} to the remote and put "pushed: <the remote ref>" on a second line. Return the verdict's first line — "# PASS" or "# BLOCK: <one sentence>" — then that pushed line if you pushed, and nothing else. ${BLOCK_RULE(dir)}`,
  { agentType: 'coding:featureverify', phase: 'Feature' })
// The first non-empty line only, for the same reason as vfPass above: the
// feature verdict's second line is prose, and "# BLOCK: the journey failed"
// explained by a sentence with PASS in it is a BLOCK.
const fvPass = !bad(fv) && new RegExp(`^${MD}PASS\\b`).test(firstLine(fv))
const pushed = fvPass ? ((fv.match(/^pushed:\s*(\S+)/m) || [null, null])[1]) : null
if (fvPass) await mark('feature', 'feature: mark passed', pushed || 'none')
log(`dispatches this run asked for — opus ${tally.opus}, sonnet ${tally.sonnet}, haiku ${tally.haiku}; a resumed run counts cached calls again`)
return {
  feature: f, branch: FB, passed, halted, merged: merged.join('\n'),
  feature_verdict: fv || 'BLOCKED: the feature-verify agent died before writing its verdict',
  feature_verdict_path: `${dir}/verdict.md`, blockedPath: `${dir}/BLOCKED.md`, answerKey: f, answerStep: 'feature',
  pushed, dispatches: tally,
}
```

## Never

- Merge to the default branch. Deploy. Push anything but the feature branch, and that only on the feature verdict's PASS with config's permission.
- Edit the rulings files, or `.claude/pipeline/` outside `features/`.
- Skip a stage, or do its work in your own session.
