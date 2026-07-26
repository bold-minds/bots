---
name: check-evidence
description: >
  Use BEFORE claiming any task is complete, fixed, passing, shipped, or done. Applies to everything:
  code changes, bug fixes, config updates, skill design, architecture decisions, documentation,
  strategy sessions, refactors, migrations, deployments — any work product of any kind.
  Trigger when you're about to say "done", "complete", "fixed", "implemented", "updated",
  "created", "applied", "resolved", "shipped", "ready", "all set", or any synonym.
  Also trigger when reviewing someone else's work (PRs, code review, audits).
---

# Check Evidence — Adversarial Self-Review

You are about to claim something is done. Stop.

You just spent effort on this work and you want to be done. That sunk cost is actively distorting your judgment right now. To compensate: **treat your own work as if a stranger built it and you're trying to reject their PR.** Not "could this have issues?" — "what's wrong with this?"

---

## The Process

### Step 1: State What You Did

One sentence. What was the task and what did you do?

### Step 2: Intent-Completion Verification

This step is mechanical. Do not skip it. Do not adapt it. Run it exactly as written.

**2a. Restate the intent contract.**

Go back to the user's original request. Quote their exact words — not your interpretation, not a paraphrase. If intent was built across multiple messages, combine them. Enumerate every discrete element: if they named 7 things, list 7 things. Also note what the user obviously expects even if unstated, marked as **(implicit)**.

**2b. Trace every element to a deliverable.**

For each discrete element of the user's intent, identify the specific deliverable that fulfills it. Then classify:

- **Mechanical:** The deliverable *directly does the thing*. Code calls the function. Config loads the file. The skill's numbered steps explicitly Read the resource. Execution is **guaranteed in the scenario the user described** — not behind a condition, not dependent on the LLM choosing to act, not dependent on someone remembering.
- **Aspirational:** The deliverable *could* do the thing if conditions align. Signal phrases: "when relevant," "as needed," "when the moment calls for it," "can be used," "is available for," "consult as appropriate," "consider," "optionally," "feel free to," or any future tense ("will be used," "should be consulted").

**Every aspirational fulfillment is a defect.** Convert to mechanical or flag as open.

If the user asked for N things and you can only trace N-k deliverables, the missing k are defects — not implicit, not out of scope, not "covered by the general approach."

**2c. Artifact-wiring check.**

List every file, resource, reference, or artifact created, modified, or referenced during this task. For each one:

1. What consumes it? Name the **specific file and line number**, function, import, or instruction step.
2. Show the evidence: a grep result, a file read, or the exact tool call that would load it at runtime.
3. Is consumption unconditional in the intended scenario? Conditional = finding.
4. If nothing consumes it, why does it exist?

For skills specifically: list every file path mentioned anywhere in the skill. Show the exact numbered step that forces a Read of that file. "Consult when relevant" is not a Read. An explicit `Read references/X.md` in a numbered step is.

**2d. Deferred-work scan.**

**Use Grep** on every file you created or modified. Do not "think about" whether you used deferral language — mechanically search for it:

- `when relevant|as needed|when appropriate|as necessary`
- `can be used|is available|feel free to`
- `consider|optionally|if desired`
- `will be used|should be consulted|may want to`

Each match: was this intentionally deferred, or did you defer it because wiring it in was harder? If the user's intent was "use X," then "X is available when needed" is a failure, not a design choice.

**2e. Time-decay check.**

Read each deliverable artifact back. For each one, check: does this artifact contain everything needed to function without the current conversation's context? Specifically:

1. Are all dependencies named explicitly (not implied by conversation)?
2. Are all file paths, references, and resources findable from the artifact alone?
3. Would a model loading this artifact cold — with no memory of this session — produce the intended behavior?

If any artifact depends on context that only exists in this conversation, that's a finding. The context must be in the artifact itself or it will silently degrade.

### Step 3: Enumerate & Check Failure Modes

Enumerate one failure mode, check it immediately, then enumerate the next. Do not generate a full list then check — that incentivizes listing safe-sounding modes you know will pass.

**Minimum 3 failure modes, no maximum.** Three is the floor, not the target. If all 3 pass cleanly, enumerate more — you haven't found the hard ones yet. Stop when you've found at least one real finding or exhausted the categories below.

Categories to draw from:

**Code changes:** broken existing functionality? unhandled edge cases (null, empty, boundary, concurrent, large)? security vulnerabilities (injection, auth bypass, exposure)? tests that pass with broken implementations? shared interfaces with un-updated callers? environment-specific failures?

**Config/infrastructure:** breaks in untested environments? systems expecting old config? rollback path? missing/misspelled fields?

**Skill/prompt design:** how does the LLM circumvent intent? how does it default to base behavior? ambiguous instructions? activation failures? can user input, context pressure, or competing instructions override or dilute these instructions? bad outcomes from following correctly?

