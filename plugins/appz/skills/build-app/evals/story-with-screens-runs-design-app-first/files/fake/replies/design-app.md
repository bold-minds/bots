Round 1 of the add-item design is written, proposed for markup.

Files:
- build/design/add-item/round-1/screens.html: screens `#list`, `#add`, `#added`, `#empty-item`, each in a phone frame (390 px) and a desktop frame (1280 px) side by side, fold marked, phone status bar drawn; every screen is reached by clicking from `#list`; the save plays its wait ("Saving…") before `#added`; `#empty-item` is brought up from the bar above the frames.
- build/design/add-item/round-1/system.md: parts, interface, decisions (all proposed), gaps and questions.

Parts: `#list` (screens.html#list), `#add` (screens.html#add), `#added` (screens.html#added), `#empty-item` (screens.html#empty-item).

Defaults taken:
- A new item goes at the bottom of the list. *
- The add box sits above the list. *
- An empty item is not added; the page shows "Type an item to add it." *
- Saving shows "Saving…" until the server answers. *
- No limit on an item's length in this round, as no one gave one. *

Questions: none.

## Think answers
- Where did a person say this? Every decision row quotes said.md or ends with *: "I type an item and it is on the list" (said.md, 2026-05-04 18:02).
- Is each part in the form people or code use it? Screens, where people look and touch: "I want one shopping list for the house, on my phone." (said.md, 2026-05-04 18:02).
- Does every action people asked for have a part, and every part an action? Adding has `#add` and `#added`: "| I type an item and it is on the list | What the story is for | proposed |" (system.md, Decisions).
- Did a number, limit, rule or error come from no one? Each is a row marked *: "| The add box sits above the list | Close to the thumb on a phone | proposed | * |" (system.md, Decisions).
- Is every word on a screen something the product says or accepts? Yes, each message has its row: "<p>Type an item to add it.</p><ul><li>milk</li></ul></section></template>" (screens.html, #empty-item).
- Can every screen be reached by clicking, at phone and at desktop width? Yes, from `#list` in both frames: "<form><input placeholder="Add an item"><button type="button" data-go="add">Add</button></form>" (screens.html, #list).
- When revising: does each change trace to a markup note or a change one forced, and is the earlier round as it was? Not reached, a first round; checked the round number: "# Pantry list: add an item, round 1" (system.md).

python3 skills/design-app/scripts/check-design.py build/design/add-item/round-1 said/said.md --answers build/design/add-item/answers.md
FAILS: 0
