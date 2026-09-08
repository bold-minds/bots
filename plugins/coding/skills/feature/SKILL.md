---
name: feature
description: Run one feature through the pipeline unattended — a feature plan, seven lenses, pre-mortem, breakdown, a stop for the owner to read the task list, then the tasks in waves (a task may come After one other), each task current-state → red tests → plan → build → review, then one serial merge, then the feature as a whole, then one push. Halts on BLOCKED. Called by /software with arguments from the repo's .claude/pipeline/config.md.
argument-hint: <feature-name>
allowed-tools: Workflow
---

Call the Workflow tool with this script, verbatim, and `args` as a JSON object
holding: `feature`, `root`, `plugin` (this plugin's root), `featureTree` (the
worktree sitting on the feature branch), `decisions`, `requirements`, `gate`,
`test`, and optionally `entry`, `stub`, `defaultBranch`, `answers`,
`answerStep`, and `confirmTasks` (default true: the run stops after breakdown
and returns the task list; the owner reads it; resume with
`confirmTasks: false`).

`/software` supplies them. Before the first run it creates the feature branch
`pipeline/<feature>` from the default branch **and a worktree on it**, and
passes that worktree's path as `featureTree`. Every feature-level file is
written and committed there.

`answers` carries the owner's ruling on a `BLOCKED.md`, keyed by `"<feature>"`
for a feature-level block or `"<feature>/<task>"` for a task-level one.
`answerStep` names the step that asked — the runner returns it as `answerStep`
beside the key, and it must be passed back unchanged — except the one restart
/software describes, which answers a review halt at `state` after the task's
worktree and branch are gone. **Both are required for a resume to work.** A
finished call is cached by its exact prompt, and every call
after a changed prompt re-runs too, so an answer that reaches more than one
prompt re-runs everything from the earliest of them. The key alone reaches
every dispatch at that level; the key *and* the step reach exactly one. That is
what makes only the blocked step run again while every call before it stays
cached.

Keep the `runId` and `scriptPath` from every result. Resume with the **same
args object**, plus `answers` + `answerStep` and `confirmTasks: false` as
needed.

```js
export const meta = {
  name: 'feature',
  description: 'One feature: plan, lenses, pre-mortem, breakdown, a stop to read the task list, then the tasks in waves — per task state, red tests, plan, build, review; then one serial merge; then the whole feature; then one push. Halts on BLOCKED.',
  phases: [
    { title: 'Plan', detail: 'the feature-level plan the lenses review' },
    { title: 'Lenses', detail: 'seven technical lenses on the plan, in parallel' },
    { title: 'Pre-mortem', detail: 'how it fails, including on purpose; keep only cases a customer hits and we can name a fallback for' },
    { title: 'Break down', detail: 'small tasks with criteria in the owner\'s words, and which of them come After another; stops for the owner to read the list' },
    { title: 'Tasks', detail: 'in waves — every task with no After: first, then the ones that come After those; each task in its own worktree: state → red tests → plan → build → review' },
    { title: 'Merge', detail: 'one agent merges the passed task branches into the feature branch, in landing order, one at a time' },
    { title: 'Feature', detail: 'the whole feature branch: journey, fitness, every test together, the gate; then one push' },
  ],
}

const A = args || {}
for (const k of ['feature', 'root', 'plugin', 'featureTree', 'decisions', 'requirements', 'gate', 'test']) {
  if (!A[k]) throw new Error(`args.${k} is required — /software fills it from .claude/pipeline/config.md`)
}
const f = A.feature, ROOT = A.root, PLUGIN = A.plugin, FT = A.featureTree
const SHARED = `${PLUGIN}/shared/pipeline`
const CODE_LENSES = `${PLUGIN}/skills/fix-code/references/lenses.md`
const LENS_RULES = `${PLUGIN}/skills/fix-code/references/lens-selection.md`
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
const TRIAGE = `${SHARED}/triage.md`
const ENTRY = A.entry || 'the program\'s main entry points'
const STUB = A.stub || 'the local end-to-end environment, if the repo has one'
const BASE = A.defaultBranch || 'the branch the feature branch was created from'
const CONFIRM = A.confirmTasks !== false
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
const GATE = (base) => `GATE_BASE=${base} ${A.gate}`

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
const stepHasNoBlockFile = (step) => /^rework(?:-\d+)?$/.test(String(step || '')) || step === 'after'
const ANSWER = (key, step) => !(A.answers && A.answers[key] && A.answerStep === step) ? ''
  : stepHasNoBlockFile(step)
    ? `The owner has ruled on the question this step raised: "${A.answers[key]}". Apply it as a ruling. Delete BLOCKED.md only if one is actually there — this step writes none. `
    : `The owner has ruled on the question in BLOCKED.md: "${A.answers[key]}". Apply it as a ruling, then delete BLOCKED.md if it is there. `
const BLOCK_RULE = (where) =>
  `If ${where}/BLOCKED.md is already there and no ruling above names it, the owner has not answered yet: return its first line and change nothing — a resume re-runs every step after the one that changed, this one included. If you must stop per ${TRIAGE}, write ${where}/BLOCKED.md — first line "BLOCKED: <one plain sentence>", then your best default in one sentence, drawn from the nearest existing thing in this repo and naming it, then what changes if the owner says otherwise — and return that first line as your whole result.`
const FEATURE_BLOCK = (b, step) => ({ blocked: b, blockedPath: `${dir}/BLOCKED.md`, answerKey: f, answerStep: step, dispatches: tally })

phase('Plan')
count('opus')
const fp = await agent(
  `${ANSWER(f, 'plan')}Read ${dir}/spec.md, ${A.requirements}, ${A.decisions}, and enough of the code to know what already exists. Entry points: ${ENTRY}. Write ${dir}/plan.md from ${TPL('featureplan')}. Then, in ${FT} — a worktree already on branch ${FB} — git add the plan and commit it. Return "planned" and nothing else. ${BLOCK_RULE(dir)}`,
  { agentType: 'coding:featureplan', phase: 'Plan' })
if (bad(fp)) return { halted: 'Plan', ...FEATURE_BLOCK(fp || 'BLOCKED: the feature-plan agent died before writing its file', 'plan') }

phase('Lenses')
const LENSES = [['architecture', 'opus'], ['sre', 'opus'], ['security', 'opus'], ['performance', 'sonnet'], ['database', 'sonnet'], ['qa', 'opus'], ['staff', 'opus']]
const lenses = await parallel(LENSES.map(([l, m]) => () => { count(m); return agent(
  `${ANSWER(f, 'lenses')}Lens: ${l}. Read ${dir}/spec.md and ${dir}/plan.md. Load ${SHARED}/lenses/${l}.md; if ${P}/lenses/${l}.md exists, load it too — it is this repo's history for this lens. Nothing about other lenses. Write ${dir}/lens-${l}.md from ${TPL('lens')}. Do not run git: you are one of several lenses writing into ${FT} at the same time, and the next step commits all of your files together. Return the number of findings and nothing else. ${BLOCK_RULE(dir)}`,
  { agentType: 'coding:lens', phase: 'Lenses', label: `lens: ${l}`, model: m }) }))
