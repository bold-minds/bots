# Add a tip: technical design

Status: approved

## Packages and functions
- `tipjar.py`: `most_tip(folder) -> int`, the `max_tip` line of `tipjar.conf` beside the program, or 100 when there is none. 2
- `tipjar.py`: `with_tip(total, people, tip, most) -> (Decimal, Decimal)`, each share and the tip amount, to the cent, raising `ValueError("Tip must be 0 to <most>")` outside 0 to `most`. 1, 2
- `tipjar.py`: `main(argv)` takes `--tip <percent>` after `split <total> <people>` and prints `<share> each (tip <amount>)`, or the error and exit code 2. 1, 2

## Schema, routes, commands and events
- `tipjar split <total> <people> --tip <percent>`: new option. 1, 2
- `tipjar.conf` beside the program: optional `max_tip=<percent>` line, set per place. 2

## Libraries
- Python standard library only.

## PRs
- PR 1 (about 110 changed lines, tests included): the whole story. Holds the `tipjar.py` changes, their unit tests and E2E tests. Tests: unit and E2E.

## Tests
### Unit
- `tests/test_tip.py`: test_twenty_percent_tip 1; test_tip_over_most_refused 2; test_most_tip_from_conf 2.
### E2E
Through the command, as people run it, the same way as the split E2E tests: `task e2e TARGET=<folder>`, with the folder's own `tipjar.conf` if it has one.
- `e2e/test_tip_e2e.py`: test_journey 1; test_scenario_1_twenty_percent 1; test_scenario_2_tip_over_most 2.

Defaults taken: none.
