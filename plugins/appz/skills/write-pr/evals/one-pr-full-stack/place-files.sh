#!/usr/bin/env bash
# Builds the fixture: a bare origin.git and its clone repo/, with main (story and
# approved design) and save-a-link/pr-1 (the built PR) committed and pushed, plus
# inputs/ (the PR's gate result and line counts).
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
git commit -q -m "linkshelf: story and approved design"
git switch -q -c save-a-link/pr-1
cp -R "$src/pr-1/." .
git add -A
git commit -q -m "save-a-link PR 1: store, shelf page, gate and CI"
git switch -q main
git remote add origin ../origin.git
git push -q origin main save-a-link/pr-1
cd ..
cp -R "$src/inputs" inputs
