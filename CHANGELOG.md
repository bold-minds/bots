# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/).

## [2.1.0] - 2026-07-25

### Added

- **Foundations plugin (1.0.0)** — `capture-intent` and `check-evidence`, the two bookends of any deliverable, domain-agnostic and model-triggered
- **Coding plugin (1.0.0)** — the engineering room `/software`, plus `write-code`, `fix-code`, and the `code-reviewer` agent. Builds, gates, and proves; does not hand implementation elsewhere. Depends on `foundations` (documented, not declared in `plugin.json`)

### Changed

- **Five skills renamed** for clarity — `calibrate` → `calibrate-profile`, `aim` → `set-goals`, `reflect` → `review-week`, `confront` → `hold-commitments`, `drill` → `demand-numbers`
- **Ship doctrine consolidated into `/software`** — release scope, architecture, the ship date, and the implementation itself now live in one room in the `coding` plugin, replacing the version of `/software` that lived in `advice`
- **Marketplace description** — no longer "advisor sessions, one per focus"; now names three plugins across two realms: advice, coding, and the foundations that bracket both

### Removed

- **`/software` from the `advice` plugin** — advice now holds four focuses: `/life`, `/money`, `/story`, `/business`. Release scope and implementation moved to the `coding` plugin's `/software`

## [2.0.0] - 2026-07-25

### Added

- **Advice plugin** — five focuses on one shared engine: `/life`, `/money`, `/story`, `/software`, `/business`
- **`shared/focus-template.md`** — the engine every focus inherits: configuration, data ritual, voice floor, shared refusals, boundaries, saving, closing
- **Configurable persona** — each focus answers to a name set in `.claude/<focus>.local.md`
- **`calibrate` skill** — first-run setup for every focus, with the disclaimer and safety gate before anything else. `/life` gets the full Enneagram pass with six calibration dials; the other four are short
- **`aim` skill** — 7-step goal creation and revision for growth and constraint goals, with external structure, binary accountability, and WOOP
- **`reflect` skill** — weekly structured reviews with commitment scorecards, pattern analysis, and a harsh truth; includes a business branch
- **`confront` skill** — commitment accountability calibrated to the user's intensity setting
- **`drill` skill** — turns vague business claims into figures, computed against a metrics reference built for the user's actual business during onboarding
- **Enneagram seed patterns** — 5-7 rationalization patterns per type, validated through observation over time
- **Safety gate** — disclaimer and crisis redirect run before any setup, on every focus

### Removed

- **Ladder plugin** — superseded by advice; `/climb` became `/life`
- **Biz plugin** — superseded by advice; `/earn` became `/business`, `metrics` became `drill`

## [1.0.0] - 2026-04-05

### Added

- **Ladder plugin** — personal growth companion with the `/climb` command: Enneagram-based onboarding (quick or full assessment, with wings), calibration dimensions, 7-step goal creation with WOOP and binary accountability, weekly reflections, accountability and coach skills, seeded rationalization patterns, safety disclaimer with 988 redirect
