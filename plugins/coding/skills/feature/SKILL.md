---
name: feature
description: Run one feature through the pipeline unattended — six lenses, pre-mortem, breakdown, then per task current-state → red tests → plan → build → review. Halts on BLOCKED. Called by /software with arguments from the repo's .claude/pipeline/config.md, not by the owner directly.
---

Call the Workflow tool with this script, verbatim, and `args` as a JSON object
holding: `feature`, `root`, `plugin` (this plugin's root), `decisions`,
`requirements`, `gate`, `test`, and optionally `entry`, `stub`. `/software`
supplies them. Keep the `runId` and `scriptPath` from the result for resuming
a blocked run.

```js
export const meta = {
  name: 'feature',
  description: 'One feature through the pipeline: lenses, pre-mortem, breakdown, then per task state, red tests, plan, build, review. Halts on BLOCKED.',
  phases: [
    { title: 'Lenses', detail: 'six technical lenses on the spec, in parallel' },
    { title: 'Pre-mortem', detail: 'how it fails; keep only cases a customer hits and we can name a fallback for' },
    { title: 'Break down', detail: 'small tasks with criteria in the owner\'s words' },
    { title: 'Tasks', detail: 'each task: state → red tests → plan → build → review' },
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
const dir = `${P}/features/${f}`
const TPL = (n) => `${SHARED}/templates/${n}.md`
const TRIAGE = `${SHARED}/triage.md`
const ENTRY = A.entry || 'the program\'s main entry points'
const STUB = A.stub || 'the local end-to-end environment, if the repo has one'

const isBlocked = (r) => typeof r === 'string' && /^BLOCKED:/m.test(r)
const bad = (r) => !r || isBlocked(r)
const tally = { opus: 0, sonnet: 0, haiku: 0 }
const count = (m) => { tally[m] = (tally[m] || 0) + 1 }
const BLOCK_RULE = (where) =>
  `If you must stop per ${TRIAGE}, write ${where}/BLOCKED.md — first line "BLOCKED: <one plain sentence>", then your best default in one sentence, then what changes if the owner says otherwise — and return that first line as your whole result.`

phase('Lenses')
const LENSES = [['architecture', 'opus'], ['sre', 'opus'], ['performance', 'sonnet'], ['database', 'sonnet'], ['qa', 'opus'], ['staff', 'opus']]
const lenses = await parallel(LENSES.map(([l, m]) => () => { count(m); return agent(
  `Lens: ${l}. Read ${dir}/spec.md. Load ${SHARED}/lenses/${l}.md; if ${P}/lenses/${l}.md exists, load it too — it is this repo's history for this lens. Nothing about other lenses. Write ${dir}/lens-${l}.md from ${TPL('lens')}. Return the number of findings and nothing else. ${BLOCK_RULE(dir)}`,
  { agentType: 'lens', phase: 'Lenses', label: `lens: ${l}`, model: m }) }))
const dead = lenses.findIndex(r => !r)
if (dead >= 0) return { halted: 'Lenses', block: `BLOCKED: the ${LENSES[dead][0]} lens agent died before writing its file` }
const lensBlock = lenses.find(isBlocked)
if (lensBlock) return { halted: 'Lenses', block: lensBlock }
log(`lenses: ${LENSES.length} written`)

phase('Pre-mortem')
count('opus')
const pm = await agent(
  `Read ${dir}/spec.md and every ${dir}/lens-*.md. Write ${dir}/premortem.md from ${TPL('premortem')}. Return the number of kept cases and nothing else. ${BLOCK_RULE(dir)}`,
  { agentType: 'premortem', phase: 'Pre-mortem' })
if (bad(pm)) return { halted: 'Pre-mortem', block: pm || 'BLOCKED: the pre-mortem agent died before writing its file' }

phase('Break down')
count('sonnet')
const bdText = await agent(
  `Read ${dir}/spec.md, every ${dir}/lens-*.md, ${dir}/premortem.md, ${A.requirements} and ${A.decisions}. Write one ${dir}/tasks/<nn>-<short-name>/criteria.md per task from ${TPL('criteria')}, in landing order, then delete the lens-*.md and premortem.md files. Return ONLY the task directory names, one per line, nothing else. ${BLOCK_RULE(dir)}`,
  { agentType: 'breakdown', phase: 'Break down' })
if (bad(bdText)) return { halted: 'Break down', block: bdText || 'BLOCKED: the breakdown agent died before writing any task' }
const tasks = bdText.split('\n').map(s => s.trim()).filter(s => /^[0-9]{2}-[a-z0-9-]+$/.test(s))
if (!tasks.length) return { halted: 'Break down', block: `BLOCKED: breakdown returned no task names. It returned: ${bdText.slice(0, 200)}` }
log(`tasks: ${tasks.length}`)

phase('Tasks')
const T = (t) => `${dir}/tasks/${t}`
const halt = (t, stage, r) => { throw new Error(`${t} halted at ${stage}: ${r || 'the agent died'}`) }
const guard = (t, stage) => (r) => bad(r) ? halt(t, stage, r) : r

