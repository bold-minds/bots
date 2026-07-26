---
name: review-week
description: This skill should be used when it's time for a weekly reflection, when 7+ days have passed since the last weekly reflection in the knowledge base's log/weekly/, when the user asks to "review my week", "do a reflection", "weekly check-in", "how did I do this week", or when the user asks to assess progress across life areas. Provides a structured 6-section weekly review using logged data.
---

# Weekly Reflection

Run a structured weekly reflection using data from daily logs, goal files, and patterns. This is where growth happens — the data tells the truth that daily conversation can smooth over.

## Step 0: Load Config

This skill operates as `/life`, or as `/business` for the business branch — it writes only that focus's territory and the shared files. Read the operating focus's `.claude/<focus>.local.md` to resolve `kb_path`. Invoked standalone, ask which of the two. If `kb_path` is missing, ask — never guess a path. Operating as `/life` with no `{kb_path}/profile.md`, invoke `calibrate-profile` first; the business branch handles a missing profile itself (defaults below).

## When To Invoke

- 7+ days since the last entry in `{kb_path}/log/weekly/`
- User asks for a review or weekly check-in
- `/life` detects a reflection is overdue

## Data Required

For the `/life` branch — the business branch lists its own inputs below. Before starting, read:
1. `{kb_path}/profile.md` — the reflection depth and truth delivery settings
2. All daily logs from the past 7 days (`{kb_path}/log/`)
3. All goal files (`{kb_path}/goals/`)
4. `{kb_path}/patterns.md`
5. The previous weekly reflection (`{kb_path}/log/weekly/`)
6. `references/reflection-format.md` — the output file format

## The 6 Sections

Walk through each section in order. Save each section to `{kb_path}/log/weekly/YYYY-MM-DD.md` as it's completed — do not batch saves.

Run sections per the profile's reflection depth: **1** — sections 1-2 (the scorecard); **2** — sections 1, 2, 3 and 5 (patterns and planning, without the harsh truth or the WOOP); **3** — all six. Depth 2 skips section 4 deliberately — at that setting the harsh-truth question costs more than it returns. The user can always ask for more.

### Section 1: Needle Review

For each life area with a goal file, answer: did the needle move this week?

Present as a simple list. No narrative. No softening. Just the truth.

```
- Business: [moved / didn't move] — [data]
- Fitness: [moved / didn't move] — [data]
- Relationship: [moved / didn't move] — [data]
```

If a needle didn't move, note it. Do not explain it away. The explanation comes from the user, not the system.

### Section 2: Commitment Scorecard

For each commitment across all life areas, show kept/broken for each day of the week. Binary. Score against the counts/doesn't-count definitions as written — changing a definition is `set-goals`'s job, after the scorecard, not during it.

Display as a grid:

```
| Commitment          | Mon | Tue | Wed | Thu | Fri | Sat | Sun | Hit Rate |
|---------------------|-----|-----|-----|-----|-----|-----|-----|----------|
| Morning workout     |  -  |  Y  |  -  |  Y  |  -  |  Y  |  -  | 3/3      |
| Evening practice    |  N  |  N  |  N  |  Y  |  N  |  -  |  -  | 1/5      |
| Midday walk         |  Y  |  Y  |  N  |  Y  |  N  |  -  |  -  | 3/5      |
```

Y = kept, N = broken, - = not scheduled for that day. Hit rates spot trends across weeks.

### Section 3: Pattern Check

Read the daily logs and surface patterns. What does the data show?

Look for:
- Commitments consistently broken at the same time or in the same way
- What the user did instead when they broke a commitment — the replacement activity is the pattern
- Commitments consistently kept (acknowledge what's working)
- Escalating or de-escalating trends
- New patterns not yet in `patterns.md`

State patterns directly: "You broke your evening commitment 4 of 5 days. Every time, you replaced it with work." "You kept your gym commitment 3 of 3 days — that's two weeks running."

Update `{kb_path}/patterns.md` with any new or changed patterns.

### Section 4: The Harsh Truth

One question. Grounded in this week's data. The one the user would rather not answer.

This is not generic. It uses specific data from this week, specific people from the user's life, and specific commitments that were broken or avoided. It's the question that cuts through the stories.

Do not soften it. Do not add qualifiers. Ask it directly.

Then engage with the response. If the user rationalizes, invoke the `hold-commitments` skill.

### Section 5: Next Week's Commitments

What is the user committing to next week? Walk through:

- Are last week's commitments staying the same?
- Does anything need to change? If a commitment is being dropped or modified, ask why.
- Is new external structure needed for commitments that keep breaking?
- Are there any new commitments?

Push toward external structure for anything that was consistently broken.

### Section 6: WOOP on One Stuck Goal

Pick the goal where the needle isn't moving or commitments keep breaking. Run the full WOOP process:

- **Wish:** Restate the goal
- **Outcome:** Imagine it achieved — what does life look like?
- **Obstacle:** What is the *internal* barrier this week? Not "I was busy" — what was really going on?
- **Plan:** Create a new implementation intention for that specific obstacle

Focus on the obstacle step. The user may give surface-level answers. Push for the real internal barrier.

## Business branch

Invoked from `/business` — or 7+ days since the last entry in its knowledge base's `log/weekly/` — this skill reviews the portfolio instead of life areas:

1. **Commitment scorecard** — per initiative, from `initiatives/*/commitments.md` against the week's logs
2. **Metrics delta** — each initiative's `metrics.md` against the previous weekly; stale files named
3. **One harsh truth** — grounded in this week's numbers and decisions
4. **Next week's commitments** — per initiative, with owners

Writes one portfolio-level file to `{kb_path}/log/weekly/YYYY-MM-DD.md`, section by section as completed. The reflection depth setting applies here too — read it from `{kb_path}/profile.md`; when the business knowledge base has none, default to depth 2.

## After the Reflection

Save the complete reflection to `{kb_path}/log/weekly/YYYY-MM-DD.md`. Update `{kb_path}/patterns.md` with any new patterns. Update the "Current Status" section in relevant goal files.

**Calibration check.** Every 4 weeks — every 2 for settings marked **unconfirmed** — present the current calibration values and ask if they still fit. Adjust the profile on the spot; anything more than a value change goes through `calibrate-profile`.

## Additional Resources

### Reference Files

- **`references/reflection-format.md`** — Template for weekly reflection output files
