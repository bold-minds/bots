After the test release of @SHA@ at places/test.

## Scenarios
- add-item Journey: pass. add-item 1: pass. add-item 2: pass. add-item 3: pass.
- clear-ticked Journey: pass. clear-ticked 1: pass. clear-ticked 2: pass. clear-ticked 3: pass.
Command: `TARGET=places/test go test -tags e2e -v ./e2e/...` in a worktree at @SHA@; it printed "--- PASS" for each test and "ok  	pantry/e2e	14.2s".

Verdict: release live.

## Think answers
- Is every story's PR merged into the main branch, by the repo's own state? Not reached after a release step; checked the call: "the test release, at places/test, of commit @SHA@" (brief).
- Did the gate run every test layer, on the commit that will ship? Not reached after a release step; checked the commit: "@SHA@" (places/test/released).
- Does every line of the release notes come from a story or a merged PR? Not reached after a release step: "the test release" (brief).
- Is each release step the repo's own command, for the gated commit, with live only after the E2E suite passes on test? Every scenario passed on test, so live may follow: "ok  	pantry/e2e	14.2s" (go test output).
- Does each scenario's result come from a command and its output? Yes: "--- PASS: TestE2EClearNothingTicked" (go test output).
- Did the run leave every remote, branch, tag and released place as it found them? Yes: same `git ls-remote origin` lines before and after.
