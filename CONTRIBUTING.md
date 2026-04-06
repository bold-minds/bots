# Contributing to Bots

Thanks for your interest in contributing. Here's how to get involved.

## Getting started

1. Fork and clone the repo
2. Install [Claude Code](https://claude.ai/code)
3. Install the plugin locally: `claude plugin add /path/to/your/clone`
4. Run `/climb` to test the onboarding flow

## Repository structure

```
bots/
  .claude-plugin/           # Repo-level plugin discovery
    marketplace.json        # Registry of available plugins
    plugin.json             # Repo metadata
  plugins/
    ladder/                 # The Ladder personal growth plugin
      .claude-plugin/
        plugin.json         # Plugin metadata
      commands/
        climb.md            # /climb entry point (onboarding + daily rhythm)
        references/
          enneagram-seed-patterns.md  # Seeded patterns for all 9 types
      skills/
        goals/              # Goal creation and revision
          references/       # Goal file format template, research foundation
        reflections/        # Weekly structured reviews
          references/       # Reflection file format template
        accountability/     # Commitment accountability
        coach/              # Framework-based coaching (9 topic areas)
          references/       # 9 curated reference files
```

## How skills work

Each skill is a markdown file with YAML frontmatter (name + description) and structured instructions. The `description` field controls when the skill triggers. The body contains the steps the model follows.

Reference files under `references/` are loaded by explicit Read instructions in the skill. If you add a reference file, you must add a corresponding Read step — a file that nothing reads is decoration.

## Types of contributions

### Adding a coach reference topic

The coach skill has 9 topic areas. To add a new one:

1. Create `skills/coach/references/your-topic.md`
2. Follow the existing format: topic header, intro line, author sections with "Apply when:" guidance
3. Add the topic to the mapping table in `skills/coach/SKILL.md`
4. Use published, attributed frameworks only — name the author and source

### Improving Enneagram seed patterns

The seed patterns at `commands/references/enneagram-seed-patterns.md` are hypotheses based on type psychology. If you have Enneagram expertise and see:

- A pattern assigned to the wrong type
- A missing pattern that's core to a type's psychology
- A response approach that would backfire for the stated type

Open an issue or PR with your reasoning.

### Improving calibration defaults

The Enneagram-to-calibration-defaults table in `commands/climb.md` maps each type to 7 settings. If a default doesn't fit (e.g., a type's accountability intensity is too high or too low), explain why in your PR.

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
- **Keep skills self-contained.** Every skill must resolve `kb_path` independently (Step 0: Load Config). Don't assume another skill already loaded the data.

## Reporting issues

Open a GitHub issue with:
- What you expected to happen
- What actually happened
- Which skill/command was involved
- Your Enneagram type and calibration settings (if relevant to the issue)

## Code of conduct

Be kind. This tool deals with personal growth — contributions should reflect that spirit.
