---
name: calibrate-profile
description: This skill should be used when a focus's knowledge base has not been set up — its gate file is missing (`profile.md` for /life, `portfolio.md` for /business, `money/ledger.md` for /money, `stories/charter.md` for /story) — when the user asks to "set up", "onboard", "get started", "redo my profile", "recalibrate", or when the calibration no longer fits — the accountability is too soft or too harsh, the truth delivery lands wrong, or the motivation anchor has changed. Runs personality discovery, six calibration dimensions, life-area selection, and profile generation, with a disclaimer and safety gate up front.
---

# Calibrate Profile

Set up or revise the knowledge base a focus reads from.

A focus invokes this when its primary state file is missing. The user can also invoke it directly to recalibrate.

## Step 0: Load config

This skill operates as the focus it is onboarding, with that focus's write authority. Read `.claude/<focus>.local.md` for the invoking focus to resolve `kb_path`. Invoked standalone, ask which focus this is for, then read that focus's config. If `kb_path` is missing, ask for it — never guess a path.

## Safety first

This runs before anything else and is not skippable.

**These tools are personal growth and accountability tools — not therapy, medical advice, or crisis support.** They can help set goals, track commitments, and surface patterns in behavior. They cannot diagnose conditions, treat mental health issues, or replace professional help.

If the user's responses at any point suggest they need professional support — depression, self-harm, crisis, trauma, severe anxiety — stop and redirect to appropriate resources before continuing. In the US, the 988 Suicide & Crisis Lifeline takes calls and texts at 988; elsewhere, a local crisis line.

Do not continue setup until you are confident the user is in a safe place to engage with a self-directed tool.

For the three short paths (`/business`, `/money`, `/story`), present this before the first setup question — the `/life` path has its own longer version below:

> Quick note before we start: **this is an advice and accountability tool — not therapy, medical care, crisis support, or licensed financial or legal advice.** If you're in crisis, in the US the 988 Suicide & Crisis Lifeline takes calls and texts at 988; elsewhere, use a local crisis line.

## Which focus is calling

Every focus has a gate file. If it's missing, that focus has not been set up, and this runs before anything else. Draft the artifacts and present them; save only after the user confirms. This skill does not commit personal records unreviewed.

| Focus | Gate file | What gets produced |
|---|---|---|
| `/life` | `profile.md` | Personality discovery, six calibration dials, life areas, full profile — the long path below |
| `/business` | `portfolio.md` | Who they are, ventures, scar tissue, operating principles, and one initiative seeded with `product.md`, `metrics.md`, `funnel.md`, `constraints.md`, `commitments.md` — see below |
| `/money` | `money/ledger.md` | The books — see below |
| `/story` | `stories/charter.md` | What the writing is for — see below |

Only `/life` needs the full personality pass. The other three are short — ten minutes at most — and they exist so a focus starts from real context instead of re-asking the same questions every session. The safety gate above applies to all of them.

### `/business` — first run

A conversation. Ask one at a time and write down what comes back:

1. **What have you built before?** Ventures, exits, failures. The failures matter more — they're what the focus will invoke when a familiar mistake shows up again.
2. **What are you building now?** One sentence per initiative.
3. **What kind of business is each one?** The model, not the market — subscription software, services, physical product, marketplace, something else. This decides which metrics matter.
4. **Who pays, and for what?** Who the customer is and what they're replacing.
5. **What do you charge?**
6. **How do people find you?** Whatever channels actually produce customers, not the ones on the plan.
7. **What do you refuse to do?** The operating principles that are already decided — no outside capital, no enterprise sales, no hiring before X, whatever they are.

**Draft.** Write `portfolio.md` from the answers: who they are, operating principles, portfolio thesis, current ventures, scar tissue. Then seed one initiative under `initiatives/<name>/` with `product.md`, `metrics.md`, `funnel.md`, `constraints.md`, `commitments.md`. Show both for review; save after the user confirms.

**Numbers gate.** Before finishing, get one real figure for the active initiative — revenue, customers, or whatever the business is actually measured by. A portfolio with no numbers produces advice aimed at a hypothetical company.

**The metrics reference.** Last step: research the metrics that decide health for this kind of business and draft `{kb_path}/bookshelf/business/metrics.md` — the handful of numbers that matter, their formulas, healthy/warning/fatal thresholds, and the classic failure patterns for this business type. Present it for review; save only after the user confirms. `demand-numbers` reads this file — without it there is nothing to drill against.

