# Before asking the owner anything

Ask yourself these, in order. The first one that answers, decides.

1. **What is the benefit of doing this?** None → don't do it, don't ask.
2. **Is there already a ruling?** Check the rulings files. Yes → apply it,
   cite it, move on — **unless the story asks for the opposite. The owner's new
   words contradicting the owner's old ruling is not yours to resolve: stop and
   ask, quoting both. Never pick one silently, in either direction.**
3. **Is there prior art — in this repo, in a platform we already pay for, or
   in a maintained package?**
   Search this repo for the nearest existing message, check, helper, or
   pattern. Then ask whether a platform already in play — the messaging
   provider, the edge, the store, the payment provider — has a feature that
   does this outright. A vendor setting that refuses a number class beats code
   that refuses it; an environment the edge already offers beats a project we
   run ourselves. Then, for anything that is not the product itself, name the
   maintained third-party package or tool that already does it. Maintained is
   recent releases, real adoption, no open critical issues, a licence we can
   use — a dependency-review tool, if one is installed, answers that; do not
   guess. Write our own only after writing down why the package does not fit,
   and take the dependency to the owner: a new one is a new external system,
   already one of the four below — unless the story's References names it,
   in which case it is ruled and never asked. Reuse or extend what exists;
   never build a second one beside it. Any default you propose — including the default
   inside a BLOCKED question — comes from the nearest existing thing, named,
   not from invention.
4. **Does the answer change what a customer is promised — what they get,
   when, or what it costs?** Yes → that is one of the four things below, and it
   stays the owner's however cheap it is to change. The exact words a refused
   customer reads are what they get. No → keep going.
5. **Is it a naming, structure, or implementation detail?** Yes → never ask.
6. **Can a test settle it instead of a person?** Yes → write the test.
7. **Is it cheap to reverse?** Yes → pick the simplest, note it, move on.
8. **Would any sensible engineer pick the same answer?** Yes → pick it.

The order matters, and 4 sits above 7 on purpose. Something a customer reads
is theirs even when changing it costs nothing; a naming or structure choice is
never theirs even when changing it costs a lot.

## Ask the owner only if the question is one of these

- It changes a promise to a customer: what they get, when, what it costs.
- It costs money, or commits to a vendor, or changes a provider — **except a
  vendor, service or piece of infrastructure the story's References names**:
  every item there has its ADR approved before the story is, so it is ruled,
  and the same goes for a package, endpoint or env the story's Solution
  lists. Only what the story does not name is asked.
- It contradicts an existing ruling — including one of their own newer
  sentences contradicting an older ruling.
- It is top-level technical direction: caching, storage, a new external system
  the story does not name.
- **The gate says `architecture review needed`.** That check exists to put a
  named list in front of the owner, and it clears on an
  `Architecture-Review-Approved:` trailer that is their signature. No agent
  writes that trailer on its own — a self-issued approval makes the check a
  string you type to go green, and it means nothing from that commit on. A red
  that is only this one is never rework and never a retry: write `BLOCKED.md`
  listing the items the check printed, exactly as it printed them, and halt.
  The owner's answer arrives as `answers` on the next run, and the step that
  asked records exactly the items they approved, quoting their answer.
- **A frozen artefact only a restart can change** — a case redtest left out
  of a task's tests. No step after the plan commit may touch a test, so the
  fix is the task run again from its start with the case written into its
  criteria; that restart is the owner's, never rework.

## Before writing your output file

Ask: **will the next step get high quality from this, or rework?**

- Could the next step read this two ways? It will pick the wrong one. Say it
  once, unambiguously. (A field written with one meaning and read with another
  doubled the trial length and every test stayed green.)
- Does this describe what the customer gets, or what the code does? Code
  changes; the customer's outcome is the spec.
- Would the step after next have to come back and ask? Answer it now.
- Is anything here a guess wearing the clothes of a fact? Mark it UNKNOWN or
  go check.
- Is this the smallest output that fully does the job? Extra words are places
  to be misread.
- **Does this design create a recurring human step?** A notice per event, a
  message per sender, an inbox item per failure, a decision someone has to
  make every time — that is a person in the loop on the normal path, and it is
  wrong by ruling. Say how often it would fire. Automate it, or write BLOCKED
  and ask. The owner is involved when something is completely failing or no
  automated process exists — never as a routine step in a design.

What that means at each step:

- **lens** — a finding the breakdown can act on, not a concern it has to interpret
- **premortem** — a Given/When/Then, not a worry
- **breakdown** — a task one agent finishes in one session, or split it
- **redtest** — a test that pins the customer's outcome, not the implementation
- **planner** — the change that will not have to be undone by the next task
- **builder** — the test went green because the behaviour changed, not because the test got weaker
- **verifier** — this question, asked of everything above

If any answer is "rework", fix it before writing. That is cheaper than every
step after you fixing it.

## How to ask

Write `BLOCKED.md` in your step's output directory — the feature directory for
the feature-level steps (plan, lenses, pre-mortem, breakdown, and the whole
feature at the end), the task directory for every step inside a task. Return
its first line as your result too, so the chain halts. `BLOCKED: ` on the first
line, then:

- the question — **one** question, one sentence, in business language. Two
  questions in one sentence cannot be answered in one line. No file names, no
  function names, no test names: if the owner has to read code to answer it,
  it is not written yet.
- what you'd do if they say nothing, one sentence (your best default)
- what changes if they say otherwise, one sentence

Nothing else. They answer in one line, and that line comes back to the run as
an argument — nobody edits `BLOCKED.md` to deliver it. The step that was
blocked re-runs with the ruling in front of it, deletes the file, and the chain
resumes.
