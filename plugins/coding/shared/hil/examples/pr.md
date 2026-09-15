## What changed
- A text with a web address in it now gets "Got it" back and one build is recorded; a text without one gets the ask-for-an-address reply.
- A fourth preview in a day is refused before any build starts.
- "Still working on it" goes out once, at five minutes, if the build is not done.
- 61 lines of production code across pkg/features/texts and pkg/preview; nothing else moved.

## Why
Story 06: a texted web address comes back as a link to a page of its own.

## How to check
`scripts/gate.sh` from the repo root: green, engine 82%. Text an address to the test number and get "Got it" within 30 seconds.

## Tests
- Journey: a web address gets "Got it" and one build is recorded — PASS on https://stenzil-brand.stenzil.dev
- 1 [A1] "hi" gets the ask-for-an-address text, nothing else — PASS
- 2 [G7] a fourth preview is refused, no build — PASS
- 3 [A3] "still working on it" once at five minutes — PASS

## Verdict
# PASS
- Tests prove their scenarios: yes, each went red when broken; each on the story verbatim
- Held to the story: Solution yes; Observed yes; References yes
- Rulings respected: checked, fine
- Gate: green
- Touched only what plan.md said: yes; tests untouched after the plan commit
