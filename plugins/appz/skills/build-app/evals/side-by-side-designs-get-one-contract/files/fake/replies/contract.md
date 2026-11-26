The milestone's contract is written at build/data/contract-M1.md.

Build order: 1. log-a-watering, 2. show-thirsty-plants (it reads the waterings log-a-watering keeps).

Parts named by more than one design, each with one name and its owner: the store step `migrations/002_waterings.sql` and the table `waterings`, the type `plants.Watering`, the function `plants.Store.LastWatered` (show-thirsty-plants adds `plants.Store.Thirsty`), the config key `SPROUT_DB_PATH` (a file path), and the test helper `plantstest.NewDB` (show-thirsty-plants adds `plantstest.Water`), all owned by log-a-watering. Dropped as clashes: `watering_log`, `002_watering_log.sql`, `plants.WateringEvent`, `plants.Store.LastWatering`, `DB_FILE`, `testdb.New`.

Questions, one list for the milestone, in place of each design's own numbering:
1. Use htmx for page updates (decision 0002 is proposed)? Pick: yes, accept 0002. Hard to undo. Rests on it: log-a-watering, show-thirsty-plants.
2. When does a plant count as thirsty? Pick: 7 days after its last watering, or when never watered, config key `SPROUT_THIRSTY_AFTER_DAYS`, in days, default 7. Rests on it: show-thirsty-plants.
3. How are watering times kept? Pick: RFC 3339 text in UTC. Hard to undo: both designs took it as a default. Rests on it: log-a-watering, show-thirsty-plants.
