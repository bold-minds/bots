# Rework: the pipeline reads the story

Ruled by Claire, 12 and 13 Sept 2026. Records: `bold-minds/strategy/decisions/2026-09-12-coding-plugin-sdlc.md` (the analysis and work list), `2026-09-12-how-we-work.md` (the agreement). This file is the implementation plan: per item, the files, the change, done-when. Evidence lines are from the 12 Sept audits of this plugin at b4e3a59.

Target shape: `/feature <name>` writes the story and owns Story and Launched (`--qa`); `/software <name>` runs Tasks, Building and Code Review. Stops on the board: Requirements, Story, Tasks, Building, Code Review, Launched. The owner reads four times: the story, the task list with its coverage table, the PR, the card.

## A. Minimum for a measured run of story 01

### A1. Move the pipeline out of `/feature` §2 into `/software`

Files: `skills/feature/SKILL.md` (lines 20–end: the `## 2. The run` prose and the JS block), `commands/software.md` (§"The chain", step 2), a new `skills/pipeline/SKILL.md`.

Change: cut §2 whole from `feature/SKILL.md` into `skills/pipeline/SKILL.md` with `allowed-tools: Workflow` and the same arg contract; `feature/SKILL.md` keeps the persona, the ownership line, the two modes and §1. `software.md` step 2 says "fire `pipeline`", not `/feature`. Every `/feature` mention in `software.md` lines 94–265 that means the run becomes `pipeline`; the ones that mean the story stay.

Done when: `grep -c 'Workflow' skills/feature/SKILL.md` is 0; `skills/pipeline/SKILL.md` carries the script unchanged; `software.md` fires `pipeline`.

### A2. Point the run at the story

The story is `docs/product/stories/<nn>-<name>.md`; its sections are Shows, Journey, Scenarios (numbered, `[<requirement id>]` first line), Flow, Solution, Observed, References, Changelog.

| File:line (audit) | Assumes today | Change |
|---|---|---|
| `skills/pipeline/SKILL.md` `SPEC = <root>/spec/<f>.md` (was feature SKILL:104) | a spec at that path | `SPEC` = the story's path, passed in `args.story` by `/software` |
| `SKILL.md:223` breakdown dispatch; `agents/breakdown.md:47-55`; `templates/criteria.md:8-12`; `templates/coverage.md:3,7-8` | rules are `S<slice>.<n>` and `X<n>`; coverage keyed by them | rules are the story's numbered scenarios; `Rules:` line names scenario numbers; `coverage.md` one row per scenario; `From:` is the scenario number |
| `templates/criteria.md` Success line; `SKILL.md:223`; `software.md:118-122` | each task has a Success line the owner reads | keep; the owner's second read is the task list with the coverage table, never Success lines alone |
| `agents/redtest.md:34-35`; `templates/tests.md:3-5` | tests written from criteria.md's re-authored GWT | the story's scenario text is the scenario file: copy the Given/When/Then verbatim into the feature file; a task's criteria.md lists which scenario numbers it carries and adds nothing |
| `agents/premortem.md:34-35`; `templates/criteria.md:34-41` "Failure that matters" | pre-mortem cases become criteria | deleted with the pre-mortem (B5); a case not on the story is not built |
| `templates/criteria.md:52-55`, `templates/design.md:29-32`, `templates/premortem.md:21-23` | exclusion lists | remove the sections; the story is the whitelist |
| `templates/featureplan.md:20-23`; `templates/criteria.md:13-15` `Journey: yes`; `agents/featureverify.md:24-26`; `SKILL.md:615` | the journey is derived by featureplan and carried by one task | featureverify runs the story's Journey section directly; no task carries `Journey: yes` |
| `agents/featureverify.md:49-55`; `templates/featureplan.md:8-18` | "where it lives" = repo path from plan.md Touches | featureverify checks touched files against the story's Solution lines (packages, endpoints, envs) instead |
| `agents/planner.md:42-47`; `shared/pipeline/triage.md:22,42-46` | a vendor is always the owner's flag | a vendor named in References is ruled; the planner never flags it |
| `agents/verifier.md` (no line: nothing reads them) | — | the verifier holds the diff to Solution (only listed packages/endpoints/envs added), Observed (only listed log lines, events, alerts written), References (no vendor outside it) |
| `software.md:183` "note in the spec's Open questions" | a section the story lacks | a dated Changelog line on the story |
| `agents/cleaner.md:38-41`; `README.md:231` | moves `dir/spec.md` to `<root>/spec/<f>.md` | deletes the copy; the story already lives in `docs/product/stories/` |
| `shared/pipeline/templates/spec.md` | the old spec shape | delete; `software.md:110-111` already calls it unused |
| `shared/pipeline/README.md:24,231,239-244` | `spec.md` is the owner-read file | the story is; list it |

Done when: a run on story 01 produces `tasks/coverage.md` with one row per scenario (five rows: Journey + four scenarios, or however the breakdown splits them) and no `S1.` id anywhere in the feature directory; `grep -rn 'S<slice>\|Success line alone\|spec.md' shared/pipeline agents` returns only the README's history.

### A3. Keep the breakdown, cut to the story

Files: `agents/breakdown.md`, `SKILL.md:223` dispatch.

