# write-stories: test results

Latest full round: round 10 of 10. It is the last round run; it had two with-skill misses, listed under "Misses left".

**Model:** claude-sonnet-5-5, high effort, 3 runs per case (set for each run when it was started).

| Case | Assertions | With skill (runs x score) | Baseline: previous version of the skill (1 run) |
|---|---|---|---|
| go-function-interface-stories | 9 | 3 x 9/9 | 8/9 |
| revises-approved-story-keeps-numbers | 8 | 3 x 8/8 | 8/8 |
| signed-out-failure-stories | 9 | 8/9, 8/9, 9/9 | 9/9 |

**Total:** with skill 76/78 (97%); previous version 25/26 (96%).

**Rounds:** 10 iteration folders. Rounds 1 to 4 and 10 ran in full; rounds 5 to 9 were stopped partway, each once a with-skill run missed (round 8 to move the rest of the story form into the script first), so the fix went into the next round.

**Misses found and fixed**
- `Defaults taken` placed under the Changelog (previous version, round 2): fixed by the step order; `scripts/check-story.py` now checks it.
- Unstated behaviour written as fact, such as "keeps nothing between calls" (previous version, round 2): fixed by adding "or behaviour" to the rule.
- Control and gesture words (swipe, circle, chip) in Journeys and Shows (previous version, round 3): the skill names the action, not the control.
- The one broad sign-in scenario worded with the design's three causes instead of the people's words (rounds 4 and 5): the scenario's Given now opens with the people's words in quotes, and the script checks the quote is word for word in what people said.
- A saved link put "at the top" of the list, a screen position (rounds 5 and 6): Act 5 gives screen position to the design; the script fails screen-position, look, motion and control words, reading screen words only so endpoint, command and function stories pass.
- A figure the inputs don't give, such as "2 tags" or "21 characters" beside limits of 3 and 20 (rounds 6 and 7): the script fails a number no input gives, and one counting a thing the inputs count that isn't one of their figures.
- An AI-added requirement id without ` *` in a scenario (round 6): Act 9 says ` *` after each id whose requirement AI added; the script checks it.
- A broad error scenario with no "what the caller should do" (rounds 2 and 9): Act 9 asks each scenario for a thing that goes wrong to end with `so they <do this>`; the script checks the scenarios given to `--wrong` and `--broad`.
- The rest of the story form (title, one-sentence Shows, a Design path that exists, Journey with Given, When and Then, numbered Scenarios, empty Changelog unless approved) moved into the script in round 8, so one round no longer fixes one mechanical item.
- Wrong assertions, reworded: a title taken from the requirement's wording now counts as the people's words (the skill's input defines requirements as in the people's terms); naming a part of the interface by its design name (the save sheet) is not a look or a control.

**Misses left**
- signed-out-failure-stories, with skill run-1, assertion "The returned message gives the Think answers, one line per question, apart from the stories, each saying what it led the skill to do." Evidence: several lines state a finding with no consequence, such as "Over about ten scenarios? No; the longest has 9 and is one action."
- signed-out-failure-stories, with skill run-2, the same assertion. Evidence: the settle-question Think answers are one run-on paragraph, not one line per question, and "Over about ten scenarios? No story has more than 7." states no consequence.

**Grader notes left open:** the revise case does not separate the two versions; the Think-answers assertion is loose on what "what it led the skill to do" means and on whether settle-question's answers are in scope; no assertion checks that each returned question carries a pick.
