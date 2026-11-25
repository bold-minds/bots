# write-stories: test results

Latest fully passing round: round 3 of 4. Round 4 had one with-skill miss (a signed-out scenario worded in system terms listing three causes, instead of one broad scenario in the people's words); the model trial used round 4's skill text, and the current skill text is later than round 3.

**Model:** claude-sonnet-5-5, high effort, one run per case (from the model trial record; the run files carry no model id).

| Case | Assertions | With skill (runs x score) | Baseline: previous version of the skill |
|---|---|---|---|
| go-function-interface-stories | 9 | 1 x 9/9 | 9/9 |
| revises-approved-story-keeps-numbers | 8 | 1 x 8/8 | 8/8 |
| signed-out-failure-stories | 9 | 1 x 9/9 | 8/9 |

**Total:** with skill 26/26 (100%); previous version 25/26 (96%).

**Rounds:** 4 iteration folders (round 3 is the latest fully passing one).

**Misses found and fixed**
- `Defaults taken` placed under the Changelog (previous version, round 2): fixed by the step order.
- Unstated behaviour written as fact, such as "keeps nothing between calls" (previous version, round 2): fixed by adding "or behaviour" to the rule.
- Control and gesture words (swipe, circle, chip) in Journeys and Shows (previous version, round 3): the skill now says to name the action, not the control.
- A library error scenario with no "what the caller should do" (round 2): the scenario step now says "see or get back" and includes handling the error.
- Open: the one broad sign-in scenario written with the design's three causes instead of the people's words (round 4, and the smaller model's run).

**Grader notes left open:** the revise case does not separate the skills; no assertion checks that each returned question carries a pick.
