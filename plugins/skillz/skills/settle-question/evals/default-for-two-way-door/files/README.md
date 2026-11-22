# pebble-cli
A small command line tool for a personal reading list.

Commands:
- `pebble add <url>`: save a link
- `pebble list [--tag TAG] [--limit N]`: show saved links, newest first
- `pebble done <id>`: mark a link read

Config lives in ~/.pebble/config.toml. Nothing in it sets a page size.
Output is plain text, one link per line. Nobody outside the author uses it yet.
