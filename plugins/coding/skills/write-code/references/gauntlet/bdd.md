# Gauntlet — BDD / Gherkin Acceptance Tests

Read `gauntlet/standards.md` first for the contract.

Gherkin is the file format. BDD is the discipline: **write the acceptance criteria as executable scenarios before writing the code**, in language the person who wanted the feature can read and correct.

This is the one gate that catches a correct implementation of the wrong requirement. Every other gate proves the code is sound. This one proves it does what was asked.

## The format

```gherkin
Feature: Debt payoff ordering
  Scenario: Highest APR is paid first when balances are equal
    Given two cards with equal balances
    And card A has APR 24.99% and card B has APR 18.00%
    When the payoff plan is generated
    Then card A appears before card B
```

Three rules:

1. **Given / When / Then, once each per scenario.** `And` extends the previous keyword. A scenario with two `When`s is two scenarios.
2. **No implementation words.** No function names, no selectors, no HTTP verbs, no database tables. If the user couldn't read the scenario and tell you it's wrong, it's written at the wrong level.
3. **One behavior per scenario.** If the `Then` has three unrelated assertions, split it.

## Where scenarios come from

Step 1 of `write-code` invokes `capture-intent`, which captures intent and enumerates every element. **Those enumerated elements become the scenarios.** Write the `.feature` file at step 1, before any implementation, and show it to the user. A wrong scenario caught before the code is written costs a sentence; caught after, it costs the feature.

If `capture-intent` surfaced an element you can't write a scenario for, that element isn't understood yet. Say so rather than guessing.

## When this gate applies

Runs in tier 1 whenever the change has **observable behavior** — a rule, a workflow, a calculation, a state transition, anything a person could describe wanting.

Skipped, with a one-line note, for changes with no observable behavior: formatting, dependency bumps, internal renames, comment edits, pure refactors that alter no output.

## Running it

| Stack | Runner | Command | Threshold |
|---|---|---|---|
| Go | [`cucumber/godog`](https://github.com/cucumber/godog) | `go test ./features/...` (godog via `TestFeatures`) | exit 0, 0 undefined steps |
| TS / Svelte | [`playwright-bdd`](https://github.com/vitalets/playwright-bdd) | `npx bddgen && npx playwright test` | exit 0, 0 undefined steps |
| TS (non-browser) | [`@cucumber/cucumber`](https://github.com/cucumber/cucumber-js) | `npx cucumber-js` | exit 0, 0 undefined steps |

**`playwright-bdd` is the recommended frontend runner** — Playwright is already a tier-1 gate, so the scenarios reuse the browser harness instead of standing up a second one.

**Undefined steps are failures, not warnings.** Both runners exit 0 by default with steps that have no implementation, reporting them as "undefined" or "pending." That is a silent pass, and it is exactly the failure mode this gate exists to prevent. Configure strict mode:

- godog: `Options{Strict: true}` in the test runner
- cucumber-js: `--strict`
- playwright-bdd: check `bddgen`'s own exit code, not just Playwright's

Verify strict behavior once per project rather than assuming it: write a scenario with a deliberately undefined step, run the gate, confirm it goes red. If it goes green, the gate is not wired and every scenario after it is decorative. Do this before trusting the first real run — runner defaults change between major versions.

Report the scenario count and the pass/fail/undefined breakdown, not just an exit code.

## Layering

BDD sits above unit tests; it does not replace them.

- **Scenarios** cover the behavior the user asked for. Few, readable, stable across refactors.
- **Unit tests** cover the branches, edge cases, and error paths behind that behavior. Many, fast, coupled to structure.
- **Coverage targets and mutation scores apply to the unit layer.** A feature file does not count toward the 90/80/70 targets.

A repo with green scenarios and no unit tests has proven the happy path and nothing else.

## Anti-patterns

- **Scenarios written after the code.** They describe what was built, not what was wanted, and the gate proves nothing.
- **Step definitions containing logic.** Steps translate English to a call. Branching inside a step means the scenario is underspecified.
- **`Given the system is in state X` where X is a database fixture.** Set up through the same interface a user would, or the scenario tests the fixture.
- **One scenario per function.** Scenarios track behaviors, not code units. If the scenarios map 1:1 to the implementation, they'll break on every refactor and prove nothing about the requirement.
