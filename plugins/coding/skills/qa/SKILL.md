---
name: qa
description: The Test and Launched stops. Input a story and an address: one fresh-context agent walks the Journey and every scenario against that address as a black box, reading nothing the builder wrote, and returns PASS with the scenario list or the first failing scenario. On PASS the story's card line moves the stop; at Launched the story's Changelog gets its launched line and the card its two sentences. Use after a merge deploys to test, and again once prod is deployed; /feature --qa calls it.
argument-hint: <story.md> <address | test | prod> [--launched]
allowed-tools: Agent, Read, Bash, Write, Artifact
---

# qa

**Input**: a story — `docs/product/stories/<nn>-<name>.md`, passing
`shared/hil/check.sh story --approved` — and an address. The address is a
URL, or the word `test` or `prod`, which `<root>/.claude/pipeline/config.md`
resolves through `test_address:` and `prod_address:`. Texting scenarios need
`test_phone:` from the same file; without it they block, they never skip.
Nothing else is read, and nothing has to have run first: a story and a
running address are the whole contract.

**Output**: the verdict, and on PASS the story's card line in the release
file (`docs/product/<release>.md`, the `shared/hil/templates/card.md` shape)
with the board republished; with `--launched`, also the story's Changelog
line and a commit. Nothing on a FAIL but the card line.

## The run

Let `P` be `${CLAUDE_PLUGIN_ROOT}`, `HIL` be `${P}/shared/hil`, `root` be
`git rev-parse --show-toplevel`, `today` be `date +%F`, and `stop` be `Test`,
or `Launched` when `--launched` is passed.

1. **Resolve the address.** A URL is used as given. `test` and `prod` read
   `test_address:` / `prod_address:` from config; a missing key is a question
   to the owner, one line, and the run stops. Read `test_phone:` too; pass it
   when it exists, and say it is absent when it is not.

2. **Dispatch `coding:qa`**, once, with: the story's path; the address; the
   test phone or the words "no test phone"; and nothing else — no TRD, no
   task directory, no branch. It returns `# PASS` with the scenario list,
   `# FAIL: scenario <n>` with expected and got, or `BLOCKED: …`.

3. **On `# PASS`.** Write the story's card line in the release file, replacing
   its existing line:
   - at Test: `<nn> Test done <today> — <what a customer can see on test,
     one sentence>. Next is Launched, once prod is deployed.`
   - at Launched: `<nn> Launched done <today> — <what a customer can see
     now, one sentence>. <what is next, one sentence>.` — and append
     `- <today>: launched` to the story's Changelog.
   Run `bash ${HIL}/check.sh card` on the line (write it to a scratch file
   first) and `bash ${HIL}/check.sh story <story> --approved`; a line printed
   is a defect, fix it before anything is written. Then run the `board` skill
   on the release file. At Launched, commit the story and the release file
   on the branch the story is on: `docs/product: <nn>-<name> launched`.

4. **On `# FAIL: scenario <n>`.** The card line becomes
   `<nn> <stop> waiting-dependency <today> — Scenario <n> failed on
   <test|prod>: <the got line, trimmed>. It goes back to Building.` Check it,
   write it, run `board`. Change nothing else. The story goes back to
   Building through `pipeline`; the failing scenario is the story's own
   scenario, so nothing is added to the story.

5. **On `BLOCKED:`.** Relay the one line to the owner and stop. A missing
   test phone or a Then nobody can observe from outside is theirs to settle —
   a phone to name, or a scenario to rewrite so it can be seen.

6. **Report** in one line: the stop, PASS or the failing scenario number, and
   the board URL.

## Never

- Read a test file, a diff, a task file, a verdict or the TRD to decide a
  scenario. The story and the environment are the whole of the evidence.
- Call a scenario passed on a status code alone when the story quotes copy.
- Skip a scenario. Blocked is a word; skipped is not.
- Move a stop without republishing the board.
