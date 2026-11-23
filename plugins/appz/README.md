# appz

Building apps from their designs. "App" means any software people or code use: an app, a service, a library.

**Needs `skillz` installed.** The build skill calls `skillz:check-work` and `skillz:settle-question`.

## Skills

- `build-app` - take an app's design to shipped code by running each delivery step in order, one subagent per step.
- `write-requirements` - turn what people said the app should do, and its design, into a draft requirements file for the caller.
- `plan-milestones` - cut the approved requirements into milestones that each leave the app working and able to do more, in an order.
- `write-stories` - turn requirements into one story per action someone or something takes through the interface.
- `design-tech` - write the technical design of one story before it is built: packages, functions, schema, routes, commands, events, libraries, how it is cut into PRs, and the tests at each package's exported surface.
- `build-story` - build one PR of a story from its approved technical design in its own git worktree: tests first and seen failing, then the code until they pass and the gate is green, committed locally and never pushed.

`build-app` also refers to `appz:design-app`, which is not part of this plugin yet. `verify-story`, `open-pr` and `ship-milestone` are not written yet either.

## Install

```
claude plugin install skillz@bots
claude plugin install appz@bots
```
