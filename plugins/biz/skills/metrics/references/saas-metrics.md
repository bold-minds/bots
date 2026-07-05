# SaaS metrics reference

Definitions, formulas, healthy ranges, and warning thresholds for the metrics most relevant to bootstrapped SaaS. Consulted during the drill in `SKILL.md` and when interpreting numbers.

## Revenue metrics

### MRR — Monthly Recurring Revenue
Sum of all recurring subscription revenue, normalized to monthly. Exclude: one-time charges, setup fees, and services revenue. Include: prorated annual contracts.

**Formula:** sum of (monthly contract value) across all active subscriptions.

**What to watch:** month-over-month change in dollars (not percent alone — percents lie at small numbers). A jump from $2,000 to $2,200 is 10% growth but only $200; a jump from $20,000 to $22,000 is the same 10% but $2,000 of real cash.

### ARR — Annual Recurring Revenue
MRR × 12. Mostly a signaling number — the real operating metric is MRR. Use ARR when talking to outsiders or measuring against annual goals.

### ARPA — Average Revenue Per Account
MRR / number of paying customers. Trend over time matters more than absolute value.

**Healthy trend:** ARPA rising as you move upmarket or add tiers. Flat ARPA for 12+ months means pricing is stuck.

### Revenue growth rate
(This month MRR - last month MRR) / last month MRR. Report monthly for early-stage; quarterly once >$50k MRR for signal.

**Healthy ranges:**
- Pre-PMF: highly variable, 10-30% MoM at small numbers
- Early PMF: 10-15% MoM
- Scaling: 5-10% MoM
- Mature: 3-5% MoM

## Retention metrics

### Logo churn (customer churn)
Customers who cancelled in the period / customers at start of period.

### Revenue churn (gross revenue churn, GRR)
MRR lost (cancellations + downgrades) / MRR at start of period.

Revenue churn can diverge from logo churn. Losing one large customer and gaining many small ones = high logo gain but high revenue churn. Watch both.

### NRR — Net Revenue Retention
(Starting MRR + expansion revenue from cohort - downgrades - cancellations) / starting MRR.

**Healthy ranges:**
- SMB: 90-105% (hard to get expansion in SMB)
- Mid-market: 105-120%
- Enterprise: 110-140%+

**NRR > 100% means:** existing customers are paying more over time than customers you lose. Your business grows even with zero new customers. This is the best metric in SaaS.

**NRR < 90% means:** you have a leaky bucket. Fix before scaling acquisition.

### Cohort retention
Of customers who signed up in month X, what percent are still paying in month X+N.

Most useful: the retention curve. Steep initial drop (first 30-90 days) means onboarding/activation is broken. Slow persistent decline means the product isn't critical enough. A flattening curve means you've found the "sticky" core of your ICP.

### Customer lifetime
1 / monthly churn rate = average months a customer stays. At 3% monthly churn, average lifetime is ~33 months.

## Acquisition metrics

### CAC — Customer Acquisition Cost
Total sales + marketing spend in a period / new customers acquired in that period.

What to include in S&M spend:
- Ad spend (paid acquisition, including Twitter/LinkedIn/Google/Facebook)
- Marketing tools (CRM, email platform, analytics if purely for marketing)
- Contractor fees (SEO, content, ads management)
- Prorated founder time IF the founder spends significant time on sales/marketing (use $100-200/hr as a realistic opportunity cost)
- Conference/event costs if used for acquisition

