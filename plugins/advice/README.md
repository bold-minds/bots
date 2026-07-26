# advice

Long-running advisor sessions for Claude Code, one per **focus** — an area of your life you actually want help with. Each focus has its own persona, its own reading list, and its own knowledge base, and none of your data lives in this repo.

These advise and prepare. They never act on your behalf: no publishing, no transfers, no filing, no sending. Your hands stay on every button. That line is what makes this an advice plugin rather than a task plugin, and it's enforced in the shared engine rather than left to each focus to remember.

## The idea

A focus is three things you supply and one thing the plugin provides.

| Part | You supply | Where |
|---|---|---|
| **Persona** | The name and voice that answers | `.claude/<focus>.local.md` → `persona` |
| **Bookshelf** | The canon it reasons from | `{kb_path}/bookshelf/<focus>/` |
| **Knowledge base** | The data it reads and writes | `.claude/<focus>.local.md` → `kb_path` |
| **Engine** | — | `shared/focus-template.md` |

Nothing here assumes a particular life, business, or set of sources.

## The focuses

| Command | Scope |
|---|---|
| `/life` | Daily planning, check-ins, commitments, weekly reflection, the gap between stated intent and actual behavior. |
| `/money` | Ledger, plans, tax math, simulator runs, documents prepared for humans. |
| `/story` | True stories about your own life, any format, any destination. Drafts from the lived record, genre tests, the backlog. |
| `/software` | Release scope, architectural decisions, debt, the ship date. |
| `/business` | Portfolio-level operating conversation, unit economics, ruthless scope. |

## The skills

Invoked by a focus, and usable on their own.

| Skill | Fires when |
|---|---|
| `calibrate-profile` | The knowledge base isn't set up, or the calibration stopped fitting |
| `set-goals` | Creating or revising a goal, growth or constraint |
| `review-week` | Weekly review, or 7+ days since the last one |
| `hold-commitments` | A commitment is being rationalized away in real time |
| `demand-numbers` | Growth, retention, pricing, or revenue mentioned without a number |

## Setup

Install the plugin, then create a config file per focus you want, in the project you'll use it from:

```markdown
<!-- .claude/life.local.md -->
---
kb_path: /absolute/path/to/your/knowledge-base
persona: Ada
---
```

`kb_path` is required. `persona` falls back to a default.

All of `/life`, `/money`, `/story`, and `/software` should point at the same knowledge base. `/business` may use its own — other focuses can still read it by resolving `.claude/business.local.md`. No focus ever writes outside its own territory, whichever knowledge base it's reading.

Then invoke it. If the knowledge base is empty, `calibrate-profile` runs first — personality discovery, six calibration dimensions, life areas, and a profile it drafts for you to review and save.

## Bookshelves ship empty

A bookshelf is whose thinking you want in your ear. Which frameworks, which authors, whose scar tissue.

That's too personal to guess at, so nothing is shipped. Put your own sources in `{kb_path}/bookshelf/<focus>/` — one directory per focus name — and they load automatically. A focus with an empty shelf works fine; it reasons from its own rules and tells you so if you ask where a recommendation came from.

**Recommendations, if you want somewhere to start:**

- **`life/`** — whoever has actually changed how you behave. If a framework is already in your head from a seminar, a book, or a therapist, write it down here so it can be invoked by name instead of re-explained.
- **`story/`** — the highest-rated TED talks are a good spine: they are short, personal, and structurally ruthless. Add anything on storytelling craft, plus two or three pieces you'd point at and say "like that." Tone prototypes teach more than principles.
- **`software/`** — writing on scope discipline and the economics of rewrites. Your own post-mortems earn their place fastest: specific, yours, and the ones you'll re-read.
- **`money/`** — the bookkeeping method you follow and the tax rules where you live. Most of what matters here is your data, not doctrine.
- **`business/`** — the operators whose economics resemble yours. A bakery and a bootstrapped SaaS should not share a shelf.

## Your data stays yours

The knowledge base is a directory you own, outside this repo. Every focus reads and writes only there. Nothing personal — no sources, no frameworks, no notes — needs to end up in a public repo, and there is no reason to fork this plugin to personalize it.

## What this is not

Personal growth and accountability tooling. **Not therapy, medical advice, or crisis support.** It cannot diagnose, treat, or replace professional help. If you're in crisis, contact a qualified professional — in the US, the 988 Suicide & Crisis Lifeline takes calls and texts at 988.

## All of it is yours to change

Nothing here resists being edited. A focus states its opinion once and then does what you asked. If a rule is wrong for you, change it — that includes the rules in this repo.

The only rules held firm are the ones protecting you from the assistant — don't invent facts, don't guess a number, don't claim something is done without checking — plus the safety gate that runs before first setup.

## License

MIT.