const results = await pipeline(tasks,
  (_, t) => { count('sonnet'); return agent(
    `Read ${T(t)}/criteria.md. Rule each criterion TRUE or FALSE against the code at the repo's default branch, with a file:line or a command you ran as evidence — never a document. Trace from a real entry point: ${ENTRY}. Write ${T(t)}/state.md from ${TPL('state')}, then git add and commit it. Return "to build: N, to guard: M" and nothing else. ${BLOCK_RULE(T(t))}`,
    { agentType: 'state', phase: 'Tasks', label: `${t}: state` }).then(guard(t, 'state')) },
  (_, t) => { count('opus'); return agent(
    `Read ${T(t)}/criteria.md and ${T(t)}/state.md. Write the tests and ${T(t)}/tests.md from ${TPL('tests')}. Run tests with: ${A.test}. Journey tests use ${STUB}. Every FALSE criterion's test must be red now. Every TRUE criterion's test must go red when you break the behaviour on purpose, then be restored. Then git add and commit the tests and tests.md. Return the tests.md table and nothing else. ${BLOCK_RULE(T(t))}`,
    { agentType: 'redtest', phase: 'Tasks', label: `${t}: red tests` }).then(guard(t, 'red tests')) },
  (_, t) => { count('opus'); return agent(
    `Read ${T(t)}/criteria.md, ${T(t)}/tests.md, the test files, the code they exercise, and ${A.decisions}. Write ${T(t)}/plan.md from ${TPL('plan')}, then git add and commit it. Return the Flag line exactly as written and nothing else. ${BLOCK_RULE(T(t))}`,
    { agentType: 'planner', phase: 'Tasks', label: `${t}: plan` }).then(r => (bad(r) || !/^Flag:\s*none\s*$/mi.test(r)) ? halt(t, 'plan', r) : r) },
  (_, t) => { count('opus'); return agent(
    `Implement ${T(t)}/plan.md. Work in your own worktree from local HEAD on a branch named pipeline/${f}/${t}. Make every test in ${T(t)}/tests.md green without weakening any test, using: ${A.test}. Then run the gate to green: ${A.gate}. Commit. Push and open a PR only if ${P}/config.md contains the line "push: confirmed". Return exactly one line — "branch: pipeline/${f}/${t}", or the PR URL if you pushed — and nothing else. ${BLOCK_RULE(T(t))}`,
    { agentType: 'builder', phase: 'Tasks', label: `${t}: build` }).then(r => (bad(r) || !/^(branch: |https?:\/\/)/m.test(r)) ? halt(t, 'build', r) : r) },
  // Stage 9 is two fresh contexts that never saw the builder's reasoning, in
  // parallel: fix-code's lensed code review, and a verifier for what a code
  // review does not do — mutation re-runs, the gate, the rulings, the touched
  // files. PASS needs both.
  (built, t) => { count('opus'); count('opus'); const b = built.trim(); return parallel([
    () => agent(
      `Branch-mode review of ${b} in ${ROOT}: diff it against the default branch. Read every CLAUDE.md in the repo and hold the code to it. File manifest: every file the diff touches — read each in full. Apply the lens prompt templates in ${CODE_LENSES}: the always-on baseline plus whatever ${LENS_RULES} selects for these files. Report findings by severity as your agent definition says, then end with exactly one line: "VERDICT: PASS" if there is no P0 or P1 finding, otherwise "VERDICT: BLOCK: <the top P0/P1 in one sentence>".`,
      { agentType: 'code-reviewer', phase: 'Tasks', label: `${t}: code review` }),
    () => agent(
      `Verify ${b} against ${T(t)}/criteria.md, ${T(t)}/tests.md and ${T(t)}/plan.md. Check the branch out in your own worktree; re-run every test and every mutation yourself with: ${A.test}; run the gate: ${A.gate}; read ${A.decisions} and confirm nothing is reversed; confirm only plan.md's files changed. Write ${T(t)}/verdict.md from ${TPL('verdict')} at that absolute path — your worktree is discarded. Return its first line exactly — "# PASS" or "# BLOCK: <one sentence>" — and nothing else. ${BLOCK_RULE(T(t))}`,
      { agentType: 'verifier', phase: 'Tasks', label: `${t}: verify` }),
  ]).then(([cr, vf]) => {
    const crPass = typeof cr === 'string' && /^VERDICT:\s*PASS/m.test(cr)
    const vfPass = !bad(vf) && /^#?\s*PASS\b/m.test(vf)
    if (crPass && vfPass) return { task: t, built: b, verdict: vf, review: (cr.match(/^VERDICT:.*$/m) || [''])[0] }
    const why = [
      !cr ? 'code-reviewer died' : (!crPass ? `code review: ${(cr.match(/^VERDICT:.*$/m) || ['no verdict line'])[0]}` : null),
      !vf ? 'verifier died' : (!vfPass ? `verify: ${vf}` : null),
    ].filter(Boolean).join(' | ')
    return halt(t, 'review', why)
  }) },
)

const passed = results.filter(Boolean)
const halted = tasks.filter((_, i) => !results[i])
if (halted.length) log(`halted: ${halted.join(', ')} — each task directory holds BLOCKED.md or verdict.md; neither means the agent died`)
log(`dispatches — opus ${tally.opus}, sonnet ${tally.sonnet}, haiku ${tally.haiku}`)
return { feature: f, passed, halted, dispatches: tally }
```

## Never

- Merge. Deploy. Push without `push: confirmed` in config.md.
- Edit the rulings files, or `.claude/pipeline/` outside `features/`.
- Skip a stage or do its work in the room.
