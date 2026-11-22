# Log a watering

Shows: Someone opens a plant, logs that they watered it, and the page shows it was last watered just now.

Design: design/screens/plant-detail.md, design/api.md#post-plantsidwaterings

## Journey
Given the plant "Fern" has never been watered
When someone opens Fern and logs a watering
Then the watering is kept with its time, and Fern's page shows "Last watered: just now"

## Scenarios
1. Logging a watering keeps it with the time it was logged. (SP3)
2. A plant never watered shows "Not watered yet". (SP4)
3. After a watering, the plant's page shows when it was last watered, and it is still shown after the page is opened again. (SP4)
4. Logging a watering for a plant that no longer exists says "That plant is gone", and nothing is kept. (SP5)

## Changelog
