# ToolShelf design

Web app, phone first. Paths below are the screens.

## Screens

- `/join` : sign-up. Asks for a name and a street code. The street code decides whose tools you can see.
- `/shelf` : my tools. Each row shows photo, name, and who has it right now, with its due date. A button goes to `/shelf/new`.
- `/shelf/new` : add a tool. Name and photo are both required.
- `/street` : every tool on my street, newest first. Tools on other streets never appear.
- `/tool/{id}` : one tool. An "Ask to borrow" button opens a date picker for the return date.
- `/requests` : requests I received. Each has Yes and No buttons.
- `/shelf` rows alternate grey and white backgrounds, and the `/street` header shows the number of tools in a small grey badge.

## Proposed (not decided)

- Proposed: neighbors see a tool's owner by first name only, or by full name.

## Rules and numbers

- A loan can be at most 5 days.
- A late reminder goes out at 9am the day after the due date, once a day, 3 times at most. It is sent to the borrower by push notification.
- One person can have at most one open request on the same tool.
