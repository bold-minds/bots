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

Run with: `<the test command the dispatch names, exactly as it names it, with
`<TestName>` replaced by this test's name and `<module dir>` by the directory of
the module that holds it, and the name anchored: -run '^<TestName>$'>`

A skip is not a pass. A green summary line over a skipped test proves nothing,
and neither does one over a test that never ran: `no tests to run` and
`no test files` are failures. The run counts as green only if the output carries
`--- PASS: <the test name>`.

## Files

<Every file this commit holds other than this one, one repo-root-relative path per line: test
files — `*_test.go`, or whatever this repo calls them — and paths under
`testdata/`. Nothing else may be here: a helper that is not a test file is a
stub with a name. The verifier reads this list; a committed file it does not
name is a BLOCK, and after the plan commit nothing may touch a file it names.>

## Green together

<One paragraph: one implementation that makes every test above green at once —
which package gains what, which file changes how — with each assertion checked
against it. Two tests that cannot both be green against one implementation
contradict each other; the builder may not change what a test asserts, so a
contradiction here stops the task. Rewrite until they agree.>

## Gate

<The gate, run in delta mode against the feature branch. Paste the first RED
line the committed tests stop at, and say which it is: these tests failing; or
the missing behaviour showing earlier — `undefined: <symbol>`, a new package
with no non-test files, a package not attached to any component — naming the
symbol, package or component the builder must add, or the After: task that
already provides it; or no RED, because every criterion is TRUE or the gate
has no arm that runs this module's tests. Say
that the lint and boundary arms between that line and the tests arm, if any,
ran green with a stub in place, and that the stub is gone from this commit.>
