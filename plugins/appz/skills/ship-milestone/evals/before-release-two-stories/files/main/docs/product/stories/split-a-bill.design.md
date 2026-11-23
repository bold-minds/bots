# Split a bill: technical design

Status: approved

## Packages and functions
- `tipjar.py`: `share(total, people) -> Decimal`, each person's share to the cent, raising `ValueError("Enter at least one person")` for fewer than one person. 1, 2
- `tipjar.py`: `main(argv)`, the `split <total> <people>` command: prints `<share> each`, or the error and exit code 2. 1, 2

## Schema, routes, commands and events
- `tipjar split <total> <people>`: new command. 1, 2

## Libraries
- Python standard library only (`decimal`, `unittest`).

## PRs
- PR 1 (about 90 changed lines, tests included): the whole story. Holds `tipjar.py`, its unit tests and its E2E tests. Tests: unit and E2E.

## Tests
### Unit
- `tests/test_split.py`: test_even_split 1; test_no_people_refused 2.
### E2E
Through the command, as people run it: `python3 <folder>/tipjar.py split ...`, with the folder holding `tipjar.py` given as `TIPJAR_DIR`. Run with `task e2e TARGET=<folder>`; the gate runs it with `TARGET` set to the repo's own folder.
- `e2e/test_split_e2e.py`: test_journey 1; test_scenario_1_even_split 1; test_scenario_2_no_people 2.

Defaults taken: none.
