# Rework: the pipeline reads the story

Ruled by Claire, 12 and 13 Sept 2026. Records: `bold-minds/strategy/decisions/2026-09-12-coding-plugin-sdlc.md` (the analysis and work list), `2026-09-12-how-we-work.md` (the agreement). This file is the implementation plan: per item, the files, the change, done-when. Evidence lines are from the 12 Sept audits of this plugin at b4e3a59.

Target shape, as ruled 13 Sept afternoon (§"The stops" below): `pm` drives every stop; `story`, `trd`, `pipeline`, `pr`, `qa` are the skills it runs, each typed by its input file. Stops: Requirements, Story, Design, Tasks, Building, Code Review, Test, Launched. The owner reads five times — the story, the TRD, the coverage table, the PR, the card — each templated, checked, capped. §A below landed 13 Sept morning; §C is the work; §B is the superseded 12 Sept list.

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

## Ruled 13 Sept, 12:17–13:51 — replaces §B

The B list below was written on a budget argument Claire was never asked to rule on. Her rulings this afternoon, each reopening one of its lines:

1. **The feature-level stages are not deleted; they move before approval.** Seven lenses and the pre-mortem review the design before the owner reads it, where a finding costs one edit. After approval the story is the whitelist and a finding can change nothing. `state` is deleted (redtest already proves every scenario red or green). `design`, `designreview` and `planner` stay per task: the story does not replace what they do.
2. **The story splits in two.** The **story** — Shows, Journey, Scenarios, Changelog — is the owner's words and `/feature`'s. The **TRD** — Flow, Solution, Observed, References, plus a Review section — is engineering's. New stop **Design** between Story and Tasks. "Making the story file short is no prob with me."
3. **Every file the owner reads has a template, a checker that fails on shape, a length cap, plain words**, and the skill that writes it runs the checker before showing it. Five reads: story, TRD, coverage table, PR, card. "Letting you come up with how to present the information to review is a nightmare."
4. **Skills are typed by their input files, never by which skill ran first.** Project specifics live in `config.md` only. Any project, feature, idea or code.
5. **`survey` is optional, keyed by requirement id, and reads main + the attic** — never the branches, worktrees or archive again. Those were read once on 13 Sept into `strategy/initiatives/stenzil/attic/{include,defer,delete}/` (81 rows; nothing deleted, moved or tagged). Branch code enters main only through a story's task.
6. **`qa` runs twice**: at **Test** after the merge deploys, at **Launched** against prod.
7. **`pm` drives.** It reads the release file, runs everything that is not the owner's, puts one read in front of them at a time, writes the board. `/software` and `/feature` stay as rooms.

### The stops

| Stop | Input (type) | Skill | Output | Owner's read |
|---|---|---|---|---|
| Requirements | the owner's words | — | `requirements.md`, one id per line | — |
| Story | requirements + a name or idea | `story` | `stories/<nn>-<name>.md` | the story |
| Design | a story (+ survey if present) | `trd` | `stories/<nn>-<name>.trd.md` | the TRD, Review last |
| Tasks | story + TRD | `breakdown` (inside `pipeline`) | `tasks/*/criteria.md`, `coverage.md` | the coverage table |
| Building | story + TRD + tasks + config | `pipeline` | feature branch, `verdict.md` | — |
| Code Review | feature branch + verdicts | `pr` | merged PR | the PR, a skim |
| Test | story + test address | `qa` | verdict | — |
| Launched | story + prod address | `qa` | Changelog line, card | the card |

Standalone, optional: `survey` (requirements + main + attic → one row per id); `board` (release file → artifact).

## C. The work, in order

Each item one commit on `rework/story-pipeline`, its done-when checked before the next.

**Landed 13 Sept:** C1 49026c6 · C2 0a1ebe17 (Stenzil) · C3 0c14aff · C5 5cf33f1 · C10 5896ee0 · C6 988ded2 · C7 7cafd26 · C8 afcbae3 · C4 93fa2cc · C9 39bc1f8 · C11+C13 30bbc9b · C12 bcd43f8. Rulings taken along the way, each its own commit: no Review section on the TRD (0869f6a); the TRD's group-and-bullets shape (36a9a13); ADRs written at Design (6ccc8b4), checked (e10e973), dated the day written with Options by platform, Pro/Con, no reopens (535d353, 934cb7f, 8f86d82). Not yet proven live: C8's merge, C9's PASS, C11's opening — each needs the first real run.

