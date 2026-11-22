# sprout API

## PATCH /plants/{id}
Renames the plant. Form field `name`.

- 200 with the plant's name fragment
- 400 with the text `Give the plant a name of 1 to 40 characters`
- 404 with the text `That plant is gone` when no plant has that id
