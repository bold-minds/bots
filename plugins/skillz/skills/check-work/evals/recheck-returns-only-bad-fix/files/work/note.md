## v3.0.0 - 2026/05/20

Tidepool now ships logs over several connections at once and drops the old config file format.

### Changed
- Uploads now run in parallel across connections.
- Sped up uploads.
- Added a `--timeout` flag that sets how long one upload may take.
- Removed support for the `.tide` config format.

### Breaking
- `.tide` config files are no longer read: convert each one to `tidepool.toml` with `tidepool convert`.