### C1. Five reads, five templates, one checker

Files: `skills/feature/{template,story,check.sh,examples.md}` → move the template and checker to `shared/hil/`: `shared/hil/templates/{story,trd,coverage,pr,card}.md`, `shared/hil/check.sh <type> <file> [--approved]`, `shared/hil/README.md` (the rule in ruling 3, and the cap per type). `story.md` (the rules) stays in `skills/feature/`, loses the four technical sections, gains "the TRD" pointer. `check.sh` gains: `trd` (five headings in order; Review non-empty after review; every References item names an ADR or "pending"; no vendor outside Observed/References), `coverage` (one row per scenario number on the story, plus Journey; a task named on every row), `pr` (tests block at top, verdict block, nothing else above the diff), `card` (two dated sentences, ≤ 40 words). Repo root via `git rev-parse --show-toplevel` from the file's directory (was B13). Caps: story ≤ 60 lines, TRD ≤ 80, coverage ≤ 20 rows, PR body ≤ 40 lines, card 2 sentences.

Done when: `check.sh <type>` fails on a deliberately broken sample of each type and passes on `examples.md`'s two stories split into story + TRD; run from inside a linked worktree it finds `.claude/`.

### C2. Split stories 01–03 (Stenzil, on main)

Files: `docs/product/stories/0{1,2,3}-*.md` → each loses Flow, Solution, Observed, References into `0N-<name>.trd.md`, verbatim, with an empty Review section; `docs/product/v1.md` unchanged.

Done when: `check.sh story` and `check.sh trd` pass on all six; `git diff` shows only moved lines.

### C3. `trd`: the design and its review

Files: new `skills/trd/SKILL.md`; `agents/featureplan.md` → `agents/trd.md` (writes the TRD from story + code on main + survey if present; on a second pass resolves findings into the Review section: TRD line added / scenario proposed for the story / dismissed, one line each); `agents/lens.md`, `agents/premortem.md`, `shared/pipeline/lenses/*.md`, `templates/{lens,premortem}.md` re-pointed at the TRD (they read a TRD, never a plan); `templates/featureplan.md` deleted. Input typed: a story → write, review, resolve, check, show; an existing TRD → review, resolve, check, show. A proposed scenario never enters the story here; it is listed for the owner.

Done when: `trd` on story 01's TRD (from C2) writes a Review section with one line per finding, `check.sh trd` passes, and no file outside the TRD changed.

### C4. `survey`

Files: new `skills/survey/SKILL.md`, `agents/survey.md` (from `~/.claude/agents/requirement-assessor.md`, brought into the plugin, plus the attic column). Input: requirements file, repo root, attic path (optional). Output: `docs/product/survey.md`, one row per id: on main TRUE/FALSE + evidence | attic files, one line each | harvest into story N or "no story yet". Reads `attic/include` and `attic/defer`; never a branch.

Done when: run on Stenzil gives one row per id in `requirements.md`, every TRUE with a file:line or command, and the attic column names files that exist.

### C5. Cut the run to the stops

Files: `skills/pipeline/SKILL.md` (delete the Plan, Lenses, Pre-mortem phases and the `state` stage; args gain `trd`, optional `survey`; breakdown reads story + TRD + survey; redtest takes over state's TRUE/FALSE — a TRUE scenario's test is proven by breaking; verifier holds the diff to the TRD's Solution/Observed/References; featureverify walks the story's Journey and holds files to the TRD's Solution); `agents/{breakdown,redtest,verifier,featureverify,designreview,planner,builder}.md` (story sections → TRD sections where technical); `agents/state.md`, `templates/state.md` deleted; `shared/pipeline/README.md` steps table.

Done when: the script's phases are Break down → Tasks (design → design review → red tests → plan → build → review) → Merge → Feature; `ls agents` lists thirteen (breakdown, builder, cleaner, code-reviewer, designreview, featureverify, lens, merger, planner, premortem, redtest, trd, verifier — twelve after C6); the script body passes `node --check`.

### C6. One reviewer, one lens list
As B6: the verifier reads `fix-code/references/lenses.md`; `code-reviewer` is dispatched only by `fix-code`; one review agent per task in the script. Done when: the script dispatches one review agent per task.

### C7. One test doctrine, one gate
As B7. Done when: `grep -n 'coupled to structure\|90/80/70\|90%' skills/write-code/references/gauntlet/*.md` returns nothing, and the builder dispatch names the standards files.

### C8. `pr`: open, merge on green, prove live

Files: new `skills/pr/SKILL.md`; the script's Feature phase returns the branch and stops. `pr` input: a feature branch + its `verdict.md` + the story. Opens the PR from `shared/hil/templates/pr.md` (tests in the owner's words at top, verdict, diff), `check.sh pr`; waits for CI; on green `gh pr merge --merge` (ruled 13 Sept 10:54); runs config `live:`; returns the merge commit and the live result. `software.md:214–219`'s owner gate run goes.

