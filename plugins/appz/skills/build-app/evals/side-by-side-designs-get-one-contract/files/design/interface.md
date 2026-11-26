# sprout interface

The plants pages already run (repo/cmd/server, repo/web/templates). The watering parts, approved as the app's design:
- Plant page (design/screens/plant-detail.md): the "Last watered" line and the "Watered it" button.
- `POST /plants/{id}/waterings` (design/api.md#post-plantsidwaterings): logs a watering.
- Plants list (design/screens/plants-list.md): the "Thirsty" mark, and the message when the list can't be loaded.
