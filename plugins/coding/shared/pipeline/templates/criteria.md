# <task name — a short sentence in Claire's words>

Feature: <feature name>
From: <the line in spec.md this comes from>
Journey: yes / no   <exactly one task per feature is "yes"; it gets a bdd or e2e test>
Depends on: <task numbers, or none>

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

<Only if the architecture lens named one. A rule about the code's shape, in
one sentence: "the worker never imports the server package", "nothing under
mcp/ reaches the live copy except through the fence". Each gets a fitness
test that reads the code and fails if the rule is broken. Usually empty.>

## Not in this task

<One line each: the nearby things this task deliberately does not do, and
the pre-mortem cases dropped for this task, with the one-line reason.>
