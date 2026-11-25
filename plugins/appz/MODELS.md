# Models per step

For each step: the model named before trials, the model its proof ran on, the next smaller candidate, the runs made, the result and the pick. Each skill's `evals/RESULTS.md` holds its proof round. A candidate is ruled out by one failed assertion in any run. The product name in the quoted assertions is masked as `<product>`.

| Step | Named before trials | Proof ran on | Candidate | Runs made | Result | Pick |
|---|---|---|---|---|---|---|
| write-requirements | Opus, high | claude-opus-5-5, 1 run per case | Sonnet, high | 9 (3 per case) | 9 of 9 pass every assertion (10/10, 6/6, 16/16 each x3) | Sonnet, high |
| design-app | Opus, high | claude-sonnet-5-5, 3 runs per case | Sonnet (the proof model) | none new | proof: 9 of 9 runs pass every assertion | Sonnet, high |
| design-tech | Opus, high | claude-sonnet-5-5, 3 runs per case | Sonnet (the proof model) | none new | proof: 9 of 9 runs pass every assertion | Sonnet, high |
| plan-milestones | Sonnet, medium | claude-sonnet-5-5, 3 runs per case (9 of 9 runs pass every assertion) | Haiku, medium | 5 | run-3 of the cuts case scores 10/11 | Sonnet, medium |
| write-stories | Sonnet, high | claude-sonnet-5-5, 3 runs per case (7 of 9 runs pass every assertion; 2 miss the Think-answers line) | Haiku, high | 1 | 7/9, trial stopped | Sonnet, high |
| build-story | Sonnet, high | claude-sonnet-5-5, 3 runs per case | Haiku, high | 6 | run-2 of one-pr-small-fix scores 13/14 | Sonnet, high |
| write-pr | Sonnet, medium | claude-sonnet-5-5, 3 runs per case | Haiku, medium | 2 | stacked-stub-new-pattern scores 14/15, trial stopped | Sonnet, medium |
| ship-milestone | Sonnet, medium | claude-sonnet-5-5, 3 runs per case | Haiku, medium | 1 | 8/9, trial stopped | Sonnet, medium |
| build-app | Sonnet | claude-sonnet-5-5, medium, 3 runs per case (final round) | none: the approved trial covered the eight steps only | 24 in the final round (18 with skill, 6 previous version) | 125/126; one miss left (approved-pr case run-1, "app is done" not said) | Sonnet |

Haiku is claude-haiku-5-5. A trial is staged: one run per case, then two more per case for a model that passes every case. A trial stops at the first failed assertion.

## Candidates ruled out

**plan-milestones, Haiku.** Cuts case, 3 runs: 11/11, 11/11, then run-3 10/11. The failing assertion: "The file ends with a `Defaults taken` section, and it names at least one order or placement that no one specified (for example where R9, R6/R8 or R12 sit) together with a reason." Evidence: the section exists with good placements, but two sections follow it, so the file does not end with it. The other two cases ran once each (4/4 and 6/6); their extra runs were not made.

**write-stories, Haiku.** Signed-out case, run 1: 7/9, two failures.
- "Every story has a scenario for when the <product> sign-in is not working, saying what the person sees (the sign-in prompt) and what to do (sign in to <product>)." Only one story quotes the prompt; the other three say only that the person sees the sign-in screen with no error code.
- "Within each story the signed-out, expired sign-in and revoked access causes are covered by one broad scenario in the people's words, not by three separate scenarios." The scenarios list the design's three causes instead of the people's broad words.

The other two cases were not run.

**build-story, Haiku.** function-cannot-serve 6/6 x3; backend-infra-split run-1 17/17; one-pr-small-fix run-1 14/14, then run-2 13/14. The failing assertion: "The returned message gives the code lines and the test lines changed in this PR as two separate numbers, with config files left out, and names the command that gave them. The numbers match the added and removed lines of that command for the code files and the test files." Evidence: the code number (20) counts go.mod and go.sum, which are config; the script's count with config left out is 7. The third one-pr run and the extra backend runs were not made.

**write-pr, Haiku.** one-pr-full-stack run-1 14/14; stacked-stub-new-pattern run-1 14/15. The failing assertion: "PR 1's description names unit and E2E tests (E2E against the stub); PR 2's names unit, integration, E2E and chaos tests." Evidence: PR 2 names unit, integration and E2E but never chaos; the read-only-file test is listed under E2E. missing-gate-result was not run.

**ship-milestone, Haiku.** before-release-two-stories run-1: 8/9. The failing assertion: "Apart from the work, the return answers in one line each, each with a quote of the line it rests on and where it is: ..." (six questions). Evidence: three of the six answers carry no quote of a line and where it is (for example "Yes... each line lists its source above"). The other two cases were not run.

## Picks checked against the gradings

All eight picks match the gradings. Two notes on the proofs behind them:
- plan-milestones: Sonnet's own proof round had one miss (the Home requirement placed in Milestone 2), since reworded, and the current skill was not re-run on Sonnet. Haiku passed that case twice on the current skill before failing the third run.
- write-stories: Sonnet's proof round had one miss (a sign-in scenario worded in system terms). The Haiku run missed that same assertion plus one more.