const dead = lenses.findIndex(r => !r)
if (dead >= 0) return { halted: 'Lenses', ...FEATURE_BLOCK(`BLOCKED: the ${LENSES[dead][0]} lens agent died before writing its file`, 'lenses') }
const lensBlock = lenses.find(isBlocked)
if (lensBlock) return { halted: 'Lenses', ...FEATURE_BLOCK(lensBlock, 'lenses') }
log(`lenses: ${LENSES.length} written`)

phase('Pre-mortem')
count('opus')
const pm = await agent(
  `${ANSWER(f, 'premortem')}Read ${dir}/spec.md, ${dir}/plan.md, every ${dir}/lens-*.md — there are ${LENSES.length}, one of them the security lens, and its last sentence is written for you — and ${A.decisions}. Write ${dir}/premortem.md from ${TPL('premortem')}. Then, in ${FT}, git add the whole feature directory — your file and every lens file — and commit it. Return the number of kept cases and nothing else. ${BLOCK_RULE(dir)}`,
  { agentType: 'coding:premortem', phase: 'Pre-mortem' })
if (bad(pm)) return { halted: 'Pre-mortem', ...FEATURE_BLOCK(pm || 'BLOCKED: the pre-mortem agent died before writing its file', 'premortem') }

phase('Break down')
count('opus')
const bdText = await agent(
  `${ANSWER(f, 'breakdown')}Read ${dir}/spec.md, ${dir}/plan.md, every ${dir}/lens-*.md, ${dir}/premortem.md, ${A.requirements} and ${A.decisions}. Write one ${dir}/tasks/<nn>-<short-name>/criteria.md per task from ${TPL('criteria')}, in landing order, each with its Success line filled in. The task carrying the plan's journey is marked "Journey: yes"; the plan's structural rules go into that task's "Structural rules". A task that cannot start until another task's work exists — the package, the file, the table it builds on is created by that one, and a worktree cut from ${FB} does not have it — carries one "After: <that task's directory name>" line, at most one name and always a lower-numbered task; most tasks carry none. Then delete the lens-*.md and premortem.md files. Then, in ${FT}, git add the feature directory — the new task files and the deletions — and commit it. Return ONLY the task directory names, one per line, nothing else. ${BLOCK_RULE(dir)}`,
  { agentType: 'coding:breakdown', phase: 'Break down' })
if (bad(bdText)) return { halted: 'Break down', ...FEATURE_BLOCK(bdText || 'BLOCKED: the breakdown agent died before writing any task', 'breakdown') }
const tasks = bdText.split('\n').map(s => s.trim()).filter(s => /^[0-9]{2}-[a-z0-9-]+$/.test(s))
if (!tasks.length) return { halted: 'Break down', ...FEATURE_BLOCK(`BLOCKED: breakdown returned no task names. It returned: ${bdText.slice(0, 200)}`, 'breakdown') }
log(`tasks: ${tasks.length}`)

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
  `${ANSWER(f, 'after')}Read each of these files: ${tasks.map(t => `${dir}/tasks/${t}/criteria.md`).join(', ')}. Each may carry one optional line that begins "After:" and names another task's directory name. Return exactly ${tasks.length} lines and nothing else — no prose, no heading, no code fence — one per task, in this order: ${tasks.join(', ')}. Each line is "<task directory name> after: <the name on that task's After: line>", or "<task directory name> after: none" when that file has no After: line. Copy each name exactly as the file spells it: do not tidy it, do not infer one from the numbering, do not skip a task. Write nothing and change nothing. ${BLOCK_RULE(dir)}`,
  { agentType: 'coding:breakdown', phase: 'Break down', label: 'after: the dependency lines', model: 'haiku' })
