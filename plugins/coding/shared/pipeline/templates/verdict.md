# PASS
<or>
# BLOCK: <one plain sentence>

- Tests prove their criteria: <each test, what was mutated, went red: yes/no>
- Rulings respected: <each entry in the rulings file this could touch — checked, fine / violated at …>
- Gate: green / red at <step>
- Touched only what plan.md said: yes / no — <what else>; test files and tests.md after the plan commit: untouched / touched by <commits>; commits before it: tests and task files only / <what else>
- Verifier saw the implementer's reasoning: no

## Feature only

<These three rows are filled in by the feature step and left out of a task's
verdict. They are the whole reason that step exists.>

- The journey, end to end: <the journey task's test, run through the real
  environment: green / red at … / the environment was down, which is a BLOCK>
- Every fitness test: <each structural rule's test: green / red at …>
- Every task's tests, together: <green / red at … — tasks that passed alone and
  fail together are what this row catches>

<The verifier re-runs everything itself. It trusts nothing in tests.md or
plan.md that it did not reproduce.>