Done when: a run ends merged with the merge commit and the live check's result in its report.

### C9. `qa`

Files: new `skills/qa/SKILL.md`, `agents/qa.md`. Input: a story + an address (from config: `test_address:`, `prod_address:` — two new keys). Fresh context; reads no test file, no diff; walks the Journey then every scenario as a black box (texting ones through a test phone, web ones through HTTP); writes PASS with the scenario list, or the failing scenario. At Launched also writes the story's Changelog "launched <date>" line and the card from `templates/card.md`, `check.sh card`. `/feature --qa` calls it; `pm` calls it at Test and Launched.

Done when: on a launched story returns PASS with the scenario list; on a broken one names the scenario; at Launched the card passes its checker.

### C10. `board`

Files: new `shared/board/render.sh` (or `skills/board/SKILL.md`), `docs/product/<release>.md` gains one line per story: `<nn> <stop> <state> <date> — <two sentences>`; renderer republishes the artifact (existing design) to the product's artifact URL. Written by whichever skill moves a stop.

Done when: republishing is one command, and no room draws the board by hand.

### C11. `pm`

Files: new `commands/pm.md` (a room: reads `.claude/pm.local.md` for `kb_path`; reads `docs/product/<release>.md`, config, the attic path). Opening: ship date, days left, the one thing waiting on the owner, what is running. Then per story in release order: the stop it is at, the next action, whose it is; runs every action that is not the owner's, in order (`story`, `trd`, `pipeline`, `pr`, `qa`); puts exactly one read in front of the owner and waits; on their word advances the stop, writes the board line, republishes. Never two reads at once; never a question without a default.

Done when: `/pm` on Stenzil opens with the date and story 01's next action, runs it, and stops at the next owner read with the checked file in front of them.

### C12. `/software` and `/feature` slimmed

Files: `commands/software.md` — the chain (lines ~92–265) goes; resume mechanics to `shared/pipeline/README.md`; onboarding reads `docs/product/<release>.md` and `docs/adr/` instead of kb `builds/<project>/{scope,decisions}.md`; `debt.md` beside the ADRs. `skills/feature/SKILL.md` — §1 only; `--qa` delegates to `qa`.

Done when: `software.md` under 150 lines and names no `answerStep`; `feature/SKILL.md` names no agent.

### C13. `config.md` keys

Files: `shared/pipeline/README.md` config block; Stenzil `.claude/pipeline/config.md`. Add `test_address:`, `prod_address:`, `attic:` (optional), `board:` (artifact URL). Done when: `pm` on Stenzil reads all of them without asking.

## Order and measurement

C1 → C2 → C5 → C3 → C4 → C6 → C7 → C8 → C9 → C10 → C11 → C12 → C13. Then `/pm` runs story 01 end to end; wall time and dispatch count go in `strategy/initiatives/stenzil/page-measurements.md`. No baseline run on the old shape: a measurement earns a run only when its number decides something (Claire, 13 Sept 11:42).

## B. Superseded 13 Sept — kept for the record

Written 12 Sept on the budget argument; each line below is reopened by one of the rulings above. Headings demoted; nothing else changed.

#### B5. Delete the restating stages
Files: `agents/{featureplan,lens,premortem,designreview,state,planner}.md`, `shared/pipeline/lenses/*`, `templates/{featureplan,lens,premortem,state,plan,rounds}.md`, and in the pipeline script the Plan (195–200), Lenses (202–211), Pre-mortem (213–218), state (342–344), design (350–357), designreview (363–382), plan (386–397) stages and the rounds evaluator (501–509). Keep: breakdown, redtest, builder, verifier, code-reviewer, merger, featureverify, cleaner. The builder's "files to touch" comes from the task's criteria.md instead of plan.md; the verifier's touched-files check reads the same.
Done when: the script's phases are breakdown → confirm → per task (redtest → build → review) → merge → feature → push, and `ls agents` lists eight.

