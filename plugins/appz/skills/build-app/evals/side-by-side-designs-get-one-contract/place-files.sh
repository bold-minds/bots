#!/usr/bin/env bash
# Copies the fixture, makes repo/ its own git repo (one commit, no remote), then copies the step skills and
# skillz skills the build runs into skills/<name>/SKILL.md.
set -eu
here="$(cd "$(dirname "$0")" && pwd)"
appz="$here/../../.."
skillz="$appz/../../skillz/skills"
cp -R "$here/files/." .
export GIT_AUTHOR_DATE="2000-01-01T12:00:00Z" GIT_COMMITTER_DATE="2000-01-01T12:00:00Z"
git -C repo init -q -b main
git -C repo -c user.name=builder -c user.email= -c commit.gpgsign=false add -A
git -C repo -c user.name=builder -c user.email= -c commit.gpgsign=false commit -q -m "sprout: requirements and the watering stories"
for s in write-requirements plan-milestones write-stories design-app design-tech build-story write-pr ship-milestone; do
  mkdir -p "skills/$s"; cp "$appz/$s/SKILL.md" "skills/$s/"
  [ -d "$appz/$s/scripts" ] && cp -R "$appz/$s/scripts" "skills/$s/"
done
for s in check-work settle-question; do mkdir -p "skills/$s"; cp "$skillz/$s/SKILL.md" "skills/$s/"; done
chmod +x fake/start-subagent