Change: inputs are the story and the code; no plan.md, no lens files, no premortem.md (their dispatches go in B5). Output unchanged: `tasks/<t>/criteria.md` (which scenarios, Success line, After:), `tasks/<t>/design.md`, `tasks/coverage.md`. The confirm stop stays (`confirmTasks` default true).

Done when: the breakdown dispatch string names only the story, the requirements file, the decisions file and the code as inputs.

### A4. Stenzil: `.claude/pipeline/config.md` on `docs/features`

Change: write it in `wt-docs-features` with `requirements: docs/product/requirements.md`, `decisions: docs/adr` (once ADRs exist), `gate:` the rules plugin's gate command, `test:` per module, `entry:` the two mains, `live:` the story 01 Journey check once it exists, `push: feature`.

Done when: `/software` can fire the run on story 01 from that worktree.

## B. Then, in order

### B5. Delete the restating stages
Files: `agents/{featureplan,lens,premortem,designreview,state,planner}.md`, `shared/pipeline/lenses/*`, `templates/{featureplan,lens,premortem,state,plan,rounds}.md`, and in the pipeline script the Plan (195–200), Lenses (202–211), Pre-mortem (213–218), state (342–344), design (350–357), designreview (363–382), plan (386–397) stages and the rounds evaluator (501–509). Keep: breakdown, redtest, builder, verifier, code-reviewer, merger, featureverify, cleaner. The builder's "files to touch" comes from the task's criteria.md instead of plan.md; the verifier's touched-files check reads the same.
Done when: the script's phases are breakdown → confirm → per task (redtest → build → review) → merge → feature → push, and `ls agents` lists eight.

### B6. One reviewer, one lens list
Files: `skills/fix-code/references/lenses.md` (nine), `shared/pipeline/lenses/` (seven, deleted in B5), `agents/code-reviewer.md`, `agents/verifier.md`.
Change: the verifier reads `fix-code/references/lenses.md`; `code-reviewer` is dispatched only by `fix-code`; the review step in the script is the verifier alone. Rework cap stays 2.
Done when: the script dispatches one review agent per task.

### B7. One test doctrine, one gate
Files: `skills/write-code/references/gauntlet/{bdd,go,frontend,standards}.md`, `agents/builder.md`, `agents/redtest.md`.
Change: `bdd.md:60-66` ("Unit tests many, fast, coupled to structure") and the 90/80/70 tiers in `go.md:25-27`, `frontend.md:26-28` are replaced by the 11 Sept rule (few, black box through the smallest public surface, one scenario each, table-driven, 80%+, fewest tests). The builder dispatch reads `craft/standards.md`, the domain `standards.md`, and `gauntlet/bdd.md`. The gate is the repo's gate command from config.md; the gauntlet tables become the description of what a repo's gate should hold, not a second gate.
Done when: `grep -n 'coupled to structure\|90/80/70\|90%' skills/write-code/references/gauntlet/*.md` returns nothing, and the builder dispatch names the standards files.

### B8. The PR
Files: the script's feature phase (603–628), `agents/featureverify.md`.
Change: after push, open the PR with `gh pr create`: title = the story's title; body = the tests named in the owner's words (from the feature files) at the top, then `verdict.md`. The owner's third read.
Done when: a passing run ends with a PR URL in its result.

### B9. `/feature --qa`
Files: new `agents/qa.md`; `skills/feature/SKILL.md` §"Two modes".
Change: a fresh-context agent that reads only the story and the production address, runs the Journey then every scenario as a black box (the texting ones through a test phone, the web ones through HTTP), writes `docs/product/stories/<nn>-<name>.md` Changelog "launched <date>" or the failing scenario, and the card's two sentences. Reads no test file, no diff.
Done when: `--qa` on a launched story returns PASS with the scenario list; on a broken one names the scenario.

### B10. The board
Files: new `shared/board/render.sh` (or a small agent), `docs/product/<release>.md` format.
Change: `<release>.md` gains one line per story: `<nn> <stop> <state> <date> — <two sentences>`; a renderer turns it into the artifact HTML (the existing design) and republishes to the product's artifact URL. `/feature` writes the line at Story and Launched; `/software` at Tasks, Building, Code Review.
Done when: republishing is a command, and no room draws the board by hand.

### B11. Who merges (Claire's ruling)
`software.md:214-219` says the owner runs the absolute gate and merges. Claire, 8 Sept: "I don't plan to do the merges." Options: the owner skims the PR and clicks merge (their third read is the merge); or the pipeline merges when the PR's CI is green and the owner has commented "go". Until ruled, `software.md` stands.

### B12. `/software` slimmed
Files: `commands/software.md` lines 100–245 (resume mechanics) → `shared/pipeline/README.md`; onboarding (lines 28–37) reads `docs/product/<release>.md` and `docs/adr/` instead of kb `builds/<project>/{scope,decisions}.md`; `debt.md` moves beside the ADRs.
Done when: `software.md` is under 150 lines and names no `answerStep`.

### B13. `check.sh`
Files: `skills/feature/check.sh:72`.
Change: find the repo root with `git rev-parse --show-toplevel` from the story's directory, not by walking for a `.git` directory.
Done when: the checker finds `.claude/` from inside a linked worktree.

## Order and measurement

A1–A4, then run story 01 and record wall time and dispatch count in `strategy/initiatives/stenzil/page-measurements.md`. Then B5–B13 in order, re-measuring on story 02. No hours; report as branches landed.
