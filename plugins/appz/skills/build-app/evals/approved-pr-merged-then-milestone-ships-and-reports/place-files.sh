#!/usr/bin/env bash
# Builds the fixture: origin.git (a bare repo standing in for the remote) and its clone repo/. main holds both
# stories with approved designs and the release path (scripts/release.sh); add-item/pr-1 is merged into main
# (PR 1); clear-ticked/pr-1 is pushed and open as PR 2, waiting on the caller. places/ holds no release yet.
# fake/gh merges a PR into origin's main; the ship-milestone replies name the commit that merge makes, worked
# out here by running the same merge on a throwaway copy.
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
chmod +x scripts/release.sh
git add -A
git commit -q -m "pantry: list package, release path, stories and approved designs"
git switch -q -c add-item/pr-1
cp -R "$src/add/." .
git add -A
git commit -q -m "add-item PR 1: list.Add"
git switch -q main
git merge -q --no-ff -m "Merge pull request #1 from add-item/pr-1" add-item/pr-1
git switch -q -c clear-ticked/pr-1
cp -R "$src/clear/." .
git add -A
git commit -q -m "clear-ticked PR 1: list.Tick and list.ClearTicked"
git switch -q main
git remote add origin ../origin.git
git push -q origin main add-item/pr-1 clear-ticked/pr-1
git branch -q -u origin/main main
cd ..
cp -R "$src/fixture/." .
chmod +x fake/start-subagent fake/gh repo/scripts/release.sh
mkdir calc
cp -R origin.git calc/
cp -R fake calc/
calc/fake/gh pr merge 2 > /dev/null
sha="$(python3 -c 'import json,sys; print([json.loads(l) for l in open(sys.argv[1])][-1]["merge_commit"])' calc/fake/calls.jsonl)"
rm -rf calc
for n in 1 2 3; do sed "s/@SHA@/$sha/g" "$src/templates/ship-milestone-$n.md" > "fake/replies/ship-milestone-$n.md"; done
for s in write-requirements plan-milestones write-stories design-app design-tech build-story write-pr ship-milestone; do
  mkdir -p "skills/$s"; cp "$appz/$s/SKILL.md" "skills/$s/"
  [ -d "$appz/$s/scripts" ] && cp -R "$appz/$s/scripts" "skills/$s/"
done
for s in check-work settle-question; do mkdir -p "skills/$s"; cp "$skillz/$s/SKILL.md" "skills/$s/"; done
