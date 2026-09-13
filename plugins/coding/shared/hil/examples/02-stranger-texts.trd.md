# A stranger texts a web address and hears it is coming — design

Story: 02-stranger-texts.md

## Flow

Phone        Texting      App          Store
  |---text---->|            |             |
  |            |--webhook~->|             |
  |            |            |-record*---->|
  |            |<--reply*---|             |
  |<---text----|            |             |

Legend:
~  async
*  5 retries, exponential backoff

Components:
- Phone: a customer's phone.
- Texting: third-party SMS service.
- App: our Go service on DigitalOcean App Platform.
- Store: object storage for site definitions and build records.

1. Texting → App: inbound text webhook. Existing.
2. App → Store: record the build. Existing.
3. App → Texting: outbound text. Existing.

## Solution
- Add Go package pkg/features/sample

## Observed
Logs, non-error:
- build started: customer id, the address, page count asked for
- taking-longer text sent: customer id, minutes since the build started
- refused, three previews used: customer id
Events:
- sample_requested: customer id; the address's domain, whether this is their first
- sample_refused: customer id; reason "three previews"
Alerts:
- None new

## References
- None

## Review
Not yet reviewed.