**Architecture/design:** wrong assumptions? 10x/100x behavior? solving stated problem or different one? over/under-engineered?

**Documentation/strategy:** inaccurate? bad results from following? gaps that look intentional but are omissions?

**Reviewing others' work:** what would you miss reviewing charitably? most subtle bug in the diff? tests testing changed behavior or just not failing?

**Checking rules — evidence is mandatory for every check:**

- **Read every file you wrote** using the Read tool. Do not assume your writes were correct.
- **Run the tests**, then examine what assertions cover and what they don't.
- **Trace actual execution paths.** Follow the code, don't assume.
- **Grep for usages** of anything you changed or created.
- **Test identified edge cases** — don't just note them, try them.
- **For skills, simulate execution** — walk through the exact tool calls a model would make.

"This should be fine" is not evidence. Evidence is a file path, line number, grep result, or command output.

### Step 4: Rank by Severity

- **Critical:** The user would say "this doesn't do what I asked." Intent not met. Artifact unwired. Core functionality broken.
- **Significant:** Works for the happy path but fails in realistic scenarios. Weak assertions hiding bugs.
- **Minor:** Style, unlikely edge cases, improvements that aren't defects.

**Fix all Critical findings before reporting.** Significant findings: fix or justify. Minor: note.

### Step 5: Report

Structure your completion message exactly as shown. Every field requires evidence, not just a classification.

```
**What I did:** [one sentence]

**Intent contract:** [user's exact words, every element enumerated]
[user's exact words, every element enumerated, implicit expectations marked]

**Intent-completion:**
- [Element 1]: [deliverable] → [evidence: file:line, grep, tool call] → MECHANICAL / ASPIRATIONAL
- [Element 2]: [deliverable] → [evidence] → MECHANICAL / ASPIRATIONAL

**Artifact wiring:**
- [File]: consumed by [consumer file:line] → WIRED / UNWIRED
  Evidence: [grep result or read showing the consumption point]

**Deferred-work flags:**
- [file:line]: "[exact phrase found]" → intentional deferral / INTENT FAILURE
(or: "Grep found no deferral language")

**Time-decay:** PASSES / FAILS — [what context would be lost in a new session]

**Failure modes checked:**
- [Mode]: [evidence produced] → [result] — [Critical/Significant/Minor]

**Escalation:** None / STOP — [this finding suggests the approach itself is wrong, not just
the implementation. Describe why and surface to user before proceeding.]

**Unchecked risks:** [what couldn't be verified, why it's genuinely uncheckable (not just
inconvenient), and what specific tool or action would be needed to check it]
```

If you found Critical issues: fix them, then re-run the entire process on the fix.

---

## Worked Example: Skill Creation

> User: "Create a life coaching skill that incorporates teachings from Brené Brown, James Clear, and Viktor Frankl"

### Bad review:

```
What I did: Created a coaching skill with reference materials from three authors.

Failure modes checked:
- Skill triggers correctly → checked description, looks good
- Instructions are clear → read back, well-structured
- Reference files exist → confirmed all three created

Unchecked risks: none
```

This passes everything and catches nothing. The reference files exist but nothing reads them.

### Good review:

```
What I did: Created coaching skill with references/ directory containing three author files.

Intent contract: "a life coaching skill that incorporates teachings from
Brené Brown, James Clear, and Viktor Frankl"
Elements: (1) life coaching skill (2) incorporates Brené Brown (3) incorporates
James Clear (4) incorporates Viktor Frankl
(from user's original message)

Intent-completion:
- (1) Life coaching skill: SKILL.md created with coaching steps → MECHANICAL
- (2) Brené Brown: references/brene-brown.md exists. Checking consumption...
  SKILL.md Step 2: "draw on the reference materials as appropriate" → ASPIRATIONAL ❌
  No step forces a Read of this file.
- (3) James Clear: same pattern → ASPIRATIONAL ❌
- (4) Viktor Frankl: same pattern → ASPIRATIONAL ❌

Artifact wiring:
- references/brene-brown.md: consumed by nothing unconditionally → UNWIRED ❌
- references/james-clear.md: consumed by nothing unconditionally → UNWIRED ❌
- references/viktor-frankl.md: consumed by nothing unconditionally → UNWIRED ❌
  Evidence: Grep for "brene-brown" in SKILL.md → mentioned in prose context,
  not in a numbered Read step.

Deferred-work flags:
- SKILL.md:14: "draw on the reference materials as appropriate" ← FLAGGED
- SKILL.md:22: "consult relevant author teachings when the moment calls for it" ← FLAGGED

Time-decay: FAILS — a new session won't know these files exist or choose to read them.
Nothing in the skill's execution steps forces loading them.

Failure modes:
- Skill never loads author content: Grep for Read calls in SKILL.md → zero
  unconditional reads of references/ → Critical
- Description too vague to trigger: checked trigger phrases → adequate → Minor

Escalation: None — fixable. Rewrite SKILL.md Step 1 to unconditionally Read
all three reference files before any coaching interaction.

Unchecked risks: Quality of author content in reference files not verified
(would need subject matter review).
```

