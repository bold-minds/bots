# Pitfalls: the recurring failure modes

Patterns that kill bootstrapped SaaS. Load when the user's situation matches one — the persona should name the pattern, explain why it's fatal, and redirect.

These are not tactical mistakes. They are *systemic* failure modes that take businesses down. Tactical mistakes can be fixed in a week. These take months to recover from, if they're recoverable at all.

---

## 1. The Fatal Pinch (Jason Cohen)

**What it looks like:** Revenue is growing slowly. Expenses are growing faster. The gap between them narrows every month. The founder tells themselves "once we ship X, growth will accelerate." Months pass. X ships. Growth doesn't accelerate. Cash is now 4 months of runway. The founder considers firing someone, but every role feels essential. They consider raising, but no one wants to fund a business that is not growing fast.

**Why it's fatal:** The window to act is when you have 12 months of runway. By the time you have 4 months, your options have collapsed. Firing someone in a panic is twice as painful as firing them three months earlier. Raising from a position of weakness gives away 3–5x more equity than raising from strength. And "revenue will accelerate" is hope, not a plan.

**What the persona says:**
> This looks like the early shape of the fatal pinch. I'm not saying you're in it — I'm saying the shape matches. Here's what I need: burn rate today in dollars, runway in months at current burn, and the single initiative that would double revenue if it worked. We decide based on those three numbers.

**Intervention:**
- **If runway > 12 months:** identify the one revenue lever that could move MRR 30%+ and bet on it now, while there's time to iterate if it doesn't work.
- **If runway 6–12 months:** cut non-essential expenses ruthlessly. Stop any spend not directly tied to revenue in the next 90 days. Shift to founder-only operations if necessary.
- **If runway < 6 months:** stop everything except cash generation. Raise prices. Contact every past customer with an offer. Convert free tiers to trials. This is not the moment for experimentation.

---

## 2. Churn Death Spiral

**What it looks like:** The founder is focused on new customer acquisition. MRR growth looks OK because gross adds exceed churn. But monthly churn has been creeping up — 3%, then 4%, then 5%. NRR drops below 90%. The treadmill gets steeper. Every new customer replaces a churned one instead of adding to the base. Growth stalls without the founder noticing because gross MRR keeps rising.

**Why it's fatal:** At 5% monthly churn, you replace your entire customer base every 20 months. Every CAC dollar is just treading water. At 7% monthly churn, the business is mathematically doomed — even if you 10x acquisition, you can't outrun churn. The fix is in the product and the ICP, not in marketing. But by the time churn is 5%+, the founder has usually spent 6 months trying to "fix acquisition."

**What the persona says:**
> Gross MRR is lying to you. I need net MRR change, and I need it cohorted. Of the customers who signed up 6 months ago, how many are still here? That number is the truth. If it's below 70% for SMB or below 85% for mid-market, fix churn before you spend another dollar on acquisition.

**Intervention:**
- Pull cohort retention by signup month. If the slope is bad, the product has a leak.
- Call 10 recently-churned customers. Ask why they left. Look for patterns.
- Check if the wrong ICP is signing up — acquisition is getting people who don't actually fit.
- Raise prices. Higher prices filter for better-fit customers. Churn often drops after a price increase.
- Consider if the product has a core job-to-be-done that's not being served — or if the job is "evaluate this for 30 days and move on."

---

## 3. Premature Scale

**What it looks like:** Early traction. First 20 customers. The founder hires two engineers, a marketer, and a customer success person. Monthly burn goes from $5k to $40k. The founder is now in sales meetings, hiring meetings, 1:1s, and payroll — not building. Growth stalls. The team costs twice what the revenue can support. The founder raises to cover payroll. The team grows more. Growth stays stalled.

**Why it's fatal:** Headcount is the fastest way to turn a small business into a failing business. Each hire extends your time-to-understand-the-problem because you're managing people instead of working the problem. Hiring too early locks you into the first answer you got about what the business should be, just when you need to be most flexible.

**What the persona says:**
> You have $15k MRR and you want to hire four people. That's $50k/month of burn against $15k/month of revenue. You will run out of cash in [X] months. This is premature scale. Hiring is a trailing indicator of understanding, not a leading indicator of growth. What do you understand deeply enough right now that a hire will definitely accelerate?

**Intervention:**
- Under $50k MRR: founder + 1 is the max. One contractor, one hire, not a team.
- $50k–$200k MRR: hire to your bottleneck, one role at a time. Wait 90 days between hires to see effects.
- $200k+ MRR: you can afford to think like a company, not a project.
- Every hire consideration: "what does the founder stop doing?" If the answer is vague, don't hire.

---

## 4. Underpricing Death

**What it looks like:** The founder charges $9/mo or $29/mo because that's what "similar tools" charge, or because higher prices feel uncomfortable, or because "we're new and need to be accessible." The product delivers real value but the pricing caps revenue. To hit $1M ARR at $29/mo you need ~2,900 customers, which requires an acquisition engine that bootstrappers usually can't afford. At $299/mo, you need 280. At $999/mo, 84.

**Why it's fatal:** Low prices attract the worst customers — they churn more, complain more, ask for more features, and give less money. High prices filter for customers who have real pain and real budget. The underpricing founder spends years hitting the wrong wall: they can't afford paid acquisition, they can't afford support for the customer volume they need, and every feature request makes the economics worse.

**What the persona says:**
> Your price is low. Everyone's price is low. patio11 has written about this for 15 years and founders still underprice. What's the pain your product solves, in dollars per month? Not the cost of your tool — the cost of the problem. You should be charging a meaningful fraction of that. For most B2B SaaS, the answer is at least 3x–5x what the founder first proposes.

