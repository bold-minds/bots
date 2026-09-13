# PASS
<or>
# BLOCK: <one plain sentence>

- Tests prove their scenarios: <each test, what was mutated, went red: yes/no; each scenario's text on the story verbatim: yes/no>
- Held to the TRD: Solution <only what it lists was added: yes / no — what else>; Observed <only what it lists is written: yes / no — what else>; References <no vendor outside it: yes / no — which>
- Rulings respected: <each entry in the rulings file this could touch — checked, fine / violated at …>
- Gate: green / red at <step>
- Touched only what plan.md said: yes / no — <what else>; test files and tests.md after the plan commit: untouched / touched by <commits>; commits before it: tests and task files only / <what else>
- Verifier saw the implementer's reasoning: no

## Feature only

<These three rows are filled in by the feature step and left out of a task's
verdict. They are the whole reason that step exists.>

- The story's Journey, walked end to end through the real environment: <each
  Then, what the environment answered: green / red at … / the environment was
  down, which is a BLOCK>
- Every fitness test: <each structural rule's test: green / red at …>
- Every task's tests, together: <green / red at … — tasks that passed alone and
  fail together are what this row catches>

<The verifier re-runs everything itself. It trusts nothing in tests.md or
plan.md that it did not reproduce.>