### `/money` — first run

Ask in this order, and write down what comes back:

1. **What budgeting or accounting tool do you use, if any?** This names the tool the authority order ranks *below* statements. Ask also how it's reached — an MCP server, a periodic export, or reading the app by hand — and when it was last reconciled against real statements.
2. **Every debt** — creditor, balance, APR, minimum, and the statement date each figure came from. Becomes `money/ledger.md`. A figure without a source and date gets a ⚠ rather than being tidied up.
3. **Every account and asset**, the same way.
4. **What's pending** — claims, filings, refunds, anything externally clocked, each with an owner and a date. Becomes `money/watchlist.md`.
5. **What's already decided** that shouldn't get reopened, each with the condition that *would* reopen it. Becomes `money/decisions.md`.
6. **Which direction should errors run** when a number is uncertain — conservative, aggressive, or decided case by case.

**The ledger header.** Answer 1 goes at the top of `money/ledger.md`, not into conversation memory. Without it the tool gets re-asked every session and the reconciliation date is never tracked — and that date is what decides whether the tool's figures can be trusted today.

```markdown
# Ledger

**Budgeting tool:** <name> — <how it's reached: MCP server, export, read by hand>
**Last reconciled against statements:** <YYYY-MM-DD>
**Authority:** statements > <tool> > older docs
⚠ = needs confirmation, or is an estimate
```

If there is no tool, write `**Budgeting tool:** none` explicitly. "None" is an answer; a missing line is ambiguous, and the focus will keep asking.

Update the reconciliation date whenever a reconciliation actually happens. A stale date is a live warning — it tells the focus how far to trust the tool before reaching for statements.

Create `money/process.md` with a header, and `{kb_path}/plans/` and `{kb_path}/money/log/` as empty directories. Present the drafted ledger, watch-list, and decisions files for review; save after the user confirms.

### `/story` — first run

A conversation, not a form. The charter is what stops this focus optimizing for an audience the user never wanted.

1. **What is this writing for?** Not what it's about — what it's *for*. Recovery, record, craft, reach, money, being known. Take the honest answer, whatever it is.
2. **Who reads it?** Nobody, one person, strangers, a specific group.
3. **Where does it go?** A newsletter, a blog, a stage, a drawer. More than one is fine.
4. **What would make a piece a success?** If the answer is a metric, ask once more — then take the second answer seriously too.
5. **What's off-limits?** People who haven't consented, anything still raw, anything that would cost a relationship.
6. **Name two or three pieces you'd point at and say "like that."** These become tone prototypes on the bookshelf, and they teach more than any rule here.

Draft `stories/charter.md` in the user's own words where possible and present it for confirmation before saving — only this skill creates the charter. For each piece named in question 6, draft one file into `{kb_path}/bookshelf/story/` — title, where to find it, one line on what to imitate — and save after review. Then create `stories/backlog.md`, `published.md`, `process.md` with headers, and `stories/log/` as an empty directory.

## Output for `/life`

Writes `{kb_path}/profile.md`. Everything from here down is the long path.

---

## Onboarding

If `{kb_path}/profile.md` does not exist, run the onboarding flow below. The user chooses their path — respect that choice.

### Phase 0: Intent and Entry Path

Open with the welcome and the disclaimer together, before any question:

> Welcome. This is a personal growth companion — it helps you set goals, track commitments, and stay honest about the gap between what you say matters and what you actually do.
>
> Before we start, a quick note: **this is a personal growth and accountability tool — not therapy, medical advice, or crisis support.** It can help you set goals, track commitments, and surface patterns in your behavior. It cannot diagnose conditions, treat mental health issues, or replace professional help.
>
> If you're in crisis or experiencing a mental health emergency, please reach out to a qualified professional or contact the 988 Suicide & Crisis Lifeline (call or text 988; outside the US, your local crisis line).
>
> By continuing, you're acknowledging that this is a self-directed growth tool and that you'll seek professional support for anything beyond its scope. Ready to continue?

After they acknowledge, ask:

> What brought you here? What are you hoping this helps with?

