---
name: fix-code
description: >
  Review and fix code using a multi-lens review pipeline. Analyzes code through 9 expert lenses
  (Security, Performance, Staff Engineer, Architect, Product Owner, SRE, QA, Legal, UX),
  generates a fix plan, and executes fixes in parallel worktrees with self-review.
  Three modes: /fix-code (full pipeline), /fix-code review (stop after REVIEW.md),
  /fix-code plan (stop after PLAN.md). Use when: reviewing code before merge, auditing a
  repo, fixing review findings, or running a full review-plan-fix cycle.
---

# Fix Code — Review, Plan, Execute

Run a multi-lens code review pipeline. By default, runs the full cycle: review → plan → execute. Use modes to stop early.

## Mode Detection

Parse the first argument:
- No argument → **Full pipeline** (review → plan → execute)
- `review` → **Review only** — stop after producing REVIEW.md
- `review branch` → Review mode, branch scope (default)
- `review repo` → Review mode, full repo audit
- `review feature "description"` → Review mode, trace a feature
- `plan` → **Plan only** — expects existing REVIEW.md, stop after producing PLAN.md
- `plan path/to/REVIEW.md` → Plan from specific review

---

## Phase 1: Review

Analyze code through multiple expert review lenses. Dispatches parallel `code-reviewer` agents per package batch and produces a consolidated `REVIEW.md`.

### 1.1 Collect files to review

**Branch scope (default):**
```bash
git diff --name-only main...HEAD
git diff --name-only          # unstaged
git diff --name-only --cached # staged
```
Deduplicate the combined list. Exclude non-code files (images, binaries, lockfiles).

Also capture the full diff for context:
```bash
git diff main...HEAD
git diff          # unstaged
git diff --cached # staged
```

**Repo scope:**
Glob for all code files. Auto-detect language from project files:
- Go: `**/*.go`
- Python: `**/*.py`
- TypeScript: `**/*.ts`, `**/*.tsx`
- Multiple languages: combine patterns

Exclude: `vendor/`, `node_modules/`, `.git/`, generated files.

**Feature scope:**
Launch an Explore agent with the feature description. The agent traces the feature through the codebase — entry points, handlers, data flow, dependencies — and returns the list of files involved.

### 1.2 Load project standards

Read all CLAUDE.md files in the repo (root and any subdirectory CLAUDE.md files). This content is injected into every `code-reviewer` agent prompt so reviews are project-aware.

### 1.3 Group files by package

Cluster files by their parent directory (Go packages, Python modules, TS directories). Each cluster becomes one `code-reviewer` agent invocation.

Rules:
- If a package has >60 files (repo scope), split into sub-batches of ~30 files
- If a package has 1-3 small files, consider merging with a sibling package into one batch
- Test files are grouped with their source package, not separately

### 1.4 Select lenses per package

Read `references/lens-selection.md` for the rules.

**Always-on baseline:** Security, Staff Engineer, SRE

**Contextual:** Read each package's imports and file names to detect signals. Add matching lenses per the selection rules.

**Override:** In `repo` scope, all packages get all 9 lenses. User can force this in other scopes with `--all-lenses`.

### 1.5 Dispatch parallel code-reviewer agents

Read `references/lenses.md` for the lens prompt templates.

For each package batch, launch a `code-reviewer` agent with this prompt structure:

```
You are reviewing the [PACKAGE_NAME] package.

## CLAUDE.md Standards
[INJECTED CLAUDE.md CONTENT]

## File Manifest — Read EVERY file:
[LIST OF FILES]

## Diff Context (branch scope only)
[RELEVANT DIFF SECTIONS]

## Review Lenses — Apply each:

### [LENS_NAME]
[LENS PROMPT TEMPLATE FROM references/lenses.md]

### [LENS_NAME]
[LENS PROMPT TEMPLATE]

...

## Output Format
[FINDING FORMAT FROM code-reviewer agent definition]
```

**Concurrency:** Max 5 agents in parallel. Queue additional batches.

### 1.6 Aggregate findings

Collect all agent outputs. For each finding:
- Parse the `[LENS] [SEVERITY] [FILE:LINE]` format
- Deduplicate findings on the same file:line with the same lens
- Sort by severity (P0 first), then by lens, then by file

### 1.7 Write REVIEW.md

Create the output directory: `.code-review/<run-id>/`

Run ID:
- Branch scope: `<branch-name>-<short-sha>` (sanitize branch name for filesystem)
- Repo scope: `full-repo-<YYYY-MM-DD>`
- Feature scope: `feature-<slugified-description>`

Write `.code-review/<run-id>/REVIEW.md`:

```markdown
# Code Review Report

**Date:** [DATE]
**Scope:** [branch|repo|feature] — [N files across M packages]
**Lenses applied:** [list]

## Executive Summary

| Severity | Count |
|----------|-------|
| P0       | N     |
| P1       | N     |
| P2       | N     |
| P3       | N     |

## P0 Findings

| # | Lens | File:Line | Finding | Recommendation |
|---|------|-----------|---------|----------------|
| 1 | Security | path:42 | ... | ... |

## P1 Findings
...

## P2 Findings
...

## P3 Findings
...
```

**If mode is `review`:** Announce the report location and summary, then stop.

---

## Phase 2: Plan

Generate a prioritized fix plan with parallel work streams from the review.

### 2.1 Find the review

If coming from Phase 1, use the REVIEW.md just written. Otherwise, look for the most recent `.code-review/*/REVIEW.md`. The user can pass an explicit path.

If no REVIEW.md is found: "No review report found. Run `/fix-code review` first."

### 2.2 Parse the report

