# shelf

A small web page that lists the books on a reading shelf.

- `store`: the shelf itself, in memory.
- `web`: the server-rendered shelf page.
- `cmd/shelf`: the server (`-addr`, default `:8080`; `-books`, a file of titles, one per line).

Gate: `task check` (also run by CI). Fast checks while working: `task fast`.
