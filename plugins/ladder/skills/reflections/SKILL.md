---
name: reflections
description: >
  This skill should be used when it's time for a weekly reflection, when 7+ days have passed
  since the last weekly reflection in the user's log/weekly/ directory, when the user asks to
  "review my week", "do a reflection", "weekly check-in", "how did I do this week", or when the
  user asks to assess progress across life areas. Provides a structured weekly review using logged data.
---

# Weekly Reflection

## Step 0: Load Config

Read `.claude/ladder.local.md` to get `kb_path`. If the file doesn't exist, tell the user to run `/climb` first to set up.

Run a structured weekly reflection using data from daily logs, goal files, and patterns. This is where growth happens — the data tells the truth that daily conversation can smooth over.

## When To Invoke

- Start of a new week (Monday or first interaction of the week)
- 7+ days since the last entry in `{kb_path}/log/weekly/`
- User asks for a review or weekly check-in
- The `/climb` command detects a reflection is overdue

## Data Required

Before starting, read:
1. All daily logs from the past 7 days (`{kb_path}/log/`)
2. All goal files (`{kb_path}/goals/`)
3. `{kb_path}/patterns.md`
4. The previous weekly reflection (`{kb_path}/log/weekly/`)
5. `{kb_path}/profile.md` — for reflection_depth setting

## Sections by Reflection Depth

The user's `reflection_depth` calibration setting determines how many sections to run.

### Level 1 (Scorecard): Sections 1-2 only
### Level 2 (Patterns): Sections 1-3 + Section 5
### Level 3 (Full depth): All 6 sections

Save each section to `{kb_path}/log/weekly/YYYY-MM-DD.md` as it's completed — do not batch saves.

---

### Section 1: Needle Review

For each life area with a goal file, answer: did the needle move this week?

Present as a simple list. No narrative. No softening. Just the truth.

```
- [Area]: [moved / didn't move] — [data]
```

If a needle didn't move, note it. Do not explain it away. The explanation comes from the user, not the system.

### Section 2: Commitment Scorecard

For each commitment across all life areas, show kept/broken for each day of the week. Binary. What counts and doesn't count was defined in the goal file — do not renegotiate.

Display as a grid:

```
| Commitment          | Mon | Tue | Wed | Thu | Fri | Sat | Sun | Hit Rate |
|---------------------|-----|-----|-----|-----|-----|-----|-----|----------|
| [Commitment name]   |  Y  |  N  |  -  |  Y  |  N  |  -  |  -  | 2/4      |
```

Y = kept, N = broken, - = not scheduled for that day.

Verify each entry against actual log data. If no log exists for a day, the commitment is unverified — mark as `?`, not `Y`.

### Section 3: Pattern Check (Level 2+)

Read the daily logs and surface patterns. What does the data show?

Look for:
- Commitments consistently broken at the same time or in the same way
- What the user did instead when they broke a commitment
- Commitments consistently kept (acknowledge what's working)
- Escalating or de-escalating trends
- New patterns not yet in `patterns.md`

State patterns directly. Use data, not judgment.

New patterns require at least 3 instances across at least 2 different days. A single event is an incident, not a pattern. Before adding a new pattern to `{kb_path}/patterns.md`, surface it to the user: "I'm seeing something that might be a pattern — does this ring true?"

Update `{kb_path}/patterns.md` with any new or changed patterns after user confirms.

### Section 4: The Harsh Truth (Level 3 only)

One question. Grounded in this week's data. The one the user would rather not answer.

This is not generic. It uses specific data from this week, specific people from the user's life, and specific commitments that were broken or avoided. It's the question that cuts through the stories.

Quality check before delivering: Is this specific to THIS week's data? Would the user rather not answer it? If it's comfortable, it's not a harsh truth — rewrite it.

Calibrate delivery to the user's truth_delivery setting.

Then engage with the response. If the user rationalizes, invoke the accountability skill.

### Section 5: Next Week's Commitments (Level 2+)

What is the user committing to next week? Walk through:

- Are last week's commitments staying the same?
- Does anything need to change? If a commitment is being dropped or modified, ask why.
- Is new external structure needed for commitments that keep breaking?
- Are there any new commitments?

**Same-plan check:** If the plan is identical to last week's and last week's hit rate was below 50%, flag it: "This is the same plan that produced a [X]% hit rate. What's structurally different about next week that would produce a different result?" If nothing is different, the plan needs to change.

Push toward external structure for anything that was consistently broken.

### Section 6: WOOP on One Stuck Goal (Level 3 only)

Pick the goal where the needle isn't moving or commitments keep breaking. Run the full WOOP process:

- **Wish:** Restate the goal
- **Outcome:** Imagine it achieved — what does life look like?
- **Obstacle:** What is the *internal* barrier this week? Not "I was busy" — what was really going on?
- **Plan:** Create a new implementation intention for that specific obstacle

Focus on the obstacle step. The user may give surface-level answers. Push for the real internal barrier.

## Quality Gate: Reflection Integrity

Before saving the final reflection, verify:

1. **Data-grounded claims.** For each "needle moved" or "commitment kept" claim, trace it to a specific log entry. If no log entry exists for a day, the commitment is unverified — mark as `?`, not `Y`. "Needle moved" requires specific evidence, not general impression.

2. **Harsh truth quality (level 3).** Re-read the harsh truth question before delivering. Is it specific to THIS week's data? Does it reference specific people or commitments? Would the user rather not answer it? If it's comfortable or generic, rewrite it.

3. **Same-plan detection.** If "Next Week's Commitments" is identical to last week's plan and last week's hit rate was below 50%, the gate fails. The plan must change — either the commitments, the external structure, or the schedule.

4. **Pattern evidence threshold.** Any new pattern claimed must have at least 3 instances across at least 2 different days in the log data. A single event is an incident, not a pattern.

If any check fails, go back and fix it before saving.

## After the Reflection

Read `references/reflection-format.md` and save the complete reflection to `{kb_path}/log/weekly/YYYY-MM-DD.md` using that format. Update `{kb_path}/patterns.md` with any new patterns. Update the "Current Status" section in relevant goal files.

## Calibration Check

Every 4 weeks (or 2 weeks for settings the user passively accepted during onboarding), add to the reflection: "It's been [N] weeks. Are your settings still right for you? Anything you want dialed up or down?"

## Additional Resources

### Reference Files

- **`references/reflection-format.md`** — Template for weekly reflection output files
