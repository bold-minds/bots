# Biz

A bootstrapped SaaS CEO companion for Claude Code. Invoked with `/earn`, it brings the scar tissue, frameworks, and push-back of a repeat founder to every business conversation.

Biz is not a productivity tool. It is not a dashboard. It is a persona that refuses to let you skip the unit economics, underprice your product, build v2 before v1 ships, or raise money because "it's what founders do."

## What it does

- **Open-ended founder conversation.** Run `/earn`, talk about anything — a feature you're considering, a pricing change, a hire, a pivot urge, a bad week. The persona stays on across the whole session.
- **Onboarding by mining.** First run, you hand it URLs (your landing page, blog, Twitter, past decks) and local files (notes, strategy docs, spreadsheets). It extracts ICP, positioning, pricing, metrics, and recent decisions into a portfolio profile you review and edit.
- **Numbers first, always.** Every non-trivial conversation gets drilled to real numbers — MRR, churn, CAC payback, gross margin. "I don't know" is a trigger to go find out, not a final answer.
- **Framework-fluent push-back.** When you propose something that violates bootstrapped physics — spending without payback, building before distribution, raising for optics — the persona names the failure mode, cites the framework, and offers the alternative.
- **Aggressive logging.** Every meaningful exchange gets written to the relevant initiative's log. If the session dies, nothing is lost.

## Who it's for

Founders running (or starting) software products on revenue, not venture capital. Portfolio operators juggling multiple small bets. Anyone who has read Hormozi, Walling, 37signals, patio11, Cohen, Kahl — and wants that canon available as a decision-making companion.

## Not for

- VC-backed operators (the unit economics and shipping discipline don't match)
- Services businesses, agencies, or hardware (the channel and pricing advice won't fit)
- People looking for validation (the persona refuses to be a yes-man)

## Install

```bash
claude plugin add bold-minds/bots
```

Then:

```
/earn
```

## What gets created

Biz stores your data in a knowledge base directory you choose during setup:

```
your-kb/
  portfolio.md           # your CEO profile, scar tissue, principles
  patterns.md            # cross-initiative recurring patterns
  sources/               # cached URLs/files from onboarding
  initiatives/
    <name>/
      product.md         # what it is, ICP, JTBD
      positioning.md     # category, alternatives, value prop
      metrics.md         # MRR, churn, CAC, pricing
      funnel.md          # the ONE channel, status, next experiment
      constraints.md     # current bottleneck
      commitments.md     # business-scoped commitments
      log/
        YYYY-MM-DD.md    # daily log
        weekly/YYYY-Www.md
  decisions/             # major capital/hire/kill decisions, dated
```

You own these files. The persona reads them on every invocation and writes to logs aggressively. It does not silently edit your profile or initiative files — those are yours.

## Sub-skills

- `metrics` — the "what's the number?" drill. Pulled when you mention growth, churn, CAC, or pricing without real figures.

More coming in v1.1: `sprint` (weekly cadence), `roast` (adversarial pre-commitment review), `decide` (major decision framework).

## License

MIT. See [LICENSE](../../LICENSE) at the repo root.
