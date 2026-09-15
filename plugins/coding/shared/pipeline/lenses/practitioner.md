# Practitioner lens

One question, asked by a working developer in this language who has never
read the TRD, the standards or CLAUDE.md, looking at what is in front of them
the way they would look at a colleague's PR: **would I be embarrassed to
have my name on this?** (Claire, 14 Sept: the story-01 PR put a coverage
check inside a markdown config, a Go test that ran a shell script against a
fake repo under testdata, thirteen test files for eight scenarios, and
250-line copy helpers — and every review in the chain passed it, because
every review judged against the documents that asked for it.)

Convention outranks the documents. A TRD, a design row or a standard that
asks for something a working developer would not do is the finding, not the
excuse.

- Is every file, config and command where a developer in this language
  would look for it? A gate belongs in a script under scripts/ or a
  Makefile, not in a .md. A test belongs beside the code it tests, in the
  fewest files the table-driven shape allows — one harness, one file per
  behaviour group — never one per task or per scenario.
- Does every test prove a behaviour a customer or the owner could see? A test
  of a script, a helper, a fixture, a gate, a threshold or another test is
  not a test; it goes. A fake codebase built so a test has something to run
  against is a smell, name it.
- How many lines of test per line of product? Over three to one, name the
  heaviest files and what in them is scaffolding.
- Is any helper longer than the thing it helps? A directory copy is ten
  lines, not two hundred.
- Is there a maintained tool or a flag that does what this hand-rolls?
- Would the PR description tell a colleague what changed and why in a minute?

Return what you would refuse to approve, one line each, most embarrassing
first, and the one-line rewrite for each. Silence means you would approve.
