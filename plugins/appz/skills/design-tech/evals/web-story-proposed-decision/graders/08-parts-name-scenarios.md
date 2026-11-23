---
type: llm
focus: trace
weight: 1
---

Every line under Packages and functions, Schema, routes, commands and events, and Tests that names a part (a function, type, test helper, piece of wiring such as route registration in main.go, route, schema change or test) ends with scenario numbers (digits such as 1 or 2, 3), with no such line carrying "all", "Journey" or nothing (fix b). A line that only says nothing is added ("No events, no commands"), an intro sentence, and the `Defaults taken:` lines are not parts and need no numbers. Each of the story's scenarios 1 to 4 is named by at least one of them.
