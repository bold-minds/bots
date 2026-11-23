---
type: llm
focus: trace
weight: 1
---

Every line under Packages and functions, Schema, routes, commands and events, and Tests that names a part (a function, type, test helper, piece of wiring, route, schema change or test) ends with scenario numbers (digits such as 1 or 2, 3), with no such line carrying "all", "Journey" or nothing in place of numbers, and no such word beside the numbers either: "(Journey, 1, 3)", "(all, 2)" and "(1, 2, all)" each fail (fix b). Only digits may stand for scenarios in the line's scenario list. A line that only says nothing is added ("None", "No new helper or wiring"), a line or clause that only says an existing part stays unchanged (for example "existing tests stay as they are"), an intro sentence, and the `Defaults taken:` lines are not parts and need no numbers. Each of the story's scenarios 1, 2 and 3 is named by at least one of them.
