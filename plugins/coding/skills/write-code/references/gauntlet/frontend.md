# Gauntlet — TypeScript / Svelte / Frontend

Read `gauntlet/standards.md` first for the contract. Every tier-1 gate below runs on every frontend task.

## Tier 1

Run from the package root, in this order.

| # | Gate | Command | Threshold |
|---|------|---------|-----------|
| 1 | Typecheck | `npx tsc --noEmit` | exit 0 |
| 2 | Svelte check | `npx svelte-check --threshold error` | 0 errors |
| 3 | Lint | `npx eslint .` *or* `npx biome check .` | exit 0 |
| 4 | Unit tests | `npx vitest run` | exit 0 |
| 5 | Coverage | `npx vitest run --coverage` | see targets below |
| 6 | Build | `npm run build` | exit 0 |
| 7 | E2E | `npx playwright test` | exit 0, if the project has specs |
| 8 | Acceptance | `npx bddgen && npx playwright test` | exit 0, 0 undefined steps |

Gate 8 applies whenever the change has observable behavior, and its feature files are written at step 1 before implementation. `playwright-bdd` reuses the Playwright harness from gate 7 rather than standing up a second runner. See `gauntlet/bdd.md`.

### Coverage targets

**Defaults, adjustable by the user, not by a task in progress:**

- **90%+** pure logic — stores, utils, validators, formatters, derived-state helpers
- **80%+** components carrying behavior — forms, stateful widgets, anything with `$effect` or event handling
- **70%+** glue — loaders, adapters, API clients

Excluded: route shells with no logic, generated types, `*.config.*`, static content components.

Report per-directory percentages against target, not one repo-wide number.

### Notes on specific gates

**`tsc --noEmit`** runs even when the build tool does its own transpiling. Vite and esbuild strip types without checking them — the build passing is not evidence the types are sound.

**`svelte-check --threshold error`** catches what `tsc` cannot: template-level type errors, unused props, a11y violations, and Svelte 5 rune misuse. If the project is Svelte and this is not installed, that is a finding to report.

**Lint** — use whichever the project has configured. If neither `eslint` nor `biome` is configured, report it; the pitfalls in `frontend/svelte.md` (rune reactivity traps, `$effect` misuse) are exactly what a configured linter catches.

**E2E** — if the project has no Playwright specs, say so rather than passing the gate silently. A UI change with no e2e coverage and no e2e suite is a gap worth naming once.

## Tier 2

Needs installation and a committed config. Run when the change touches validation, money math, permission logic, or state machines.

| Gate | Command | Threshold |
|------|---------|-----------|
| Mutation | `npx stryker run` | mutation score ≥ 70% |

[Stryker](https://stryker-mutator.io/) mutates the source and checks whether tests catch it. This is the gate that catches tests which render a component and assert nothing meaningful — the frontend failure mode coverage numbers are blindest to. A suite at 85% coverage and 30% mutation score is testing that the code runs, not that it is correct.

Install: `npm i -D @stryker-mutator/core @stryker-mutator/vitest-runner`. If not installed, report the gate as not run.

## What a passing gauntlet does not prove

Visual correctness. None of these gates look at the rendered page. A screenshot or a real browser check is still required for anything the user sees — the gauntlet proves the code is sound, not that the UI is right.
