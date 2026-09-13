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

## Changelog
