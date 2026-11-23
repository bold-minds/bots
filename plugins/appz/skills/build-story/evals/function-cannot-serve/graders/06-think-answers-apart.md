---
type: llm
focus: trace
weight: 1
---

Apart from the work's report, the returned message answers each of these in one line: does each test serve a scenario; does the code do only what the design lists; does this PR build and test on its own; did anything need a design change (answered with this Parse/Sum question). Each of the four answers gives its finding and quotes, with where it is, text it rests on: a line or part of a line of the design, of the story, of a file in the repo (with the path), or of a command's output (with the command). Where no code was written, an answer quotes what was checked and what stopped the work (for example the design's Parse or Sum signature and the scenario 2 line it cannot serve). Each quote is found word for word (markdown aside) in that place, on the line number given when one is given, and backs the finding; every claim in an answer is backed by one of its quotes. The answer on doing only what the design lists names every file the run changed against main, committed or not, or says from a command's quoted output that there is none. An answer that quotes nothing, such as "Nothing was written" or "Not checked" alone, or that is only "Yes" or "No", fails the assertion; any one such answer fails it.
