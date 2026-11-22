# Linkshelf interface (commands)

- `shelf add <url> [--note "text"] [--tag name ...]` saves a link. Prints `saved <id>`.
- `shelf list [--tag name]` prints saved links, newest first, one per line: `<id>  <url>  <tags>`.
- `shelf tag <id> <name>` adds a tag to a saved link. Prints `tagged <id>`.
- Data lives in `~/.linkshelf/links.json`. Nothing is sent over the network.