#### B6. One reviewer, one lens list
Files: `skills/fix-code/references/lenses.md` (nine), `shared/pipeline/lenses/` (seven, deleted in B5), `agents/code-reviewer.md`, `agents/verifier.md`.
Change: the verifier reads `fix-code/references/lenses.md`; `code-reviewer` is dispatched only by `fix-code`; the review step in the script is the verifier alone. Rework cap stays 2.
Done when: the script dispatches one review agent per task.

#### B7. One test doctrine, one gate
Files: `skills/write-code/references/gauntlet/{bdd,go,frontend,standards}.md`, `agents/builder.md`, `agents/redtest.md`.
Change: `bdd.md:60-66` ("Unit tests many, fast, coupled to structure") and the 90/80/70 tiers in `go.md:25-27`, `frontend.md:26-28` are replaced by the 11 Sept rule (few, black box through the smallest public surface, one scenario each, table-driven, 80%+, fewest tests). The builder dispatch reads `craft/standards.md`, the domain `standards.md`, and `gauntlet/bdd.md`. The gate is the repo's gate command from config.md; the gauntlet tables become the description of what a repo's gate should hold, not a second gate.
Done when: `grep -n 'coupled to structure\|90/80/70\|90%' skills/write-code/references/gauntlet/*.md` returns nothing, and the builder dispatch names the standards files.

#### B8. The PR
Files: the script's feature phase (603–628), `agents/featureverify.md`.
Change: after push, open the PR with `gh pr create`: title = the story's title; body = the tests named in the owner's words (from the feature files) at the top, then `verdict.md`. The owner's third read.
Done when: a passing run ends with a PR URL in its result.

#### B9. `/feature --qa`
Files: new `agents/qa.md`; `skills/feature/SKILL.md` §"Two modes".
Change: a fresh-context agent that reads only the story and the production address, runs the Journey then every scenario as a black box (the texting ones through a test phone, the web ones through HTTP), writes `docs/product/stories/<nn>-<name>.md` Changelog "launched <date>" or the failing scenario, and the card's two sentences. Reads no test file, no diff.
Done when: `--qa` on a launched story returns PASS with the scenario list; on a broken one names the scenario.

#### B10. The board
Files: new `shared/board/render.sh` (or a small agent), `docs/product/<release>.md` format.
Change: `<release>.md` gains one line per story: `<nn> <stop> <state> <date> — <two sentences>`; a renderer turns it into the artifact HTML (the existing design) and republishes to the product's artifact URL. `/feature` writes the line at Story and Launched; `/software` at Tasks, Building, Code Review.
Done when: republishing is a command, and no room draws the board by hand.

#### B11. Who merges: `/software` (ruled 13 Sept 10:54, "you will be merging")
Files: `commands/software.md:214-219` and the feature phase of the script.
Change: after the PR opens and its CI is green, `/software` merges it (`gh pr merge --merge`) and runs the config's `live:` check; the owner's PR read is a skim, not a gate. The absolute-mode gate run that `software.md:214` gave the owner becomes the PR's CI. A red there is the backlog's and the merge waits for the story that owns it.
Done when: a passing run ends merged, with the merge commit and the live check's result in its report.

#### B12. `/software` slimmed
Files: `commands/software.md` lines 100–245 (resume mechanics) → `shared/pipeline/README.md`; onboarding (lines 28–37) reads `docs/product/<release>.md` and `docs/adr/` instead of kb `builds/<project>/{scope,decisions}.md`; `debt.md` moves beside the ADRs.
Done when: `software.md` is under 150 lines and names no `answerStep`.

#### B13. `check.sh`
Files: `skills/feature/check.sh:72`.
Change: find the repo root with `git rev-parse --show-toplevel` from the story's directory, not by walking for a `.git` directory.
Done when: the checker finds `.claude/` from inside a linked worktree.

#### Order and measurement (superseded)

A1–A4, then run story 01 and record wall time and dispatch count in `strategy/initiatives/stenzil/page-measurements.md`. Then B5–B13 in order, re-measuring on story 02. No hours; report as branches landed.
