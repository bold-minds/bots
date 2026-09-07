---
name: feature
description: Run one feature through the pipeline unattended — a feature plan, six lenses, pre-mortem, breakdown, a stop for the owner to read the task list, then per task current-state → red tests → plan → build → review → merge into the feature branch, then the feature as a whole, then one push. Halts on BLOCKED. Called by /software with arguments from the repo's .claude/pipeline/config.md.
---

Call the Workflow tool with this script, verbatim, and `args` as a JSON object
holding: `feature`, `root`, `plugin` (this plugin's root), `decisions`,
`requirements`, `gate`, `test`, and optionally `entry`, `stub`, and
`confirmTasks` (default true: the run stops after breakdown and returns the
task list; the owner reads it; resume with `confirmTasks: false`). `/software`
supplies them and creates the feature branch `pipeline/<feature>` from the
default branch before the first run. Keep the `runId` and `scriptPath` from
every result for resuming.

```js
export const meta = {
  name: 'feature',
  description: 'One feature: plan, lenses, pre-mortem, breakdown, a stop to read the task list, then per task state, red tests, plan, build, review, merge; then the whole feature; then one push. Halts on BLOCKED.',
  phases: [
    { title: 'Plan', detail: 'the feature-level plan the lenses review' },
    { title: 'Lenses', detail: 'six technical lenses on the plan, in parallel' },
    { title: 'Pre-mortem', detail: 'how it fails; keep only cases a customer hits and we can name a fallback for' },
    { title: 'Break down', detail: 'small tasks with criteria in the owner\'s words; stops for the owner to read the list' },
    { title: 'Tasks', detail: 'each task: state → red tests → plan → build → review → merge into the feature branch' },
    { title: 'Feature', detail: 'the whole feature branch: journey, fitness, every test together, the gate; then one push' },
  ],
}

const A = args || {}
for (const k of ['feature', 'root', 'plugin', 'decisions', 'requirements', 'gate', 'test']) {
  if (!A[k]) throw new Error(`args.${k} is required — /software fills it from .claude/pipeline/config.md`)
}
const f = A.feature, ROOT = A.root, PLUGIN = A.plugin
const SHARED = `${PLUGIN}/shared/pipeline`
const CODE_LENSES = `${PLUGIN}/skills/fix-code/references/lenses.md`
const LENS_RULES = `${PLUGIN}/skills/fix-code/references/lens-selection.md`
const P = `${ROOT}/.claude/pipeline`
const CONFIG = `${P}/config.md`
const dir = `${P}/features/${f}`
const FB = `pipeline/${f}`
const TPL = (n) => `${SHARED}/templates/${n}.md`
const TRIAGE = `${SHARED}/triage.md`
const ENTRY = A.entry || 'the program\'s main entry points'
const STUB = A.stub || 'the local end-to-end environment, if the repo has one'
const CONFIRM = A.confirmTasks !== false

const isBlocked = (r) => typeof r === 'string' && /^BLOCKED:/m.test(r)
const bad = (r) => !r || isBlocked(r)
const tally = { opus: 0, sonnet: 0, haiku: 0 }
const count = (m) => { tally[m] = (tally[m] || 0) + 1 }
// Every prompt carries both halves of the halt protocol: how to stop, and how
// to read the owner's answer when resumed. The first version wrote the answer
// under "Answer:" and no step ever read it.
const BLOCK_RULE = (where) =>
  `First: if ${where}/BLOCKED.md exists and contains a line starting "Answer:", the owner has ruled on the question above it — apply that answer as a ruling, then delete ${where}/BLOCKED.md. If you must stop per ${TRIAGE}, write ${where}/BLOCKED.md — first line "BLOCKED: <one plain sentence>", then your best default in one sentence, drawn from the nearest existing thing in this repo and naming it, then what changes if the owner says otherwise — and return that first line as your whole result.`

phase('Plan')
count('opus')
const fp = await agent(
  `Read ${dir}/spec.md, ${A.requirements}, ${A.decisions}, and enough of the code to know what already exists. Entry points: ${ENTRY}. Write ${dir}/plan.md from ${TPL('featureplan')}. Return "planned" and nothing else. ${BLOCK_RULE(dir)}`,
  { agentType: 'coding:featureplan', phase: 'Plan' })
if (bad(fp)) return { halted: 'Plan', block: fp || 'BLOCKED: the feature-plan agent died before writing its file' }

phase('Lenses')
const LENSES = [['architecture', 'opus'], ['sre', 'opus'], ['performance', 'sonnet'], ['database', 'sonnet'], ['qa', 'opus'], ['staff', 'opus']]
const lenses = await parallel(LENSES.map(([l, m]) => () => { count(m); return agent(
  `Lens: ${l}. Read ${dir}/spec.md and ${dir}/plan.md. Load ${SHARED}/lenses/${l}.md; if ${P}/lenses/${l}.md exists, load it too — it is this repo's history for this lens. Nothing about other lenses. Write ${dir}/lens-${l}.md from ${TPL('lens')}. Return the number of findings and nothing else. ${BLOCK_RULE(dir)}`,
  { agentType: 'coding:lens', phase: 'Lenses', label: `lens: ${l}`, model: m }) }))