if (bad(afterText)) return { halted: 'Break down', ...FEATURE_BLOCK(afterText || 'BLOCKED: the agent reading the After: lines died before returning them', 'after') }

// dep[t] is the one task t must come after, or null. graphBad collects the
// tasks whose line cannot be used — an unknown name, a self-reference, a
// missing answer, or a cycle. Any of them halts the run before a task starts:
// a wave order built on a broken graph runs tasks in an order nothing checked.
const dep = {}, graphBad = []
const afterLines = String(afterText).split('\n').map(s => s.trim()).filter(Boolean)
for (const t of tasks) {
  // "^<name>\s" and not a bare prefix: 01-config must not read 01-config-list's
  // line. Task names are /^[0-9]{2}-[a-z0-9-]+$/, so nothing here is a regex
  // metacharacter.
  const line = afterLines.find(l => new RegExp(`^${t}\\s`).test(l))
  const a = line ? ((line.match(/\safter:\s*([^\s.]+)/i) || [])[1] || '') : ''
  if (!a) graphBad.push({ task: t, why: `BLOCKED: no "After:" answer came back for ${t}, so the pipeline cannot tell whether it may start in the first wave. Read ${dir}/tasks/${t}/criteria.md and say whether it carries an After: line and what it names.` })
  else if (/^none$/i.test(a)) dep[t] = null
  else if (a === t) graphBad.push({ task: t, why: `BLOCKED: ${t}'s After: line names ${t} itself, so nothing can ever start it.` })
  else if (!tasks.includes(a)) graphBad.push({ task: t, why: `BLOCKED: ${t}'s After: line names ${a}, which is not one of this feature's tasks (${tasks.join(', ')}).` })
  else dep[t] = a
}
// Wave 1 is every task with no After:. Wave n+1 is every task whose After:
// landed in a wave already built. A task left over when no further wave can be
// built is in a cycle, or waiting on one.
const waves = []
let unplaced = tasks.filter(t => !graphBad.some(b => b.task === t))
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
log(`waves: ${waves.map((w, i) => `${i + 1} — ${w.join(', ')}`).join(' | ')}`)

