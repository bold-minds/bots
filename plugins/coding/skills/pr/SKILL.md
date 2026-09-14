---
name: pr
description: The Code Review stop. Input a pushed feature branch with its verdict, and the story: opens the PR with the tests in the owner's words at the top and the verifier's verdict as the body, waits for CI, merges on green, runs the live check, writes the card, republishes the board. The owner's read is a skim; the merge is this skill's (ruled 13 Sept 10:54, "you will be merging"). Use when a pipeline run has passed and pushed.
argument-hint: <feature> — the pipeline result's branch and verdict path
allowed-tools: Bash, Read, Write, Artifact
---

# pr

**Input**: a feature branch `pipeline/<feature>` that `pipeline` has pushed
(`pushed:` in its result), its `features/<feature>/verdict.md` on that
branch, every task's `tests.md`, the story, and the repo's
`.claude/pipeline/config.md` (`live:`, the default branch). Nothing else is
required to have run in this session: a branch and a verdict on disk are
enough.

**Output**: a merged PR, the merge commit, the live check's result, the card
line on the release file, the board republished. Or: the PR open and red,
with the failing check named, nothing merged.

## The run

Let `HIL` be `${CLAUDE_PLUGIN_ROOT}/shared/hil`.

1. **The body.** Write `<scratchpad>/pr.md` from `${HIL}/templates/pr.md`:
   - `## Tests` — one line per scenario on the story, in story order, in the
     owner's words: `- <n> [<id>] <the scenario's Then, trimmed> — PASS`, the
     result taken from the task's `tests.md` row for that scenario; the
     Journey line first, `— PASS on <the test address>`, from
     `verdict.md`'s "Feature only" rows. Every scenario on the story has a
     line; one missing is a stop, not a PR.
   - `## Verdict` — `verdict.md`'s first line, then its bullets, verbatim.
   `bash ${HIL}/check.sh pr <scratchpad>/pr.md`; a line printed is a defect
   in what the run produced, and the PR is not opened until it prints none.
2. **Open it.** `gh pr create --base <default branch> --head pipeline/<feature>
   --title "<the story's title, its first line without the #>" --body-file
   <scratchpad>/pr.md`. Keep the PR URL. Card line on the release file:
   `<nn> Code Review now <date> — The PR is open: <one sentence>. CI is running.`;
   run `board`.
3. **Wait for CI.** `gh pr checks <url> --watch --fail-fast`. This is the
   absolute-mode gate on the whole repo, the first run that judges it;
   everything inside the pipeline ran in delta mode.
   - **Red**: the card line becomes `<nn> Code Review waiting-dependency <date>
     — <the failing check, one sentence>. Nothing is merged.`; `board`; stop
     and report the check. A red here is the backlog's, not this feature's,
     and the merge waits for the story that owns it — say which requirement
     it traces to when the check names one.
   - **Green**: on.
4. **Merge.** `gh pr merge <url> --merge --delete-branch=false`. Keep the merge
   commit (`gh pr view <url> --json mergeCommit`). Pull the default branch.
5. **Prove it live.** Run config's `live:` command from the repo root; keep
   its exit code and output. A non-zero exit is reported, not hidden — the
   merge stands, the card says so.
6. **Card and board.** `<nn> Code Review done <date> — Merged as <short sha>:
   <one sentence of what is now on main>. Live check <passed|failed: one
   clause>; next is Test.` Commit the release file on the default branch,
   push it, run `board`.
7. **Clean.** Dispatch `coding:cleaner` as `software.md` describes — the
   feature name, the feature directory, the pipeline directory, the worktree
   directory, every `wt-<feature>*` and `vf-<feature>-*` path. Only after the
   merge: the cleaner deletes the branches.

Report three lines: the PR URL and merge commit; the live check's result;
the card line as written. Then the story is at Test, which is `qa`'s.

## Never

- Merge on a red check, or re-run a check to make it green.
- Edit the PR body by hand after the checker passed it, or add prose above
  the tests.
- Open a second PR for the same branch; one PR per story.
