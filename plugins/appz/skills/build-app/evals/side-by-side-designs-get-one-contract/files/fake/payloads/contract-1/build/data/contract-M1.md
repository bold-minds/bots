# Milestone M1 (Watering): contract

Written from the designs of log-a-watering and show-thirsty-plants and from their stories.

## Build order
1. log-a-watering: it keeps the waterings.
2. show-thirsty-plants: it reads the waterings log-a-watering keeps.

## Parts
| Part | Name | Owner | What later stories add |
|---|---|---|---|
| Store step | `migrations/002_waterings.sql` | log-a-watering | show-thirsty-plants: nothing |
| Table | `waterings (id INTEGER PRIMARY KEY, plant_id INTEGER NOT NULL REFERENCES plants(id), watered_at TEXT NOT NULL)` | log-a-watering | show-thirsty-plants: nothing; it reads the table |
| Type | `plants.Watering{ID, PlantID int64; WateredAt time.Time}` | log-a-watering | show-thirsty-plants: nothing |
| Function | `plants.Store.LastWatered(ctx, plantID int64) (time.Time, bool, error)` | log-a-watering | show-thirsty-plants: `plants.Store.Thirsty(ctx, now time.Time, after time.Duration) ([]int64, error)` |
| Config key | `SPROUT_DB_PATH`: the SQLite file's path, default `sprout.db` | log-a-watering | show-thirsty-plants: nothing |
| Test helper | `plantstest.NewDB(t) *sql.DB`: a migrated SQLite file in `t.TempDir()` | log-a-watering | show-thirsty-plants: `plantstest.Water(t, db, plantID int64, at time.Time)` |

## Questions
1. Use htmx for page updates (decision 0002 is proposed)? Pick: yes, accept 0002. Hard to undo: every page update is built on it. Stories whose lines rest on it: log-a-watering, show-thirsty-plants.
2. When does a plant count as thirsty? Pick: 7 days after its last watering, or when never watered, set by config key `SPROUT_THIRSTY_AFTER_DAYS`, in days, default 7. Stories whose lines rest on it: show-thirsty-plants.
3. How are watering times kept? Pick: RFC 3339 text in UTC. Hard to undo: stored rows keep the form. Stories whose lines rest on it: log-a-watering, show-thirsty-plants.
