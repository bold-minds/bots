---
name: feature
description: Run one feature through the pipeline unattended — a feature plan, seven lenses, pre-mortem, breakdown, a stop for the owner to read the task list, then per task current-state → red tests → plan → build → review, then one serial merge, then the feature as a whole, then one push. Halts on BLOCKED. Called by /software with arguments from the repo's .claude/pipeline/config.md.
argument-hint: <feature-name>
allowed-tools: Workflow
---

Call the Workflow tool with this script, verbatim, and `args` as a JSON object
holding: `feature`, `root`, `plugin` (this plugin's root), `featureTree` (the
worktree sitting on the feature branch), `decisions`, `requirements`, `gate`,
`test`, and optionally `entry`, `stub`, `defaultBranch`, `answers`, and
`confirmTasks` (default true: the run stops after breakdown and returns the
task list; the owner reads it; resume with `confirmTasks: false`).

`/software` supplies them. Before the first run it creates the feature branch
`pipeline/<feature>` from the default branch **and a worktree on it**, and
passes that worktree's path as `featureTree`. Every feature-level file is
written and committed there.

`answers` carries the owner's ruling on a `BLOCKED.md`, keyed by `"<feature>"`
for a feature-level block or `"<feature>/<task>"` for a task-level one. It is
what makes a resume re-run the blocked step: the answer goes into that step's
prompt, so its call is new and every call before it is still cached.

Keep the `runId` and `scriptPath` from every result. Resume with the **same
args object**, plus `answers` and `confirmTasks: false` as needed.

```js
export const meta = {
  name: 'feature',
  description: 'One feature: plan, lenses, pre-mortem, breakdown, a stop to read the task list, then per task state, red tests, plan, build, review; then one serial merge; then the whole feature; then one push. Halts on BLOCKED.',
  phases: [
    { title: 'Plan', detail: 'the feature-level plan the lenses review' },
    { title: 'Lenses', detail: 'seven technical lenses on the plan, in parallel' },
    { title: 'Pre-mortem', detail: 'how it fails, including on purpose; keep only cases a customer hits and we can name a fallback for' },
    { title: 'Break down', detail: 'small tasks with criteria in the owner\'s words; stops for the owner to read the list' },
    { title: 'Tasks', detail: 'each task in its own worktree: state → red tests → plan → build → review' },
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
const dir = `${FT}/.claude/pipeline/features/${f}`
const WT = (t) => `${FT}/../wt-${f}-${t}`
const T = (t) => `${WT(t)}/.claude/pipeline/features/${f}/tasks/${t}`
const TPL = (n) => `${SHARED}/templates/${n}.md`
const TRIAGE = `${SHARED}/triage.md`
const ENTRY = A.entry || 'the program\'s main entry points'
const STUB = A.stub || 'the local end-to-end environment, if the repo has one'
const BASE = A.defaultBranch || 'the branch the feature branch was created from'
const CONFIRM = A.confirmTasks !== false

const isBlocked = (r) => typeof r === 'string' && /^BLOCKED:/m.test(r)
const bad = (r) => !r || isBlocked(r)
const tally = { opus: 0, sonnet: 0, haiku: 0 }
const count = (m) => { tally[m] = (tally[m] || 0) + 1 }
// The owner's answer arrives as an argument, never as an edit to BLOCKED.md.
// Every finished call is cached by its (prompt, opts); putting the answer in
// the prompt is what makes the blocked call — and only it — run again.
const ANSWER = (key) => (A.answers && A.answers[key]) ? `The owner has ruled on the question in BLOCKED.md: "${A.answers[key]}". Apply it as a ruling, then delete BLOCKED.md. ` : ''
const BLOCK_RULE = (where) =>
  `If you must stop per ${TRIAGE}, write ${where}/BLOCKED.md — first line "BLOCKED: <one plain sentence>", then your best default in one sentence, drawn from the nearest existing thing in this repo and naming it, then what changes if the owner says otherwise — and return that first line as your whole result.`
const FEATURE_BLOCK = (b) => ({ blocked: b, blockedPath: `${dir}/BLOCKED.md`, answerKey: f, dispatches: tally })

phase('Plan')
count('opus')
const fp = await agent(
  `${ANSWER(f)}Read ${dir}/spec.md, ${A.requirements}, ${A.decisions}, and enough of the code to know what already exists. Entry points: ${ENTRY}. Write ${dir}/plan.md from ${TPL('featureplan')}. Then, in ${FT} — a worktree already on branch ${FB} — git add the plan and commit it. Return "planned" and nothing else. ${BLOCK_RULE(dir)}`,
  { agentType: 'coding:featureplan', phase: 'Plan' })
if (bad(fp)) return { halted: 'Plan', ...FEATURE_BLOCK(fp || 'BLOCKED: the feature-plan agent died before writing its file') }

phase('Lenses')
const LENSES = [['architecture', 'opus'], ['sre', 'opus'], ['security', 'opus'], ['performance', 'sonnet'], ['database', 'sonnet'], ['qa', 'opus'], ['staff', 'opus']]
const lenses = await parallel(LENSES.map(([l, m]) => () => { count(m); return agent(
  `${ANSWER(f)}Lens: ${l}. Read ${dir}/spec.md and ${dir}/plan.md. Load ${SHARED}/lenses/${l}.md; if ${P}/lenses/${l}.md exists, load it too — it is this repo's history for this lens. Nothing about other lenses. Write ${dir}/lens-${l}.md from ${TPL('lens')}. Do not run git: you are one of several lenses writing into ${FT} at the same time, and the next step commits all of your files together. Return the number of findings and nothing else. ${BLOCK_RULE(dir)}`,
  { agentType: 'coding:lens', phase: 'Lenses', label: `lens: ${l}`, model: m }) }))
