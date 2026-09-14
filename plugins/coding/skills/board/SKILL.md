---
name: board
description: Renders the status board from the release file and republishes it to the product's artifact. Input a release file (docs/product/<release>.md) whose story lines are card lines. Run it after any stop moves; nothing about the board is drawn by hand. Use when a stop changes, when the owner asks for the board, or when the release file changed.
argument-hint: <docs/product/release.md>
allowed-tools: Bash, Read, Artifact
---

# board

**Input**: a release file — `docs/product/<release>.md` — in the shape
`shared/board/render.py` documents at its top: a title, `Launch: <date>`,
`Board: <artifact url>`, one card line per story
(`<nn> <stop> <state> <YYYY-MM-DD> — <two sentences>`, the
`shared/hil/templates/card.md` shape), an optional `Next: <nn> — <title>`,
an optional `## Before any story builds` list. The story titles come from
the story files beside it. Nothing else is read.

**Output**: the artifact at the `Board:` URL, republished; nothing committed.

## The run

1. `bash ${CLAUDE_PLUGIN_ROOT}/shared/board/render.sh <release.md>
   <scratchpad>/board.html`. Every card line is checked first; a line that
   fails stops the render and its message names the line — fix the release
   file, never the HTML.
2. Publish `<scratchpad>/board.html` with the Artifact tool, `url` = the
   `Board:` line, `label` = today's date and the stop that moved. The
   favicon and title stay as they are.
3. Report one line: the artifact URL and, per story, `<nn> <stop> <state>`.

## Who runs it

Whichever skill moves a stop writes the story's card line in the release
file and then runs this: `story` at Story, `trd` at Design, `pipeline` at
Tasks and Building, `pr` at Code Review, `qa` at Test and Launched; `pm`
after any of them. A stop moved and no board republished is a stop nobody
can see.

## Never

- Edit the HTML. The release file is the board; the HTML is its rendering.
- Publish to any URL but the `Board:` line, or create a second artifact.
- Add a stop, a state or a box the renderer does not know; those change in
  `render.py` with the owner's word, and `check.sh card` with them.
