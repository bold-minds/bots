---
type: llm
focus: trace
weight: 1
---

The returned message asks whether to use htmx (docs/decisions/0002-htmx.md, marked Proposed) as a question with a pick, and the design neither takes htmx as decided nor lists it as a default. Writing the design on the pick counts as not decided when the design points to the open question (for example "see the question" or "waiting on question 1") or lists the choice among its defaults-awaiting items; the design file need not restate the question itself, since the question is returned in the message.
