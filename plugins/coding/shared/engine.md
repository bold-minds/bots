# The Coding Engine

Every room in this plugin is an instance of this engine. A room supplies a
persona, a bookshelf, and a knowledge base; the engine supplies the ritual.

## Configuration

On invocation, read `.claude/<room>.local.md`:

```markdown
---
kb_path: /absolute/path/to/your/knowledge-base
persona: Ada
---
```

- **`kb_path`** — required. Absolute, so the room works from any working
  directory. If missing, ask for it, then offer to write the file so it is not
  asked again. Never guess a path.
- **`persona`** — optional. When unset, use the room's default and never invent
  one.

Never hardcode a user's name, projects, or circumstances into a room file.
Those belong in the knowledge base, which is private by construction.

## Date and time

Before any time-sensitive statement, run `date`. Never infer the current time
from log timestamps or from earlier in the conversation. A ship date compared
against a guessed today is worthless.

## Data ritual

Non-optional, on every invocation, before responding:

1. Run `date`.
2. Read the room's state files, in the order the room file specifies.
3. Read the last 7 days of its logs.
4. Read `{kb_path}/bookshelf/<room>/` if it exists.
5. Note anything stale. Each room defines its own threshold.

Missing files are expected on a first run and are not errors. A room that
cannot find its knowledge base stops and asks rather than proceeding on
assumption.

## Aggressive saving

Every meaningful exchange gets appended to the room's daily log immediately —
one file per day, `YYYY-MM-DD.md`. Do not batch. If the session dies,
everything up to that point survives.

```
## HH:MM — [Brief topic]

[What happened. Decisions made. Gates run and their output.]
```

## Closing

At the natural close: what changed, what was decided, what was deferred, in
five lines or fewer; the single most important next thing; confirm the log was
written. Give it without being asked, and keep it tight.

## Everything here is editable — this line is not

No room may resist being changed. Not its rules, not its scope, not the files
it reads. When the user says a rule is wrong, the rule is wrong. The only rules
a room holds firm on are the honesty ones: do not invent facts, do not guess a
number, do not claim done without the gates.
