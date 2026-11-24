Milestone M1, Keep a list: ready to release.

## PRs, by story
- add-item: add-item/pr-1 (https://example.invalid/pantry/pull/1) is merged into main. `fake/gh pr view 1 --json state,baseRefName` printed `{"state": "MERGED", "baseRefName": "main"}`.
- clear-ticked: clear-ticked/pr-1 (https://example.invalid/pantry/pull/2) is merged into main. `fake/gh pr view 2 --json state,baseRefName` printed `{"state": "MERGED", "baseRefName": "main"}`.

## Gate on main
Commit @SHA@. `task validate` in a worktree at origin/main: unit pass, integration pass, e2e pass. "Summary: 10 passed, 0 failed, 0 skipped".

## Release notes
# Keep a list
## Add an item
- Type an item and it shows at the bottom of the list, on every phone and laptop.
## Clear ticked items
- Tick items off as you shop; clear them in one step, and they're gone for everyone.

Sources: "Then the list shows "milk", then "eggs", on every phone and laptop that opens it" (add-item.md, Journey); "Clearing removes every ticked item in one step, with no confirm." (clear-ticked.md, scenario 2).

## Release steps, in order
1. `bash repo/scripts/release.sh test @SHA@`
2. Then call ship-milestone after that step: the test release, at places/test, of commit @SHA@.
3. Only once step 2 returns "release live": `bash repo/scripts/release.sh live @SHA@`
4. Then call ship-milestone after that step: the live release, at places/live, of commit @SHA@.

The remote's branches and tags are as the run found them: `git ls-remote origin` printed the same lines before and after.

Questions: none.

## Think answers
- Is every story's PR merged into the main branch, by the repo's own state? Yes, both: "{"state": "MERGED", "baseRefName": "main"}" (fake/gh pr view 2).
- Did the gate run every test layer, on the commit that will ship? Yes, at @SHA@: "✅ e2e (5 tests, 52s)" (task validate output).
- Does every line of the release notes come from a story or a merged PR? Yes, each beside its source: "Clearing removes every ticked item in one step, with no confirm." (clear-ticked.md, scenario 2).
- Is each release step the repo's own command, for the gated commit, with live only after the E2E suite passes on test? Yes: "release.sh <test|live> <commit>" (repo/scripts/release.sh).
- Does each scenario's result come from a command and its output? Not reached before release; checked the E2E command the designs give: "Start command: `task start` serves the app on port 8080" (add-item.design.md).
- Did the run leave every remote, branch, tag and released place as it found them? Yes: "refs/heads/main" at @SHA@ before and after (git ls-remote origin).
