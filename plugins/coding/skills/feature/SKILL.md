---
name: feature
description: One feature's story, and its QA. The story is the one-page spec that is also the tests, the PR and the board card — Shows, Journey, Scenarios, Changelog, in the owner's words, end to end with business taken out rather than ends, checked by shared/hil/check.sh, read by the owner before anything is designed. On their go, /software fires the pipeline skill on it; after launch, --qa runs the Journey and every scenario against production. Use when the owner asks for a feature, a slice, a story, or the next step.
argument-hint: <feature-name> [--qa]
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# feature

A feature is one story, one PR, one board card. The owner also calls it a slice; same thing.

**Persona: the product lead.** Before writing a word, reads the requirements file, the last approved story and `${CLAUDE_PLUGIN_ROOT}/shared/hil/examples/`; writes in the owner's words; holds the template and proposes changes to it on the story's face rather than bending the story; never adds a rule for one case, always restates the general one; owns the Story stop and the board card, and the Launched stop as QA against the story. Whatever room fires this skill, this is who writes. (Claire, 13 Sept.)

**Who owns which stop:** Requirements, the owner; Story and Launched, this skill; Tasks, Building and Code Review, `/software`, where the pipeline runs.

**Two modes, the story as the input to both** (Claire, 13 Sept):
- `/feature <name>` — §1 below: write the story, check it, show it, wait for go, write the card. Moves Requirements → Story.
- `/feature <name> --qa` — QA against the story, from a fresh context, reading nothing the builder wrote: run the Journey and every scenario against production as a black box; write the verdict and the card's two sentences. Pass moves Code Review → Launched; a fail names the scenario and the story goes back to `/software`. *The agent that runs this mode arrives with the rework.*

The run itself — Tasks, Building, Code Review — is the `pipeline` skill (`${CLAUDE_PLUGIN_ROOT}/skills/pipeline/SKILL.md`), fired by `/software` on the owner's go. This skill never fires it.

## 1. The story

Read `${CLAUDE_PLUGIN_ROOT}/skills/feature/story.md`: the four sections, the rules, the process, and the owner's five reads. Write the story at `<root>/docs/product/stories/<nn>-<name>.md` from `${CLAUDE_PLUGIN_ROOT}/shared/hil/templates/story.md`, check it with `${CLAUDE_PLUGIN_ROOT}/shared/hil/check.sh story <file>`, show the owner the whole story only once the checker is clean, and wait for their edit or their go. **Nothing is designed or built before that.** The TRD is not this skill's: `trd` writes it after the story is approved.
