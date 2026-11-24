---
name: design-app
description: Design an app's interface and the system behind it from what people said it should do, in whatever form people or code use it (screens, endpoints, commands, library functions), as local files a story can point to, proposed for markup before anything is built. Screens come as one playable HTML file per round, at phone and desktop width, every screen reachable by clicking; endpoints, commands and functions come as one page per part; a short system page holds the parts that run, the decisions with who they came from, and the open questions. Revises a marked-up round into the next round beside it. "App" means any software people or code use: an app, a service, a library, a tool. Use whenever an app, service, library or tool needs its design before requirements, stories or code, when there is no design and no running interface, and whenever a design round comes back marked up.
---

# Design app

## In
- What people said the app should do, in their own wording, in the order it was said, each with where it was said. What people said is marked apart from anything AI added.
- A folder it can write the design in.
- The `skillz:settle-question` skill.
- Optional: an interface the design must fit: a running app, its code, a brand or a design system.
- Optional, when revising: the earlier round's files, and the markup on them: each note, with the part it is on.

## Out
Written as local files in the folder, one subfolder per round, `round-<N>/`, starting at `round-1/`. The caller publishes or shares them.
- The interface, in the form people or code use it:
  - Screens: `round-<N>/screens.html`, one self-contained file that plays. Each screen shows at phone width and at desktop width; every screen is reachable by clicking from the first; each screen has an id, and opening the file at `#<id>` shows that screen.
  - Endpoints, commands or functions: one page per part, `round-<N>/<part>.md`, with its signature, inputs, outputs, errors and an example call with its result.
- `round-<N>/system.md`: the parts that run and how they talk; each part of the interface with its path or link; a decisions table (decision, why, status `proposed` or `approved`, and last, from whom: the shortest quote that says it, with where it was said, or ` *` for a default or a pick); and the gaps and questions.
- When revising: `round-<N+1>/` beside `round-<N>/`, with `round-<N+1>/changes.md`: each change, and the markup note it traces to, quoted, or the change that forced it. `round-<N>/` stays byte for byte as it was.
- Returned to the caller: where each file is, each part with its path, the defaults taken, each question from `skillz:settle-question` with its pick, and the change list when revising, with each shortfall of the earlier round kept as it was beside it.
- This skill's Think answers, in the reply to the caller after the rest of the return, one line per question, each saying what it led the skill to do and, in quotes with where it is, the line it rests on. Kept apart from the work, and followed by the command that checked them and its last line, `FAILS: 0`.

## Think
- Where did a person say this?
- Is each part in the form people or code use it: screens where people look and touch, endpoints where software calls over a network, commands where people or scripts run it, functions where code calls it?
- Does every action people asked for have a part, and every part an action?
- Did a number, limit, rule or error come from no one?
- Is every word on a screen something the product says or accepts?
- Can every screen be reached by clicking, at phone and at desktop width?
- When revising: does each change trace to a markup note or a change one forced, and is the earlier round as it was?

## Act
1. Check each input against `## In` before anything else. If what people said, the folder or the `skillz:settle-question` skill is missing or falls short, or, when revising, the earlier round or its markup is, return to the caller exactly what's missing and what it must contain, with the Think answers. When revising, go to step 7.
2. Read what people said. List each action people or code take with the app, and who or what takes it. Pick the interface's form per action: screens where people look and touch, endpoints where software calls over a network, commands where people or scripts run it, functions where code calls it. When an interface to fit is given, use its form, parts, names and look, and add to it.
3. Settle each question with `skillz:settle-question`.
   - Settle from what people said and the interface to fit first; take a default on what is easy to undo; return a question with its pick only for what is hard to undo and changes what comes next.
   - `skillz:settle-question` returns each new question it names with no answer; take each one to `skillz:settle-question` as a question of its own, so every question returned carries a pick.
   - Take every number, limit, rule and error from what people said or the interface to fit, or mark it ` *`: a default and a question's pick both came from no one yet.
   - A line comes from someone only when a quote says it; a detail that goes past a quote's words (which characters are kept, the order of a list, the wording of a message, a name, the absence of a limit) is marked too.
4. For screens, write `round-<N>/screens.html` as one file with its styles and scripts inline. When the app has screens and other parts too, write steps 4 and 5 at the same time; step 6 waits for both, since its `## Interface` lists their paths.
   - Show each screen in a phone frame 390 px wide and a desktop frame 1280 px wide (default), side by side; a click in either moves both to the screen it leads to.
   - Link every screen from the first by the clicks people make in the app, including the empty, loading and error states people said or would plainly hit.
   - Give each state that only typing, a failure or time passing brings up (no match, a lost connection, a due date passed) a control that brings it up, in a bar above the frames marked as not part of the app.
   - Where a screen waits on something (a save, a search, a send), play the wait out in real time, then the result.
   - Mark the fold on each frame: 844 px down on the phone, 800 px on the desktop (default).
   - Draw a status bar on each phone: the time, and icons for signal, wifi and battery.
   - Fill each screen with what the product says or accepts: its labels, its messages, and sample entries of the kind people said they'd make.
