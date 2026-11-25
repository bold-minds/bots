# design-tech: test results

Latest round: round 12 of 12 (its fourth sub-round, the final one), every with-skill run passed every assertion.

**Model:** claude-sonnet-5-5, high effort, 3 runs per case (from the model trial record, which read the transcript model ids).

| Case | Assertions | With skill (runs x score) | Baseline: previous version of the skill (1 run) |
|---|---|---|---|
| go-library-design | 15 | 3 x 15/15 | 14/15 |
| web-story-proposed-decision | 17 | 3 x 17/17 | 15/17 |
| revise-from-markup | 10 | 3 x 10/10 | 9/10 |

**Total:** with skill 126/126 (100%); previous version 38/42 (90%).

**Rounds:** 12 iteration folders, plus 6 side folders (3 sub-rounds of the last round and 3 aside rounds). The last round alone ran 4 sub-rounds, each finding one with-skill miss until the final one found none.

**Misses found and fixed**
- Scenario lines ending in a label (`Journey`, `all`) or a trailing note instead of digits: a script now checks scenario digits, and step 7 searches for them.
- Revision adding a detail the markup left open (for example a trim or a validation call on a handler): step 2 and the per-word quoted trace now fail it.
- A revision dropping a function from a PR without naming its replacement: step 9 names the replacement in the same line.
- An unexported helper listed as a test target, and an estimate booked as a default: step 8 exports check and the forced-change quote cover them.
- Test layers missing per PR (no E2E through the calling program, no integration layer, chaos as a unit test only): the layered-tests ruling and the chaos wording ("for each scenario where something the story depends on fails") fixed these.
- The standard checks not named in the PR (previous version, every round): the current skill names them.
- An over-limit PR split into a third infra PR: a part still over now stays one PR.

**Grader notes left open:** the revise-case added-detail assertion varies run to run for both versions; chaos assertions accept several ways to break the dependency.
