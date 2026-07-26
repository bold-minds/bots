---
name: demand-numbers
description: Use when the user mentions growth, retention, customer acquisition cost, pricing, or revenue without real numbers, or when an initiative's metrics.md hasn't been updated in 14+ days. Drills for actual figures, computes unit economics, flags kill-the-business thresholds.
---

# Metrics: the "what's the number?" drill

This skill turns vague claims about the business into hard figures and unit economic truths. It is the most-invoked sub-skill because every non-trivial conversation eventually hits a place where "we're growing" needs to become a number.

## Step 0: Load Config

This skill operates as `/business` — it writes only `/business`'s territory and the shared files. Read `.claude/business.local.md` to resolve `kb_path`; if the file is missing, ask — never guess a path.

## The metrics reference

Read `{kb_path}/bookshelf/business/metrics.md` before drilling. Onboarding built it for this specific business: which metrics decide health here, their formulas, healthy/warning/fatal thresholds, and the classic failure patterns for this business type. If it does not exist, invoke `calibrate-profile` — without it there is nothing to drill against. No business type's metrics ship with the plugin.

## When to invoke

Invoke automatically when:

- The user says "growing," "growing fast," "traction," "customers are happy," "doing well," or any vague positive claim about the business without citing a number
- The user mentions retention, acquisition cost, lifetime value, pricing, or revenue without specifics
- The user proposes a spend, hire, or strategic move that hinges on unit economics
- It's been 14+ days since the relevant initiative's `{kb_path}/initiatives/<slug>/metrics.md` was updated
- The user is planning for the next month/quarter and hasn't said what the current numbers are
- A weekly review is happening and metrics haven't been captured yet

Do not invoke when:

- The user has already cited specific numbers in the current session and is now talking about what to DO about them
- The conversation is explicitly non-financial (emotional check-in, customer discovery, product design detail)
- The user has just run through metrics in the last hour

## The drill

Work through the metrics reference's metrics in this order, demanding exact figures — not "around" or "roughly." Do not skip ahead. Do not accept hand-wave answers. "I don't know" is logged as a thing to fix, and the drill continues with what IS known.

1. **Revenue shape.** Revenue last period and this period, in currency. Delta in currency and percent. Customer or client count and its delta.
2. **Retention.** Whatever the reference defines for this business — repeat rate, renewal rate, churn, return visits. Cohort behavior if tracked.
3. **Acquisition economics.** Where the last 10 customers actually came from — specific channel per customer, not "marketing." Cost to acquire, using the reference's formula. Payback period.
4. **Pricing.** Current prices, exact. Revenue per customer. When prices last changed — if never and the business is >12 months old, flag it. What the alternative costs the customer.
5. **Profitability and runway.** Monthly costs in one number. Margin. Net profit or burn. Months of runway — infinite if profitable.

If any core figure is unknown, getting that data is the first next action. The drill continues with what is known; label anything that leans on the gap.

If a number lands in the reference's fatal range: pause everything else — that metric is the priority, and the reference's failure patterns name the intervention.

## Computing it when the user can't

If the user has the raw data (customer list, payment dashboard, spreadsheet) but not the computed metrics, offer to compute live. Ask the user to paste or share the raw data. Do the math using the reference's formulas. Write the result to the initiative's `metrics.md`.

Example:
> Paste in: customer count at the start of each month for the last 6 months, and new customers + lost customers per month. I'll compute retention and the cohort shape. Takes 5 minutes.

## Updating metrics.md

After the drill, update `{kb_path}/initiatives/<slug>/metrics.md` with what was captured. Format:

```markdown
---
initiative: <name>
last_updated: YYYY-MM-DD
---

# Metrics — <name>

## Revenue
## Retention
## Acquisition
## Pricing
## Runway

(line items per the metrics reference — every figure with its as-of date)

## Gaps
- [UNKNOWN items to fix]

## Notes
- [anything else surfaced during the drill]
```

If a previous metrics.md exists: preserve history by appending a dated snapshot at the bottom (`## YYYY-MM-DD snapshot`) before overwriting the top-line values. This lets the persona spot trends over time.

## Interpretation — what to do with the numbers

After capturing, make one call against the reference's thresholds: is this business healthy, warning, or dying?

Name the call plainly. "These numbers read as warning." or "This is a dying pattern — we have weeks to change the trajectory, not months." Then move to intervention, using the failure patterns in the metrics reference.

## Logging

Every drill writes:

1. The captured metrics to `{kb_path}/initiatives/<slug>/metrics.md` (overwriting, with dated snapshot appended to history)
2. The interpretation (healthy/warning/dying) and any intervention decisions to `{kb_path}/initiatives/<slug>/log/YYYY-MM-DD.md`
3. Any UNKNOWNs that surfaced as a to-do list in the log entry
4. If dying: also write to `{kb_path}/decisions/YYYY-MM-DD-<slug>-trajectory.md` with the severity call

## The meta-rule

Tactical advice without the numbers is aimed at a hypothetical business — say so once, then answer with the assumption labeled. If the drill reveals critical unknowns, the first next action is getting the number.
