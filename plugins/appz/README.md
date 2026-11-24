# appz

Building apps from their designs. "App" means any software people or code use: an app, a service, a library.

**Needs `skillz` installed.** The build skill calls `skillz:check-work` and `skillz:settle-question`.

## Skills

In chain order. `build-app` runs the others, one subagent per step.

- `build-app` - take an app's design to shipped code by running each step below in order, one subagent per step; it pushes, opens and merges the PRs and runs the releases itself, and writes a build report at each milestone's end.
- `write-requirements` - turn what people said the app should do, and its design, into a draft requirements file for the caller.
- `plan-milestones` - cut the approved requirements into milestones that each leave the app working and able to do more, in an order.
- `write-stories` - turn requirements into one story per action someone or something takes through the interface.
- `design-app` - design the interface people or code use, and the system behind it, from what people said, as local files proposed for markup: per story with an interface, before its technical design, and once per app before its requirements when there is no design.
- `design-tech` - write the technical design of one story before it is built: packages, functions, schema, routes, commands, events, libraries, how it is cut into PRs, and the tests for every layer the story needs.
- `build-story` - build one PR of a story from its approved technical design in its own git worktree: every test first and seen failing, then the code until they pass and the gate is green, committed locally and never pushed.
- `write-pr` - write the title and description of each PR of one story from the story, its design, and each PR's diff, gate result and line counts; pushing and opening stay with the caller.
- `ship-milestone` - check a milestone is ready to ship, write its release notes, return the release commands in order, and check each release with the milestone's E2E suite.

## Install

```
claude plugin install skillz@bots
claude plugin install appz@bots
```
