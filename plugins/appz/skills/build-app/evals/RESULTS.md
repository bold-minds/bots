# build-app: test results

Latest round: iteration 7, round 4 (the last round run), one with-skill miss left.

**Model:** claude-sonnet-5-5, medium effort, for every run and grader (read from the run transcripts), 3 runs per case. Subagents in these runs are fakes (`fake/start-subagent`, `fake/gh`), so the cases test what build-app itself does.

| Case | Assertions | With skill (runs x score) | Baseline: previous version of the skill (1 run) |
|---|---|---|---|
| approved-pr-merged-then-milestone-ships-and-reports | 13 | 12/13, 13/13, 13/13 | 13/13 |
| names-missing-skills-and-starts-nothing | 5 | 3 x 5/5 | 5/5 |
| pr-written-by-write-pr-opened-by-build-app | 8 | 3 x 8/8 | 8/8 |
| records-approval-and-moves-requirements-draft | 5 | 3 x 5/5 | 5/5 |
| reports-state-without-starting-a-step | 5 | 3 x 5/5 | 5/5 |
| story-with-screens-runs-design-app-first | 6 | 3 x 6/6 | 5/6 |

**Total:** with skill 125/126 (99%); previous version 41/42 (98%). The previous version differs from this one only in the step models and the three Act fixes below, so most assertions pass for both.

**Rounds:** 7 iteration folders, plus 3 side folders for the earlier rounds of iteration 7 (one of them stopped at its first miss).

**Misses found and fixed**
- design-app started on Opus (previous version, every round): the step list now names Sonnet; the case's grader was renamed to match.
- A status return answering the input Think question "Not checked, because no step was run" though the input check had run and found missing files (iteration 7, round 1): Act 3 now answers the input question with what step 1's check found.
- Missing step skills listed only by step number, with no work named (iteration 7, round 2): Act 1 now names each one's work in words, not only its step number.
- A run with a missing skill and no caller answers still writing to the build state (iteration 7, round 3): Act 1 now records the caller's answers "and change nothing else in it".
- Harness: the previous version's snapshot lacked its scripts folder, so its report run could not write the report; the snapshot now carries it and that run was redone.

**Misses left**
- approved-pr-merged-then-milestone-ships-and-reports, with_skill run-1, "The response tells the caller the app is done (its last milestone shipped).": the return opens "M1 "Keep a list" shipped: PR 2 is merged, and the test release and the live release both passed." and never says the app is done.

**Grader notes left open:** several assertions pass for both versions and so do not tell them apart (report numbers come from the report script; "app is done" passes on a plain statement); the Think-answer count is checked only in the status case, and some runs in other cases return five of the six answers.

## November 26th, 2026: the milestone's contract (Act step 7)

New case `side-by-side-designs-get-one-contract`: two stories' design-tech runs side by side, then one contract subagent, check-work on each design, one fix round per design with the contract and its misses, check-work once more, and the contract's questions returned under one numbering. Subagents are fakes (`fake/start-subagent`, picking each reply by the story the brief names by path). Run with `claude plugin eval plugins/appz --eval-dir <copy> --case side-by-side-designs-get-one-contract --model sonnet --runs 1 --ablation none --scaffold --trust-plugin --allow-tools Bash Write Edit --max-cost-usd 3 --no-publish`, Claude Code 2.1.332, model claude-sonnet-5-5, judge haiku.

| Run | Score | Cost (agent + judge) | What happened |
|---|---|---|---|
| 1 | 0/9 | $0.22 + $0.09 | The eval's Bash mounted the working folder (`build/`, `repo/`, `fake/`) and `$TMPDIR` read-only, so no brief could be written and `fake/start-subagent` could not record or copy anything. The run started no subagent and returned the read-only folder to the caller, with the next steps it would take: design-tech for both stories side by side, then the M1 contract, then check-work on each design. |
| 2 (outer sandbox off) | 0/9 | $0.24 + $0.09 | The same: the case's working folder is mounted read-only by the eval harness itself, and the case format has no setting to make it writable. |

**Not tested yet:** the case could not run its steps, so no assertion here says anything about the new lines. The same read-only Bash would also stop the earlier cases, whose fakes write through Bash; they were not re-run. Re-run this case on a harness where the case's Bash can write.

**Model:** the contract's subagent is named Sonnet, high, the smallest model that has passed steps of this size (Haiku failed every comparable trial in MODELS.md). It is untested: this case runs it as a fake, so its own model needs a case that runs the real subagent before the pick stands.
