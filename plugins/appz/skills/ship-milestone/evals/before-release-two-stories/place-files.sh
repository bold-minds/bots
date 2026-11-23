#!/usr/bin/env bash
# Builds the fixture: origin.git (a bare repo standing in for the remote) and its clone repo/.
# main holds the gate and release path (Taskfile.yml), CI, and both stories with approved designs;
# split-a-bill/pr-1 and add-a-tip/pr-1 are built and merged into main, and all is pushed.
# places/ holds the test place and the live place, neither released to yet.
set -eu
src="$(cd "$(dirname "$0")" && pwd)/files"
export GIT_AUTHOR_DATE="2000-01-01T12:00:00Z" GIT_COMMITTER_DATE="2000-01-01T12:00:00Z"
git init -q --bare -b main origin.git
mkdir repo
cp -R "$src/main/." repo/
cd repo
git init -q -b main
git config user.name builder
git config user.email ""
git add -A
git commit -q -m "tipjar: gate, release path, stories and approved designs"
git switch -q -c split-a-bill/pr-1
cp -R "$src/split/." .
git add -A
git commit -q -m "split-a-bill PR 1: the split command"
git switch -q main
git merge -q --no-ff -m "Merge split-a-bill/pr-1" split-a-bill/pr-1
git switch -q -c add-a-tip/pr-1
cp -R "$src/tip/." .
git add -A
git commit -q -m "add-a-tip PR 1: the --tip option"
git switch -q main
git merge -q --no-ff -m "Merge add-a-tip/pr-1" add-a-tip/pr-1
git remote add origin ../origin.git
git push -q origin main split-a-bill/pr-1 add-a-tip/pr-1
git branch -q -u origin/main main
cd ..
cp -R "$src/places" places