const dead = lenses.findIndex(r => !r)
if (dead >= 0) return { halted: 'Lenses', ...FEATURE_BLOCK(`BLOCKED: the ${LENSES[dead][0]} lens agent died before writing its file`) }
const lensBlock = lenses.find(isBlocked)
if (lensBlock) return { halted: 'Lenses', ...FEATURE_BLOCK(lensBlock) }
log(`lenses: ${LENSES.length} written`)

phase('Pre-mortem')
count('opus')
const pm = await agent(
  `${ANSWER(f)}Read ${dir}/spec.md, ${dir}/plan.md, every ${dir}/lens-*.md — there are ${LENSES.length}, one of them the security lens, and its last sentence is written for you — and ${A.decisions}. Write ${dir}/premortem.md from ${TPL('premortem')}. Then, in ${FT}, git add the whole feature directory — your file and every lens file — and commit it. Return the number of kept cases and nothing else. ${BLOCK_RULE(dir)}`,
  { agentType: 'coding:premortem', phase: 'Pre-mortem' })
if (bad(pm)) return { halted: 'Pre-mortem', ...FEATURE_BLOCK(pm || 'BLOCKED: the pre-mortem agent died before writing its file') }

phase('Break down')
count('opus')
const bdText = await agent(
  `${ANSWER(f)}Read ${dir}/spec.md, ${dir}/plan.md, every ${dir}/lens-*.md, ${dir}/premortem.md, ${A.requirements} and ${A.decisions}. Write one ${dir}/tasks/<nn>-<short-name>/criteria.md per task from ${TPL('criteria')}, in landing order, each with its Success line filled in. The task carrying the plan's journey is marked "Journey: yes"; the plan's structural rules go into that task's "Structural rules". Then delete the lens-*.md and premortem.md files. Then, in ${FT}, git add the feature directory — the new task files and the deletions — and commit it. Return ONLY the task directory names, one per line, nothing else. ${BLOCK_RULE(dir)}`,
  { agentType: 'coding:breakdown', phase: 'Break down' })
if (bad(bdText)) return { halted: 'Break down', ...FEATURE_BLOCK(bdText || 'BLOCKED: the breakdown agent died before writing any task') }
const tasks = bdText.split('\n').map(s => s.trim()).filter(s => /^[0-9]{2}-[a-z0-9-]+$/.test(s))
if (!tasks.length) return { halted: 'Break down', ...FEATURE_BLOCK(`BLOCKED: breakdown returned no task names. It returned: ${bdText.slice(0, 200)}`) }
log(`tasks: ${tasks.length}`)
if (CONFIRM) {
  log('stopping for the owner to read the task list — resume with confirmTasks: false')
  return { awaiting: 'confirm', feature: f, tasks, taskDir: `${dir}/tasks`, dispatches: tally }
}

phase('Tasks')
const halt = (t, stage, r) => { throw new Error(`${t} halted at ${stage}: ${r || 'the agent died'}`) }
const guard = (t, stage, shape) => (r) => (bad(r) || (shape && !shape.test(r))) ? halt(t, stage, r) : r

