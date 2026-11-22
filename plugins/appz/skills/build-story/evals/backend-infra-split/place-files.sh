#!/usr/bin/env bash
# Builds the fixture: a bare origin.git and its clone repo/, with main and PR 1's
# branch (pin-a-note/pr-1, the front end against the stub) committed and pushed.
set -eu
src="$(cd "$(dirname "$0")" && pwd)/files"
git init -q --bare -b main origin.git
mkdir repo
cp -R "$src/main/." repo/
cd repo
git init -q -b main
git config user.name builder
git config user.email ""
git add -A
git commit -q -m "pinboard: story and approved design"
git switch -q -c pin-a-note/pr-1
cp -R "$src/pr-1/." .
git add -A
git commit -q -m "pin-a-note PR 1: board page against the stubbed store"
git switch -q main
git remote add origin ../origin.git
git push -q origin main pin-a-note/pr-1
