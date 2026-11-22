# appz

Building apps from their designs. "App" means any software people or code use: an app, a service, a library.

**Needs `skillz` installed.** The build skill calls `skillz:check-work` and `skillz:settle-question`.

## Skills

- `build-app` - take an app's design to shipped code by running each delivery step in order, one subagent per step.
- `write-requirements` - turn what people said the app should do, and its design, into a draft requirements file for the caller.
- `write-stories` - turn requirements into one story per action someone or something takes through the interface.

`build-app` also refers to `appz:design-app`, which is not part of this plugin yet.

## Install

```
claude plugin install skillz@bots
claude plugin install appz@bots
```
