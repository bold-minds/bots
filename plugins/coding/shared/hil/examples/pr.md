## Why
Story 06: a texted web address comes back as a link to a page of its own.

- [x] PR 1: replying "Got it" to a texted address and starting one build for it
- [ ] PR 2: refusing a fourth preview in a day before any build starts
- [ ] PR 3: sending "still working on it" once if the build passes five minutes

## What
- Replying "Got it" to any text that carries a web address, and asking for one when the text has none, so a customer always hears back within thirty seconds.
- Recording exactly one build per address texted, so two texts of the same address never build twice.
- No change to how a text without an address is answered; it gets the same ask-for-an-address reply as before.

## How to check
Run the gate from the repo root and it is green. Text an address to the test number and "Got it" arrives within thirty seconds; the build appears once in the log.
