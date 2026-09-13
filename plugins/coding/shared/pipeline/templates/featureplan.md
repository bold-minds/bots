# Plan — <feature name>

The story carries the Journey, the Scenarios, the Solution, what is Observed
and the References. This plan repeats none of them; it says how the pieces the
story names get built, in the components' names.

## Approach

<Five to ten lines. How this gets built, in the components' names, not the
files'.>

## Touches

- Leans on: <a platform capability that does part or all of this — named,
  with what it does — or "none: <why no platform in play does it>">
- Components: <which of the program's parts — each one named, and after it the
  path it lives at (`the queue worker — internal/worker/`).>
- New state: <any new store, field, marker, flag — who writes it, who reads it>
- Outside calls: <only what the story's Solution and References already name;
  a call to anything outside them is a BLOCKED, not a plan line>
- Stays untouched: <the nearby things this must not change>

## Structural rules

<Rules about the code's shape this feature must keep or introduce — "the
worker never imports the server", "nothing reaches the live copy except
through the fence". Each becomes a fitness test. Usually one or none.>

## Decided here

<Choices triage let this step make, one line each, so nobody re-asks.>

## Open

<Only what the owner must decide, already past triage. Usually empty.>
