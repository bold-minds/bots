---
name: write-release-note
description: Write the release note for one version of a small tool from its list of changes.
---

# Write release note

## In
- The list of changes in the release, one per line.
- The version number and release date.

## Out
- One file, `note.md`, that starts with the heading `## v<version> - <date>`, the date written as YYYY-MM-DD.
- Under the heading, a one-sentence summary of 20 words or fewer.
- A `### Changed` list with one bullet per change, each bullet starting with a past-tense verb.
- A `### Breaking` section, only when a change is breaking, with one item per breaking change that says what the reader must do.

## Think
- Is any change breaking?
- Which change will a user notice most?
- Does any change repeat another, so that it is cut?

## Act
1. Read the changes and answer the Think questions.
2. Cut every change that repeats another.
3. Write `note.md` with the most noticeable change first in `### Changed`.
