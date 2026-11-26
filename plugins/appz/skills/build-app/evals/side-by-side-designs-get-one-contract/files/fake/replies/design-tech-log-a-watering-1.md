The design for log-a-watering is written at repo/docs/product/stories/log-a-watering.design.md, a draft for approval.

Parts: `plants.Watering`, `plants.Store.LogWatering`, `plants.Store.LastWatered`, `web.LogWatering`, `web.ShowPlant`, `plantstest.NewDB`; `migrations/002_waterings.sql` (table `waterings`); `POST /plants/{id}/waterings`; config `SPROUT_DB_PATH`. Two PRs: front end on a stub (about 60 lines), back end with its data (about 80 lines).

Defaults taken:
- Times are kept as RFC 3339 text in UTC. *

Questions:
1. Use htmx for page updates (decision 0002 is proposed)? Pick: yes, accept 0002.

## Think answers
- Does each part have one job? Nothing changed: each part keeps, reads or shows waterings, one each.
- Does it reuse what the repo already has? Nothing changed: it builds on plants.Store, web.ShowPlant and SQLite.
- Does a scenario need each part? Nothing changed: every part lists the scenarios it serves.
- Can each PR be built and tested on its own? Nothing changed: PR 1 runs on the stub, PR 2 replaces it.
- Is it cut into as few PRs as fit the limit? Nothing changed: the story is over 100 lines as one PR, so front end | back end.

python3 skills/design-tech/scripts/check-design.py repo/docs/product/stories/log-a-watering.design.md
FAILS: 0
