# A text reaches us and is answered — design

Story: 01-text-answered.md
Reviewed: 2026-09-13

## Flow

Phone        Texting      App          CRM
  |---text---->|            |             |
  |            |--webhook~+>|             |
  |            |            |-upsert~*+->|
  |            |<--reply*+--|             |
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

## Solution
A text to our number reaches the app and gets a reply.
- webhook endpoint https://[env.]stenzil.systems/api/incoming
- Go package pkg/infra/texting
- the reply is sent before the CRM upsert, which is async

Every number that texts us is in the CRM once.
- Go package pkg/infra/crm
- upsert by phone number, five retries with backoff

Each vendor has its own credential.
- envs in CI and app config: TEXTING_TOKEN, CRM_TOKEN, ANALYTICS_TOKEN

## Observed
Every text in and out is logged, by customer id only.
- text in: customer id, text length, time received
- text out: customer id, time to reply in seconds
- person upserted in CRM: customer id, new or existing

A first text is an event, and a text with no reply is an alert.
- texted: customer id; whether this is their first text
- text in with no text out after 15 minutes: customer id

## References
- SMS vendor: ADR 1
- Hosting: ADR 2
- CRM vendor: ADR 3
