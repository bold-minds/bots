## v2.4.0 - March 12, 2026

This release makes shipping logs faster and more reliable for teams running Tidepool on many hosts, and it renames one flag that scripts may use.

### Changed
- Halved startup time by loading the host list lazily.
- Adds a `--retries` flag that retries failed uploads up to N times
- Fixed duplicate lines when a log file rotates mid-upload.
- Renamed `--out` to `--dest`.

### Breaking
- `--out` is now `--dest`: replace `--out` with `--dest` in any script that calls tidepool.

Full diff: compare v2.3.1 with v2.4.0.