const dead = lenses.findIndex(r => !r)
if (dead >= 0) return { halted: 'Lenses', block: `BLOCKED: the ${LENSES[dead][0]} lens agent died before writing its file` }
const lensBlock = lenses.find(isBlocked)
if (lensBlock) return { halted: 'Lenses', block: lensBlock }
log(`lenses: ${LENSES.length} written`)

phase('Pre-mortem')
count('opus')
const pm = await agent(
  `Read ${dir}/spec.md, ${dir}/plan.md, every ${dir}/lens-*.md, and ${A.decisions}. Write ${dir}/premortem.md from ${TPL('premortem')}. Return the number of kept cases and nothing else. ${BLOCK_RULE(dir)}`,
  { agentType: 'coding:premortem', phase: 'Pre-mortem' })
if (bad(pm)) return { halted: 'Pre-mortem', block: pm || 'BLOCKED: the pre-mortem agent died before writing its file' }

phase('Break down')
count('sonnet')
const bdText = await agent(
  `Read ${dir}/spec.md, ${dir}/plan.md, every ${dir}/lens-*.md, ${dir}/premortem.md, ${A.requirements} and ${A.decisions}. Write one ${dir}/tasks/<nn>-<short-name>/criteria.md per task from ${TPL('criteria')}, in landing order. The task carrying the plan's journey is marked "Journey: yes"; the plan's structural rules go into that task's "Structural rules". Then delete the lens-*.md and premortem.md files. Return ONLY the task directory names, one per line, nothing else. ${BLOCK_RULE(dir)}`,
  { agentType: 'coding:breakdown', phase: 'Break down' })
if (bad(bdText)) return { halted: 'Break down', block: bdText || 'BLOCKED: the breakdown agent died before writing any task' }
const tasks = bdText.split('\n').map(s => s.trim()).filter(s => /^[0-9]{2}-[a-z0-9-]+$/.test(s))
if (!tasks.length) return { halted: 'Break down', block: `BLOCKED: breakdown returned no task names. It returned: ${bdText.slice(0, 200)}` }
log(`tasks: ${tasks.length}`)
if (CONFIRM) {
  log('stopping for the owner to read the task list — resume with confirmTasks: false')
  return { awaiting: 'confirm', feature: f, tasks, dispatches: tally }
}

phase('Tasks')
const T = (t) => `${dir}/tasks/${t}`
const halt = (t, stage, r) => { throw new Error(`${t} halted at ${stage}: ${r || 'the agent died'}`) }
const guard = (t, stage) => (r) => bad(r) ? halt(t, stage, r) : r

