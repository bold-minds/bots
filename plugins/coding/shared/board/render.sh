#!/usr/bin/env bash
# render.sh <release.md> [out.html] — the board's HTML from its written form.
# Every card line is checked first; a bad line stops the render.
set -eu
here="$(cd "$(dirname "$0")" && pwd)"
rel="${1:?usage: render.sh <release.md> [out.html]}"
out="${2:-}"
check="$here/../hil/check.sh"
tmp="$(mktemp)"; trap 'rm -f "$tmp"' EXIT
grep -E '^[0-9]{2} ' "$rel" | while IFS= read -r line; do
  printf '%s\n' "$line" > "$tmp"
  bash "$check" card "$tmp" || exit 1
done
if [ -n "$out" ]; then python3 "$here/render.py" "$rel" > "$out"; else python3 "$here/render.py" "$rel"; fi
