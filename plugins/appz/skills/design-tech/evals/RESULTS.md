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

## November 26th, 2026: the milestone's contract (Act step 6)

New case `fix-design-to-milestone-contract`: a story's design written side by side with another story's, before the milestone's contract existed, is fixed to the contract (its names, its owners, its question numbers). Run with `claude plugin eval plugins/appz --eval-dir <copy> --case fix-design-to-milestone-contract --model sonnet --runs 1 --ablation none --scaffold --trust-plugin --allow-tools Bash Write Edit --max-cost-usd 3 --no-publish`, Claude Code 2.1.332, model claude-sonnet-5-5 (from the transcript), judge haiku. The earlier cases were not re-run; step 6 is new and steps 6 to 11 only moved to 7 to 12.

| Run | Score | Cost (agent + judge) | Failed assertion |
|---|---|---|---|
| 1 | 8/9 | $0.27 + $0.10 | 02: the grader asked the design to name `plants.Watering` and `plants.Store.LastWatered`; the design used the contract's name for every shared part it named and dropped those two, as no scenario of the story needs them (step 7). The grader asked for more than the skill says, so it now asks for the contract's name wherever the design names a shared part. |
| 2 (grader 02 fixed) | 8/9 | $0.31 + $0.11 | 01: a scratch copy `earlier.design.tmp` was left in the repo root. The eval's Bash mounts the working folder read-only on this Claude Code version, so the run could write the copy with the Write tool (step 8's `--earlier` copy) but could not delete it. |

Every assertion on the new lines passed in both runs: the contract's names with none of the old ones left, none of the owner's parts built again, only what the contract says this story adds, each line marked with the contract's question number, and the questions returned under those numbers.

**Left open:** the scratch-copy miss comes from the read-only Bash, not from a skill line; it needs a run where Bash can write before it can be told apart from a skill miss.
