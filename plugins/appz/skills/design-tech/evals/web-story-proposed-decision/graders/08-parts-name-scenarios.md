---
type: llm
focus: trace
weight: 1
---

Every line under Packages and functions, Schema, routes, commands and events, and Tests that names a part (a function, type, test helper, piece of wiring such as route registration in main.go, route, schema change or test) ends with scenario numbers (digits such as 1 or 2, 3), with no such line carrying "all", "Journey" or nothing in place of numbers, and no such word beside the numbers either: "(Journey, 1, 3)", "(all, 2)" and "(1, 2, all)" each fail (fix b). Only digits may stand for scenarios in the line's scenario list. A line that only says nothing is added ("No events, no commands"), a clause that only says an existing part is unchanged (for example "`List` unchanged"), a line that only says a helper is exercised by the tests above and has no test of its own, an intro sentence, a layer's name (such as "Unit" or "E2E") with what runs that layer, a line saying a layer has no tests and why, and the `Defaults taken:` lines are not parts and need no numbers. Each of the story's scenarios 1 to 5 is named by at least one of them.
