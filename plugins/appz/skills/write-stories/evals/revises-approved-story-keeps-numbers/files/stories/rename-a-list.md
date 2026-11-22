# Rename a list

Shows: The person opens a list's menu, types a new name, saves, and sees the new name on their lists.

Design: design/screens/rename-list.md

## Journey
- Given a list named "Groceries"
- When the person opens its menu, types "Weekend shop" and saves
- Then the list shows as "Weekend shop" on their lists

## Scenarios
1. TL-1: Saving a new name shows it on the person's lists.
2. TL-1: Cancelling leaves the name as it was.
3. TL-1: Saving an empty name keeps the old name and asks the person to type a name.
4. TL-2 *: A name longer than 40 characters is not saved; the person is told the name is too long and to shorten it.
5. TL-1: Saving a name another of their lists already has keeps the old name and tells the person that name is taken.
6. TL-1: Saving the name the list already has changes nothing and shows no error.

Defaults taken:
- TL-2: the name limit is 40 characters (no source gave a number).

## Changelog
- Approved.
