# <task name — a short sentence in the owner's words>

Success: <one sentence, in the owner's words, of what the customer can do
afterwards that they cannot do now. This is the line the owner is shown, beside
the coverage table, before any task runs. Not the title again.>

Feature: <feature name>
Story: <the story's path — docs/product/stories/<nn>-<name>.md>
Rules: <the numbers of the story's scenarios this task carries, comma separated
— "1, 3". Those scenarios are this task's criteria, and their text lives on the
story only: nothing is copied or re-authored here, and a word changed on the
story changes the tests. The coverage table in tasks/coverage.md is built from
these lines, and a scenario no task names halts the feature. A task with no
scenario behind it does not exist.>
After: <optional, and at most one task directory name. Write it when this task
cannot start until that task's work exists — the file, the package, the table
this one builds on is created by that one, and a worktree cut from the feature
branch does not have it. The pipeline runs that task in an earlier wave and
this task's builder merges its branch first. A task that needs two others is
two tasks: split it rather than name two. Leave the line out — most tasks do —
when this task can start from the feature branch as it stands.>

## Structural rules

<Only if the story itself states one, in its Flow's Components or its
Solution: a rule about the shape of the code itself, in one sentence — "the worker never imports the server package",
"nothing under mcp/ reaches the live copy except through the fence". Each gets
a fitness test: a test that reads the code and fails if the rule is broken.
This section is about the code rather than the customer, which is why it is the
one part of this file not written in the customer's terms. Usually empty.>
