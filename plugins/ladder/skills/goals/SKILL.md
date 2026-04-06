---
name: goals
description: >
  This skill should be used when the user asks to "create a goal", "add a life area", "set up
  a new goal", "revise a goal", "update my commitments", "change my needle", "redefine what
  counts", "set a boundary", "limit something", mentions wanting to track a new area of their
  life, or during first-time onboarding when no goals exist yet. Provides a structured 7-step
  goal creation process that produces externally-bound commitments with binary accountability.
---

# Goal Creation and Revision

## Step 0: Load Config

Read `.claude/ladder.local.md` to get `kb_path`. Then read `{kb_path}/profile.md` to check the user's balance_challenge and structure_preference settings. If `.claude/ladder.local.md` doesn't exist, tell the user to run `/climb` first to set up.

Guide the user through creating or revising goals using a structured 7-step process. Every goal must have external structure — if nobody will notice when a commitment is broken, it's a wish, not a commitment.

## When To Invoke

- First-time onboarding (no goal files exist in `{kb_path}/goals/`)
- User mentions a new life area to track
- User wants to revise an existing goal (needle not moving, commitments not working)
- Weekly reflection reveals a goal needs reworking

## The 7-Step Process

Before starting, read `references/research-foundation.md` to understand the evidence basis for each layer. Use this to explain the reasoning to the user when they ask "why" — but do not lecture unprompted.

Walk through these steps one at a time. Do not rush. Each step is a conversation, not a form to fill out.

### Step 1: Pick the Life Area

What domain of life is this about? The user names what matters to them — accept whatever they choose.

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

Do not accept willpower-based commitments. "I'll try to go to the gym" is not a commitment. "I'm signed up for the 6am class, there's a $25 no-show fee, and my partner expects me home by 7:15am" is a commitment.

### Step 4: Define Counts / Doesn't Count

For each commitment, eliminate the gray zone. Define explicitly:

- **Counts:** What actions meet this commitment
- **Does not count:** What actions feel like meeting it but don't

Be specific. The user's intelligence will find loopholes in vague definitions. Close the loopholes in advance.

### Step 5: Build When-Thens

Implementation intentions for high-risk moments. Format: "When [specific trigger], I will [specific response]."

Ask: "What are the moments where you'll be most tempted to skip this? What does the pull to override feel like? What will you do instead?"

These are pre-decisions that bypass in-the-moment rationalization.

### Step 6: WOOP It

Walk through the WOOP process (Oettingen's mental contrasting):

- **Wish:** State the goal
- **Outcome:** Vividly imagine achieving it — what does life look like?
- **Obstacle:** What is the main *internal* obstacle? Not external barriers. The internal pattern, feeling, or belief that gets in the way. This is where honesty matters most.
- **Plan:** Create an implementation intention specifically for that obstacle

Do not rush the obstacle step. The user may intellectualize or give surface-level answers. Push for the real internal barrier.

### Step 7: Save to Goal File

Read `references/goal-file-format.md` for the template. Save immediately to `{kb_path}/goals/[area].md` using that format.

Do not wait for the conversation to end. Save as soon as the goal is defined.

## Boundary Goals (for "Balancing" users)

If the user's profile indicates balance_challenge = "balancing" and they're defining a goal for the area that tends to expand, the same 7-step process applies with an inverted focus:

### Step 2 (inverted): Define the Ceiling

The ceiling is the upper bound — the line that must not be crossed. Ask: "What's the boundary? How do you measure a violation? What does 'too much' look like?"

- Good: "No more than 50 hours of work per week" / "Laptop closed by 7pm on weeknights"
- Bad: "Work less" / "Keep things manageable"

### Step 3 (inverted): Set STOP Commitments

What to stop/limit, with external structure for enforcement. Ask: "Who will tell you to stop? What system prevents you from overriding this?"

### Step 4 (inverted): Define What Counts as a Violation

What actions break this boundary vs. what's actually fine.

### Step 6 (inverted): WOOP Inverted

- **Wish:** The bounded state
- **Outcome:** What life looks like when the boundary is held — what other areas flourish
- **Obstacle:** The PULL toward the thing being bounded. Not external barriers — the internal drive that makes overriding feel justified.
- **Plan:** Implementation intention for that pull

## Quality Gate

Before saving any goal, verify:

- The needle/ceiling can be checked weekly with a binary yes/no
- Every commitment has external structure (a person who notices, a cost for skipping — NOT willpower)
- Counts/doesn't count is defined for each commitment
- At least one when-then exists for the highest-risk moment
- The WOOP obstacle names an internal barrier, not an external one

If any of these are missing, do not save. Go back to the relevant step.

Actively try to find loopholes in the counts/doesn't-count definitions. If you can find a way the user could technically meet the commitment while missing the spirit, close the loophole before saving.

## Revision Process

When revising an existing goal:
1. Read the current goal file
2. Identify what's not working (needle not moving? commitments being broken? wrong external structure?)
3. Walk through only the steps that need changing
4. Update the goal file immediately

## Additional Resources

### Reference Files

- **`references/goal-file-format.md`** — Template and format specification for goal files
- **`references/research-foundation.md`** — Research basis for the three-layer goal framework
