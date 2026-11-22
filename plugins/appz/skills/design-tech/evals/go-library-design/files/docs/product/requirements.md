# tagset requirements

## Cleaning tags
**TG1. Normalize turns a tag into lowercase, with inner spaces joined by one hyphen.**
**TG2. A tag with no letters or digits is an error.**

## Combining tags
**TG3. Merge combines any number of tag lists into one list that holds each normalized tag once, in the order first seen.**
**TG4. Merge leaves out a tag with no letters or digits and keeps the rest.**
