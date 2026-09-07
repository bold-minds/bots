# Tests — <task name>

| criterion | test | level | now | proves it |
|---|---|---|---|---|
| <first line of the Given> | `TestX_InClairesWords` in `<file>` | unit / integration / bdd / e2e / fitness | RED / GREEN | <what was broken on purpose and the test went red> |

Test names are the criterion in Claire's words. Failure messages say what the
customer would have experienced.

A GREEN test with no "proves it" entry is not finished. Break the thing it
guards; watch it go red; restore; then record what you broke.

Run with: `TRIGGER_POSTGRES_DSN=… go test -run <name> -count=1 -v ./…`
A skip is not a pass. `ok` with `--- SKIP` proves nothing.
