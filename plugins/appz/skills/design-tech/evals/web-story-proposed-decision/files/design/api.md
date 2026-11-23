# sprout API

## POST /plants/{id}/waterings
Logs a watering for the plant now.

- 201 with `{"id": <int>, "plant_id": <int>, "watered_at": "<RFC 3339 time>"}`
- 404 with the text `That plant is gone` when no plant has that id
- 503 with the text `Couldn't save that, try again` when the watering can't be saved
