# Add amounts: technical design

Status: Approved

## Packages and functions
- `tally`: `func Parse(args []string) ([]int, error)`: each argument read as a whole number; the first that is not a number gives an error naming it. Scenarios 1, 2, 3.
- `tally`: `func Sum(values []int) int`: the total of values. Scenarios 1, 2.
- `cmd/tally`: prints "Total: N" with N from `Sum(Parse(args))`, or "Not a number: X" and exit status 1 on a Parse error. Scenarios 1, 2, 3.
- `e2e` (new, package `e2e_test`): a test helper that builds the command once with `task build` and runs `bin/tally` with the given arguments, giving its output and exit status. Scenarios 1, 2, 3.
- `Taskfile.yml`: new task `build`, running `go build -o bin/tally ./cmd/tally`. `check` already runs `go test -count=1 ./...`, which holds the E2E tests. Scenarios 1, 2, 3.

## Schema, routes, commands and events
- Command `tally AMOUNT...` (exists; it gains its output). Scenarios 1, 2, 3.
- Command `task build` (new): builds the command to `bin/tally`. Scenarios 1, 2, 3.

## Libraries
- None added; Go standard library only.

## PRs
- PR 1, about 130 changed lines, tests included: `Parse`, `Sum`, the command's output, the `build` task, the `e2e` helper, and their tests. Tests: unit and E2E. Builds on nothing.

## Tests
Unit:
- `tally` (package `tally_test`): `TestParse`: "2" and "3" give 2 and 3; "abc" gives an error naming abc. Scenarios 1, 3. `TestSum`: 2 and 3 give 5; 1.50 and 2.25 give 3.75. Scenarios 1, 2.

Integration: none; `tally` and `cmd/tally` talk to no database, API or file.

E2E (package `e2e_test`, running `bin/tally` built by `task build`, as a user runs it; needs `task` on the PATH; run with `go test -count=1 ./e2e/...`):
- `TestJourney`: `tally 2 3 1.50 2.25` prints "Total: 8.75" and exits 0. Scenarios 1, 2.
- `TestWholeAmounts`: `tally 2 3` prints "Total: 5". Scenario 1.
- `TestDecimalAmounts`: `tally 1.50 2.25` prints "Total: 3.75". Scenario 2.
- `TestNotANumber`: `tally 2 abc` prints "Not a number: abc" and exits with status 1. Scenario 3.

Perf: none; no requirement or design line gives a speed or load number.

Chaos: none; the command depends on nothing that can fail.
