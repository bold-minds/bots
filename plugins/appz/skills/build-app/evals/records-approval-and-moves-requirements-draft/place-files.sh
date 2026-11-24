#!/usr/bin/env bash
# Copies the fixture, and makes repo/ its own git repo (one commit, no remote).
set -eu
cp -R "$(dirname "$0")/files/." .
export GIT_AUTHOR_DATE="2000-01-01T12:00:00Z" GIT_COMMITTER_DATE="2000-01-01T12:00:00Z"
git -C repo init -q -b main
git -C repo -c user.name=builder -c user.email= -c commit.gpgsign=false add -A
git -C repo -c user.name=builder -c user.email= -c commit.gpgsign=false commit -q -m "linkshelf: start"