const results = await pipeline(tasks,
  (_, t) => { count('sonnet'); return agent(
    `Read ${T(t)}/criteria.md. Rule each criterion TRUE or FALSE against the code on branch ${FB}, with a file:line or a command you ran as evidence — never a document. Trace from a real entry point: ${ENTRY}. Write ${T(t)}/state.md from ${TPL('state')}, then git add and commit it on ${FB}. Return "to build: N, to guard: M" and nothing else. ${BLOCK_RULE(T(t))}`,
    { agentType: 'coding:state', phase: 'Tasks', label: `${t}: state` }).then(guard(t, 'state')) },
  (_, t) => { count('opus'); return agent(
    `Read ${T(t)}/criteria.md and ${T(t)}/state.md. Write the tests and ${T(t)}/tests.md from ${TPL('tests')}. Run tests with: ${A.test}. Journey tests use ${STUB}. Every FALSE criterion's test must be red now. Every TRUE criterion's test must go red when you break the behaviour on purpose, then be restored. Then git add and commit the tests and tests.md on ${FB}. Return the tests.md table and nothing else. ${BLOCK_RULE(T(t))}`,
    { agentType: 'coding:redtest', phase: 'Tasks', label: `${t}: red tests` }).then(guard(t, 'red tests')) },
  (_, t) => { count('opus'); return agent(
    `Read ${T(t)}/criteria.md, ${T(t)}/tests.md, the test files, the code they exercise, and ${A.decisions}. Write ${T(t)}/plan.md from ${TPL('plan')}, then git add and commit it on ${FB}. Return the Flag line exactly as written and nothing else. ${BLOCK_RULE(T(t))}`,
    { agentType: 'coding:planner', phase: 'Tasks', label: `${t}: plan` }).then(r => (bad(r) || !/^Flag:\s*none\s*$/mi.test(r)) ? halt(t, 'plan', r) : r) },
  (_, t) => { count('opus'); return agent(
    `Implement ${T(t)}/plan.md. Work in your own worktree on a branch named ${FB}/${t}, created from ${FB} — not from the default branch, not from origin. Make every test in ${T(t)}/tests.md green without weakening any test, using: ${A.test}. Then run the gate to green: ${A.gate}. Commit. Do not push. Return exactly one line — "branch: ${FB}/${t}" — and nothing else. ${BLOCK_RULE(T(t))}`,
    { agentType: 'coding:builder', phase: 'Tasks', label: `${t}: build` }).then(r => (bad(r) || !/^branch: /m.test(r)) ? halt(t, 'build', r) : r) },
  // Two fresh contexts that never saw the builder's reasoning, in parallel:
  // fix-code's lensed code review, and a verifier for what a code review does
  // not do. PASS needs both. On PASS the verifier merges the task into the
  // feature branch; on BLOCK nothing merges.
  (built, t) => { count('opus'); count('opus'); const b = built.trim().replace(/^branch: /, ''); return parallel([
    () => agent(
      `Branch-mode review of ${b} in ${ROOT}: diff it against ${FB}. Read every CLAUDE.md in the repo and hold the code to it. File manifest: every file the diff touches — read each in full. Apply the lens prompt templates in ${CODE_LENSES}: the always-on baseline plus whatever ${LENS_RULES} selects for these files. Report findings by severity as your agent definition says, then end with exactly one line: "VERDICT: PASS" if there is no P0 or P1 finding, otherwise "VERDICT: BLOCK: <the top P0/P1 in one sentence>".`,
      { agentType: 'coding:code-reviewer', phase: 'Tasks', label: `${t}: code review` }),
    () => agent(
      `Verify ${b} against ${T(t)}/criteria.md, ${T(t)}/tests.md and ${T(t)}/plan.md. Check the branch out in your own worktree; re-run every test and every mutation yourself with: ${A.test}; run the gate: ${A.gate}; read ${A.decisions} and confirm nothing is reversed; diff against ${FB} and confirm only plan.md's files changed. Write ${T(t)}/verdict.md from ${TPL('verdict')} at that absolute path — your worktree is discarded. On PASS, merge ${b} into ${FB} (fast-forward if possible, otherwise a merge commit); on BLOCK merge nothing. Return the verdict's first line exactly — "# PASS" or "# BLOCK: <one sentence>" — and nothing else. ${BLOCK_RULE(T(t))}`,
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
if (halted.length) {
  log(`halted: ${halted.join(', ')} — each task directory holds BLOCKED.md or verdict.md; neither means the agent died`)
  log(`dispatches — opus ${tally.opus}, sonnet ${tally.sonnet}, haiku ${tally.haiku}`)
  return { feature: f, branch: FB, passed, halted, dispatches: tally }
}

phase('Feature')
count('opus')
const fv = await agent(
  `Feature branch ${FB} in ${ROOT}, every task merged. Read ${dir}/plan.md and every ${dir}/tasks/*/criteria.md and tests.md. Check ${FB} out in your own worktree. Run the journey task's end-to-end test through ${STUB}; run every fitness test; run every task's tests together with: ${A.test}; run the gate: ${A.gate}; diff against the default branch and confirm nothing outside the plan's "Touches" moved. Write ${dir}/verdict.md from ${TPL('verdict')} at that absolute path. On PASS, and only if ${CONFIG} contains a line "push: feature" or "push: confirmed", push ${FB} to the remote and put the remote ref on a second line. Return the verdict's first line — "# PASS" or "# BLOCK: <one sentence>" — then the ref if pushed, and nothing else. ${BLOCK_RULE(dir)}`,
  { agentType: 'coding:featureverify', phase: 'Feature' })
const fvPass = !bad(fv) && /^#?\s*PASS\b/m.test(fv)
const pushed = fvPass ? ((fv.match(/^(origin\S*|refs\S*|[a-z]+\/pipeline\/\S+)$/m) || [null])[0]) : null
log(`dispatches — opus ${tally.opus}, sonnet ${tally.sonnet}, haiku ${tally.haiku}`)
return { feature: f, branch: FB, passed, halted, feature_verdict: fv, pushed, dispatches: tally }
```

## Never

- Merge to the default branch. Deploy. Push anything but the feature branch, and that only on the feature verdict's PASS with config's permission.
- Edit the rulings files, or `.claude/pipeline/` outside `features/`.
- Skip a stage or do its work in the room.
