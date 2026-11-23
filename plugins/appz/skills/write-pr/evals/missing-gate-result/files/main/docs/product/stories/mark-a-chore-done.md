# Mark a chore done

Shows: someone ticks a chore off the list and it shows as done, with when.

Design: design/screens/chores.md

## Journey
Given the list holds "Water the ferns", not done
When I mark "Water the ferns" done
Then the list shows it ticked, with the time it was done

## Scenarios
1. Given a chore not done, When I mark it done, Then the list shows it ticked with the time it was done.
2. Given a chore already done, When I mark it done again, Then it stays done once, with the first time.
3. Given no chore with that number, When I mark it done, Then I see "No such chore" and the list is unchanged.
4. Given a chore marked done, When the app restarts, Then the list still shows it done with the same time.
5. Given the list can't be saved, When I mark a chore done, Then I see "Couldn't save that, try again" and the chore stays not done.

## Changelog
- Written.
