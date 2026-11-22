#!/usr/bin/env bash
# Builds the fixture: a bare origin.git and its clone repo/, main committed and pushed.
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
git commit -q -m "tally: story and approved design"
git remote add origin ../origin.git
git push -q origin main
