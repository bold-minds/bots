# <task name — a short sentence in the owner's words>

Success: <one sentence, in the owner's words, of what the customer can do
afterwards that they cannot do now. This is the line the owner is shown before
any task runs. Not the title again.>

Feature: <feature name>
From: <the line in spec.md this comes from>
Rules: <every rule id this task satisfies, from the feature's binding spec
(S<slice>.<n>) and the owner's cross-cutting list (X<n>), comma separated.
The coverage table in tasks/coverage.md is built from these lines, and a rule
no task names halts the feature. A task with no rule behind it does not exist.>
Journey: yes / no   <exactly one task per feature is "yes"; it gets an
end-to-end test — one that walks the whole path a customer walks, through the
real environment, not a unit test>
After: <optional, and at most one task directory name. Write it when this task
cannot start until that task's work exists — the file, the package, the table
this one builds on is created by that one, and a worktree cut from the feature
branch does not have it. The pipeline runs that task in an earlier wave and
this task's builder merges its branch first. A task that needs two others is
two tasks: split it rather than name two. Leave the line out — most tasks do —
when this task can start from the feature branch as it stands.>

## Success

Given <a situation a customer is in>
When <the thing they do>
Then <what they get, observably>

Given <…>
When <…>
Then <…>

## Failure that matters

<Only cases a real customer would plausibly hit AND we could do something
about. From premortem.md. Skip the rest.>

Given <…>
When <…>
Then <what they get instead — a message, a refusal, a fallback>

## Structural rules

<Only if the architecture lens named one: a rule about the shape of the code
itself, in one sentence — "the worker never imports the server package",
"nothing under mcp/ reaches the live copy except through the fence". Each gets
a fitness test: a test that reads the code and fails if the rule is broken.
This section is about the code rather than the customer, which is why it is the
one part of this file not written in the customer's terms. Usually empty.>

## Not in this task

<One line each: the nearby things this task deliberately does not do, and
the pre-mortem cases dropped for this task, with the one-line reason.>
