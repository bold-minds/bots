# write-requirements: test results

Latest round: round 5 of 5, every with-skill run passed every assertion.

**Model:** claude-opus-5-5, high effort, one run per case (the run files carry no model id; this is from the model trial record). A later model trial ran the same cases and skill on claude-sonnet-5-5, high effort: 3 runs per case, 9 of 9 runs passed every assertion (see `plugins/appz/MODELS.md`).

| Case | Assertions | With skill (runs x score) | Baseline: previous version of the skill |
|---|---|---|---|
| go-library-without-screens | 10 | 1 x 10/10 | 10/10 |
| missing-design-returns-gap | 6 | 1 x 6/6 | 6/6 |
| quotes-and-design-to-sourced-draft | 16 | 1 x 16/16 | 16/16 |

**Total:** with skill 32/32 (100%); previous version 32/32 (100%).

**No-skill baseline (round 1, when the cases had 10, 6 and 11 assertions):** with skill 27/27; without the skill 2/10, 2/6 and 4/11 (8/27, 30%). Without the skill every format assertion failed: no `Said:`/`From:` lines, numbers not in the inputs with no defaults list, a draft written when the design was missing, and no reply sections for starred lines, defaults and questions.

**Rounds:** 5 iteration folders.

**Misses found and fixed**
- Star marker not last on a defaulted line (`* (default)`): failed in rounds 2 and 3, passed from round 4.
- `From:` line citing a section heading instead of the named rule or function (previous version, rounds 2 and 4): the current skill quotes the rule or names the function.
- Look-only wishes left out, or a "later" item put under `Not requirements yet` when it was a requirement (previous version, round 3): fixed in the skill and passed 16/16.
- Draft that ended with a section after `Defaults taken` (previous version, round 2): the defaults list now ends the file.

**Grader notes left open:** the "no screens" and "no points or ratings" assertions can pass on a negation; the missing-design reply assertion would also pass a list of interface parts taken straight from the quotes.
