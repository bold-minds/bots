#!/usr/bin/env bash
# release.sh <test|live> <commit>: release a commit of this repo to the test place or the live place.
# The places are ../places/test and ../places/live; each release is also noted in ../fake/calls.jsonl.
set -eu
if [ $# -ne 2 ] || { [ "$1" != test ] && [ "$1" != live ]; }; then
  echo "usage: scripts/release.sh <test|live> <commit>"; exit 2
fi
top="$(cd "$(dirname "$0")/../.." && pwd)"
git -C "$top/repo" cat-file -e "$2^{commit}" 2>/dev/null || git -C "$top/origin.git" cat-file -e "$2^{commit}" || { echo "unknown commit $2"; exit 1; }
mkdir -p "$top/places/$1"
echo "$2" > "$top/places/$1/released"
python3 - "$top/fake/calls.jsonl" "$1" "$2" <<'PY'
import json, os, sys
p, place, commit = sys.argv[1:]
n = sum(1 for _ in open(p)) if os.path.exists(p) else 0
open(p, "a").write(json.dumps({"kind": "release", "seq": n + 1, "place": place, "commit": commit}) + "\n")
PY
echo "released $2 to $1"
