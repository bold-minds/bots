# Add amounts: technical design

Status: Approved

## Packages and functions
- `tally`: `func Parse(args []string) ([]int, error)`: each argument read as a whole number; the first that is not a number gives an error naming it. Scenarios 1, 2, 3.
- `tally`: `func Sum(values []int) int`: the total of values. Scenarios 1, 2.
- `cmd/tally`: prints "Total: N" with N from `Sum(Parse(args))`, or "Not a number: X" and exit status 1 on a Parse error. Scenarios 1, 2, 3.

## Schema, routes, commands and events
- Command `tally AMOUNT...` (exists; it gains its output). Scenarios 1, 2, 3.

## Libraries
- None added; Go standard library only.

## PRs
- PR 1, about 80 changed lines, tests included: `Parse`, `Sum`, the command's output, and their tests. Builds on nothing.

## Tests
- `tally` (package `tally_test`): `TestParse`: "2" and "3" give 2 and 3; "abc" gives an error naming abc. Scenarios 1, 3. `TestSum`: 2 and 3 give 5; 1.50 and 2.25 give 3.75. Scenarios 1, 2.