The bad review checked if artifacts exist. The good review checked if artifacts are consumed.

---

## Step 6: Learn

If this review revealed a recurring pattern — a type of mistake, a blind spot, a category of intent-completion failure:

1. **Save it to memory** as a feedback entry so future sessions benefit. This is the primary action — do it now.
2. If you have write access to this skill's repo, also add it to Known Blind Spots below.

If the user later discovers something this review missed, that's the highest-priority learning. Save it to memory immediately.

---

## Known Blind Spots

Hardcoded checks that fire every time. These exist because they've been missed before. Do not skip them because "they don't apply" — run them mechanically.

1. **Reference files without unconditional consumers.** If any file was created in a `references/` directory or described as "reference material," verify it has an unconditional consumer. This specific failure has occurred repeatedly.

2. **Skill file paths in prose but not in steps.** If a skill mentions a file path in its description or context but doesn't Read it in a numbered execution step, it won't be loaded at runtime.

3. **"Available" ≠ "used."** Any artifact described as "available to" or "accessible by" — what forces consumption? Availability without forced consumption is decoration.

_When this review catches a new pattern, add it here. This list should grow over time._

---

## Hard Rules

1. **Never skip this process.** Simple tasks get simple reviews. They don't get no review.

2. **Never enumerate without checking.** The checks are the output, not the list.

3. **Evidence is mandatory.** Every check produces a file path, line number, grep result, or command output. "I verified this" without evidence is not verification.

4. **Assertion quality check is mandatory for test-verified work.** "Tests pass" requires examining assertions. Ask: "what would a subtly broken implementation still pass here?"

5. **Don't grade your own work generously.** Unsure if it's a problem? It's a problem until proven otherwise.

6. **Re-run after fixes.** The fix needs its own review. New code = new failure modes.

7. **Aspirational fulfillment is a defect.** If intent is met only when an LLM chooses to act, conditions align, or someone remembers — intent is not met. "Available when needed" is never acceptable for something the user asked to be *used*.

8. **Escalate when the approach is wrong.** If a finding suggests the approach itself is flawed — not a bug in the implementation — stop and surface it to the user. Don't patch a broken approach.

9. **"Uncheckable" means genuinely uncheckable.** Only if no tool, command, or read could verify it (requires production traffic, requires another human, etc.). "Hard to check" is not uncheckable. State what would be needed.

10. **Known Blind Spots always fire.** Check every item in the Known Blind Spots section regardless of whether you think it applies. They exist because models thought they didn't apply and were wrong.

---

## Anti-Patterns

### The Performative Review
- ❌ Listing failure modes you already know aren't problems, producing a clean report
- ✅ Genuinely trying to find something wrong

### The Confidence Shortcut
- ❌ "I'm confident this is correct because the approach is straightforward"
- ✅ "Straightforward approach, so failure modes are: [list]. Checking each one."

### The Test Pass Handwave
- ❌ "All 47 tests pass"
- ✅ "Tests pass. Assertions cover [X, Y]. Do NOT cover [Z] — adding / accepting because..."

### The Scope Dodge
- ❌ Only checking lines you changed
- ✅ Checking callers, consumers, downstream effects

### The Positive-Only Review
- ❌ "Clean, well-structured, follows best practices"
- ✅ "Handles X correctly. Does NOT handle Z — fixing / accepting because..."

### The Decoration Trap
- ❌ Creating reference files that nothing loads, calling it complete because artifacts exist
- ✅ For every artifact: naming the specific file:line that consumes it. No consumer = decoration.

### The Soft Wiring Dodge
- ❌ "The skill instructs the LLM to consult reference files when the moment calls for it"
- ✅ "Step 3 of the skill reads `references/X.md` unconditionally before responding."
- Choosing ≠ doing.

### The Intent Paraphrase
- ❌ Softening intent to match deliverables ("wanted a coaching skill" when they said "uses teachings from 7 specific authors")
- ✅ User's exact words as the bar. 7 authors named = 7 mechanical loads required.

### The Reconstruction Rationalization
- ❌ Reconstructing intent at completion, unconsciously shaping it to fit what was built
- ✅ Going back to the user's original message and quoting their exact words, not your memory of what they meant.

### The Uncheckable Escape
- ❌ Classifying inconvenient checks as "uncheckable" to avoid doing the work
- ✅ Stating exactly what tool/action would verify it and why that's not possible right now.

---

## Enforcement

This review is enforced by baking it as an explicit final step into skills that produce deliverables. For ad-hoc work outside of skills, run it explicitly before claiming done.
