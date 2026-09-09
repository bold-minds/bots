# Coverage — <feature name>

Every rule the feature's binding spec and the owner's cross-cutting list carry, and the task that satisfies it. This table is what the owner reads to know nothing was dropped between the spec and the tasks; a rule with no task is a halt, not a row.

| Rule | In the owner's words (short) | Task | Where in the task |
|---|---|---|---|
| S<slice>.<n> | <the rule, trimmed> | <task directory name> | <Success / Failure / Structural / Not in this task, and which line> |
| X<n> | <the cross-cutting line> | <every task it applies to, or "answered in plan.md: <one line>"> | <where> |

## Deferred by the tasks

<Rules the spec carries that these tasks deliberately leave to a later slice, one per line, with the slice named. Only rules the spec itself marks as belonging elsewhere; anything else is a halt.>