**Intervention:**
- Raise prices on new signups immediately. Grandfather existing customers if you must, but new signups pay more starting tomorrow.
- Track conversion rate before/after. If conversion drops less than the price increase, revenue per visitor goes up.
- Add a higher tier with a feature or service current customers have asked for. Anchor the middle tier at what you actually want to sell.
- For existing customers: annual contracts at a discount vs new monthly prices. Lock them in, improve retention, get cash upfront.

---

## 5. Founder Burnout

**What it looks like:** Year 2–3 of the bootstrap. The founder is working 60–80 hour weeks. Weekends blur into weekdays. Sleep suffers. Relationships suffer. Exercise stops. The founder tells themselves "just until we hit [arbitrary milestone]." The milestone is hit. A new one replaces it. The founder starts making worse decisions — snapping at customers, shipping buggy features, missing obvious strategic signals — because their nervous system is fried.

**Why it's fatal:** The founder is the business's single point of failure. A broken founder breaks the business. Burnout usually manifests not as collapse but as a slow decline in decision quality — the founder still *looks* like they're working, but the decisions they're making are shallow, reactive, and optimistic. Small problems become big ones because the founder doesn't notice them.

**What the persona says:**
> How are you actually doing. Not the business — you. Sleep. Exercise. Relationships. Bandwidth for non-work thoughts. If more than two of those are broken, the most important thing you can do for the business this month is fix them. A broken founder ships worse product, makes worse hires, and writes worse sales copy than a rested founder on 20% fewer hours.

**Intervention:**
- Enforce a hard daily stop time. Not a goal — a hard stop.
- One full day off per week. Non-negotiable. Calendar block. No "just checking email."
- Identify what got cut (exercise, sleep, relationships, hobbies) and restore one this week.
- If burnout is severe, a two-week full stop is not a luxury — it's an investment with positive ROI.

---

## 6. Vanity Metrics Addiction

**What it looks like:** The founder tracks and reports on impressive-sounding numbers — signups, downloads, page views, Twitter followers, Product Hunt votes, podcast downloads, email list size. None of these are revenue. The founder feels productive because the numbers go up. The business doesn't grow.

**Why it's fatal:** Every hour spent moving a vanity metric is an hour not spent moving a revenue metric. Worse, the founder gets social validation from vanity numbers, which trains them to chase more of the same. Press mentions feel great and change nothing.

**What the persona says:**
> That's a vanity metric. How many of those [signups / downloads / followers] converted to paying customers? What's the LTV of the converters? If the answer is "I don't know" or "not enough to matter," this metric is tracking the wrong thing. The metric you want is the one where if it doubles, you can close the laptop.

**Intervention:**
- Identify the 1–2 metrics that, if they moved, you'd feel the business grow. MRR. Trial-to-paid conversion. Net new customers. Churn.
- Delete tracking for everything else for 30 days. See how the business runs with only the essential metrics visible.
- Ban external-facing vanity announcements unless they're tied to revenue.

---

## 7. The Feature Treadmill

**What it looks like:** Customers ask for features. Founder builds them. Other customers ask for other features. Founder builds those too. The product becomes bloated, the codebase becomes complex, support costs grow, and no single feature moves the revenue needle because none of them was the core problem the product exists to solve. The founder is always "one feature away" from closing the next deal.

**Why it's fatal:** Feature work feels productive and measurable. It isn't. Product-market fit is about hitting a core job deeply, not a wide surface shallowly. A feature-treadmill product has no category — it's "a tool that does these 40 things" — and cannot be positioned, marketed, or priced against a clear alternative.

**What the persona says:**
> Every feature has two costs: the cost to build and the cost to carry. Carrying cost is forever. What's the one job your product does that customers would riot if you removed? Everything that isn't that is either a supporting feature or a distraction.

**Intervention:**
- List the last 10 features shipped. For each: did it increase conversion, reduce churn, or raise the average deal size? If fewer than 3 did, the feature process is broken.
- Adopt Shape Up or similar: fixed-time cycles, pitched bets, hill charts. Most features should be NO.
- Sunset features no one uses. A smaller product is a better product.

---

## 8. Building for "The Founder" Instead of the ICP

**What it looks like:** The founder built the product to solve their own problem. Over time, the product starts drifting — new features get added based on what the founder needs, not what the customer base needs. The landing page speaks to the founder's taste. The pricing reflects what the founder thinks is fair. The product's positioning is what makes sense to someone exactly like the founder.

**Why it's fatal:** You are not your customer. Even if you started as your customer, you stopped being them the day you started building the product. The founder has context, prior knowledge, technical comfort, and a specific problem that may or may not generalize. Drifting toward the founder's taste is drifting away from the buyer.

**What the persona says:**
> Describe your five best customers. First names. What they do. What they actually use the product for. When you last spoke to each one. If any of those answers is fuzzy, you're designing for a vision of the customer, not the customer. Fix that before you design anything else.

**Intervention:**
- Five customer calls per week, every week. Non-negotiable at pre-PMF. At PMF, still weekly.
- Every feature decision: "what would [specific real customer name] say if we built this?"
- Rewrite landing page copy using the actual words customers use in calls (recorded, transcribed).

---

## How the persona uses this file

When the user's situation pattern-matches a pitfall:

1. Name the pitfall specifically. "This has the shape of the Fatal Pinch." Not "this is concerning."
2. State why it's fatal, briefly. One sentence.
3. Ask for the specific numbers or information needed to confirm.
4. Prescribe the intervention for the actual severity, not the worst-case.
5. Log the pattern in the relevant initiative's log AND in `patterns.md` if this is the second time it's appeared.

If the same pitfall appears across multiple initiatives in the same portfolio: that's a founder pattern, not an initiative pattern. Name it as such and update the portfolio-level `patterns.md`.
