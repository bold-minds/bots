# Merge tag lists

Shows: A caller passes several tag lists to Merge and gets back one list with each tag once, in the order first seen.

Design: design/tagset.md#merge

## Journey
Given the lists ["Go", "Web Dev"] and ["web  dev", "CLI"]
When the caller calls tagset.Merge with both lists
Then it returns ["go", "web-dev", "cli"]

## Scenarios
1. Tags that normalize to the same tag appear once, where first seen. (TG3)
2. A tag with no letters or digits is left out, and the rest are returned in order. (TG4)
3. When no lists, or only empty lists, are passed, Merge returns an empty list. (TG3)
4. Merging 10 lists of 1,000 tags each takes under 20 ms. (TG5)

## Changelog
