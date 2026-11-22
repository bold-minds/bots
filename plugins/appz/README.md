# appz

Building apps from their designs.

**Needs `skillz` installed.** The build skill calls `skillz:check` and `skillz:ask-or-decide`.

## Skills

- `build` - take an app's designs to shipped code by running each delivery step in order, one subagent per step.
- `requirements` - turn the owner's words into the app's requirements file.
- `stories` - turn requirements into one story per user action.

`build` also refers to `appz:design`, which is not part of this plugin yet.

## Install

```
claude plugin install skillz@bots
claude plugin install appz@bots
```
