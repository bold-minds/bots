# Design: Toolshed interface (web site)

Every page is reached from the Home menu; nothing is linked only from another page except where noted.

| Part | Path | Notes |
|---|---|---|
| Home | /home | Menu with links to every part below. Stewards also see the Steward console link. |
| Catalog | /catalog | Grid of tools with a name, photo and status ("Available", "On loan", "In repair"). Each tool opens its Item page. |
| Item page | /tools/{id} | One tool's details and a "Borrow" button, linked only from the Catalog. |
| Checkout | /tools/{id}/borrow | Pick a return date, at most 14 days out. Reached from the Item page's "Borrow" button. |
| My Loans | /loans | A member's held tools with due dates and a "Return" button. |
| Steward console | /steward | Add a tool, mark a tool in repair or back in service, and a list of overdue loans. Stewards only. |
| Reminder notice | email | Sent two days before the due date; links to My Loans. |

Rules: a tool is borrowed by one member at a time. Every page uses real buttons and links so the keyboard reaches them in order.
