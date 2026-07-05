---
name: metrics
description: Use when the user mentions growth, churn, CAC, pricing, or revenue without real numbers, or when an initiative's metrics.md hasn't been updated in 14+ days. Drills for actual figures, computes unit economics, flags kill-the-business thresholds.
---

# Metrics: the "what's the number?" drill

This skill turns vague claims about the business into hard figures and unit economic truths. It is the most-invoked sub-skill because every non-trivial conversation eventually hits a place where "we're growing" needs to become a number.

## When to invoke

Invoke automatically when:

- The user says "growing," "growing fast," "traction," "customers are happy," "doing well," or any vague positive claim about the business without citing a number
- The user mentions churn, CAC, LTV, pricing, or revenue without specifics
- The user proposes a spend, hire, or strategic move that hinges on unit economics
- It's been 14+ days since the relevant initiative's `{kb_path}/initiatives/<slug>/metrics.md` was updated
- The user is planning for the next month/quarter and hasn't said what the current numbers are
- A weekly review is happening and metrics haven't been captured yet

Do not invoke when:

- The user has already cited specific numbers in the current session and is now talking about what to DO about them
- The conversation is explicitly non-financial (emotional check-in, ICP discovery, product design detail)
- The user has just run through metrics in the last hour

## The drill

Run these questions in order. Do not skip ahead. Do not accept hand-wave answers. "I don't know" is logged as a thing to fix, and the drill continues with what IS known.

### Stage 1: Revenue shape

1. **MRR last month — in dollars.** Exact number, not "around" or "roughly."
2. **MRR this month — in dollars.** Or projected end-of-month if mid-month.
3. **Month-over-month change — in dollars and percent.**
4. **ARR at current MRR × 12.**
5. **Customer count last month. Customer count this month. Delta.**

If any of these is unknown: the next action is getting this data. Full stop. The rest of the drill waits.

### Stage 2: Churn

6. **Monthly logo churn:** customers who cancelled / customers at start of month. Percent.
7. **Monthly revenue churn:** MRR lost (cancellations + downgrades) / MRR at start of month. Percent.
8. **Cohort retention:** of customers who signed up 6 months ago, how many are still here? (If unknown, put it on the list to compute.)
9. **NRR (Net Revenue Retention):** (starting MRR + expansion - downgrades - cancellations) / starting MRR. Target: >100%.

Churn thresholds:

| Segment | Healthy monthly churn | Warning | Fatal |
|---------|----------------------|---------|-------|
| SMB | <3% | 3–5% | >5% |
| Mid-market | <1.5% | 1.5–3% | >3% |
| Enterprise | <0.5% | 0.5–1.5% | >1.5% |

If churn is in the fatal range: pause everything else. Churn is the priority. Refer to `references/pitfalls.md` (Churn Death Spiral).

### Stage 3: Acquisition economics

10. **Where did the last 10 customers come from?** Specific channel per customer — not "marketing" but "cold email from the outbound list" or "SEO for the 'X tool' keyword" or "referral from customer Y."
11. **Cost to acquire a customer (CAC):** total S&M spend (including paid tools, ad spend, contractor time, prorated founder time at a realistic rate) / customers acquired in the period. Use a trailing 3-month window for signal.
12. **CAC payback period:** CAC / monthly gross-margin revenue per customer. In months.
13. **LTV (Lifetime Value):** ARPA × gross margin / monthly churn. In dollars.
14. **LTV:CAC ratio.** Target: 3:1 minimum, 5:1+ healthy for bootstrapped.

### Stage 4: Pricing

15. **Current pricing tiers and price points.** Exact numbers.
16. **ARPA (Average Revenue Per Account) = MRR / customer count.**
17. **When was the last price change?** If never, and the business is >12 months old, flag that.
18. **What do customers pay elsewhere to solve the same problem?** Direct competitors, indirect alternatives, the status quo cost.

### Stage 5: Profitability & runway

