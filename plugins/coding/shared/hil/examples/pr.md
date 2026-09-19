## Why
Story 06: a texted web address comes back as a link to a page of its own.

- [x] PR 1: replying "Got it" to a texted address and starting one build for it
- [ ] PR 2: refusing a fourth preview in a day before any build starts
- [ ] PR 3: sending "still working on it" once if the build passes five minutes

## What
- A text with a web address is answered "Got it".
- A text with no address is asked for one.
- An address texted twice builds once.
- A text without an address is answered as before.

## How to check
Run the gate from the repo root and it is green. Text an address to the test number and "Got it" arrives within thirty seconds; the build appears once in the log.
