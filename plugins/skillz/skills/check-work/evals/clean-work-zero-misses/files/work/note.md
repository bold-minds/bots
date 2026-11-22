## v2.5.0 - 2026-04-02

Tidepool gains a doctor command and ships logs from rotated files without gaps.

### Changed
- Added the `tidepool doctor` command, which checks the config and the connection to each host.
- Fixed gaps in shipped logs after a file rotates.
- Raised the default batch size from 200 to 500 lines
- Updated the bundled TLS roots.
