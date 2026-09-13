# Design — <task name>

What this task makes true, one row per case, written before any test. The
red-test step writes one subtest per row; the builder builds to the rows; both
reviews judge the change against them. A behaviour a reviewer finds that has no
row here is a gap in this file first, and the row is added before the code is.

Written from the scenarios the task carries (on the story, named by
criteria.md's Rules line), the TRD's Solution and Observed, and the code as
it stands. The first two columns are in the customer's terms; the last is in
the code's. The story is the whitelist: a row with no scenario behind it is
not a row; a row that names something the TRD's Solution or Observed does
not is a row the design review strikes.

| # | Given (the case) | Then (what is true, observably) | Where in the code |
|---|---|---|---|
| 1 | <a definition carries `size: display`> | <the heading renders at the display scale, fluid between its narrow and wide values> | <display/scales.go> |

Everything the scenarios enumerate has a row, and so does everything the code
enumerates where the scenarios only count — every node kind the engine renders,
every setting the server reads, every error path a visitor can hit, every
message a customer can be sent. A row that no test could check is not a row;
rewrite it until one could.

## Size

<the number of rows>. Over 20 rows is a task too big for its tests to carry
the meaning: write `SPLIT` on the next line and name the parts, two to four,
each a thing a customer or the owner can see working when it is done, each
with the rows that go to it; the pipeline re-cuts the task along those lines.
Under 20: write `one task`.
