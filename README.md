# Bots

Claude Code plugins by [Bold Minds](https://github.com/bold-minds).

## Plugins

### Ladder

A personal growth companion that turns intentions into externally-bound commitments, tracks progress with honest data, and refuses to let rationalizations go unchallenged. Calibrated to your personality via the Enneagram.

#### What it does

- **Onboarding** — Discovers your Enneagram type (quick 5-question or full 12-15 question assessment), calibrates 7 dimensions of how the system communicates with you, and seeds personalized rationalization patterns it will watch for
- **Goal tracking** — 7-step goal creation process that pushes every commitment toward external structure. "If nobody will notice when it's broken, it's a wish, not a commitment."
- **Daily accountability** — Context-aware check-ins against your commitments. When you drift, the system engages at your calibrated intensity — from gentle observation to adversarial holdout
- **Weekly reflections** — Structured review with commitment scorecards, pattern analysis, and (at higher depth settings) harsh truth questions grounded in your own data
- **Coaching** — 9 topic areas drawing from 20+ published thought leaders (Brene Brown, James Clear, Viktor Frankl, Annie Duke, and more). Delivered in your preferred coaching style

#### The 7 calibration dials

During onboarding, Ladder sets these based on your Enneagram type. You adjust from there.

| Dial | What it controls |
|------|-----------------|
| Accountability intensity (1-5) | How hard the system pushes when you drift |
| Truth delivery (1-5) | How bluntly gaps between intention and action are surfaced |
| Motivation anchor | What makes you follow through (People, Stakes, Identity, Progress, Meaning) |
| Reflection depth (1-3) | Scorecard only, patterns + planning, or full depth with WOOP |
| Structure preference | Scheduled, rhythmic, or threshold-based commitments |
| Balance challenge | Whether your growth challenge is starting, sustaining, or balancing |
| Coaching style | Frameworks, questions, stories, or direct action |

#### Three ways to start

- **Full setup** (~20 min) — Personality discovery, calibration, life areas, full profile
- **Quick start** (~5 min) — Compressed assessment, batch defaults, fast profile
- **Just goals** — Skip everything. Start tracking. The system learns about you over time

### Install

```bash
claude plugin add bold-minds/bots
```

Then run:

```
/climb
```

#### What gets created

Ladder stores your data in a knowledge base directory you choose during setup:

```
your-kb/
  profile.md              # Your type, calibration settings, life areas
  patterns.md             # Rationalization patterns (seeded + observed)
  goals/                  # One file per life area
  log/                    # Daily logs (YYYY-MM-DD.md)
  log/weekly/             # Weekly reflections
  references/             # Enneagram profile, custom author references
```

All your data stays local. Nothing is sent anywhere.

#### Coach reference library

The coaching skill draws from 9 topic areas, each backed by a curated reference file of frameworks from published authors:

| Topic | Key authors |
|-------|------------|
| Self-awareness | Brene Brown, Mark Manson, Brianna Wiest, Eckhart Tolle, Mo Gawdat, Joe Dispenza, Kegan & Lahey |
| Decision-making | Annie Duke, Daniel Kahneman, Tim Ferriss, Morgan Housel |
| Courage & action | Ryan Holiday, Tim Ferriss, Mel Robbins, Annie Duke, Brene Brown, Mark Manson, Napoleon Hill, Krystal Zellmer |
| Growth & learning | Adam Grant, Tim Ferriss, James Clear, Ryan Holiday, Stephen Covey, Daniel Kahneman, Krystal Zellmer |
| Habits & systems | James Clear, Stephen Covey, Dave Ramsey, Ramit Sethi, Napoleon Hill, Joe Dispenza, Kimberly Zink |
| Relationships | Gary Chapman, Brene Brown, Dale Carnegie, Adam Grant, Stephen Covey |
| Resilience & meaning | Viktor Frankl, Ryan Holiday, Brene Brown, Mark Manson, Mo Gawdat, Kimberly Zink |
| Mindset & state | Joe Dispenza, Eckhart Tolle, Mel Robbins, Jen Sincero |
| Money & resources | Dave Ramsey, Ramit Sethi, Morgan Housel, Daniel Kahneman |

If you have favorite authors not in the library, the system can create custom reference files in your KB during onboarding.

## Requirements

- [Claude Code](https://claude.ai/code) CLI, desktop app, or IDE extension

## License

[MIT](LICENSE)
