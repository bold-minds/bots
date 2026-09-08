# Architecture lens

- Does this add a new place state lives? Every new store is a new thing that can disagree with another.
- Does it cross a boundary that is fenced today — live vs preview, one tenant vs another, production vs test?
- Does it depend on a name, address, or config value that has moved before?
- Are the writer and the reader of any new field in the same change? A field written with one meaning and read with another is the classic silent failure.
- Which component does it belong in, and does the spec assume the wrong one?
- Could it be done with something that already exists — in this repo, or as a feature of a platform we already pay for? Name it. Does the plan's "Leans on" line hold up, or is it building what a vendor setting would do?
- Is anything here hand-rolled that a maintained package already does? Name it; adopting the dependency is the owner's call, not the plan's.
- Does this respect `spec/cross-cutting.md`'s homes and rulings, if the repo has one? A concern put outside the home it names is a finding.
