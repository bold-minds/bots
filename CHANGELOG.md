# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/).

Each plugin carries its own version in its `plugin.json`. This file records
marketplace releases; the heading is the marketplace version.

## [1.0.0] - 2026-07-26

First release. Three plugins, each at `1.0.0`.

### advice — long-running advisor sessions

Four focuses on one shared engine: `/life`, `/money`, `/story`, `/business`. Each
is a persona, a bookshelf, and a knowledge base you supply. Bookshelves ship
empty; the canon is yours. Advises and prepares; never acts on your behalf.

- **`shared/focus-template.md`** — the engine every focus inherits: configuration,
  data ritual, voice floor, shared refusals, boundaries, aggressive saving, closing
- **Configurable persona** — each focus answers to a name set in `.claude/<focus>.local.md`
- **`calibrate-profile`** — first-run setup for every focus, with the disclaimer and
  safety gate before anything else. `/life` gets the full Enneagram pass and six
  calibration dials; the other three are short
- **`set-goals`** — 7-step creation and revision for growth goals and constraint
  goals, producing externally-bound commitments with binary accountability and WOOP
- **`review-week`** — structured weekly review with a commitment scorecard, pattern
  analysis, and a harsh truth; a business branch writes one portfolio weekly
- **`hold-commitments`** — accountability calibrated to your intensity setting, with
  calendar-independent overwork detection
- **`demand-numbers`** — turns vague business claims into figures against a metrics
  reference researched for your actual business at onboarding
- **Enneagram seed patterns** — 5–7 rationalization patterns per type, all nine covered
- **Safety gate** — disclaimer and crisis redirect run before any setup, on every focus

### coding — the engineering room and the tools it runs

- **`/software`** — release scope, architecture, and the ship date, then builds it,
  gates it, and proves it. Owns `scope.md` as a written contract, `decisions.md` with
  reopens-if conditions, and `debt.md`. Does not hand implementation elsewhere
- **`shared/engine.md`** — a short engine of its own: configuration, date, data
  ritual, aggressive saving, closing
- **`write-code`** — captures intent, writes the acceptance scenarios first, detects
  the domain (Go, frontend, DevOps, SRE), loads the matching standards, and runs the
  gauntlet. Gate thresholds ship as defaults a project can override in its own `scope.md`
- **`fix-code`** — multi-lens review across nine expert lenses auto-selected per
  package, a severity-phased fix plan, execution in isolated worktrees with a
  self-review loop, and durable `.code-review/<run-id>/` artifacts
- **`code-reviewer`** — the per-package reviewer agent `fix-code` dispatches
- Depends on `foundations`, documented rather than declared — `plugin.json` has no
  dependency field. `write-code` does the work inline when `foundations` is absent

### foundations — the two bookends of any deliverable

- **`capture-intent`** — the intent contract before the work: quote the request,
  enumerate every element including the implicit ones, and name for each whether
  fulfillment is mechanical or depends on the model choosing to act
- **`check-evidence`** — adversarial review before any completion claim:
  intent-completion trace, artifact-wiring proof, deferral-language grep, time-decay
  check, severity ranking, and a report shape that requires evidence per field
- Domain-agnostic. Both apply to code, config, documents, strategy, and skill design

### Tooling

- **`scripts/check-wiring.sh`** — lints all three plugins: reference files are named
  by their skill, frontmatter matches directory names, commands read their engine,
  gate files appear in their focus, skill writes stay inside their focus, bookshelf
  paths are keyed by focus, `${CLAUDE_PLUGIN_ROOT}` paths resolve inside the
  referencing plugin, and nothing personal ships
