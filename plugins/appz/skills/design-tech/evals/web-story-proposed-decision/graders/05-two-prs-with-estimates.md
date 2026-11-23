---
type: llm
focus: trace
weight: 1
---

The PRs section estimates the changed lines, tests included, for each PR it lists. It lists the front end (the plant page's last-watered line and its Watered it action) in one PR and the back end with its data (at least the migration and the store's watering methods) in another, with a third PR for the infra only if the infra has changed lines. A PR whose estimate is over the prompt's 100 lines stays one PR: no part (front end, back end, infra) is cut into two or more PRs, and no question or pick the run returns asks about a PR's size or a further split. No part is built in two PRs.
