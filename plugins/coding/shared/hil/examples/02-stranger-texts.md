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

## Changelog
