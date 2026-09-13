# A text reaches us and is answered — design

Story: 01-text-answered.md

## Flow

Phone        Texting      App          CRM
  |---text---->|            |             |
  |            |--webhook~->|             |
  |            |            |-upsert~*-->|
  |            |<--reply*---|             |
  |<---text----|            |             |

Legend:
+  new in this story
~  async
*  5 retries, exponential backoff

Components:
- Phone: a customer's phone.
- Texting: third-party SMS service; holds our number, delivers texts both ways.
- App: our Go service on DigitalOcean App Platform.
- CRM: third-party CRM.

1. Texting → App: inbound text webhook. New.
2. App → CRM: upsert a person by phone number. New.
3. App → Texting: outbound text. New.

## Solution
- Add envs to CI and app config: TEXTING_TOKEN, CRM_TOKEN, ANALYTICS_TOKEN
- Add Go packages pkg/infra/texting, pkg/infra/crm
- Add external endpoint for the texting webhook: https://[env.]stenzil.systems/api/incoming

## Observed
Logs, non-error:
- text in: customer id, text length, time received
- text out: customer id, time to reply in seconds
- person upserted in CRM: customer id, new or existing
Events:
- texted: customer id; whether this is their first text
Alerts:
- text in with no text out after 15 minutes: customer id

## References
- SMS vendor: ADR 1
- Hosting: ADR 2
- CRM vendor: ADR 3

## Review
| # | Finding | From | Outcome |
|---|---|---|---|
| 1 | The webhook accepts any caller; a forged post would text a stranger from our number. | security | Story: proposed "Given a post to the webhook without the vendor's signature, When it arrives, Then nothing is sent and nothing is stored." |
| 2 | The CRM upsert has no timeout; a slow CRM holds the reply past 30 seconds. | sre | TRD: reply is sent before the upsert; the upsert is async (arrow 2 marked ~). |
| 3 | Five retries on the reply could send the same text five times. | pre-mortem | Dismissed: the vendor de-duplicates on our message id; noted in ADR 1. |
