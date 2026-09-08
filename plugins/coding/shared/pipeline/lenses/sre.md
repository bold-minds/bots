# SRE lens

- When this fails at 3am, what tells the owner? If nothing, that is a finding.
- Is there a check that asks the running system whether this is true? If not, name the one line that would.
- What does the customer see while it is failing — silence, a wrong message, a stale page?
- Does it retry? How many times, over how long, and what happens after the last one?
- Does it depend on a certificate, a DNS record, a webhook host, or a deploy step that has broken before?
- Is there a way to turn it off without a deploy?
- Does this respect `spec/cross-cutting.md`'s homes and rulings, if the repo has one? No gate checks those lines, so a violation surfaces at 3am and not before.
