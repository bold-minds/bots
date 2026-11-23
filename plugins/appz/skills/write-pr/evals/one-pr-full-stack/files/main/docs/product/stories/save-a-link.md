# Save a link

Shows: someone saves a web address under a name and gets a short address for it on the shelf.

Design: design/screens/links.md

## Journey
Given the shelf is empty
When I save "https://example.com/recipes/bread" under the name "Bread"
Then the shelf lists Bread with the short address /l/bread
And opening /l/bread takes me to https://example.com/recipes/bread

## Scenarios
1. Given the shelf is empty, When I save a web address under a name, Then the shelf lists it with a short address made from the name.
2. Given the shelf holds a link named "Bread", When I save another link named "Bread", Then the new one gets the short address /l/bread-2.
3. Given any shelf, When I save "ftp://example.com/file" under a name, Then nothing is saved and I see "Enter a web address".

## Changelog
- Written.
