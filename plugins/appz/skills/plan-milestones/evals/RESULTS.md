# plan-milestones: test results

**Latest round did not pass every assertion.** There is one round (round 1); its with-skill runs scored 10/11 on one case. The skill was changed after this round (the reworded placement rule noted below) and the full set was not re-run on Sonnet. The model trial later ran the current skill on a smaller model (see `plugins/appz/MODELS.md`).

**Model:** claude-sonnet-5-5, medium effort, one run per case (from the model trial record; the run files carry no model id).

| Case | Assertions | With skill (runs x score) | Baseline: no skill |
|---|---|---|---|
| cuts-orders-and-leaves-out-later | 11 | 1 x 10/11 | 4/11 |
| returns-missing-requirements | 4 | 1 x 4/4 | 2/4 |
| revise-moves-one-id-keeps-rest | 6 | 1 x 6/6 | 6/6 |

**Total:** with skill 20/21 (95%); no skill 12/21 (57%).

**Rounds:** 1 iteration folder.

**Misses**
- The one with-skill miss: the Home requirement was placed in Milestone 2, not Milestone 1. The assertion was reworded afterwards. It is not marked fixed in a later round because there is none.
- Baseline misses the skill removes: wrong file place and heading form, the same requirement listed in several milestones, no `After it,` lines, no `Defaults taken` section, no Think answers, and a milestone plan written when requirements were missing.