**Safety gate:** If the response suggests they need professional help — depression, self-harm, crisis, trauma, severe anxiety — gently redirect to appropriate resources before proceeding. Do not continue onboarding until you are confident the user is in a safe place to engage with a self-directed growth tool.

Then present three paths:

1. **Full setup** (~20 min) — Personality discovery, calibration, life areas, full profile
2. **Quick start** (~5 min) — Compressed personality assessment, batch defaults, fast profile
3. **Just goals** (skip everything) — Minimal profile, conservative defaults, straight to goal creation

### Phase 1: Enneagram Discovery

**Why (said to user):**

> Your personality type shapes how you respond to accountability, what motivates you, and how you tend to talk yourself out of commitments. Getting this right means the system pushes you in ways that actually work instead of ways that backfire. One caveat: the Enneagram is a self-report lens, not a validated clinical instrument — treat your type as a working hypothesis you can revise.

**If they know their type:** Accept it and validate with 2-3 targeted questions to confirm the typing is accurate — use the differentiator questions below for whichever pair their type is commonly mistaken for (1/6, 2/9, 3/7, 4/5, 5/1, 8/3). Identify their wing.

**If they don't know their type:** Offer two options:

- **Quick assessment** (5 questions, ~5 min)
- **Full assessment** (12-15 questions, ~15-25 min)

#### Quick Assessment Questions

Say before the first question: these get personal — skip any you don't want to answer.

Ask these one at a time. Wait for the answer before asking the next.

1. "What's the feeling you'd do almost anything to avoid?"
2. "When you're stressed and at your worst, what do you do?"
3. "When things are going really well, what do you naturally start doing more of?"
4. "What do people close to you wish you'd do differently?"
5. "What's the story you tell yourself to justify your worst habit?"

What each question isolates, in order: core fear · stress behavior · growth direction · blind spot · rationalization style.

After the user answers all five, identify their type and wing. Present your assessment with reasoning — which answers pointed where — and ask for confirmation. If they disagree, explore further.

**Mark a quick-assessment result as provisional.** Watch calibration accuracy over the first few weeks and resurface the type question if observed behavior diverges from the type's predicted patterns. A full-assessment result is **confirmed** — keep observing, but don't proactively re-open the typing.

#### Full Assessment

Start with the 5 quick-assessment questions above, then continue with these additional questions. Adapt based on earlier answers — skip questions already answered.

