---
name: ship-milestone
description: Get one milestone ready to ship, and check each release of it, once every story's PRs are built. Before release, confirm every story's PRs are merged into the main branch, run the full gate there once with every test layer, write the release notes from the stories and merged PRs, and return the repo's own release commands, in order, for the caller to run. After each release step, run the milestone's E2E suite against what was released and return pass or fail per scenario, and for a test release whether to release live. It prepares and checks; the caller merges, deploys, tags and publishes, and fixes what fails. Works for any app, service or library and any release path the repo defines (a deploy to a test place then a live one, a version tag). Use once per milestone after its stories' PRs are in, and again after each release step, whenever a milestone is to be shipped, released, deployed, tagged or checked after release.
---

# Ship milestone

## In
- The milestone: its name and its stories, each with its PRs (a PR address or a branch) and their merge state as the caller knows it.
- Each story: its Journey and its numbered scenarios.
- Each story's technical design `## Tests`: its E2E tests, each with its scenario numbers, and the command that runs them, taking the address or version to test (for example a variable or a flag).
- The app's repo, with its remote, its main branch, its gate (the checks every change must pass, running every test layer the designs list), and its release path: how it ships, as its CI or Taskfile defines it (for a service or app, a deploy to a test place then a live place; for a library, a version tag).
- The call: before release, or after a release step. After a release step: which step it was, the address or version it released, and the commit it released.
- The `skillz:settle-question` skill.

## Out
Returned to the caller. Every remote, branch, tag and released place stays as the run found it; what the run makes is local: a git worktree for the gate, and one for the E2E suite.
- Before release:
  - Per story, each PR and whether it is merged into the main branch, with the command that showed it and its output.
  - The gate result on the main branch: the commit, the command, pass or fail for each test layer, and the output lines that show it.
  - The release notes in Markdown, ready to paste: what the milestone lets people do, by story, in plain words. Beside them, each line with the story line or merged PR it comes from.
  - The release steps, in order, each the exact command from the repo's release path for the commit the gate passed on, each followed by the call to this skill that verifies it.
- After a release step: per scenario, by story and number, pass or fail, with the command and its output. Then the verdict: after a test release, "release live" when every scenario passes, or "do not release live" with the failing scenarios; after the last step, that the milestone shipped, or the failing scenarios.
- On a failure (a PR not merged, the gate red, a scenario failing): what failed, with its command and output, as the return's last result; the code stays as it is, for the caller to fix.
- Each question from `skillz:settle-question`, with its pick.
- This skill's Think answers, one line per question, each saying what it led the skill to do and, in quotes with where it is, the line it rests on; for a question the call doesn't reach, what was checked instead, quoted. Kept apart from the work.

## Think
- Is every story's PR merged into the main branch, by the repo's own state?
- Did the gate run every test layer, on the commit that will ship?
- Does every line of the release notes come from a story or a merged PR?
- Is each release step the repo's own command, for the gated commit, with live only after the E2E suite passes on test?
- Does each scenario's result come from a command and its output?
- Did the run leave every remote, branch, tag and released place as it found them?

## Act
1. Check each input against `## In` before anything else. If one is missing or falls short, return to the caller exactly what's missing and what it must contain, before running any command. A repo with no remote or no release path is a missing input, and so is an E2E command that can't take an address or version: the suite has to test what was released. Return the Think answers with it, each quoting what was checked and what stopped the work.
2. Fetch the remote, then list its branches and tags with a command (for example `git ls-remote <remote>`) and keep the output for step 7. For a call after a release step, go to step 6.
3. For each PR: with a PR address, read its state and base branch from the host (for example `gh pr view <address> --json state,baseRefName`); with a branch, check that its tip is in the remote's main branch (`git merge-base --is-ancestor <remote>/<branch> <remote>/<main>`, then `echo $?`). Keep each command and its output. If any PR isn't merged into the main branch, keep which ones, by story, with the commands and their output, and go straight to step 7, past steps 4 to 6: the gate and the notes are for the whole milestone.
4. Check out the remote main branch's tip in its own git worktree and note its commit. Run the full gate there once. Check from its output that it ran each test layer the designs' `## Tests` list. If the gate fails or leaves a layer out, keep what failed, with its output lines, and go to step 7.
5. Write the release notes and the release steps.
   - Notes: a heading for the milestone, then a short section per story of what people can now do, in plain words, from its Journey and scenarios. Check each line against a story line or a merged PR; reword it to what that source says, or cut it. List each line beside its source, in quotes with where it is.
   - Steps: read the release path from the repo's CI workflows and Taskfile: each task or job that deploys, tags or publishes, and what each needs (a commit, a version, a place). Write each step as the exact command the repo defines, for the commit the gate passed on, so what ships is what was tested. When a step needs a value the inputs and the repo don't give (for example the next version number), settle it with `skillz:settle-question` and write the command with the pick.
   - For a service or app: the test deploy; this skill's call against the test place; the live deploy, to run only once that call returns "release live"; this skill's call against the live place.
   - For a library: the tag, and the publish when the path has one; then this skill's call against that version.
   Then go to step 7.
6. After a release step: in a git worktree at the released commit, run every E2E test the milestone's designs list, with the designs' command pointed at the released address or version, verbose so each test reports its own result. Give each scenario, by story and number, pass or fail, with the command and its test's output lines. After a test release, return "release live" when every scenario passes, or "do not release live" with each failing scenario and its output. After the last step, return that the milestone shipped, or each failing scenario with its output.
7. List the remote's branches and tags again with the same command, and compare with step 2's output.
8. Evaluate the work against each `## Think` question, and fix what fails one. Answer each in one line, in this form: `<question> <what it led you to do>: "<quoted line>" (<where it is>).` The quoted line is a story or design line, a line of the release path, or a command with a line of its output, copied from one line as it stands, in the answer itself. For the last question, give step 2's and step 7's commands with what they printed. Give every answer a quote, also for a question this call doesn't reach (for example the release notes after a release step, or the gate when a PR isn't merged): say what was checked instead and quote it, such as the input line that names the call or the command output that stopped the work.
9. Return to the caller what `## Out` lists for the call made, and the Think answers apart from the work.
