# Example 1: a technical story. New wires, end to end, no business: the customer sees "Got it."

```
# A text reaches us and is answered

Shows: any text to our number gets a reply, and the number is in the CRM.

## Journey
Given a phone we have never seen
When it texts "anything" to our number
Then the reply arrives within 30 seconds
And the number is in the CRM.

## Scenarios
1. [A3]
   Given any phone number
   When it texts anything to our number
   Then it receives "Got it." within 30 seconds.

2. [K2]
   Given a text has arrived
   When it is received
   Then that number is in the CRM exactly once, with the time of its latest text.

## Flow

Phone        Texting      App          CRM
  |---text---->|            |             |
  |            |--webhook~->|             |
  |            |            |-upsert~*-->|
  |            |<--reply*---|             |
  |<---text----|            |             |

Legend:
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

## Changelog
```

# Example 2: a business story on the wires above. Nothing new in Flow; the content goes in.

```
# A stranger texts a web address and hears it is coming

Shows: a stranger texts our number a web address and is told a preview link is on its way.

## Journey
Given a phone we have never seen
When it texts "https://valleypoolsaz.com" to our number
Then it receives "Got it. You'll get a preview link in a few minutes."
And one build is recorded for that number.

## Scenarios
1. [A1]
   Given a number we have never seen
   When it texts "hi"
   Then it receives "Text me your website address and I'll build you a free preview."
   And nothing else happens.

2. [G7]
   Given a number that has already received three previews
   When it texts a web address
   Then it receives "That's the three free previews for this number."
   And no build starts.

3. [A3]
   Given a build that started five minutes ago with no preview link sent
   When the five minutes pass
   Then the number receives "Still working on it. A few more minutes." once
   And never again for that build.

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

## Changelog
```
