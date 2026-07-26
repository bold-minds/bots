---
name: set-goals
description: This skill should be used when the user asks to "create a goal", "add a life area", "set up a new goal", "revise a goal", "update my commitments", "change my needle", "redefine what counts", "set a constraint", "add a boundary", "limit something", "stop doing something", mentions wanting to track a new area of their life, mentions needing to constrain or bound a behavior, or during first-time onboarding when no goals exist yet. Provides a structured 7-step goal creation process for both growth goals (push toward a target) and constraint goals (hold a line) that produces externally-bound commitments with binary accountability.
---

# Goal Creation and Revision

Guide the user through creating or revising goals using a structured 7-step process. Every goal must have external structure — if nobody will notice when a commitment is broken, it's a wish.

## Step 0: Load Config

This skill operates as `/life` — it writes only `{kb_path}/goals/` and the shared files. Read `.claude/life.local.md` to resolve `kb_path`; if the file or `kb_path` is missing, ask — never guess a path. Then read `{kb_path}/profile.md` for the motivation anchor and structure preference; they shape how commitments get framed below. If `profile.md` does not exist, invoke `calibrate-profile` first.

## When To Invoke

- First-time onboarding (no goal files exist in `{kb_path}/goals/`)
- User mentions a new life area to track
- User wants to revise an existing goal (needle isn't moving, commitments aren't working)
- Weekly reflection reveals a goal needs reworking

## The 7-Step Process

Walk through these steps one at a time. Do not rush. Each step is a conversation, not a form to fill out.

### Step 1: Pick the Life Area

What domain of life is this about? Examples: fitness, relationship, finances, business, creative practice, home. The user may have areas not listed here — accept whatever matters to them.

### Step 2: Define the Needle

The needle is the lag measure — the outcome that actually matters. One per life area. Checked weekly.

Ask: "What moves? How do you measure it? What does weekly movement look like?"

The needle must be concrete enough to answer "did it move this week?" with a yes or no. Push back on vague needles.

- Good: "Revenue came in" / "Debt balance went down by at least $X" / "Did at least one activity together"
- Bad: "Feel better about my finances" / "Relationship improved" / "Made progress"

### Step 3: Set the Commitments

Commitments are lead measures — specific, scheduled, externally-bound actions that move the needle. For each commitment, establish:

- **What:** Specific action, specific time, specific frequency
- **External structure:** Who will notice if this doesn't happen? What's the cost of skipping?

Push every commitment toward external structure. Ask: "Who will know if you don't do this?" If the answer is "nobody," push: "How can we change that? Can you sign up for a class? Tell someone? Set a financial stake?"

Frame the structure through the profile's motivation anchor — **People:** who's counting on you; **Stakes:** what skipping costs; **Identity:** who keeping it makes you; **Progress:** the momentum on record; **Meaning:** why it matters. Match the commitment style to the structure preference (scheduled, rhythmic, or threshold).

Do not accept willpower-based commitments. "I'll try to go to the gym" is not a commitment. "I'm signed up for the 6am class, there's a $25 no-show fee, and a friend is meeting me there" is a commitment.

### Step 4: Define Counts / Doesn't Count

For each commitment, eliminate the gray zone. Define explicitly:

- **Counts:** What actions meet this commitment
- **Does not count:** What actions feel like meeting it but don't

Be specific. The user's intelligence will find loopholes in vague definitions. Close the loopholes in advance.

### Step 5: Build When-Thens

Implementation intentions for high-risk moments. Format: "When [specific trigger], I will [specific response]."

Ask: "What are the moments where you'll be most tempted to skip this? What does the pull to override feel like? What will you do instead?"

These are pre-decisions that bypass in-the-moment rationalization. They work because the decision is made in advance, in a calm state, not in the moment of temptation.

### Step 6: WOOP It

