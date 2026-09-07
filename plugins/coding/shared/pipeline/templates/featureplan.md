# Plan — <feature name>

## Approach

<Five to ten lines. How this gets built, in the components' names, not the
files'.>

## Touches

- Components: <which of the program's parts>
- New state: <any new store, field, marker, flag — who writes it, who reads it>
- Outside calls: <any vendor, provider, or external system — or "none">
- Stays untouched: <the nearby things this must not change>

## The journey

<The one path a customer walks end to end for this feature, as a sentence or
three. This becomes the journey task's end-to-end test.>

## Structural rules

<Rules about the code's shape this feature must keep or introduce — "the
worker never imports the server", "nothing reaches the live copy except
through the fence". Each becomes a fitness test. Usually one or none.>

## Decided here

<Choices triage let this step make, one line each, so nobody re-asks.>

## Open

<Only what the owner must decide, already past triage. Usually empty.>
