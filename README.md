# Bots

Claude Code plugins by [Bold Minds](https://github.com/bold-minds).

## Plugins

### Advice

Long-running advisor sessions, one per **focus** — an area of your life you actually want help with. Each focus has its own persona, its own reading list, and its own knowledge base, and none of your data lives in this repo.

These advise and prepare. They never act on your behalf: no publishing, no transfers, no filing, no sending. Your hands stay on every button.

| Command | Scope |
|---|---|
| `/life` | Daily planning, check-ins, commitments, weekly reflection, the gap between stated intent and actual behavior. |
| `/money` | Ledger, plans, tax math, simulator runs, documents prepared for humans. |
| `/story` | True stories about your own life, any format, any destination. Drafts from the lived record, genre tests, the backlog. |
| `/software` | Release scope, architectural decisions, debt, the ship date. |
| `/business` | Portfolio-level operating conversation, unit economics, ruthless scope. |

A focus is three things you supply and one thing the plugin provides: a **persona** (the name and voice that answers), a **bookshelf** (the canon it reasons from), a **knowledge base** (the data it reads and writes), and a shared **engine**.

Full documentation: [`plugins/advice/README.md`](plugins/advice/README.md).

#### Skills

Invoked by a focus, and usable on their own.

| Skill | Fires when |
|---|---|
| `calibrate` | The knowledge base isn't set up, or the calibration stopped fitting |
| `aim` | Creating or revising a goal, growth or constraint |
| `reflect` | Weekly review, or 7+ days since the last one |
| `confront` | A commitment is being rationalized away in real time |
| `drill` | Growth, retention, pricing, or revenue mentioned without a number |

#### Calibration

First run of any focus goes through `calibrate`. For `/life` that means Enneagram discovery — a 5-question quick pass or a 12-15 question full assessment — then six dials that set how the system talks to you.

| Dial | What it controls |
|------|-----------------|
| Accountability intensity (1-5) | How hard it pushes when you drift |
| Truth delivery (1-5) | How bluntly gaps between intention and action get surfaced |
| Motivation anchor | What makes you follow through (People, Stakes, Identity, Progress, Meaning) |
| Reflection depth (1-3) | Scorecard only, patterns + planning, or full depth with WOOP |
| Structure preference | Scheduled, rhythmic, or threshold-based commitments |
| Balance challenge | Whether your challenge is starting, sustaining, or balancing |

Three ways in: **full setup** (~20 min), **quick start** (~5 min), or **skip everything** and start tracking, letting it learn about you over time.

#### Bookshelves ship empty

Whose thinking you want in your ear is too personal to guess at, so no canon is shipped. Put your own sources in `{kb_path}/bookshelf/<focus>/` and they load automatically. A focus with an empty shelf works fine — it reasons from its own rules and says so if you ask where a recommendation came from.

The plugin README carries starting recommendations per focus.

#### Your data stays yours

Everything lives in a knowledge base directory you choose during setup, outside this repo. Nothing is sent anywhere.

```
your-kb/                  # shared by /life, /money, /story, /software
  profile.md              # Type, calibration settings, life areas
  patterns.md             # Rationalization patterns, seeded and observed
  goals/                  # One file per life area
  plans/                  # Plans of record
  log/                    # /life daily logs (YYYY-MM-DD.md)
  log/weekly/             # Weekly reflections
  money/                  # Ledger, watch-list, decisions, process, daily log
  stories/                # Charter, backlog, published, process, daily log
  builds/<project>/       # Scope, decisions, debt, daily log
  bookshelf/<focus>/      # Your canon, per focus

business-kb/              # /business may use its own knowledge base
  portfolio.md            # Who you are, principles, scar tissue
  initiatives/<name>/     # Product, metrics, funnel, constraints, commitments, log
  decisions/              # Major decisions
  log/weekly/             # Portfolio weeklies
  bookshelf/business/     # Your canon + the metrics reference calibrate drafts
```

## Install

```bash
claude plugin marketplace add bold-minds/bots
claude plugin install advice@bots
```

Then create a config file for the focus you want and invoke it. Point `/life`, `/money`, `/story`, and `/software` at the same knowledge base; `/business` may use its own. A focus can read another's knowledge base through that focus's config file — reads cross knowledge bases, writes never do.

```markdown
<!-- .claude/life.local.md -->
---
kb_path: /absolute/path/to/your/knowledge-base
persona: Ada
---
```

```
/life
```

## Requirements

- [Claude Code](https://claude.ai/code) CLI, desktop app, or IDE extension

## License

[MIT](LICENSE)
