# write-pr: test results

Latest round: round 4 of 4, every with-skill run passed every assertion.

**Model:** claude-sonnet-5-5 for every run (read from the run transcripts), 3 runs per case.

| Case | Assertions | With skill (runs x score) | Baseline: no skill (1 run) |
|---|---|---|---|
| missing-gate-result | 6 | 3 x 6/6 | 2/6 |
| one-pr-full-stack | 14 | 3 x 14/14 | 8/14 |
| stacked-stub-new-pattern | 15 | 3 x 15/15 | 12/15 |

**Total:** with skill 105/105 (100%); no skill 22/35 (63%; the benchmark's mean of case rates is 57%).

**Rounds:** 4 iteration folders, plus 1 side folder.

**Misses found and fixed**
- Think answers reading "Not reached" with no quote when the gate result is missing (rounds 1 to 3): fixed by round 4.
- PR 1's description naming a scenario that belongs to PR 2 (round 1): fixed in round 2.
- Claims no input backs, such as "mostly the store integration tests" or "It ships to users" (rounds 1 to 3): fixed in round 4.
- Think answers quoting no input text (round 1): fixed by round 2.
