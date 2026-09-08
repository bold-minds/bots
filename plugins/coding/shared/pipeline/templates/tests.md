# Tests — <task name>

| criterion | test | level | now | proves it |
|---|---|---|---|---|
| <first line of the Given> | `TestX_InTheOwnersWords` in `<file>` | unit / integration / end-to-end / fitness | RED / GREEN | <what was broken on purpose and the test went red> |

Levels: **unit** for a rule, **integration** for a store or a queue,
**end-to-end** for the whole path a customer walks through the real
environment, **fitness** for a rule about the shape of the code — a test that
reads the code and fails if the rule is broken.

Test names are the criterion in the owner's words. Failure messages say what
the customer would have experienced.

A GREEN test with no "proves it" entry is not finished. Break the thing it
guards; watch it go red; restore; then record what you broke.

Run with: `<the test command the dispatch names, exactly as it names it>`
A skip is not a pass. A green summary line over a skipped test proves nothing.
