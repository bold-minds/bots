# Coverage — <feature name>

Every rule the feature's binding spec and the owner's cross-cutting list carry, and the task that satisfies it. This table is what the owner reads to know nothing was dropped between the spec and the tasks; a rule with no task is a halt, not a row, unless one of the two sections below names where it is held.

| Rule | In the owner's words (short) | Task | Where in the task |
|---|---|---|---|
| S<slice>.<n> | <the rule, trimmed> | <task directory name> | <Success / Failure / Structural / Not in this task, and which line> |
| X<n> | <the cross-cutting line> | <every task it applies to; a cross-cutting line the feature has no work for says "no work in this feature: <why, one line>" and names the plan line that says so> | <where> |

## Deferred by the tasks

<Rules the spec carries that these tasks deliberately leave to a later slice, one per line, with the slice named. Only rules the spec itself marks as belonging elsewhere; anything else is a halt.>

## Held outside the tasks

<Rules the spec itself marks as a working rule or a runbook item, one per line, each naming exactly where it is held (which document, which check, which person). A rule the spec does not mark this way never appears here. "Plan only" and "note" are not places: a rule that a test would not catch is either a fitness test in some task or a halt.>
