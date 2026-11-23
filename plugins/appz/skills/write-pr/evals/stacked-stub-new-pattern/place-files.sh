#!/usr/bin/env bash
# Builds the fixture: a bare origin.git and its clone repo/, with main (story, approved
# design, gate and CI), mark-a-chore-done/pr-1 (front end on the stubbed store) and
# mark-a-chore-done/pr-2 (the real store, replacing the stub), committed and pushed,
# plus inputs/ (each PR's gate result and line counts).
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
git commit -q -m "chorelist: story and approved design"
git switch -q -c mark-a-chore-done/pr-1
cp -R "$src/pr-1/." .
git add -A
git commit -q -m "mark-a-chore-done PR 1: chore page on the stubbed store"
git switch -q -c mark-a-chore-done/pr-2
cp -R "$src/pr-2/." .
while read -r f; do git rm -q "$f"; done < "$src/pr-2.delete"
git add -A
git commit -q -m "mark-a-chore-done PR 2: litesql store with migrations, replacing the stub"
git switch -q main
git remote add origin ../origin.git
git push -q origin main mark-a-chore-done/pr-1 mark-a-chore-done/pr-2
cd ..
cp -R "$src/inputs" inputs