Walk through the WOOP process (Oettingen's mental contrasting):

- **Wish:** State the goal
- **Outcome:** Vividly imagine achieving it — what does life look like?
- **Obstacle:** What is the main *internal* obstacle? Not external barriers. The internal pattern, feeling, or belief that gets in the way. This is where honesty matters most.
- **Plan:** Create an implementation intention specifically for that obstacle

Do not rush the obstacle step. The user may intellectualize or give surface-level answers. Push for the real internal barrier.

### Step 7: Save to Goal File

Save immediately to `{kb_path}/goals/[area].md` using the format in `references/goal-file-format.md`.

Do not wait for the conversation to end. Save as soon as the goal is defined.

## Constraint Goals (Inverted Direction)

Some life areas need goals that hold a LINE, not push toward a target. Overwork, scope creep, consumption — these are things to constrain, not grow. The same 7-step process applies, but each step is inverted:

### Step 1: Pick the Area to Constrain

What domain needs a boundary? This is not about growth — it's about what's consuming too much. Examples: work hours, alcohol, doomscrolling, scope creep on projects, spending.

### Step 2: Define the Ceiling

The ceiling is the upper bound — the line that must not be crossed. One per constraint area. Checked weekly.

Ask: "What's the boundary? How do you measure a violation? What does 'too much' look like in concrete terms?"

The ceiling must be concrete enough to answer "did I stay under this week?" with a yes or no. Push back on vague ceilings.

- Good: "No more than 50 hours of work per week" / "Zero drinks on weeknights" / "No new feature scope after sprint planning"
- Bad: "Work less" / "Drink less" / "Keep things manageable"

### Step 3: Set STOP Commitments

STOP commitments are lead measures — specific, scheduled, externally-bound rules about what to stop or limit. For each commitment, establish:

- **What to stop/limit:** Specific action, specific boundary, specific trigger for stopping
- **External structure for enforcement:** Who will enforce this? What mechanism prevents override?

Push every STOP commitment toward external structure. Ask: "Who will tell you to stop? What system prevents you from overriding this?" If the answer is "me, I'll just stop" — push harder: "That's willpower. What external structure can make stopping automatic? A calendar block? A person who physically pulls you away? A device that locks?"

Do not accept willpower-based stop rules. "I'll try to drink less" is not a commitment. "No alcohol in the house, and Thursday trivia is sparkling water — my teammates know and will notice" is a commitment.

### Step 4: Define What Counts as a Violation

For each STOP commitment, eliminate the gray zone. Define explicitly:

- **Violation:** What actions break this constraint
- **Not a violation:** What might feel like breaking it but doesn't count

Be specific. The user's intelligence will find loopholes that redefine "not really working" or "just this once." Close those loopholes in advance.

### Step 5: Build When-Thens for High-Pull Moments

Implementation intentions for the moments when the pull to override the constraint is strongest. Format: "When [specific high-pull trigger], I will [specific response that holds the line]."

Ask: "When is the pull to keep going strongest? What does it feel like right before you override your own boundary? What's the story you tell yourself to justify one more hour, one more feature, one more drink?"

These are pre-decisions for the moments when the pull, the momentum, or the rationalization is at peak intensity.

### Step 6: WOOP It (Inverted)

Walk through the WOOP process, but inverted:

- **Wish:** The bounded state — life with the constraint held (e.g., "I leave work at 6pm and am present for my family every evening")
- **Outcome:** Vividly imagine the bounded life — what does life look like when this constraint is consistently held? What other life areas flourish?
- **Obstacle:** The PULL toward the thing being constrained. Not external barriers — the internal drive, identity, or belief that makes overriding feel justified. "Stopping feels like falling behind." "If I don't handle it, nobody will." "One more won't hurt."
- **Plan:** Create an implementation intention specifically for that pull

Do not rush the obstacle step. The pull toward overwork or consumption often feels like identity, not temptation. Push for the real internal driver.

### Step 7: Save to Goal File

Save immediately to `{kb_path}/goals/[area].md` using the constraint goal format in `references/goal-file-format.md`.

### A Note on External Structure for Constraints

External structure is critical for constraint goals — and harder to build. For growth goals, the world often provides structure (classes have schedules, gyms have hours, partners notice effort). For constraint goals, the person who sees you building at midnight and says "stop" often doesn't exist. The boss who says "go home" doesn't exist when you're the founder. The friend who says "that's enough scope" doesn't exist when you're the architect.

Finding or creating that person or mechanism is part of the goal design. If the user cannot identify external structure for a constraint, do not accept the goal as complete. Help them design the structure: an accountability partner, a hard technology cutoff, a scheduled commitment that physically conflicts with the constrained behavior.

## Revision Process

When revising an existing goal:
1. Read the current goal file
2. Identify what's not working (needle not moving? commitments being broken? wrong external structure?)
3. Walk through only the steps that need changing — do not redo the entire process unless the goal is fundamentally broken
4. Update the goal file immediately

## Quality Gate

Before saving any goal, verify:

**For growth goals:**
- The needle can be checked weekly with a binary yes/no
- Every commitment has external structure (a person who notices, a cost for skipping)
- Counts/doesn't count is defined for each commitment
- At least one when-then exists for the highest-risk moment
- The WOOP obstacle names an internal barrier, not an external one

**For constraint goals:**
- The ceiling can be checked weekly with a binary yes/no ("did I stay under?")
- Every STOP commitment has external structure (a person or mechanism that enforces the stop — NOT willpower)
- Violation/not-a-violation is defined for each STOP commitment
- At least one when-then exists for the highest-pull moment
- The WOOP obstacle names the internal PULL (identity, drive, rationalization), not an external barrier

If any of these are missing, do not save. Go back to the relevant step.

**Then run three adversarial checks before the file is written.**

*Mechanical vs. aspirational.* Classify every commitment:
- **Mechanical** — the external structure directly enforces it. A class is scheduled. A person is expecting them. Money is at stake. It holds when motivation is zero.
- **Aspirational** — it depends on the user choosing to follow through. "I'll go to the gym" with no class, no partner, and no cost for skipping.

**Every aspirational commitment is a finding.** Push to convert it to mechanical, or name it plainly: "This one depends entirely on willpower. What structure goes under it?"

*Loophole scan.* Read the Counts / Does-not-count definitions and actively hunt for a way to satisfy the commitment technically while missing its spirit — the minimum claimed as credit ("I went to the gym" — for five minutes?), an easier substitution ("I exercised" — a walk to the fridge?), a redefined term ("I worked on my relationship" — by being in the same room?). If you can find a loophole, their future self will too. Close it before saving.

*Needle simulation.* Say it out loud: "It's Sunday. Did this needle move?" If the answer needs judgment, qualifiers, or "well, sort of," the needle isn't concrete enough yet.

## Additional Resources

### Reference Files

- **`references/goal-file-format.md`** — Template and format specification for goal files. Read it at Step 7, before saving.
- **`references/research-foundation.md`** — Research basis for the three-layer goal framework. Read it when the user asks why a step exists or pushes back on the structure.
