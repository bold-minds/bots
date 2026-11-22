---
type: llm
focus: trace
weight: 1
---

The PRs section estimates the changed lines, tests included, for each PR it lists, and every estimate is within the limit of 200 the prompt gives. It lists two PRs: the front end (the plant page's last-watered line and its Watered it action) in one, and the back end with its data and any infra (at least the migration and the store's watering methods) in the other. Only if its own estimate for the back end with infra is over 200 may it list three PRs, with the back end and the infra apart. No part is built in two PRs.
