The log-a-watering design is fixed at repo/docs/product/stories/log-a-watering.design.md, a draft for approval.

Changes:
- Fixed to the milestone's contract: the `watered_at` line in `migrations/002_waterings.sql` now says "(pick for question 3)", as the contract numbers it; the UTC default moved into the contract's question 3. Every part this design owns already carries the contract's name.
- check-work's miss: added `### Chaos`: "Make the file at `SPROUT_DB_PATH` read-only after start; pressing "Watered it" shows "Couldn't save that, try again" and the line keeps the last watering. 5", and PR 2 now holds chaos tests (about 90 lines).

Questions (the contract's numbers):
1. Use htmx for page updates (decision 0002 is proposed)? Pick: yes, accept 0002.
3. How are watering times kept? Pick: RFC 3339 text in UTC.

## Think answers
- Does each part have one job? Nothing changed: each part keeps, reads or shows waterings.
- Does it reuse what the repo already has? Nothing changed: plants.Store, web.ShowPlant, SQLite.
- Does a scenario need each part? Added the chaos test scenario 5 needs.
- Can each PR be built and tested on its own? Nothing changed: PR 1 on the stub, PR 2 replaces it.
- Is it cut into as few PRs as fit the limit? Changed PR 2's estimate to about 90 lines for the chaos test.

python3 skills/design-tech/scripts/check-design.py repo/docs/product/stories/log-a-watering.design.md
FAILS: 0
