# ship-milestone: test results

Latest round: round 3 of 3, every with-skill run passed every assertion.

**Model:** claude-sonnet-5-5 for every run (read from the run transcripts), 3 runs per case.

| Case | Assertions | With skill (runs x score) | Baseline: no skill (1 run) |
|---|---|---|---|
| before-release-two-stories | 9 | 3 x 9/9 | 3/9 |
| pr-not-merged | 6 | 3 x 6/6 | 2/6 |
| verify-test-one-scenario-fails | 7 | 3 x 7/7 | 3/7 |

**Total:** with skill 66/66 (100%); no skill 8/22 (36%).

**Rounds:** 3 iteration folders.

**Misses found and fixed**
- Think answers with no quote of the line they rest on, or no location, or answered "not applicable" (rounds 1 and 2, in all three cases): fixed by round 3.
- Running the gate and handing out release steps when a story's PR was not merged (round 1, pr-not-merged): fixed in round 2.
