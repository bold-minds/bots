# plan-milestones: test results

Latest round: round 3 of 3, every with-skill run passed every assertion.

**Model:** claude-sonnet-5-5, medium effort, 3 runs per case (set for each run when it was started).

| Case | Assertions | With skill (runs x score) | Baseline: previous version of the skill (1 run) |
|---|---|---|---|
| cuts-orders-and-leaves-out-later | 11 | 3 x 11/11 | 10/11 |
| returns-missing-requirements | 4 | 3 x 4/4 | 4/4 |
| revise-moves-one-id-keeps-rest | 6 | 3 x 6/6 | 6/6 |

**Total:** with skill 63/63 (100%); previous version 20/21 (95%).

**Rounds:** 3 iteration folders. Round 1 compared the skill with no skill (with skill 20/21, no skill 12/21). Rounds 2 and 3 compared it with its previous version, which differs only in the description's when-to-use clause.

**Misses found and fixed**
- The Home requirement placed in Milestone 2 (round 1): a wrong assertion. The skill places an id that names several parts in the milestone where all its parts exist; the run did, with Home built in Milestone 1. The assertion now checks that.
- The keyboard rule counted in five milestones because later ones carried a `Keeps: R10` line (round 2): a wrong assertion. The skill says every later milestone keeps a standing rule. The assertion now counts the Requirements lines only, as the every-id assertion does.
- A section after `Defaults taken` (previous version, round 3, and the smaller model's trial): the skill already says to end the file with `Not in any milestone yet` and `Defaults taken`; the current skill's runs all did.
- Baseline misses the skill removes (round 1, no skill): wrong file place and heading form, the same requirement listed in several milestones, no `After it,` lines, no `Defaults taken` section, no Think answers, and a milestone plan written when requirements were missing.

**Grader notes left open:** the missing-requirements and revise cases do not separate the two versions; the reply assertion cannot tell a short recap with ids from a pasted outline; no assertion checks the sign-in and roles question some runs raise.
