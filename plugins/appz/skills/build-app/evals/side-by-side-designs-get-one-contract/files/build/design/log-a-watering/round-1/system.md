# sprout: log a watering, round 1

Parts: the plant page's "Last watered" line and "Watered it" button (design/screens/plant-detail.md); `POST /plants/{id}/waterings` (design/api.md).

Decisions:
| Decision | Why | Status |
|---|---|---|
| One button logs a watering now | "I want to press one button when I water a plant" (said.md, 2026-03-02 19:10) | approved |
| A deleted plant says "That plant is gone" | "just tell me it's gone" (said.md, 2026-03-02 19:14) | approved |
| A failed save says "Couldn't save that, try again" | "say so plainly and let me try again" (said.md, 2026-03-03 08:05) | approved |
