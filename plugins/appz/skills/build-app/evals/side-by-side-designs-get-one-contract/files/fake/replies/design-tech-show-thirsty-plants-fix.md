The show-thirsty-plants design is fixed at repo/docs/product/stories/show-thirsty-plants.design.md, a draft for approval.

Changes:
- Fixed to the milestone's contract: `watering_log` and `002_watering_log.sql` dropped for log-a-watering's `waterings` table; `plants.WateringEvent` and `plants.Store.LastWatering` replaced by log-a-watering's `plants.Watering` and `plants.Store.LastWatered`; `DB_FILE` replaced by `SPROUT_DB_PATH`; `testdb.New` replaced by `plantstest.NewDB`, with `plantstest.Water` added as the contract says this story adds; `THIRSTY_AFTER_HOURS` (168) replaced by `SPROUT_THIRSTY_AFTER_DAYS` (days, default 7). The thirsty line now says "pick for question 2", the htmx line "pick for question 1", the UTC line "pick for question 3". The PR builds on log-a-watering's PR 2 and is about 100 lines.
- check-work's miss: dropped the `web` unit test on the unexported `thirstySet`; `ListPlants`'s test covers it.

Questions (the contract's numbers):
1. Use htmx for the list's update (decision 0002 is proposed)? Pick: yes, accept 0002.
2. When does a plant count as thirsty? Pick: 7 days after its last watering, or when never watered, in `SPROUT_THIRSTY_AFTER_DAYS`, in days.
3. How are watering times kept? Pick: RFC 3339 text in UTC.

## Think answers
- Does each part have one job? Nothing changed: Thirsty finds plants, ListPlants shows them.
- Does it reuse what the repo already has? Changed: it uses log-a-watering's table, type, function, config key and test helper instead of its own.
- Does a scenario need each part? Dropped the thirstySet test, which reached an unexported helper.
- Can each PR be built and tested on its own? Changed: the PR builds on log-a-watering's PR 2, which adds the table it reads.
- Is it cut into as few PRs as fit the limit? Nothing changed: one PR, now about 100 lines.

python3 skills/design-tech/scripts/check-design.py repo/docs/product/stories/show-thirsty-plants.design.md
FAILS: 0
