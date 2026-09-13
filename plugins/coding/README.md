# coding

The engineering room and the tools it runs. `/software` is this plugin's room: it decides release scope, architecture, and the ship date, then builds against the gates that decide whether a change is done, checks the work through nine expert lenses, and fixes what it finds. Surround the agent with constraints instead of reading its diffs.

## Command

### /software

Owns the distance between a decision to build and a thing that is live: technical direction, release scope, the ship date, the implementation, and the gates that decide whether it is done. Its territory is `{kb_path}/builds/` and the working tree. Product judgment — whether to build at all, who pays, at what price — routes out to `/business` in the `advice` plugin.

The only command in this plugin. Everything below is model-triggered from its own description: there is no wrapper command for any skill, and nothing else here for a user to type.

## Skills

### feature

One feature's story. The one-page spec that is also the tests, the PR and the board card: Shows, Journey, Scenarios, Changelog, in the owner's words; every scenario names a requirement id; every story end to end, sized by taking business out; a Changelog for anything after approval. The technical half — Flow, Solution, Observed, References, and the review the seven lenses and the pre-mortem write — is the TRD beside it, engineering's, written after the story is approved. Every file the owner reads (story, TRD, coverage table, PR, card) has a template, a checker and a cap in `shared/hil/`; `shared/hil/check.sh <type> <file>` holds the shape mechanically, and the owner reads the story before anything is designed. Then `pipeline` runs unattended on story + TRD.

### write-code

Orchestrates the full code-writing workflow: captures intent, detects the domain (Go, frontend, DevOps, SRE), loads the matching standards, writes the code, and runs every applicable gate in the gauntlet — build, lint, typecheck, tests, coverage, BDD acceptance scenarios, and (for parsers, decoders, money math, permission checks, state machines) mutation testing and fuzzing. A failing gate gets fixed and re-run, never loosened. The gauntlet's tiers and thresholds are defaults the user owns, overridable per project in `builds/<project>/scope.md`.

### fix-code

Reviews and fixes existing code through nine lenses — Security, Performance, Staff Engineer, Architect, Product Owner, SRE, QA, Legal, UX — auto-selected per package from its imports and path signals. Batches files by package, produces a severity-phased fix plan, and executes fixes in parallel git worktrees with a self-review loop before merging back. Three modes: full pipeline, review-only, plan-only.

## Agent

### code-reviewer

Per-package multi-lens reviewer, dispatched by `fix-code` to review a batch of files through the lenses `fix-code` selected. Not invoked directly — there's nothing here for a user to call by hand.

## Depends on `foundations`

Both skills are invoked at two levels. `/software` opens its chain with `capture-intent` and closes it with `check-evidence`, before any claim that something is finished. `write-code` invokes both again around its own work — intent before the first line, evidence after the gate table. If `foundations` isn't installed, each does that work inline instead of skipping it.

```
claude plugin install foundations@bots
```

## Install

```
claude plugin install coding@bots
```