const results = await pipeline(tasks,
  (_, t) => { count('sonnet'); return agent(
    `${ANSWER(`${f}/${t}`)}First, cut this task's worktree from the feature branch: git -C ${FT} worktree add ${WT(t)} -b ${FB}/${t} ${FB} — unless ${WT(t)} already exists, in which case use it as it is. Everything you read and write is inside it. Read ${T(t)}/criteria.md. Rule each criterion TRUE or FALSE against the code in ${WT(t)}, which is branch ${FB} — not the default branch — with a file:line or a command you ran as evidence, never a document. Trace from a real entry point: ${ENTRY}. Write ${T(t)}/state.md from ${TPL('state')}, then git add and commit it in ${WT(t)}. Return "to build: N, to guard: M" and nothing else. ${BLOCK_RULE(T(t))}`,
    { agentType: 'coding:state', phase: 'Tasks', label: `${t}: state` }).then(guard(t, 'state', /^to build:\s*\d+/mi)) },
  (_, t) => { count('opus'); return agent(
    `${ANSWER(`${f}/${t}`)}Work in ${WT(t)}, a worktree on branch ${FB}/${t}. Read ${T(t)}/criteria.md and ${T(t)}/state.md. Write the tests and ${T(t)}/tests.md from ${TPL('tests')}. The test command is: ${A.test}. Journey tests use ${STUB}. Every FALSE criterion's test must be red now. Every TRUE criterion's test must go red when you break the behaviour on purpose, then be restored. Then git add and commit the tests and tests.md in ${WT(t)}. Return the tests.md table and nothing else. ${BLOCK_RULE(T(t))}`,
    { agentType: 'coding:redtest', phase: 'Tasks', label: `${t}: red tests` }).then(guard(t, 'red tests', /^\s*\|/m)) },
  (_, t) => { count('opus'); return agent(
    `${ANSWER(`${f}/${t}`)}Work in ${WT(t)}, a worktree on branch ${FB}/${t}. Read ${T(t)}/criteria.md, ${T(t)}/tests.md, the test files, the code they exercise, and ${A.decisions}. Write ${T(t)}/plan.md from ${TPL('plan')}, then git add and commit it in ${WT(t)}. If the Flag line is not "Flag: none", also write ${T(t)}/BLOCKED.md with that flag as its first line, prefixed "BLOCKED: ", then your best default and what changes if the owner says otherwise. Return the Flag line exactly as written and nothing else. ${BLOCK_RULE(T(t))}`,
    { agentType: 'coding:planner', phase: 'Tasks', label: `${t}: plan` }).then(r => (bad(r) || !/^Flag:\s*none\b(?!\s+\w)/mi.test(r)) ? halt(t, 'plan', r) : r) },
  (_, t) => { count('opus'); return agent(
    `${ANSWER(`${f}/${t}`)}Implement ${T(t)}/plan.md. Work in ${WT(t)} — the worktree already on branch ${FB}/${t}, cut from ${FB}, holding the criteria, the state, the red tests and the plan. Do not create another worktree. Make every test in ${T(t)}/tests.md green without weakening any test, using: ${A.test}. Then run the gate to green: ${A.gate}. Commit in ${WT(t)}. Do not push. Do not merge. Return exactly one line — "branch: ${FB}/${t}" — and nothing else. ${BLOCK_RULE(T(t))}`,
    { agentType: 'coding:builder', phase: 'Tasks', label: `${t}: build` }).then(r => { const m = bad(r) ? null : (r.match(/^branch: (\S+)/m) || [])[1]; return m || halt(t, 'build', r) }) },
  // Two fresh contexts that never saw the builder's reasoning, in parallel:
  // fix-code's lensed code review, and a verifier for what a code review does
  // not do. PASS needs both. Neither merges — the Merge phase does, after every
  // task has passed, so a code-review BLOCK can never land on an already-merged
  // branch.
  (b, t) => { count('opus'); count('opus'); return parallel([
    () => agent(
      `Branch-mode review of ${b} in ${WT(t)}: diff it against ${FB}, the feature branch it was cut from — not the default branch. Read every CLAUDE.md in the repo and hold the code to it. File manifest: every file the diff touches — read each in full. Apply the lens prompt templates in ${CODE_LENSES}: the always-on baseline plus whatever ${LENS_RULES} selects for these files. Report findings by severity as your agent definition says. This dispatch comes from the /feature pipeline rather than fix-code, and it adds one line to your format: end with exactly "VERDICT: PASS" if there is no P0 or P1 finding, otherwise "VERDICT: BLOCK: <the top P0/P1 in one sentence>". Both are intended.`,
      { agentType: 'coding:code-reviewer', phase: 'Tasks', label: `${t}: code review` }),
    () => agent(
      `${ANSWER(`${f}/${t}`)}Verify ${b} against ${T(t)}/criteria.md, ${T(t)}/tests.md and ${T(t)}/plan.md. Check it out in a worktree of your own, detached so you do not fight the build worktree: git -C ${WT(t)} worktree add --detach ../vf-${f}-${t} ${b}. Re-run every test and every mutation yourself with: ${A.test}; run the gate: ${A.gate}; read ${A.decisions} and confirm nothing is reversed; diff ${b} against ${FB} — the feature branch, not the default branch — and confirm only plan.md's files changed. Write ${T(t)}/verdict.md from ${TPL('verdict')} at that absolute path — your own worktree is discarded. Merge nothing: the merge is a separate step after every task has passed. Return the verdict's first line exactly — "# PASS" or "# BLOCK: <one sentence>" — and nothing else. ${BLOCK_RULE(T(t))}`,
      { agentType: 'coding:verifier', phase: 'Tasks', label: `${t}: verify` }),
  ]).then(([cr, vf]) => {
    const crPass = typeof cr === 'string' && /^VERDICT:\s*PASS/m.test(cr)
    const vfPass = !bad(vf) && /^#?\s*PASS\b/m.test(vf)
    if (crPass && vfPass) return { task: t, branch: b, verdict: vf, review: (cr.match(/^VERDICT:.*$/m) || [''])[0] }
    const why = [
      !cr ? 'code-reviewer died' : (!crPass ? `code review: ${(cr.match(/^VERDICT:.*$/m) || ['no verdict line'])[0]}` : null),
      !vf ? 'verifier died' : (!vfPass ? `verify: ${vf}` : null),
    ].filter(Boolean).join(' | ')
    return halt(t, 'review', why)
  }) },
)