5. For endpoints, commands or functions, write one page per part, `round-<N>/<part>.md`: the signature (method and path, the command with its flags, or the function in the app's language), each input with its type and limits, the outputs, each error with when it happens and what the caller gets, and an example call with its result. Under the title, write `Said: "<shortest quote>" (<where>)` for each thing people said that the part serves. End each line that holds a number, limit, rule or error with ` *` unless it copies a quote's own words; a line that applies a quote to a case it doesn't name, or rests on a pick, gets ` *` too. In a code block, put the ` *` in a comment on the line, an error's message wording included.
6. Write `round-<N>/system.md`.
   - `## Parts`: each part that runs (for example a page, a server, a store, the library and its caller), and how they talk: the calls between them and what they carry.
   - `## Interface`: a line for each screen, with its own path (`screens.html#shelf`, say), and a line for each other part, with its path.
   - `## Decisions`: a table with columns Decision, Why, Status, From, so a ` *` in From ends its row.
     - Give every number, limit, rule and error the design uses its own row; one row may cover several messages when it names each.
     - Status is `proposed` for every row of a new round.
     - From holds the shortest quote that says it, with where it was said, or ` *` for a default or a pick. It holds quotes alone only when the Decision copies their own words; when it rests on more than one, give each.
     - Every other row ends From with ` *`, after the quote it rests on if there is one: a reading such as a field being required, a quote applied to a case it doesn't name (a limit applied after a later step, what happens when nothing needs doing), a pick, a label's wording, where a thing sits, a detail, and a row that rests on a question or a maybe.
     - Split a row that joins a quote's words with more, so the copied part keeps its quotes alone and the rest gets its own row marked ` *`.
   - `## Gaps and questions`: each question from step 3 with its pick, and each thing people left open with the default the design takes, named in words as what the design does; a thing the design leaves out is a default too. End each line that holds a pick or a default with ` *`.
   Then go to step 8.
7. When revising, record a checksum of each file in `round-<N>/`, and copy `round-<N>/` to `round-<N+1>/`.
   - Change only what a markup note touches, what such a change forces, and the round number where the files name it. A change is forced when without it the round would break or contradict a note (for example a link to a removed screen).
   - A part a note adds gets the waits and states step 4 gives every screen.
   - Build each change from the note, the earlier round and what people said, keeping the round's flow, names, look, code and table columns where no note changes them.
   - Where the earlier round already fell short of what people said and no note asks for more (a sample list that keeps an item it should drop), keep it as it was and name it to the caller beside the change list, for the next markup.
   - Take a question to `skillz:settle-question` only when a change can't be written without its answer.
   - Set a decision's status to `approved` where the markup approves it, and add a row for each decision a note makes, with the note quoted in From.
   - Write `round-<N+1>/changes.md`: each change, with the note quoted or the change that forced it.
   - Check every checksum in `round-<N>/` again, and run a diff of each file in `round-<N+1>/` against its earlier one: give every hunk a line in `changes.md` naming the note it traces to, the change that forced it, or the round number, and undo every other hunk.
8. Check the work. When revising, make each pass below over only what this round's changes added or changed, and give each row it adds a line in `changes.md` naming that change.
   - For screens, read `screens.html` back: list each screen's id and the screens each one's clicks lead to, and confirm every screen is reached from the first, at both widths, that each action that saves, sends or loads plays its wait, and that each id has its line in `## Interface`.
   - Go through each screen's text and each line of every page in the round, `system.md` included, in turn, and list every number, limit, rule, error, message, name and list order on it; check that each has a row in `## Decisions` whose From quotes its words or ends in ` *`, and add the rows that are missing.
   - Check that each entry in `## Gaps and questions` carries a pick or a default named in words, on a line ending with ` *`.
9. Evaluate the work against each `## Think` question, and fix what fails one.
   - Answer every question, in order, each as one list item that starts with the question and says what the check found across the whole question (every screen at both widths, every word added), in this form: `<question> <what it led you to do>: "<quoted line>" (<where it is>).`
   - Give a quoted line and where it is for each thing the answer claims. A quoted line is something people said, a markup note, or a line of the design, copied from one line as it stands; where it is names the file and the message, section or screen.
   - For a question the call doesn't reach (screens in a design with none, revising in a first round), say what was checked instead and quote it.
   - Write the answers to a scratch file outside the round's folder, and save what people said (and, when revising, the markup) as files beside it.
   - Run `python3 <the folder holding this SKILL.md>/scripts/check-design.py <the round's folder> <said file> --answers <answers file>`, adding `--markup <markup file> --earlier <the earlier round's folder>` when revising. Fix each FAIL (copy the quote's words, add the missing decisions row marked ` *`, split the rest into a row marked ` *`, or add the ` *`) and run it again until it prints `FAILS: 0`.
   - Then check what the script can't: that each quote shows what its answer says; rewrite an answer that fails.
10. Reply to the caller with what `## Out` lists, then, under their own heading in the same reply, the Think answers copied word for word from the file the check passed, then the check's command and its last line as it printed.
