---
type: llm
focus: trace
weight: 1
---

Every unit and integration test the design lists goes through a package's exported surface (for example the HTTP route, a web handler constructor, or exported plants.Store methods); none tests an unexported function.
