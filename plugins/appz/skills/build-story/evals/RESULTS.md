# build-story: test results

Latest round: round 15 of 15 (its third sub-round, the final one), every with-skill run passed every assertion.

**Model:** claude-sonnet-5-5 for every run (read from the run transcripts), 3 runs per case.

| Case | Assertions | With skill (runs x score) | Baseline: previous version of the skill (1 run) |
|---|---|---|---|
| backend-infra-split | 17 | 3 x 17/17 | 14/17 |
| function-cannot-serve | 6 | 3 x 6/6 | 6/6 |
| one-pr-small-fix | 14 | 3 x 14/14 | 14/14 |

**Total:** with skill 111/111 (100%); previous version 34/37 (92%). The previous version fails only the standard-checks assertions in backend-infra-split: standard installed, standard CI workflow, and `task validate` running every layer.

**Rounds:** 15 iteration folders, plus 35 side folders (sub-rounds, most of them partial runs). Several rounds each found one with-skill miss, fixed it and re-ran in full.

**Misses found and fixed**
- Building to a design signature that cannot serve the scenario, then reporting a green gate (rounds 2 and 3): the skill now stops before writing code and returns the question with a pick.
- A stub-passing test never seen failing before the real code was written (rounds 2 to 7): step 5 says "before writing any code".
- Config files counted as code lines (Taskfile, CI workflow): step 10 now names them as left out.
- Think answers with no quote, a bare yes or no, or no command output behind a file list (rounds 5 to 10): answers now quote one line character for character, take line numbers from a command, and hold only what the quotes back.
- Test layers the design lists not all written, start command not real, chaos not breaking the dependency (round 12): build-story writes unit, integration, E2E, perf and chaos per story, and its Think answers check each test against its scenario.
- Last answer not saved in the checked form (round 14): a check script now confirms it.
- Standard checks not installed (round 15, previous version): the skill installs them and `task validate` runs every layer.

**Grader notes left open:** the Think-answers assertion is compound and fails on one slip; red-first accepts a chaos test that first fails at its setup when a later changed-stub run shows the check failing.