if (CONFIRM) {
  log('stopping for the owner to read the task list — resume with confirmTasks: false')
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
  ? `This task's criteria.md carries "After: ${dep[t]}", so ${dep[t]}'s work must exist before yours can stand on it. Your FIRST act, before you read the plan and before you change a file: git -C ${WT(t)} merge --no-ff ${TB(dep[t])}. That branch has passed both reviews — this run does not start your wave until the wave holding it has finished — and without the merge your worktree is the feature branch, which does not have what your plan is written against. Say so in your commit message, one line: "Merged ${TB(dep[t])} first: this task comes After ${dep[t]}." If the merge conflicts, stop and write BLOCKED.md asking which behaviour should win where the two changes disagree: that is the owner's, never yours. `
  : ''

const STAGES = [
  (_, t) => { count('sonnet'); return agent(
    `${ANSWER(`${f}/${t}`, 'state')}If ${T(t)}/state.md is already committed on the task branch ${TB(t)}, return its "to build" line and change nothing: a resume re-runs this step for every task in the wave. Otherwise, first, cut this task's worktree from the feature branch: git -C ${FT} worktree add ${WT(t)} -b ${TB(t)} ${FB} — unless ${WT(t)} already exists, in which case use it as it is. The task branch is ${TB(t)}, beside the feature branch and not under it: git cannot hold a branch ${FB} and a branch ${FB}/${t} at the same time. Everything you read and write is inside it. Read ${T(t)}/criteria.md. Rule each criterion TRUE or FALSE against the code in ${WT(t)}, which is branch ${FB} — not the default branch — with a file:line or a command you ran as evidence, never a document. Trace from a real entry point: ${ENTRY}. Write ${T(t)}/state.md from ${TPL('state')}, then git add and commit it in ${WT(t)}. Return "to build: N, to guard: M" and nothing else. ${BLOCK_RULE(T(t))}`,
    { agentType: 'coding:state', phase: 'Tasks', label: `${t}: state` }).then(guard(t, 'state', /^to build:\s*\d+/mi)) },
  (_, t) => { count('opus'); return agent(
    `${ANSWER(`${f}/${t}`, 'redtest')}Work in ${WT(t)}, a worktree on branch ${TB(t)}. If ${T(t)}/tests.md is already committed on this branch, return its table and change nothing: a resume re-runs this step for every task in the wave, and only the restarted one has a fresh branch. Read ${T(t)}/criteria.md and ${T(t)}/state.md. Write the tests and ${T(t)}/tests.md from ${TPL('tests')}. The test command is: ${A.test} — run it exactly as written except that where it contains "<TestName>" you substitute the name of the test you are running, and where it contains "<module dir>" you substitute the directory of the module that holds that test; change nothing else. Anchor the name so it cannot match a neighbour: -run '^<TestName>$'. A run is green only if its output contains "--- PASS: <that test name>"; "no tests to run" or "no test files" is a failure, never a pass, and so is a summary "ok" with no such line. Journey tests use ${STUB}. Every FALSE criterion's test must be red now. Every TRUE criterion's test must go red when you break the behaviour on purpose, then be restored. A criterion that enumerates — each of N names, three states — is every case it counts, as subtests, one "--- PASS: <Test>/<case>" line per case in the run's output; nobody after you can add a case, so one you leave out is an owner's halt at review that restarts the task. Your tests are red for one reason only: the behaviour they ask for does not exist yet. Never for the shape of the test itself. Two checks before you commit. First, run the gate in delta mode against the feature branch: ${GATE(FB)}. It stops at its first RED line. On a FALSE criterion that is usually the missing behaviour showing before the tests arm — "undefined: <symbol>", a new package with no non-test Go files, a package not attached to any component in the architecture file — and it hides every arm behind it: add the smallest uncommitted stub that makes the package compile, run the gate again, delete the stub, and confirm the tests are red again before you commit. A RED on the shape of a line you wrote — a formatter, go vet, a linter rule, an import across a boundary — is yours to fix now and run again; a RED on the stub is fixed in the stub, until the gate reaches the tests arm. The three lines above go under "Gate", never into BLOCKED; any other RED on a file you did not write is BLOCKED naming the arm. Under tests.md's "Gate" heading paste the RED line the committed tests stop at, name the symbol, package or component the builder must add${dep[t] ? ` — unless ${dep[t]}, the task this one comes After, provides it: confirm with git -C ${WT(t)} grep -n <symbol> ${TB(dep[t])}, the one read of another branch you may make, then say so and name nothing for the plan —` : ' — this task has no After: line, so no other task provides it —'} and say the lint and boundary arms between that line and the tests arm, if any, ran green with the stub and that the stub is gone from the commit. A task whose criteria are all TRUE has no red test and the gate may run through; a module the gate has no test arm for cannot show one; say which. Second, write the "Green together" paragraph tests.md asks for: one implementation that turns every test green at once, and each assertion checked against it. Two tests that cannot both be green against it contradict each other, and nobody after you may touch a test; rewrite until they agree. Then in ${WT(t)} git add the test files and tests.md each by path — never -A, never . — check git status --porcelain shows nothing but the staged test files and tests.md, and git commit -m "pipeline: ${t} red tests". Every file you commit besides tests.md is a test file or a path under testdata/, and every one is named under tests.md's "Files" heading, repo-root-relative; the verifier reads that list, and a committed file it does not name, or a named file that is neither, is a BLOCK. Return the tests.md table and nothing else. ${BLOCK_RULE(T(t))}`,
    { agentType: 'coding:redtest', phase: 'Tasks', label: `${t}: red tests` }).then(guard(t, 'redtest', /^\s*\|/m)) },
  (_, t) => { count('opus'); return agent(
    `${ANSWER(`${f}/${t}`, 'plan')}Work in ${WT(t)}, a worktree on branch ${TB(t)}. If ${T(t)}/plan.md is already committed on this branch, return its Flag line and change nothing: a resume re-runs this step for every task in the wave. Read ${T(t)}/criteria.md, ${T(t)}/tests.md, the test files, the code they exercise, and ${A.decisions}. Write ${T(t)}/plan.md from ${TPL('plan')}, then git add and commit it in ${WT(t)}. The Flag line is read by a machine: it is either the four characters "Flag: none" alone on the line, with nothing after them but an optional full stop, or it names the one thing that halts the chain. There is no third shape — a qualifier, a parenthesis or a "none, but …" is a flag. If the line is not exactly "Flag: none", also write ${T(t)}/BLOCKED.md with that flag as its first line, prefixed "BLOCKED: ", then your best default and what changes if the owner says otherwise. Return the Flag line exactly as written and nothing else. ${BLOCK_RULE(T(t))}`,
    { agentType: 'coding:planner', phase: 'Tasks', label: `${t}: plan` }).then(r => {
      if (bad(r)) return halt(t, 'plan', r)
      // Only the first Flag: line, and the whole of it: "Flag: none, but …"
      // and "Flag: none - …" are flags, and a "Flag: none" followed by prose
      // on its own line is not.
      const fl = ((r.match(/^[ \t]*Flag:.*$/mi) || [''])[0]).trim()
      return /^Flag:[ \t]*none[.!]?$/i.test(fl) ? r : halt(t, 'plan', r)
    }) },
  (_, t) => { count('opus'); return agent(
    `${ANSWER(`${f}/${t}`, 'build')}${AFTER_MERGE(t)}If every test in ${T(t)}/tests.md is already green on this branch and the branch has a commit after the one that added plan.md, return the branch line and change nothing — the merge above, if any, is already in this branch's history: a resume re-runs this step for every task in the wave, and only the restarted one has a fresh branch. Implement ${T(t)}/plan.md. Work in ${WT(t)} — the worktree already on branch ${TB(t)}, cut from ${FB}, holding the criteria, the state, the red tests and the plan. Do not create another worktree. Make every test in ${T(t)}/tests.md green without weakening any test, using: ${A.test} — substitute the test's name for "<TestName>" and the module's directory for "<module dir>", change nothing else, and anchor the name as -run '^<TestName>$'. A test is green only when the output carries "--- PASS: <that name>"; "no tests to run" is a failure. Then run the gate to green in the task worktree, in delta mode against the feature branch: ${GATE(FB)}. Green means nothing you touched got worse and nothing you added is red — the repo's backlog since before ${FB} is not this task's to clear, and the absolute run is the owner's at the merge. Never touch a test file or tests.md: a gate finding on a test line that only your finished code let the linter see means the test and the plan disagree about a signature, and that is BLOCKED.md, not an edit — the verifier fails every commit after the plan that reaches a test file, whatever its message says. Commit in ${WT(t)}. Do not push. Do not merge${dep[t] ? ` anything but the ${TB(dep[t])} merge above, and that only into ${TB(t)} — never into ${FB}` : ''}. Return exactly one line — "branch: ${TB(t)}" — and nothing else. ${BLOCK_RULE(T(t))}`,
    { agentType: 'coding:builder', phase: 'Tasks', label: `${t}: build` }).then(r => { const m = bad(r) ? null : (r.match(/^branch: (\S+)/m) || [])[1]; return m || halt(t, 'build', r) }) },
  // Two fresh contexts that never saw the builder's reasoning, in parallel:
  // fix-code's lensed code review, and a verifier for what a code review does
  // not do. PASS needs both. Neither merges — the Merge phase does, after every
  // task has passed, so a code-review BLOCK can never land on an already-merged
  // branch.
  //
  // Most of what these two return on a BLOCK is rework: test files over the
  // size cap, lint findings the change added, a mutation that survived. That is
  // the builder's work, and halting the whole feature to hand the owner a lint
  // count stops a run one more build pass would have finished. So a BLOCK goes
  // back to the builder with both review texts, and both reviews run again on
  // the branch as it then stands — REWORK_MAX times. Only a block that says the
  // OWNER must decide — "BLOCKED:" on the first line, triage.md's shape —
  // leaves the loop early, because no build pass can answer a question about a
  // promise to a customer. So does a dead agent: there is nothing to fix.
  async (b, t) => {
    let last = null
    for (let attempt = 0; attempt <= REWORK_MAX; attempt++) {
      count('opus'); count('opus')
      // Round 1's prompts have to differ from round 0's or the runner hands
      // back the cached BLOCK on code that has since been fixed: a finished
      // call is cached by its exact (prompt, opts). This line is what makes the
      // re-review a new call, and its absence at round 0 is what leaves round
      // 0 — and every step before it — cached.
      const again = attempt === 0 ? '' : `Rework pass ${attempt} of ${REWORK_MAX}: the builder has been given the previous round's findings and has just fixed them. Review the branch as it stands now, on its own; nothing the previous round said is evidence about this one. `
      const crStep = stepAt('code-review', attempt), vfStep = stepAt('review', attempt)
      const [cr, vf] = await parallel([
        () => agent(
          `${ANSWER(`${f}/${t}`, crStep)}${again}Branch-mode review of ${b} in ${WT(t)}: diff it against ${DIFF_BASE(t)} in the merge-base form, git diff ${DIFF_BASE(t)}...${b} with three dots, never the two-endpoint form — ${dep[t] ? `the tip of ${TB(dep[t])}, the branch this task comes After and whose commits its builder merged into this one before it started, and NOT ${FB}: against the feature branch the diff would also carry every file ${dep[t]} changed, which is code this task did not write and which has already passed both reviews on its own branch, so a finding there would send this task's builder into a rework pass over someone else's work` : `the feature branch it was cut from, not the default branch`}. Read every CLAUDE.md in the repo and hold the code to it. File manifest: every file the diff touches — read each in full. Apply the lens prompt templates in ${CODE_LENSES}: the always-on baseline plus whatever ${LENS_RULES} selects for these files. Report findings by severity as your agent definition says. This dispatch comes from the /feature pipeline rather than fix-code, and it adds one line to your format: end with exactly "VERDICT: PASS" if there is no P0 or P1 finding, otherwise "VERDICT: BLOCK: <the top P0/P1 in one sentence>". Both are intended. A BLOCK the builder can act on — a named file, a named change, a cap to get under — needs nothing else from you: say what to do about it, and the pipeline hands your whole report straight back to the builder for a fix pass. Only when the OWNER has to decide per ${TRIAGE} — a promise to a customer, money, a contradicted ruling, top-level technical direction — write ${T(t)}/BLOCKED.md (first line "BLOCKED: " and one plain sentence, then your best default, then what changes if they rule otherwise) and put that same "BLOCKED: <sentence>" on the FIRST line of what you return, above everything else, as well as the VERDICT line at the end. That first line is what stops the feature and wakes the owner, so a finding the builder could have fixed must not carry it; and a halt with no BLOCKED.md beside it reads as an agent that died. ${BLOCK_RULE(T(t))}`,
          { agentType: 'coding:code-reviewer', phase: 'Tasks', label: `${t}: code review${attempt ? ` (rework ${attempt})` : ''}` }),
        () => agent(
          `${ANSWER(`${f}/${t}`, vfStep)}${again}Verify ${b} against ${T(t)}/criteria.md, ${T(t)}/tests.md and ${T(t)}/plan.md. Check it out in a worktree of your own, detached so you do not fight the build worktree — clear any worktree a previous run left at that path first, because "worktree add" onto an existing directory is fatal: git -C ${WT(t)} worktree remove --force ../vf-${f}-${t} 2>/dev/null; git -C ${WT(t)} worktree add --detach ../vf-${f}-${t} ${b}. That path is the only worktree you may create. It is the one the cleaner knows by name; a path you invent for a comparison — ../vf-base-${f}, ../vf-baseline-${f} — is one nothing ever removes, and the next run's "worktree add" onto it is fatal. To compare against another branch, use git diff, git show, git log or git ls-tree against the branch this dispatch names for that comparison, from the worktree you already have — none needs a checkout, and there is no comparison here that needs a second tree. No other worktree, ever, at any path, for any reason. Re-run every test and every mutation yourself with: ${A.test} — substitute the test's name for "<TestName>" and the module's directory for "<module dir>", change nothing else, and anchor the name as -run '^<TestName>$'. A run is green only if its output contains "--- PASS: <that test name>"; "no tests to run", "no test files", or a summary "ok" without that line is a failure, not a pass, and it is a BLOCK. Then read ${T(t)}/criteria.md against tests.md's table: every criterion has a row, and a criterion that enumerates — each of N names, three states — has every case it counts as a subtest line of its test's run, "--- PASS: <Test>/<case>", one per case criteria.md names or per item the code enumerates where it only counts; a criterion or a case with no test is the owner's BLOCKED.md naming what is missing, with the default that the task is restarted — the owner adds the cases to ${TREL(t)}/criteria.md on ${FB}, removes ${WT(t)} and ${TB(t)}, and answers at the task's state step — because no test may change after the plan commit and no answer can add one. Run the gate the same way the builder was told to, in delta mode against the feature branch: ${GATE(FB)} — green means nothing this task touched got worse and nothing it added is red, not that the repo's backlog is clear, and that backlog is not this task's; read ${A.decisions} and confirm nothing is reversed; diff ${b} against ${DIFF_BASE(t)} in the merge-base form, git diff ${DIFF_BASE(t)}...${b} with three dots and never the two-endpoint form, because the feature branch can gain a commit after this branch was cut and that commit is not this task's — ${dep[t] ? `the tip of ${TB(dep[t])}, the branch this task comes After and whose commits its builder merged in before it started, and NOT ${FB}: against the feature branch this diff would also carry every file ${dep[t]} changed, which is in none of the three lists below and would BLOCK this task for work that has already passed its own review` : `the feature branch, not the default branch`} — and confirm every changed file is one of three things: a file in plan.md's "Touch" list; a file under ${T(t)}/ — this task's own .claude/pipeline/ bookkeeping, state.md and tests.md and plan.md, committed on this branch by the steps before you, which no plan lists because no plan writes it; or a file named under "Files" in ${T(t)}/tests.md — a *_test.go, or whatever this repo's test files are called, or a path under testdata/ — which redtest wrote and committed and which the plan does not list either. Those three are the whole of what may have moved; anything else is a BLOCK. Then the history. Every git command here runs from the root of your own worktree — git -C ${WT(t)}/../vf-${f}-${t} — with repo-root-relative pathspecs; from a module directory a pathspec matches nothing and every read prints nothing, which is the shape of a clean branch. The plan commit is the oldest commit on this branch touching ${TREL(t)}/plan.md: git log --format=%H ${FB}..${b} -- ${TREL(t)}/plan.md | tail -1; none is a BLOCK, and no builder can put a commit before it. The paths are the files tests.md names under "Files" and ${TREL(t)}/tests.md itself; git ls-tree ${b} -- <those paths> must list every one first, and a named path that is not a test file or under testdata/ is a stub with a name and a BLOCK. After the plan commit: git log --no-merges --format=%h --name-only <plan commit>..${b}${dep[t] ? ` ^${TB(dep[t])}` : ''} -- <those paths> must print nothing, and a commit it prints, on the branch or merged in from a side branch, is a weakened test and a BLOCK, whatever its message says; then each merge in git log --first-parent --merges --format=%h <plan commit>..${b} gets git show --cc <merge> -- <those paths>, which must show no hunk — git's own merge result shows none, a hand edit inside the merge shows the lines, and a merge that took one side's file whole shows none either, which is what your test re-run catches${dep[t] ? `, so re-run the names in ${TREL(dep[t])}/tests.md in your worktree as well` : ''}. Before the plan commit, git log --format=%h --name-only ${FB}..<plan commit> may print only paths under ${TREL(t)}/ and those files; anything else is a stub redtest forgot to delete, and a BLOCK. Record both in the verdict's "Touched only" row. Write ${T(t)}/verdict.md from ${TPL('verdict')} at that absolute path — your own worktree is discarded. A BLOCK is the builder's to fix unless ${TRIAGE} says the owner must decide it: say what to do about it and return "# BLOCK: <one sentence>", and keep the "BLOCKED:" first line for the owner's questions alone — it stops the feature, where a "# BLOCK" goes back to the builder for a fix pass. Merge nothing: the merge is a separate step after every task has passed. Return the verdict's first line exactly — "# PASS" or "# BLOCK: <one sentence>" — and nothing else. ${BLOCK_RULE(T(t))}`,
          { agentType: 'coding:verifier', phase: 'Tasks', label: `${t}: verify${attempt ? ` (rework ${attempt})` : ''}` }),
      ])
      // A reviewer writing markdown puts the verdict in bold or in a bullet:
      // "**VERDICT: PASS**" and "- VERDICT: PASS" are the same verdict as
      // "VERDICT: PASS", so allow a few leading non-word characters. \b after
      // PASS is what keeps "VERDICT: PASSED" from reading as a pass.
      const crPass = typeof cr === 'string' && new RegExp(`^${MD}VERDICT:\\s*PASS\\b`, 'mi').test(cr)
      // Only the first non-empty line: see firstLine above.
      // Same markdown allowance as crPass: a verifier writing its verdict as
      // "**PASS**" or "- # PASS" has passed the task, and a bare regex reads it
      // as a block that no rework pass can clear.
      const vfPass = !bad(vf) && new RegExp(`^${MD}PASS\\b`).test(firstLine(vf))
      // A reviewer can hand back BOTH — "BLOCKED:" on the first line for the
      // owner and "VERDICT: PASS" at the end, because the two lines answer
      // different questions and the format asks for both. Returning on the pass
      // alone merges the branch with the owner's question still unanswered, so
      // the pass is gated on neither side having raised one.
      const owner = ownerBlock(cr) || ownerBlock(vf)
      if (crPass && vfPass && !owner) return { task: t, branch: b, verdict: vf, review: (cr.match(new RegExp(`^${MD}VERDICT:.*$`, 'm')) || [''])[0], reworks: attempt }
      const why = [
        !cr ? 'code-reviewer died' : (ownerBlock(cr) ? `code review: ${firstLine(cr)}` : (!crPass ? `code review: ${(cr.match(new RegExp(`^${MD}VERDICT:.*$`, 'm')) || ['no verdict line'])[0]}` : null)),
        !vf ? 'verifier died' : (ownerBlock(vf) ? `verify: ${firstLine(vf)}` : (!vfPass ? `verify: ${vf}` : null)),
      ].filter(Boolean).join(' | ')
      // Name the half that stopped: that is the step whose prompt the owner's
      // answer has to change on the resume, and after a rework round it is that
      // round's step, not round 0's. An owner block wins the naming even when
      // its own side also said PASS — the question is that side's, and the
      // ruling has to reach the step that asked it.
      last = { why, step: ownerBlock(cr) ? crStep : (ownerBlock(vf) ? vfStep : (crPass ? vfStep : crStep)), cr, vf, attempt, rework: false }
      if (!cr || !vf || owner) break
      if (attempt === REWORK_MAX) {
        // Out of rework passes with neither side asking the owner anything —
        // so both sides may be blocking, and a review step can carry the
        // ruling to only one of them. The other re-runs unchanged, blocks
        // again, and the resume 2-cycles forever. The builder is the single
        // place that can fix both halves, so the ruling goes to its last
        // dispatch; both reviews sit after it and re-run live on what it did.
        last.step = stepAt('rework', REWORK_MAX)
        last.rework = true
        break
      }
      count('opus')
      const reworkStep = stepAt('rework', attempt + 1)
      const rb = await agent(
        `${ANSWER(`${f}/${t}`, reworkStep)}Rework pass ${attempt + 1} of ${REWORK_MAX} on ${TB(t)}. Work in ${WT(t)} — the worktree you already built in, on branch ${TB(t)}. Do not create another worktree. Both reviews of your branch have run and at least one came back BLOCK. Read ${T(t)}/verdict.md — the verifier wrote it, and it carries the detail its one-line result does not — and re-read ${T(t)}/criteria.md and ${T(t)}/plan.md before you change anything: a fix that satisfies a reviewer and misses a criterion comes back next round as a worse block. Every finding below is yours, not the owner's: fix these, then re-run the gate. Fix them by changing the code — never by weakening a test, deleting a test, skipping one, or moving a threshold; a finding answered that way comes back as a worse block next round. Never touch a test file or tests.md at all: a finding on a test line means the test and the plan disagree, and that is BLOCKED.md, not an edit — the verifier fails every commit after the plan that reaches a test file. If a finding is one you genuinely must not fix — it contradicts ${T(t)}/plan.md, or ${TRIAGE} makes it the owner's — write ${T(t)}/BLOCKED.md and return its first line instead of building. Keep every test in ${T(t)}/tests.md green with: ${A.test} — substitute the test's name for "<TestName>" and the module's directory for "<module dir>", change nothing else, and anchor the name as -run '^<TestName>$'; a test is green only when the output carries "--- PASS: <that name>". Then run the gate green again, in delta mode against the feature branch: ${GATE(FB)}. Commit in ${WT(t)}. Do not push. Do not merge. Return exactly one line — "branch: ${TB(t)}" — and nothing else. ${BLOCK_RULE(T(t))}

--- the code review ---
${cr}

--- the verifier ---
${vf}`,
        { agentType: 'coding:builder', phase: 'Tasks', label: `${t}: rework ${attempt + 1}` })
      // The rework builder raised its own block, or died. The two review texts
      // that sent it here are the only account of why it was reworking at all,
      // and nothing else records them — so they go back with this halt too,
      // exactly as they do when the loop runs out.
      if (bad(rb) || !/^branch: \S+/m.test(rb)) {
        lastReview[t] = { reworks: attempt, codeReview: cr || null, verify: vf || null }
        return halt(t, reworkStep, rb)
      }
    }
    // Out of rework passes, or a block no build pass can answer. The last two
    // review texts are the whole record of a rework block — it writes no
    // BLOCKED.md — so they go back with the halt.
    lastReview[t] = { reworks: last.attempt, codeReview: last.cr || null, verify: last.vf || null }
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
const passed = ordered.filter(t => resultOf.has(t)).map(t => resultOf.get(t))
const halted = ordered.filter(t => !resultOf.has(t))
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
log(`dispatches this run asked for — opus ${tally.opus}, sonnet ${tally.sonnet}, haiku ${tally.haiku}; a resumed run counts cached calls again`)
if (halted.length) {
  const waited = halted.filter(t => waitingOn.has(t))
  log(`halted: ${halted.join(', ')} — where blocks[].blockedPath is set, read that BLOCKED.md or the verdict.md beside it, and neither file means the agent died; where it is null the halt is a rework halt, which writes no BLOCKED.md — read blocks[].codeReview and blocks[].verify, which are the whole record of it${waited.length ? `. ${waited.join(', ')} never ran at all: each comes After a task that halted, and clearing that task is what starts it` : ''}`)
  return { feature: f, branch: FB, waves, passed, halted, blocks, dispatches: tally }
}

phase('Merge')
count('haiku')
const order = passed.map(p => p.branch)
const mg = await agent(
  `${ANSWER(f, 'merge')}Feature worktree ${FT}, on branch ${FB}. First, if a merge is in progress in ${FT} — a previous run stopped on a conflict and left it that way — run git -C ${FT} merge --abort before anything else. Nothing can be committed in that tree until you do, so every step after you dies if you skip it; check with git -C ${FT} status --porcelain=v1 -b. Then merge these task branches into ${FB}, in this order, one at a time — never two at once: ${order.join(', ')}. That is the landing order: the wave each task ran in first, then its number inside that wave. A task that came After another already merged that task's branch into its own before it built, so it sits behind that task in this list and the two share history. For each, run: git -C ${FT} merge --no-ff <branch>. On the first conflict, stop there: run git -C ${FT} merge --abort so the tree is usable again, then write ${dir}/BLOCKED.md — first line "BLOCKED: <one plain sentence, in business terms, asking which behaviour should win where the two changes disagree>", then in one sentence what you would do by default, then what changes if the owner rules otherwise. Return that first line as your whole result. Otherwise return the branches you merged, one per line, and nothing else.`,
  { agentType: 'coding:merger', phase: 'Merge' })
if (bad(mg)) return { feature: f, branch: FB, passed, halted, ...FEATURE_BLOCK(mg || 'BLOCKED: the merge agent died before merging every task branch', 'merge') }

phase('Feature')
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
  `${ANSWER(f, 'feature')}Feature branch ${FB} in the worktree ${FT}, every task branch already merged into it. Read ${dir}/plan.md and every ${dir}/tasks/*/criteria.md and tests.md. Work in ${FT}. Run the journey task's end-to-end test through ${STUB}; run every fitness test; run every task's tests together with: ${A.test} — substituting each test's name for "<TestName>" and the module's directory for "<module dir>", once per test, anchored as -run '^<TestName>$', changing nothing else. Every one of them must show "--- PASS: <that test name>"; "no tests to run" or "no test files" against a name that should exist is a BLOCK, never a pass. Run the gate in delta mode against ${BASE}, the branch this feature was cut from: ${FV_GATE}. Green means nothing this feature touched got worse and nothing it added is red; the repo's backlog from before the feature is not this feature's, and the absolute run belongs to the owner's merge to the default branch. Then diff ${FB} against ${BASE} and check the changed files this way: ignore every path under .claude/pipeline/ — that is the pipeline's own bookkeeping, one criteria/state/tests/plan/verdict set per task, and it is on this branch because every task committed its own — and ignore every test file, which redtest wrote. Every remaining changed file must sit under the path of a component named in ${dir}/plan.md's "Touches" — the Touches section names components and the path each one lives at, so match by path prefix, not by file. A remaining file under no named component's path is a BLOCK, naming the file and the components it fits none of. Write ${dir}/verdict.md from ${TPL('verdict')} at that absolute path, filling in the "Feature only" rows. On PASS, and only if ${CONFIG} contains a line "push: feature" or "push: confirmed", push ${FB} to the remote and put "pushed: <the remote ref>" on a second line. Return the verdict's first line — "# PASS" or "# BLOCK: <one sentence>" — then that pushed line if you pushed, and nothing else. ${BLOCK_RULE(dir)}`,
  { agentType: 'coding:featureverify', phase: 'Feature' })
// The first non-empty line only, for the same reason as vfPass above: the
// feature verdict's second line is prose, and "# BLOCK: the journey failed"
// explained by a sentence with PASS in it is a BLOCK.
const fvPass = !bad(fv) && new RegExp(`^${MD}PASS\\b`).test(firstLine(fv))
const pushed = fvPass ? ((fv.match(/^pushed:\s*(\S+)/m) || [null, null])[1]) : null
log(`dispatches this run asked for — opus ${tally.opus}, sonnet ${tally.sonnet}, haiku ${tally.haiku}; a resumed run counts cached calls again`)
return {
  feature: f, branch: FB, passed, halted, merged: mg,
  feature_verdict: fv || 'BLOCKED: the feature-verify agent died before writing its verdict',
  feature_verdict_path: `${dir}/verdict.md`, blockedPath: `${dir}/BLOCKED.md`, answerKey: f, answerStep: 'feature',
  pushed, dispatches: tally,
}
```

## Never

- Merge to the default branch. Deploy. Push anything but the feature branch, and that only on the feature verdict's PASS with config's permission.
- Edit the rulings files, or `.claude/pipeline/` outside `features/`.
- Skip a stage, or do its work in your own session.
