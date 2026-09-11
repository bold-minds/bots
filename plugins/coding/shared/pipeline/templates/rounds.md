# Rounds — <task name>

Why this task needed more than three review rounds, and what changes so it
needs fewer. Written by the pipeline when a fourth round would start; the task
pauses until the change below is applied. Quality is never the thing traded:
no test, check, lens or review is dropped, shortened or weakened here.

## What each round found

| round | verifier | code review | what the rework changed |
|---|---|---|---|
| 1 | <first line> | <first line> | <the rework commit's subject> |

## Why so many

<the pattern, one paragraph, from the rows above: findings outside the design;
one layer found per pass; a fix that broke another row; a task too big for its
tests; a criterion too vague to test; a reviewer re-reading a diff it had
already passed>

## The change

<exactly one: SPLIT the task into <named parts>; REWRITE design.md, adding
these rows; AMEND criteria.md with <what>; or a change to the pipeline, named
precisely. Say what it costs and why it cannot lower quality. The operator
applies it, appends "## Change applied" below, and relaunches; it is a two-way
door and goes on the slice summary.>
