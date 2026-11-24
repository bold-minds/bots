#!/usr/bin/env bash
# Builds the fixture: origin.git (a bare repo standing in for the remote) holding main, and its clone repo/
# with the story's built PR on the branch add-item/pr-1, committed and not pushed. Then the build folder,
# the fakes, and the step skills and skillz skills at skills/<name>/SKILL.md.
set -eu
here="$(cd "$(dirname "$0")" && pwd)"
src="$here/files"
appz="$here/../../.."
skillz="$appz/../../skillz/skills"
export GIT_AUTHOR_DATE="2000-01-01T12:00:00Z" GIT_COMMITTER_DATE="2000-01-01T12:00:00Z"
git init -q --bare -b main origin.git
mkdir repo
cp -R "$src/main/." repo/
cd repo
git init -q -b main
git config user.name builder
git config user.email ""
git config commit.gpgsign false
git add -A
git commit -q -m "pantry: list package, story and approved design"
git remote add origin ../origin.git
git push -q origin main
git branch -q -u origin/main main
git switch -q -c add-item/pr-1
cp -R "$src/pr/." .
git add -A
git commit -q -m "add-item PR 1: list.Add and POST /items, with unit, integration and E2E tests"
sha="$(git rev-parse HEAD)"
cd ..
cp -R "$src/fixture/." .
mkdir -p build/data/gates
sed "s/@SHA@/$sha/" gate-template.txt > build/data/gates/add-item-pr-1.txt
rm gate-template.txt
for s in write-requirements plan-milestones write-stories design-app design-tech build-story write-pr ship-milestone; do
  mkdir -p "skills/$s"; cp "$appz/$s/SKILL.md" "skills/$s/"
  [ -d "$appz/$s/scripts" ] && cp -R "$appz/$s/scripts" "skills/$s/"
done
for s in check-work settle-question; do mkdir -p "skills/$s"; cp "$skillz/$s/SKILL.md" "skills/$s/"; done
chmod +x fake/start-subagent fake/gh