Read `REVIEW.md`. Extract every finding with: severity, lens, file:line, description, recommendation.

### 2.3 Build the conflict map

Group findings by the files they affect. When multiple findings touch the same file, they must either:
- Be in the same work stream (simplest)
- Be sequenced with explicit merge order (when they're in different severity phases)

### 2.4 Group into work streams

Cluster findings into work streams:
- Findings touching the same file go in the same stream
- Findings with logical dependencies go in the same stream
- Remaining findings are grouped by thematic similarity
- Each stream should target non-overlapping files where possible for worktree isolation

### 2.5 Phase by severity

- **Phase 1:** All work streams containing P0 findings
- **Phase 2:** All work streams containing P1 findings (no P0)
- **Phase 3:** All work streams containing only P2/P3 findings

Within a phase, streams run in parallel. Phases run sequentially.

### 2.6 Generate stream details

For each work stream:
- **Name:** `fix/<descriptive-slug>`
- **Finding IDs:** reference the finding numbers from the report
- **Files to modify:** exact paths with one-line description of what changes
- **Verification:** the command to run to confirm the stream's changes are correct

### 2.7 Write PLAN.md

Write to the same `.code-review/<run-id>/` directory:

```markdown
# Code Plan

**Source:** REVIEW.md ([N] findings: [X] P0, [Y] P1, [Z] P2, [W] P3)
**Streams:** [N] across [M] phases
**Strategy:** Parallel worktree branches per stream, sequential phases

---

## Phase 1 — P0 Fixes ([N] parallel streams)

### WS-1: `fix/stream-name` — Findings: #1, #4, #7

**Files to modify:**
- `path/to/file.ext` — description of change
- `path/to/other.ext` — description of change

**Verification:** `command to verify`

### WS-2: `fix/stream-name` — Findings: #2, #5
...

## Phase 2 — P1 Fixes ([N] parallel streams)
...

## Phase 3 — P2/P3 Fixes ([N] parallel streams)
...

---

## Conflict Map

| File | Streams | Merge Order |
|------|---------|-------------|
| path/to/contested.ext | WS-1, WS-4 | WS-1 first |

## Verification Plan

After each phase:
1. [Project-specific build command]
2. [Project-specific test command]
3. [Project-specific lint command]
```

**If mode is `plan`:** Announce the plan location and summary, then stop.

---

## Phase 3: Execute

Implement the fix plan using parallel worktree agents with self-review.

### 3.1 Find the plan

If coming from Phase 2, use the PLAN.md just written. Otherwise, look for the most recent `.code-review/*/PLAN.md`. The user can pass an explicit path.

If no PLAN.md is found: "No fix plan found. Run `/fix-code plan` first."

### 3.2 Parse the plan

Read `PLAN.md`. Extract: phases, work streams (with branch names, file manifests, specific changes, verification commands), and the conflict map.

### 3.3 Execute phase by phase

For each phase (Phase 1 first, then 2, then 3):

**Launch parallel agents** — one per work stream in the phase. Each agent runs in an isolated worktree (`isolation: "worktree"`).

Each agent receives this prompt:

```
You are implementing fixes for work stream [WS-NAME].

## Changes to make:

[FOR EACH FINDING IN THIS STREAM:]
### Finding #[N]: [DESCRIPTION]
**File:** [PATH]
**Change:** [RECOMMENDATION FROM REVIEW]

## Files in scope:
[FILE MANIFEST]

## Instructions:
1. Read every file in scope
2. Implement each change described above
3. Run the verification command: [VERIFICATION]
4. If verification fails, fix the issue and re-run
5. Report what you changed and verification results
```

**Concurrency:** Max 5 agents per phase. Queue additional streams.

**Conflict map:** If the conflict map says "WS-1 before WS-4", wait for WS-1 to complete before launching WS-4, even within the same phase.

### 3.4 Self-review loop (per stream)

After each agent completes implementation:

1. Run the review phase (1.1-1.6) in `branch` scope on the worktree's changes (diff against main)
2. Focus only on findings in files the agent CHANGED — ignore pre-existing issues
3. If the self-review finds P0 or P1 issues:
   - Send the findings back to the agent for fixing
   - Re-run verification
   - Re-run self-review
4. Max 3 review cycles per stream to prevent infinite loops
5. P2/P3 findings are noted but do not block — they go into RESULTS.md

### 3.5 Write RESULTS.md

Write to the same `.code-review/<run-id>/` directory:

```markdown
# Results

**Plan:** PLAN.md ([N] streams across [M] phases)
**Executed:** [DATE]

## Execution Summary

| Stream | Branch | Status | Self-Review | Cycles |
|--------|--------|--------|-------------|--------|
| WS-1   | worktree-xxx | Pass | Clean | 1 |
| WS-2   | worktree-yyy | Pass | 1 P2 remaining | 2 |
| WS-3   | worktree-zzz | Fail | Build error | 3 (max) |

## Remaining Findings (P2/P3 from self-review)

| Stream | Severity | File:Line | Finding |
|--------|----------|-----------|---------|
| WS-2   | P2       | path:42   | ... |

## Failed Streams (require manual intervention)

### WS-3: `fix/stream-name`
**Branch:** worktree-zzz
**Error:** Build failed after 3 cycles
**Last error output:**
[ERROR DETAILS]
```

### 3.6 Announce completion

Tell the user:
- Results location: `.code-review/<run-id>/RESULTS.md`
- Summary: N streams passed, M failed, K remaining P2/P3 findings
- Worktree branches are available for review and merge
- If any streams failed: "Streams [list] need manual intervention. Check RESULTS.md for details."