What NOT to include:
- Product development
- Customer success for existing customers (that's retention, not acquisition)
- General admin

**Windowing:** use a trailing 3-month window. Smaller windows are too noisy for bootstrapped volumes.

### CAC payback period
CAC / (ARPA × gross margin).

**Formula expanded:** how many months of gross-margin revenue does it take to recover the acquisition cost?

**Healthy ranges:**
- Excellent: < 6 months
- Good: 6-12 months
- Warning: 12-18 months
- Fatal for bootstrap: > 18 months

The shorter the payback, the faster you can redeploy acquisition capital. Bootstrap economics require short paybacks — you don't have VC runway to wait.

### LTV — Lifetime Value
ARPA × gross margin / monthly churn.

**Simplified:** how much gross-margin revenue will an average customer generate over their lifetime?

This formula assumes stable churn and no expansion revenue. If you have meaningful expansion (NRR > 100%), LTV can be much higher — but the simple formula is still the right floor.

### LTV:CAC ratio
LTV / CAC.

**Healthy ranges:**
- Below 1:1 — you're losing money on every acquisition
- 1:1 to 3:1 — treading water; scaling will make it worse
- 3:1 — minimum viable for SaaS
- 5:1 to 10:1 — healthy bootstrap
- 10:1+ — either excellent unit economics or you're under-investing in acquisition

**A 20:1 ratio isn't an unmixed good.** It often means the business could grow faster by spending more on acquisition. Bootstrap founders sometimes optimize too hard for efficiency and leave growth on the table.

## Profitability and capital efficiency

### Gross margin
(Revenue - COGS) / Revenue.

COGS for SaaS = hosting + third-party services tied to delivery (e.g., Stripe fees, API costs per user, email sending costs) + customer support labor tied to delivery.

**Healthy ranges:**
- SaaS: > 70% is the floor; 75-85% is typical; 85%+ is excellent
- < 60%: you're running a services business in disguise, not SaaS

### Net burn / Net profit
Monthly revenue - monthly costs (all-in, including founder draws).

Positive = profit. Negative = burn.

### Runway
Cash in bank / monthly net burn. In months.

Bootstrappers should stay default alive — i.e., runway should be infinite (profitable) OR reaching infinite (trajectory toward profitability before cash runs out).

### Default alive vs default dead (pg)
Project forward. At current growth rate and current expense structure, will the business reach profitability before cash runs out?

- **Default alive:** yes → keep executing, spend on growth if good ROI
- **Default dead:** no → act NOW to either raise revenue or cut costs. You have months, not years.

### Rule of 40
(YoY growth rate %) + (profit margin %) ≥ 40.

For bootstrap SaaS at scale, 40+ is the standard. Below 40 is a warning — either grow faster or get more profitable.

### Magic number
(Net new ARR in quarter) / (S&M spend in prior quarter).

- **> 1.5:** scale up aggressively; spend is highly efficient
- **0.75 - 1.5:** scale up cautiously
- **0.5 - 0.75:** hold and optimize; scale only on validated channels
- **< 0.5:** scale down; S&M spend is inefficient

### Burn Multiple (David Sacks)
Net burn / net new ARR.

- < 1: excellent capital efficiency
- 1-2: OK
- 2-3: caution
- \> 3: bad — revisit spend and go-to-market

Less relevant for profitable bootstrap, more relevant when briefly deficit-financing a growth push.

### Quick Ratio
(New MRR + expansion MRR) / (churned MRR + contraction MRR).

Measures if you're growing net of losses.

- \> 4: very healthy
- 2-4: OK
- 1-2: warning
- \< 1: you're shrinking

## Conversion metrics

### Trial-to-paid conversion rate
Paying customers / trial signups, per cohort.

**Healthy ranges (broad):**
- Freemium to paid: 2-5%
- Opt-in free trial: 15-25%
- Opt-out (credit card required) free trial: 40-60%

### Activation rate
Users who reach the "aha moment" / total signups.

You have to define the aha moment. It's the action that correlates with retention at 30/60/90 days. Find it with cohort analysis. Once defined, optimize relentlessly.

### Lead-to-customer
For outbound-driven businesses: customers / qualified leads.

Useful only if you have a defined lead qualification step. For inbound-first businesses, track signup-to-paid instead.

## Segment-specific notes

### SMB (small & medium businesses, 1-50 employees)
- Higher churn (3-5%/month is normal)
- Lower ARPA ($20-200/mo)
- Short sales cycles (days to weeks)
- Price sensitivity matters
- Referrals drive growth more than ads

### Mid-market (50-500 employees)
- Medium churn (1-3%/month)
- Higher ARPA ($200-2,000/mo)
- Sales cycles of weeks to months
- Security and compliance start to matter
- Annual contracts become common

### Enterprise (500+ employees)
- Low churn (< 1%/month)
- High ARPA ($2,000+/mo, often much more)
- Sales cycles of months to year+
- Procurement, SOC2, custom contracts required
- Mostly not a bootstrap motion — enterprise sales need capital for the long sales cycle

Bootstrappers typically live in SMB or lower mid-market by default. Moving upmarket usually requires hiring enterprise sales talent and surviving 6-12 month sales cycles — hard to do on cash flow alone.

## Pricing reference

### Anchoring
Customers evaluate your price against something. Usually the first price they see. If you show $29 first, $99 feels expensive. If you show $999 first, $99 feels cheap. Set your price anchor deliberately.

### Price sensitivity rule of thumb
Cut the price in half, sales don't double. Double the price, sales don't halve. Most SaaS pricing is less elastic than founders fear.

### The patio11 principle
Charge more. Most bootstrapped founders underprice by 2-5x. Test: raise prices on new signups by 50%. If conversion drops less than 50%, revenue per visitor goes up.

### Price test methodology
- Change prices on new signups only
- Keep existing customers at their current price (or grandfather with opt-out)
- Measure trial-to-paid conversion before and after
- Give it 60 days minimum for signal
- Compare: revenue per trial, not just conversion rate

### Annual vs monthly
- Annual discount: 15-20% is standard
- Annual improves cash flow (upfront payment) and dramatically improves retention (locked in for 12 months)
- Default to monthly at launch; add annual once you have enough customers to offer it

## What the persona does with all this

The persona uses this reference to:

1. Know the formula when computing from raw data
2. Know the healthy/warning/fatal thresholds when interpreting a number
3. Cite the right threshold in push-back ("churn at 6%/month is in the fatal range for SMB")
4. Name the metric correctly (NRR vs GRR matters)
5. Refuse vague claims — if the user says "retention is good," ask "what's NRR, as a number."

Memorize the thresholds. Apply them consistently. A number is only meaningful in context, and this file IS the context.
