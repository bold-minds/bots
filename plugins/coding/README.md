# coding

The engineering room and the tools it runs. `/software` (from the `advice` plugin) decides release scope, architecture, and the ship date, and owns the gates that decide whether a change is done. This plugin is what builds against those gates, checks the work through nine expert lenses, and fixes what it finds.

## Skills

### write-code

Orchestrates the full code-writing workflow: captures intent, detects the domain (Go, frontend, DevOps, SRE), loads the matching standards, writes the code, and runs every applicable gate in the gauntlet — build, lint, typecheck, tests, coverage, BDD acceptance scenarios, and (for parsers, decoders, money math, permission checks, state machines) mutation testing and fuzzing. A failing gate gets fixed and re-run, never loosened. The gauntlet's tiers and thresholds are defaults the user owns, overridable per project in `builds/<project>/scope.md`.

### fix-code

Reviews and fixes existing code through nine lenses — Security, Performance, Staff Engineer, Architect, Product Owner, SRE, QA, Legal, UX — auto-selected per package from its imports and path signals. Batches files by package, produces a severity-phased fix plan, and executes fixes in parallel git worktrees with a self-review loop before merging back. Three modes: full pipeline, review-only, plan-only.

## Agent

### code-reviewer

Per-package multi-lens reviewer, dispatched by `fix-code` to review a batch of files through the lenses `fix-code` selected. Not invoked directly — there's nothing here for a user to call by hand.

## Depends on `foundations`

`write-code` invokes `capture-intent` before writing any code and `check-evidence` before claiming the work done. If `foundations` isn't installed, it does that work inline instead of skipping it.

```
claude plugin install foundations@bots
```

## Install

```
claude plugin install coding@bots
```
