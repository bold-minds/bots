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
+  new in this story
~  async
*  5 retries, exponential backoff

Components:
- Phone: a customer's phone.
- Texting: third-party SMS service.
- App: our Go service on DigitalOcean App Platform.
- Store: object storage for site definitions and build records.

## Solution
The reply and the refusal live in one new package on the existing wire.
- Go package pkg/features/sample
- nothing new on the surface: no env, no endpoint

## Observed
Every build and every refusal is logged, by customer id only.
- build started: customer id, the address, page count asked for
- taking-longer text sent: customer id, minutes since the build started
- refused, three previews used: customer id

A request and a refusal are events.
- sample_requested: customer id; the address's domain, whether this is their first
- sample_refused: customer id; reason "three previews"

## References
- None
