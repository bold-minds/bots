---
type: llm
focus: trace
weight: 1
---

The design plans a chaos test for scenario 5 that breaks the SQLite database for real while the app runs (for example removes, locks or makes read-only the database file, or closes the database) and checks what the person gets: "Couldn't save that, try again", with the page still showing the last watering it had or nothing new kept.
