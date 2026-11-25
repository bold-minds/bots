# design-app: test results

Latest round: round 19 of 19, every with-skill run passed every assertion. It is the first full round with no with-skill miss; full rounds ran from round 4 to round 19.

**Model:** claude-sonnet-5-5 for every run and grader (read from the run transcripts), 3 runs per case.

| Case | Assertions | With skill (runs x score) | Baseline: no skill (1 run) |
|---|---|---|---|
| library-functions-only | 9 | 3 x 9/9 | 1/9 |
| revise-round-from-markup | 10 | 3 x 10/10 | 7/10 |
| screens-from-quotes | 11 | 3 x 11/11 | 1/11 |

**Total:** with skill 90/90 (100%); no skill 9/30 (30%).

**Rounds:** 19 iteration folders, plus 2 side folders (one cut-off round, one partial round).

**Misses found and fixed**
- Decision rows that went past their quote but carried no ` *` (round 4, all three screens runs): the From cell itself must end in ` *`; now checked by the skill's script.
- A new question returned with no pick (round 4): every returned question must carry one picked answer.
- Think answers written to a file, not the reply (round 4): the reply must hold them.
- A Think answer with no quoted line (round 4, revise): step 10 re-checks every answer for a quote before replying.
- Numbers, quoted strings, error messages and limit names not in what people said and not starred (later rounds): the check script now fails any such literal.

**Grader notes left open:** the Think-answer assertions check that a quote and a location exist, not that the quote supports the answer; two screen assertions accept a state reached only through controls the run adds. A headless read-back of a 17 to 20 screen design can take up to 30 minutes per run (test tooling, not the skill).
