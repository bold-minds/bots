# Practitioner lens

One question, asked by a working developer in this language who has never
read the TRD, the standards or CLAUDE.md, looking at what is in front of them
the way they would look at a colleague's PR: **would I be embarrassed to
have my name on this?**

Convention outranks the documents. A TRD, a design row or a standard that
asks for something a working developer would not do is the finding, not the
excuse. And the list below is not the question — it is the places this
pipeline has already been caught (story 01, 14 Sept: a coverage check inside
a markdown config, a Go test running a shell script against a fake repo,
thirteen test files for eight scenarios, 250-line copy helpers). A diff can
be embarrassing in a way no line here names; the question still applies.

Ask it of everything, in this order:

- **The approach.** Is this the way a competent developer would do it, or
  the way someone who read a specification would? Is there a simpler shape
  that delivers the same behaviour — fewer types, fewer layers, fewer
  files, no abstraction that has one caller, no configurability nothing
  configures, no generality for a second case that does not exist?
- **The place.** Is every file, config and command where a developer in
  this language would look for it? A gate belongs in a script or a
  Makefile, not in a .md. Tests sit beside the code, in the fewest files
  the table-driven shape allows. A setting lives where the language's tools
  read settings.
- **The dependencies.** Would a developer add this package for this? Is
  there a standard-library or already-present way?
- **The tests.** Does every test prove a behaviour a customer or the owner
  could see? A test of a script, a helper, a fixture, a gate, a threshold
  or another test is not a test. A fake codebase built so a test has
  something to run against is a smell. How many lines of test per line of
  product — over three to one, name the heaviest files and what in them is
  scaffolding. Is any helper longer than what it helps?
- **The words.** Names a colleague would understand without the TRD.
  Comments that say why, not what; none that narrate the pipeline. A commit
  message and a PR body that say what changed.
- **The size.** Would a reviewer read this diff in one sitting? If not,
  what is in it that the story did not ask for?

One thing is never the rewrite: deleting a log line to get a function under
a length or complexity cap. What the code logs is the owner's (Claire, 16
Sept 2026, on story 02's PR: "put the logging back, split the func, same
moving forward"). A function over its cap is split; its log lines survive
the split in the same order with the same text.

Return what you would refuse to approve, one line each, most embarrassing
first, and the one-line rewrite for each. Silence means you would approve.
