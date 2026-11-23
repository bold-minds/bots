---
type: llm
focus: trace
weight: 1
---

The revised design adds no package, function, route, library, PR or test that is not in the earlier design or asked for by the markup. A change to a line's estimate that the markup's change forces does not count as added. A new entry under `Defaults taken:`, a standard-library function named to settle a detail the markup left open (for example how length is counted), and any new line the markup doesn't touch and no change forces, all count as added (fix c). So does a clause added to a changed line that settles a detail the markup, the earlier design and the repo leave open (for example that web.RenamePlant trims the name, or that it is the part that checks the name with plants.ValidName). Naming the existing plants.Store.Update where Rename was used does not count, nor does saying that web.RenamePlant saves, sets or calls the name through Update (the earlier design has the handler as Rename's only caller, and the markup says to use Update instead), nor restating what the repo's Update already fixes (its signature, that it takes the plant with its id and new name, that it returns ErrNotFound). A line the markup doesn't touch that is retitled or reworded for any other reason counts as added.
