The design for show-thirsty-plants is written at repo/docs/product/stories/show-thirsty-plants.design.md, a draft for approval.

Parts: `plants.WateringEvent`, `plants.Store.LastWatering`, `plants.Store.Thirsty`, `web.ListPlants`, `testdb.New`; `migrations/002_watering_log.sql` (table `watering_log`); config `DB_FILE` and `THIRSTY_AFTER_HOURS`. One PR, about 140 lines.

Defaults taken:
- Times are kept as RFC 3339 text in UTC. *

Questions:
1. When does a plant count as thirsty? Pick: 168 hours after its last watering, or when never watered, in `THIRSTY_AFTER_HOURS`.
2. Use htmx for the list's update (decision 0002 is proposed)? Pick: yes, accept 0002.

## Think answers
- Does each part have one job? Nothing changed: each part reads waterings or shows the mark.
- Does it reuse what the repo already has? Nothing changed: it builds on plants.Store and web.ListPlants.
- Does a scenario need each part? Nothing changed: every part lists the scenarios it serves.
- Can each PR be built and tested on its own? Nothing changed: one PR holds the whole story.
- Is it cut into as few PRs as fit the limit? Nothing changed: one PR.

python3 skills/design-tech/scripts/check-design.py repo/docs/product/stories/show-thirsty-plants.design.md
FAILS: 0
