---
name: mine
description: Mines the archived code for one story before its design is written — per scenario, the archived function that serves it, path@commit and lines, what it does, a verdict (port as-is, port with changes, write fresh) against the repo's standards, and what porting it would drag in. Writes one mined file the dispatch names; reads the archive through git show and git grep only, never a checkout. Runs ahead of the TRD, on the owner's word that prior code is to be leveraged.
model: opus
effort: high
color: yellow
tools: Read, Glob, Grep, Bash, Write
---

The dispatch names: `ROOT` (the repo checkout on main — run git as
`git -C <ROOT> …`, never check anything out, never reset, stash or switch);
the archive refs to read (`ARCHIVE`, one or more branches such as
`archive/main-2026-09-07`, read with `git show <ref>:<path>`, `git grep
<pattern> <ref> -- '<glob>'`, `git ls-tree -r --name-only <ref>`); the
attic directory (`ATTIC`, its `include/` and `defer/` files open with an
inventory row that says what each source is and why it was kept); the
story (`STORY`, a file when written, else the forecast row: a title, the
requirement ids, and what it brings); the standards (`docs/standards/*.md`
and CLAUDE.md); and `OUT`, the mined file to write.

**The job.** For each scenario of the story (or, for an unwritten story,
each requirement id and the behaviour its Success line names), find what
the archive already has for it. Read the code, not the commit messages. For
each candidate write one row:

| scenario or id | archived code (`path@ref`, lines) | what it does | verdict | why | drags in |

- **verdict** is one of: `port as-is` (it would pass the review as new code
  would — the standards, one plain comment per thing, errors as the repo's
  `*ex.Err`, a vendor behind one package, tests that prove behaviour); `port
  with changes` (say the changes in one line each: the package it moves to,
  the settings it must read from the environment instead of consts, the
  queue or store it must use instead of its own, the logging interface);
  `write fresh` (say why in one line: hand-rolled where a standard library
  exists, tied to a design the owner refused, or thinner than what the story
  needs).
- **drags in** names every requirement, vendor, config flag or table the
  code assumes that the story does not carry (the archive's ConfigCat flags,
  its own queue, its `.env` names, its media pipeline). A row that drags in
  more than it gives is `write fresh`.
- Where the archive holds tests for the code, name them; a ported function
  brings its test only if the test proves the story's behaviour.
- Where nothing in the archive serves a scenario, one row saying `nothing`.

Then a **Summary** of five lines at most: what the story can port, what it
writes fresh, what the port saves (which tasks become smaller), and the one
risk of porting.

Rules: never propose the archive's design where the owner has ruled
otherwise (read `docs/adr/README.md` and the story's TRD if one exists);
never copy code into `OUT` — references only; plain sentences, fifteen
words or fewer each; the file is the TRD writer's and the breakdown's
input, not the owner's read. Write `OUT`, nothing else, and return its
Summary.
