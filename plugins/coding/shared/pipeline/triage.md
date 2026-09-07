# Before asking Claire anything

Ask yourself these, in order. The first one that answers, decides.

1. **What is the benefit of doing this?** None → don't do it, don't ask.
2. **Is there already a ruling?** Check `requirements.md` and `decisions.md`.
   Yes → apply it, cite it, move on.
3. **Is it a naming, structure, or implementation detail?** Yes → never ask.
4. **Can a test settle it instead of a person?** Yes → write the test.
5. **Is it cheap to reverse?** Yes → pick the simplest, note it, move on.
6. **Would any sensible engineer pick the same answer?** Yes → pick it.
7. **Does the answer change what a customer is promised — what they get,
   when, or what it costs?** No → decide it yourself and note the choice.
   Yes → that is one of the four things below.

The order matters. A customer-visible string that is cheap to change is
decided at 5, not escalated at 7.

## Ask Claire only if the question is one of these

- It changes a promise to a customer: what they get, when, what it costs.
- It costs money, or commits to a vendor, or changes a provider.
- It contradicts an existing ruling.
- It is top-level technical direction: caching, storage, a new external system.

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

What that means at each step:

- **lens** — a finding the breakdown can act on, not a concern it has to interpret
- **premortem** — a Given/When/Then, not a worry
- **breakdown** — a task one agent finishes in one session, or split it
- **redtest** — a test that pins the customer's outcome, not the implementation
- **planner** — the change that will not have to be undone by the next task
- **builder** — the test went green because the behaviour changed, not because the test got weaker
- **reviewer** — this question, asked of everything above

If any answer is "rework", fix it before writing. That is cheaper than every
step after you fixing it.

## How to ask

Write `BLOCKED.md` in your step's output directory — the feature directory for
steps 1–4, the task directory for steps 5–9. Return its first line as your
result too, so the chain halts. `BLOCKED: ` on the first line, then:

- the question, one sentence, in business language
- what you'd do if they say nothing, one sentence (your best default)
- what changes if they say otherwise, one sentence

Nothing else. They answer in one line. The chain resumes.