const passed = results.filter(Boolean)
const halted = tasks.filter((_, i) => !results[i])
// A halt's message dies inside pipeline(), so name the files that hold the
// reason and the key the owner's answer comes back under.
const blocks = halted.map(t => ({ task: t, blockedPath: `${T(t)}/BLOCKED.md`, verdictPath: `${T(t)}/verdict.md`, answerKey: `${f}/${t}` }))
log(`dispatches this run asked for — opus ${tally.opus}, sonnet ${tally.sonnet}, haiku ${tally.haiku}; a resumed run counts cached calls again`)
if (halted.length) {
  log(`halted: ${halted.join(', ')} — read each task's BLOCKED.md or verdict.md; neither file means the agent died`)
  return { feature: f, branch: FB, passed, halted, blocks, dispatches: tally }
}

phase('Merge')
count('haiku')
const order = passed.map(p => p.branch)
const mg = await agent(
  `Feature worktree ${FT}, on branch ${FB}. Merge these task branches into ${FB}, in this order, one at a time — never two at once: ${order.join(', ')}. For each, run: git -C ${FT} merge --no-ff <branch>. On the first conflict, stop there: write ${dir}/BLOCKED.md — first line "BLOCKED: <branch> and ${FB} changed the same lines, so the merge stopped", then the two branch names and the files that clashed, then that whoever resolves it decides which behaviour wins — and return that first line as your whole result. Otherwise return the branches you merged, one per line, and nothing else.`,
  { agentType: 'coding:merger', phase: 'Merge' })
if (bad(mg)) return { feature: f, branch: FB, passed, halted, ...FEATURE_BLOCK(mg || 'BLOCKED: the merge agent died before merging every task branch') }

phase('Feature')
count('sonnet')
const fv = await agent(
  `${ANSWER(f)}Feature branch ${FB} in the worktree ${FT}, every task branch already merged into it. Read ${dir}/plan.md and every ${dir}/tasks/*/criteria.md and tests.md. Work in ${FT}. Run the journey task's end-to-end test through ${STUB}; run every fitness test; run every task's tests together with: ${A.test}; run the gate: ${A.gate}; diff ${FB} against ${BASE} and confirm nothing outside the plan's "Touches" moved. Write ${dir}/verdict.md from ${TPL('verdict')} at that absolute path, filling in the "Feature only" rows. On PASS, and only if ${CONFIG} contains a line "push: feature" or "push: confirmed", push ${FB} to the remote and put "pushed: <the remote ref>" on a second line. Return the verdict's first line — "# PASS" or "# BLOCK: <one sentence>" — then that pushed line if you pushed, and nothing else. ${BLOCK_RULE(dir)}`,
  { agentType: 'coding:featureverify', phase: 'Feature' })
const fvPass = !bad(fv) && /^#?\s*PASS\b/m.test(fv)
const pushed = fvPass ? ((fv.match(/^pushed:\s*(\S+)/m) || [null, null])[1]) : null
log(`dispatches this run asked for — opus ${tally.opus}, sonnet ${tally.sonnet}, haiku ${tally.haiku}; a resumed run counts cached calls again`)
return {
  feature: f, branch: FB, passed, halted, merged: mg,
  feature_verdict: fv || 'BLOCKED: the feature-verify agent died before writing its verdict',
  feature_verdict_path: `${dir}/verdict.md`, blockedPath: `${dir}/BLOCKED.md`, answerKey: f,
  pushed, dispatches: tally,
}
```

## Never

- Merge to the default branch. Deploy. Push anything but the feature branch, and that only on the feature verdict's PASS with config's permission.
- Edit the rulings files, or `.claude/pipeline/` outside `features/`.
- Skip a stage, or do its work in your own session.