6. "When you were a kid, what role did you play in your family?" *(formation pattern)*
7. "What's the compliment that matters most to you?" *(core desire)*
8. "When you disagree with someone you respect, what do you do?" *(assertive / withdrawn / compliant)*
9. "What do you do when you have nothing planned — a completely free Saturday?" *(default state: withdrawal, stimulation-seeking, merging, productivity reflex)*
10. "When something goes wrong that's clearly your fault, what's your first internal reaction?" *(shame type — 1: I should have known better · 2: they'll think I'm selfish · 3: they'll see me fail · 4: something is wrong with me)*
11. "What makes you angry?" *(gut triad — 8: injustice/being controlled · 9: being overlooked/dismissed · 1: things being wrong/unfair)*
12. "When you're at your best, what are you like?" *(growth direction — confirms or contradicts the quick-assessment typing)*

For types that are close after the core questions, add targeted differentiators:
- 3 vs 7: "When a project gets boring, do you push through to finish it or pivot to something more exciting?"
- 5 vs 4: "When you're alone, do you tend toward thinking and research or feeling and creative expression?"
- 1 vs 6: "Do you trust your own sense of right and wrong above others, or do you frequently double-check your judgment against people you trust?"
- 9 vs 2: "Do you lose yourself in other people's needs because you want to help or because it's easier than asserting your own agenda?"
- 5 vs 1: "When something is wrong, do you want to understand why it's wrong (5) or fix it so it's right (1)?"
- 8 vs 3: "When you dominate a room, is it because you refuse to be controlled by anyone (8) or because you need to be seen as the most competent person there (3)?"

#### Wing Identification

After confirming the core type, determine the wing. Every type has two possible wings — the types on either side of it on the Enneagram circle (e.g., a Type 5 has a 4-wing or a 6-wing).

Present brief descriptions of both wings and ask which resonates more:

| Type | Wing A | Wing B |
|------|--------|--------|
| 1 | **1w9** — More idealistic, detached, principled. Calm reformer. | **1w2** — More interpersonal, helpful, critical of others. Activist energy. |
| 2 | **2w1** — More principled, self-critical, duty-driven helping. | **2w3** — More ambitious, image-conscious, charming helping. |
| 3 | **3w2** — More people-oriented, charming, relational achievement. | **3w4** — More introspective, creative, identity-focused achievement. |
| 4 | **4w3** — More ambitious, image-aware, productive creativity. | **4w5** — More withdrawn, cerebral, unconventional creativity. |
| 5 | **5w4** — More creative, emotional depth, idiosyncratic thinking. | **5w6** — More analytical, loyal, systems-oriented thinking. |
| 6 | **6w5** — More withdrawn, cerebral, self-reliant anxiety. | **6w7** — More outgoing, playful, distraction-seeking anxiety. |
| 7 | **7w6** — More loyal, anxious, responsible enthusiasm. | **7w8** — More assertive, intense, driven enthusiasm. |
| 8 | **8w7** — More expansive, energetic, pleasure-seeking intensity. | **8w9** — More grounded, patient, steady intensity. |
| 9 | **9w8** — More assertive, stubborn, comfort-seeking peace. | **9w1** — More principled, orderly, idealistic peace. |

Ask: "Which of these two descriptions sounds more like you?" Accept their answer. If they're unsure, mark the wing as provisional and note it in the profile — it can be refined through observation.

#### Post-Typing

After type and wing are confirmed, offer the deep-dive video for their type:

> If you want to go deeper on your type, this is a solid deep dive from the You've Got a Type channel — it covers your core motivations, wings, stress and growth paths, and how your type shows up day to day:

| Type | Video |
|------|-------|
| 1 | https://www.youtube.com/watch?v=PNTi3KfNZUE |
| 2 | https://www.youtube.com/watch?v=vGfrzzvWebE |
| 3 | https://www.youtube.com/watch?v=IwAHPR6wcmo |
| 4 | https://www.youtube.com/watch?v=V8H22OLdWwQ |
| 5 | https://www.youtube.com/watch?v=tSrcN4mmzU0 |
| 6 | https://www.youtube.com/watch?v=jcjSX4qHb9Y |
| 7 | https://www.youtube.com/watch?v=dn60SfxiTA8 |
| 8 | https://www.youtube.com/watch?v=MU48u52wtMc |
| 9 | https://www.youtube.com/watch?v=dkYR6b_hUMQ |

> You don't need to watch it now — we can keep going. But it's worth coming back to when you have 20 minutes.

### Phase 2: Growth References

**Why:**

> When you're stuck, I can draw on frameworks from people who've thought deeply about the kind of challenge you're facing. If you already have authors or ideas that resonate with you, I'll prioritize those.

Ask if they have favorite authors, books, or frameworks for personal growth. Record what they share, then ask the follow-up: "What specifically resonates about them? Is there a concept you find yourself coming back to?" That tells you which *ideas* land, not just which names the user likes.

If they have nothing specific, offer 2-3 suggestions based on their Enneagram type:

| Type | Starting points | Why |
|------|-----------------|-----|
| 1 | Brené Brown (perfectionism as armor), Stephen Covey (principle-centered living) | Permission to be imperfect, and a principled frame that isn't about being "right" |
| 2 | Brené Brown (boundaries + self-worth), Adam Grant (sustainable giving) | Boundaries, and learning that self-care isn't selfish |
| 3 | Greg McKeown (essentialism), Mark Manson (values beyond achievement) | Frameworks that challenge the achievement treadmill |
| 4 | Viktor Frankl (meaning in suffering), Mel Robbins (action despite feeling) | Meaning-grounded purpose, and tools to act without waiting for the right mood |
| 5 | Cal Newport (deep work + boundaries), Annie Duke (decisions under uncertainty) | Structured approaches to managing energy and moving with incomplete information |
| 6 | Annie Duke (probabilistic thinking), Ryan Holiday (obstacle as the way) | Navigating uncertainty; making fear actionable |
| 7 | Greg McKeown (disciplined pursuit of less), James Clear (identity-based habits) | Narrowing focus; habits tied to identity rather than novelty |
| 8 | Ryan Holiday (ego and discipline), Brené Brown (vulnerability as strength) | Reframes vulnerability; channels intensity sustainably |
| 9 | Mel Robbins (activation energy), Mark Manson (choosing what matters) | Overcoming inertia; asserting their own priorities |

### Phase 3: Calibration (6 dimensions)

**Why:**

> People respond differently to accountability. I'm going to show you a few settings — think of them as dials. I've pre-set them based on your type, but you know yourself better than any framework does.

Present each dimension one at a time with the Enneagram-seeded default pre-selected. The user adjusts or accepts. Use this mapping for defaults:

| Type | Accountability | Truth | Motivation | Reflection | Structure | Balance |
|------|---------------|-------|------------|------------|-----------|---------|
| 1 | 3 | 3 | Identity | 2 | Scheduled | Sustaining |
| 2 | 3 | 2 | People | 2 | Rhythmic | Balancing |
| 3 | 4 | 4 | Identity | 2 | Rhythmic | Balancing |
| 4 | 2 | 2 | Meaning | 3 | Threshold | Starting |
| 5 | 4 | 4 | Progress | 3 | Scheduled | Balancing |
| 6 | 3 | 2 | People | 2 | Scheduled | Starting |
| 7 | 4 | 4 | Meaning | 1 | Threshold | Sustaining |
| 8 | 5 | 5 | Stakes | 2 | Rhythmic | Balancing |
| 9 | 3 | 2 | People | 3 | Scheduled | Starting |

#### 1. Accountability Intensity (1-5)

> This controls what happens when you're drifting from something you committed to.

- **1 — Gentle reminder.** "Hey, you had a plan for today."
- **2 — Direct observation.** "You said X. You did Y. What happened?"
- **3 — Pattern surfacing.** "This is the third time this week. What's the structural problem?"
- **4 — Confrontation.** "You're choosing comfort over the life you said you wanted. Name it."
- **5 — No retreat.** "You made a commitment with a person attached. Are you breaking it? Say it out loud."

#### 2. Truth Delivery (1-5)

> This system tracks what you actually do. When there's a gap between what you said and what happened, I need to tell you. This setting controls how.

- **1 — Curious.** Questions only. "How did that land for you?"
- **2 — Observational.** "I notice X happened three times this week."
- **3 — Direct.** "That's the pattern again. You know it is."
- **4 — Blunt.** "You're lying to yourself about this. Here's the data."
- **5 — Unflinching.** "You said this mattered. Your actions say it doesn't. Which is true?"

#### 3. Motivation Anchor

> When I'm helping you build commitments, I need to know what kind of structure actually makes you follow through.

- **People** — "Someone is counting on you showing up."
- **Stakes** — "You committed money / reputation / a promise."
- **Identity** — "Is this who you said you are?"
- **Progress** — "Look at the data. You were building momentum."
- **Meaning** — "Remember why this matters to you."

#### 4. Reflection Depth (1-3)

> Each week I'll review how things went. This controls whether that's a quick scorecard or a deeper look.

- **1 — Scorecard.** Needle review plus commitments kept/broken. Data only.
- **2 — Analysis.** Scorecard plus pattern exploration and next-week planning — no harsh-truth question, no WOOP.
- **3 — Deep dive.** All six sections: scorecard, patterns, the harsh truth, WOOP on a stuck goal, next-week planning.

#### 5. Structure Preference

> Some people thrive with exact schedules. Others feel trapped by them.

- **Scheduled** — Specific days, specific times, specific places. "Tuesday and Thursday at 6am at the gym."
- **Rhythmic** — Frequency-based with flexible timing. "3x per week, any days."
- **Threshold** — A minimum or maximum per period, fully flexible. "At least 3 sessions this week."

#### 6. Balance Challenge

> This helps me understand the shape of your challenge — where growth usually stalls for you.

- **Starting** — The hardest part is beginning. Once moving, you're fine. *(System: activation energy, habit building, showing up.)*
- **Sustaining** — You start strong but fade. Week 3 is your graveyard. *(System: watches for drop-off points and re-engages when commitments start slipping.)*
- **Balancing** — You go hard on one area and starve the others. *(System: tracks attention across life areas and surfaces when one dominates. During goal creation, helps set boundary goals — ceilings on the area that expands, not just floors on the areas that shrink.)*

**Why there's no "stopping" option:** this is a personal growth tool, not a clinical one. If someone's challenge is genuinely about stopping a behavior they can't control, they need professional support — a therapist, a counselor, a recovery program. This tool can complement that work; it shouldn't be the primary intervention. "Balancing" handles the common, non-clinical version ("work takes too much time") without framing it as pathology.

### Phase 4: Life Areas

**Why:**

> Now I know how you're wired and how you want to be pushed. Next I need to know what matters to you.

Ask what areas of life the user wants to track. For each area, determine: **growth** (building toward something) or **boundaries** (constraining something)?

Growth areas get needles and upward commitments. Boundary areas get limits and stop-conditions. Both are tracked with equal rigor — a broken boundary is as serious as a missed growth commitment.

### Phase 5: Profile Generation

**Why:**

> I've put together a profile based on everything you've told me. Before I save it, I want you to read it and tell me what's right, what's wrong, and what's missing.

Generate two files:

1. **`{kb_path}/profile.md`** — Enneagram type/wing, calibration settings, life areas, motivation anchors, growth references, what works on this person, what doesn't.
2. **`{kb_path}/patterns.md`** — Read `references/enneagram-seed-patterns.md` and extract the patterns for the user's confirmed type. Copy the relevant type's patterns into the user's file. Mark each pattern as "seeded — to be validated through observation."

Present both files to the user for review: "Here's your profile and a set of patterns I'd expect based on your type. Read through the patterns — which ring true? Which are wrong? What's missing?" Remove any patterns the user rejects. Add any they identify. Save only after the user confirms. With the save, create `{kb_path}/goals/`, `{kb_path}/log/`, and `{kb_path}/log/weekly/` as empty directories.

**Quality Gate: Profile Completeness.** Before saving, verify:
- Could the system calibrate its voice from this profile alone? (all six calibration values present and specific)
- Could commitments be checked without conversation context? (life areas named, structure preference clear)
- Are the growth references recorded? (preferred authors listed or explicitly "none", Enneagram type and wing present)
- Which settings were actively confirmed vs. passively accepted? Mark passively accepted settings as **unconfirmed** — these get re-checked at 2 weeks instead of 4.

**Transition:**

> Setup's done — let's build your first goal. While we do that, I'll be doing some homework in the background to flesh out your profile and build reference material based on what you told me.

### Post-Onboarding Research

After the profile is saved, dispatch the research below to a subagent running in the background (the Agent tool), then continue straight into goal creation while it runs. Present the subagent's findings for review at the next natural pause. If no subagent tool is available, run the research after the first goal is saved — never make the user wait on it.

1. **Enneagram deep dive.** Research the user's confirmed type and wing — core fear/desire with behavioral examples, stress and growth directions specific to the wing variant, type-specific insights — and update the profile's What Works / What Doesn't Work sections with the findings. Present the additions for review.

2. **Preferred author bookshelf files.** For each author the user named in Phase 2: offer to draft a one-page summary — key frameworks, when to apply, core insight — into `{kb_path}/bookshelf/life/<author>.md` for review. The data ritual loads the bookshelf, so these are available every session.

3. **Seeded pattern enrichment.** For each pattern in `{kb_path}/patterns.md` that the user confirmed as resonating, expand the "sounds like" section with 2-3 additional examples specific to the user's wing variant and life areas. Update the file in place.

If the user didn't name any preferred authors, skip step 2. If no patterns were confirmed, skip step 3. Step 1 always runs.

Invoke the **set-goals** skill for first goal creation.

### Quick Start Path (Phase 0 option 2)

Compressed version:

- Quick Enneagram assessment only (5 questions)
- Present all six calibration dimensions as a batch with defaults — user adjusts any they disagree with
- Life area names only (growth/boundary determined later)
- All settings marked **unconfirmed** — re-check at 2 weeks
- Generate profile and proceed to goal creation

### Skip Path (Phase 0 option 3)

- Create a minimal profile with conservative defaults (mid-range accountability, observational truth delivery, rhythmic structure)
- System observes behavior patterns and suggests Enneagram type after 2 weeks of interaction
- Skip directly to goal creation via the **set-goals** skill

## Calibration Over Time

Every 4 weeks (every 2 weeks for settings marked **unconfirmed**), during the weekly reflection: ask the user if their calibration settings are still right.

> Are these settings still right for you? Anything feel too soft, too harsh, or just off?

Present the current values and let them adjust. This is not optional — people change, and settings that worked in week 1 may not work in week 8.
