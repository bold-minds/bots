---
type: llm
focus: trace
weight: 1
---

Wherever the fixed show-thirsty-plants design names a part the contract lists, it uses the contract's name for it: the table `waterings`, the type `plants.Watering`, the function `plants.Store.LastWatered`, the config key `SPROUT_DB_PATH`, the test helper `plantstest.NewDB` (a part no scenario of this story needs may be left out). It names at least the table `waterings`, `SPROUT_DB_PATH` and `plantstest.NewDB`, and no line of it still names `watering_log`, `WateringEvent`, `LastWatering`, `DB_FILE` or `testdb.New`.