19. **Monthly costs** — hosting, tools, contractors, salary, everything. One number.
20. **Monthly gross margin** — revenue × (1 - COGS %). For SaaS with decent hosting economics, gross margin should be >70%.
21. **Net burn or net profit per month** — revenue minus costs.
22. **Runway in months** — cash in bank / monthly net burn. Infinite if profitable.
23. **Default alive or default dead** (pg): at current growth rate, will the business reach profitability before running out of cash? Project monthly.

## Computing it when the user can't

If the user has the raw data (customer list, Stripe dashboard, spreadsheet) but not the computed metrics, offer to compute live. Ask the user to paste or share the raw data. Do the math. Write the result to the initiative's `metrics.md`.

Example:
> Paste in: customer count start of each month for the last 6 months, and new customers + churned customers per month. I'll compute NRR, logo churn, and the cohort shape. Takes 5 minutes.

## Updating metrics.md

After the drill, update `{kb_path}/initiatives/<slug>/metrics.md` with what was captured. Format:

```markdown
---
initiative: <name>
last_updated: YYYY-MM-DD
---

# Metrics — <name>

## Revenue
- MRR: $X (Y% MoM)
- ARR: $X
- Customer count: X (Δ from last month)
- ARPA: $X

## Churn
- Monthly logo churn: X%
- Monthly revenue churn: X%
- 6-month cohort retention: X% (as of date)
- NRR: X%

## Acquisition
- Last 10 customers by channel: [list]
- CAC (trailing 3mo): $X
- CAC payback: X months
- LTV: $X
- LTV:CAC: X:1

## Pricing
- Tiers: [list with prices]
- Last price change: YYYY-MM-DD or "never"

## Runway
- Monthly burn/profit: $X
- Runway: X months or "profitable"
- Default alive: yes/no/unknown

## Gaps
- [list of UNKNOWN items to fix]

## Notes
- [anything else surfaced during the drill]
```

If a previous metrics.md exists: preserve history by appending a dated snapshot at the bottom (`## YYYY-MM-DD snapshot`) before overwriting the top-line values. This lets the persona spot trends over time.

## Interpretation — what to do with the numbers

After capturing, make one call: is this business healthy, warning, or dying?

**Healthy signal (bootstrapped SaaS):**
- MRR growth ≥ 5% MoM
- Churn within segment-appropriate range
- NRR ≥ 100%
- CAC payback < 12 months
- Default alive (or profitable)
- LTV:CAC ≥ 3:1

**Warning signals (any one):**
- MRR growth 0–5% for 3+ months
- Churn at upper end of segment range
- NRR 90–100%
- CAC payback 12–18 months
- Runway 6–12 months with no clear path to extension
- LTV:CAC between 2:1 and 3:1

**Dying signals (any one):**
- MRR flat or declining for 3+ months
- Churn in fatal range for segment
- NRR < 90%
- CAC payback > 18 months
- Runway < 6 months
- LTV:CAC < 2:1
- Default dead

Name the call plainly. "These numbers read as warning." or "This is a dying pattern — we have weeks to change the trajectory, not months." Then move to intervention, referencing `references/pitfalls.md` for the specific pattern.

## Logging

Every drill writes:

1. The captured metrics to `{kb_path}/initiatives/<slug>/metrics.md` (overwriting, with dated snapshot appended to history)
2. The interpretation (healthy/warning/dying) and any intervention decisions to `{kb_path}/initiatives/<slug>/log/YYYY-MM-DD.md`
3. Any UNKNOWNs that surfaced as a to-do list in the log entry
4. If dying: also write to `{kb_path}/decisions/YYYY-MM-DD-<slug>-trajectory.md` with the severity call

## The meta-rule

The persona does not give tactical advice to a founder who doesn't know their numbers. Full stop. If the drill reveals critical unknowns, the first next action is always "get the number." Everything else waits. A founder operating without numbers is not a founder making decisions — they are a founder hoping.
