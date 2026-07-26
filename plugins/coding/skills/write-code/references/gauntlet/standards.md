# The Gauntlet — Mechanical Constraints

The point of this tier is that code can be trusted without being read. That only holds if the constraints are machine-run, not judgment calls. Craft references say how to write well; the gauntlet proves it.

## The contract

A gate is not a gate unless it has all four properties:

1. **It is a command.** Something a shell runs and returns an exit code for. "Consider whether the error handling is adequate" is not a gate. `golangci-lint run` is.
2. **It has a threshold.** Exit 0, or a number to clear. "Good coverage" is not a threshold. "80%+ on handlers" is.
3. **It blocks.** Failing means the work is not done. Not "noted as a follow-up," not "acceptable for now" — not done. You do not report completion with a red gate behind you.
4. **It produces evidence.** Paste the command and its actual output. Not a summary of the output. Not "tests pass." The output.

A constraint missing any of the four is a note, not a gate. Notes go in the craft references.

## Running the gauntlet

Run every tier-1 gate that applies to the languages touched. Not "the relevant ones" — every one. Selecting which gates to run is the escape hatch this tier exists to close.

If a gate's tool is not installed in the project, that is a finding to report, not a gate to skip. Say which gate could not run and why. An unrun gate is never a passed gate.

If a gate fails, fix the code and re-run. Do not adjust the threshold to make it green. Threshold changes are a separate conversation with the user, made deliberately and never mid-task.

## Tiers

**Tier 1 — runs today, no new tooling.** Build, vet, format, lint, typecheck, unit tests, race detection, coverage. These use tools already present in a healthy Go or TS/Svelte project. Every task runs tier 1.

**Acceptance — BDD scenarios, written first.** Gherkin feature files covering the behavior that was actually asked for, authored at step 1 from `capture-intent`'s captured intent, before implementation. Runs in tier 1 for any change with observable behavior. This is the only gate that catches a correct implementation of the wrong requirement — every other gate assumes the requirement was right. See `gauntlet/bdd.md`.

**Tier 2 — needs per-project setup.** Mutation testing and fuzzing. Slow, and requires installing a tool and committing a config. Run when adding or changing logic that a coverage number alone can't vouch for: parsers, decoders, money math, permission checks, state machines. Not on every task.

## Thresholds — defaults, overridable per project

Every number in the language gate files is a default. A project may record its own in `builds/<project>/scope.md`, under a `## Gate thresholds` heading, one line per gate — the gate's name as those files name it, then the number. Where a project records one, that is its threshold and the default stops applying to it.

`/software` reads `scope.md` at the start of every session, so inside the room the project's numbers are already in context — use them. Invoked with no `scope.md` in reach, run the defaults and say that is what you ran.

This is the only override path, and it does not soften the rule above. A task in progress still never moves a threshold to make a gate go green. The difference is *when* and *where*: a project override is written into `scope.md` deliberately, before the work, and binds every task after it. A number changed while a red gate is on the screen is a threshold bent to fit the code that already exists, which is the one thing a threshold exists to prevent.

Report which you cleared against — the target column carries the project's number when there is one, the default otherwise.

## Reporting

Close the gauntlet with a table — gate, command, result. Every applicable gate gets a row, including ones that could not run.

| Gate | Command | Result |
|---|---|---|
| Build | `go build ./...` | pass |
| Coverage | `go test -cover ./...` | 84.2% (handlers, target 80%) |
| Mutation | `gremlins unleash` | not installed — not run |

Anything less than the full table is an incomplete report.

## Scope discipline in the code lane

The gauntlet raises the cost of every line written. That is the point, and it means scope control matters more here, not less.

- Write the smallest change that satisfies the captured intent from `capture-intent`. Every extra file is more gauntlet surface.
- No speculative abstraction. An interface with one implementation is a guess.
- If the change can't clear tier 1 today, it is too big. Cut it until it can.
- Refactors, rewrites, and redesigns need a named problem they solve. "Cleaner" is not one.

## Language gates

- Go → `gauntlet/go.md`
- TypeScript / Svelte / frontend → `gauntlet/frontend.md`
- Acceptance scenarios, all stacks → `gauntlet/bdd.md`
