Misses:
1. repo/docs/product/stories/show-thirsty-plants.design.md, `## Tests`, Unit: "`web`: `thirstySet(ids []int64) map[int64]bool` holds each id given." tests an unexported helper. design-tech step 9 asks: "Check that each unit and integration test the design adds or changes reaches only what its packages export". Kind: test reaches unexported code.

## Think answers
- Do I have the skill's text, the work and the work's Think-answers record? Yes, all three as given in the brief.
- Does the work break a line the skill states, or is the miss something the skill doesn't say? It breaks step 9's export line, quoted above.
