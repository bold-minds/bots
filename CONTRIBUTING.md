# Contributing to Bots

Thanks for your interest in contributing. Here's how to get involved.

## Getting started

1. Fork and clone the repo
2. Install [Claude Code](https://claude.ai/code)
3. Install the plugin locally: `claude plugin marketplace add /path/to/your/clone`, then `claude plugin install advice@bots`
4. Run `/life` to test the onboarding flow

## Repository structure

```
bots/
  .claude-plugin/           # Repo-level plugin discovery
    marketplace.json        # Registry of available plugins
  scripts/
    check-wiring.sh         # Wiring lint — run before a PR
  plugins/
    advice/                 # Five focuses on a shared engine
      .claude-plugin/
        plugin.json         # Plugin metadata
      shared/
        focus-template.md   # The engine every focus inherits
      commands/
        life.md             # Planning, check-ins, accountability
        money.md            # Ledger, plans, documents
        story.md            # True stories, any format
        software.md         # Release scope, architecture, ship date
        business.md         # Portfolio, unit economics, scope
      skills/
        calibrate-profile/  # First-run setup for every focus
          references/       # Enneagram seed patterns for all 9 types
        set-goals/          # Goal creation and revision
          references/       # Goal file format, research foundation
        review-week/        # Weekly structured reviews
          references/       # Reflection file format
        hold-commitments/   # Commitment accountability
        demand-numbers/     # "What's the number?" — reads the user's metrics reference
```

Bookshelves are not in this repo. A focus reads its canon from `{kb_path}/bookshelf/<focus>/`, which the user owns.

## How skills work

Each skill is a markdown file with YAML frontmatter (name + description) and structured instructions. The `description` field controls when the skill triggers. The body contains the steps the model follows.

Reference files under `references/` are loaded by explicit Read instructions in the skill. If you add a reference file, you must add a corresponding Read step — a file that nothing reads is decoration.

## Types of contributions

### Adding to a bookshelf

Bookshelves ship empty and live in the user's knowledge base, not here. Whose thinking belongs in someone's ear is theirs to decide, and a shipped canon produces advice aimed at a stranger.

If you want to contribute reading recommendations, they go in `plugins/advice/README.md` under the per-focus starting points — as suggestions a user can take or ignore, never as files the plugin loads.

### Improving Enneagram seed patterns

The seed patterns at `skills/calibrate-profile/references/enneagram-seed-patterns.md` are hypotheses based on type psychology. If you have Enneagram expertise and see:

- A pattern assigned to the wrong type
- A missing pattern that's core to a type's psychology
- A response approach that would backfire for the stated type

Open an issue or PR with your reasoning.

### Improving calibration defaults

The Enneagram-to-calibration-defaults table in `skills/calibrate-profile/SKILL.md` maps each type to six settings. If a default doesn't fit (e.g., a type's accountability intensity is too high or too low), explain why in your PR.

### Bug fixes and wiring issues

If you find:
- A reference file that nothing reads
- A file path that doesn't resolve
- Inconsistent terminology between skills
- A quality gate that doesn't actually check what it claims

These are high-priority fixes. Please include evidence (grep output, file paths, line numbers).

## Guidelines

- **No proprietary frameworks.** All coach reference content must be from published, publicly available sources with author attribution.
- **No clinical language.** This is a personal growth tool, not therapy. Avoid clinical diagnoses, pathological framing, or language that implies the user has a disorder.
- **Test the full flow.** If you change onboarding, run through it as a new user. If you change a skill, invoke it and verify it reads the files it claims to read.
- **Run `scripts/check-wiring.sh`** before opening a PR. It catches dead reference files, frontmatter/filename mismatches, and missing template reads.
- **Keep skills self-contained.** Every skill must resolve `kb_path` independently (Step 0: Load Config). Don't assume another skill already loaded the data.
- **Skills declare an operating focus** in Step 0 — the focus whose write authority they use. A skill writes only that focus's territory plus the shared files (`profile.md`, `patterns.md`). Reads are unrestricted.

## Reporting issues

Open a GitHub issue with:
- What you expected to happen
- What actually happened
- Which skill/command was involved
- Your Enneagram type and calibration settings (if relevant to the issue)

Share only what's relevant — never paste knowledge-base contents.

## Code of conduct

Be kind. This tool deals with personal growth — contributions should reflect that spirit.
