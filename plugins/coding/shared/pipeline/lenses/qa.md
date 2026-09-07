# QA lens

- For each thing the spec promises, what is the cheapest test that proves it — unit, integration, end-to-end, fitness? Name it.
- Which criteria can only be proven by running the product? Those need the end-to-end environment, not a unit test.
- What would a test double have to fake, and could the fake hide the bug?
- What message does the customer get in each failure the pre-mortem kept? Is it written, or an empty string?
- Is anything promised in copy that no code performs? Every "we'll follow up" needs a sender.
- Which existing tests would this change break, and are they guarding a behaviour or a symptom?
