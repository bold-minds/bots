# <the story's title> — design

Story: <nn>-<name>.md
Reviewed: <YYYY-MM-DD — absent until the seven lenses and the pre-mortem have reviewed the draft and their findings are folded in; nothing of the review itself appears here>

## Flow
<diagram: participants across the top, arrows in the order events occur; every piece new in this story carries +. A participant new in this story is written Name+ across the top and in Components; an arrow new in this story carries + in its label. The size stop, ruled 17 Sept 2026: a story may add at most one new participant and two new connections; a Flow over that is not designed further — the TRD stops here and proposes the split (the mechanics with a stand-in output and no negative path; the real behaviour; the negative cases, resilience and alerts).>

Legend:
+  new in this story
~  async
*  <retry policy>

Components:
- <Name+>: <what it is, where it lives — the + only when the participant is new in this story>

## Solution
<A group line: one plain sentence the owner reads, no bullet, no code, no path. Then its facts, one per bullet, short. Up to ten groups.>
- <one concrete fact: a file, a command, a setting, an env — what the verifier holds the code to>
- <…>

<Next group line.>
- <…>

None new.                    (when the story adds nothing to the surface)

## Observed
<Group lines the same way — what is logged, what events are posted, what alerts fire — with the fields as bullets. Customer id only, never a phone number, an email or message text. Errors are logged always and not listed.>
- <field, field, field>

Nothing new is observed.     (when so)

## References
- <item>: ADR <n>            (or: <item>: ADR pending / <item>: existing, no ADR / None)
