# Rename a plant

Shows: Someone opens a plant, gives it a new name, and the page shows the new name.

Design: design/screens/plant-detail.md, design/api.md#patch-plantsid

## Journey
Given the plant "Fern"
When someone opens Fern and renames it "Boston fern"
Then the new name is kept, and the page shows "Boston fern"

## Scenarios
1. Renaming a plant keeps the new name, and it is shown on the plant's page and in the list of plants. (SP6)
2. A name that is empty or over 40 characters once trimmed is refused with "Give the plant a name of 1 to 40 characters", and the old name stays. (SP7)
3. Renaming a plant that no longer exists says "That plant is gone". (SP8)

## Changelog
