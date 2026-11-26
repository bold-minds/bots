# Show thirsty plants

Shows: Someone opens the plants list and sees which plants need water.

Design: design/screens/plants-list.md

## Journey
Given "Fern" was last watered 8 days ago and "Ivy" was watered today
When someone opens the plants list
Then Fern is marked "Thirsty" and Ivy is not

## Scenarios
1. A plant last watered longer ago than the thirsty time is marked "Thirsty" on the list. (SP7)
2. A plant watered within the thirsty time has no mark. (SP7)
3. A plant never watered is marked "Thirsty". (SP7)
4. When the app can't read its database, the list says "Couldn't load your plants, try again". (SP8)

## Changelog
