#!/usr/bin/env bash
# check.sh <story.md> [--approved]
# Prints one line per defect. Exit 0 when the story is clean.
#   --approved   the story has been approved; the Changelog may be non-empty.
set -u

page="${1:?usage: check.sh <story.md> [--approved]}"
approved=0
[ "${2:-}" = "--approved" ] && approved=1
[ -f "$page" ] || { echo "no such file: $page"; exit 2; }
page="$(cd "$(dirname "$page")" && pwd)/$(basename "$page")"

bad=0
say() { echo "$page: $*"; bad=1; }

# 1. Eight sections, in order, each exactly once. Shows is a line, the rest are headings.
want=(Journey Scenarios Flow Solution Observed References Changelog)
mapfile -t have < <(grep -E '^## ' "$page" | sed -E 's/^## +//; s/ +$//')
if [ "${#have[@]}" -ne 7 ]; then
  say "expected 7 headings after Shows, found ${#have[@]}: ${have[*]:-none}"
else
  for i in "${!want[@]}"; do
    [ "${have[$i]}" = "${want[$i]}" ] || say "heading $((i+1)) is '${have[$i]}', expected '${want[$i]}'"
  done
fi
grep -qE '^Shows: .+' "$page" || say "no 'Shows:' line"
head -1 "$page" | grep -qE '^# .+' || say "first line is not the slice title"

# Section bodies, by heading.
section() {
  awk -v h="## $1" '
    $0 == h {on=1; next}
    /^## / {on=0}
    on {print}
  ' "$page"
}
nonblank() { grep -cvE '^[[:space:]]*$' || true; }

# 2. Journey has Given/When/Then.
j="$(section Journey)"
for k in Given When Then; do
  grep -qE "^[[:space:]]*(And )?$k " <<<"$j" || say "Journey has no '$k' line"
done

# 3. Every scenario names a requirement id on its first line, and none is empty.
s="$(section Scenarios)"
n="$(grep -cE '^[[:space:]]*[0-9]+\.' <<<"$s" || true)"
[ "$n" -gt 0 ] || say "no scenarios"
while IFS= read -r line; do
  grep -qE '^[[:space:]]*[0-9]+\.[[:space:]]*\[[^]]+\]' <<<"$line" || say "scenario without a requirement id: ${line}"
done < <(grep -E '^[[:space:]]*[0-9]+\.' <<<"$s")
[ "$n" -gt 10 ] && say "$n scenarios: split the page at ten"

# 4. Flow has a Legend, Components, and a numbered list marked New or Existing.
f="$(section Flow)"
grep -qE '^Legend:' <<<"$f" || say "Flow has no Legend:"
grep -qE '^Components:' <<<"$f" || say "Flow has no Components:"
grep -qE '^[0-9]+\..*(New|Existing)\.?[[:space:]]*$' <<<"$f" || say "Flow has no numbered connection marked New or Existing"
# One new wire per story: one new service, which may need a connection each
# way. More than two New connections means a second new service; split.
newc="$(grep -cE '^[0-9]+\..*[[:space:]]New\.?[[:space:]]*$' <<<"$f" || true)"
[ "$newc" -gt 2 ] && say "$newc New connections in Flow: one new wire per story, split it"

# 5. Solution, Observed, References are non-empty (a 'None' line counts).
for sec in Solution Observed References; do
  [ "$(section "$sec" | nonblank)" -gt 0 ] || say "$sec is empty (write 'None new' or 'None' if so)"
done

# 6. Changelog empty before approval.
if [ "$approved" -eq 0 ] && [ "$(section Changelog | nonblank)" -gt 0 ]; then
  say "Changelog is not empty before approval"
fi

# 7. No observability vendor named outside Observed. Names come from the repo's
#    .claude/slice-observability (one per line) when present; else a default list.
dir="$(cd "$(dirname "$page")" && pwd)"
root="$dir"; while [ "$root" != "/" ] && [ ! -d "$root/.git" ]; do root="$(dirname "$root")"; done
vendors=()
if [ -f "$root/.claude/slice-observability" ]; then
  mapfile -t vendors < "$root/.claude/slice-observability"
else
  vendors=("Better Stack" "PostHog" "Datadog" "Sentry" "Grafana")
fi
outside="$(awk '
  /^## Observed/ {skip=1; next}
  /^## / {skip=0}
  !skip {print}
' "$page")"
for v in "${vendors[@]}"; do
  [ -n "$v" ] || continue
  grep -qF "$v" <<<"$outside" && say "'$v' named outside Observed"
done

# 8. No line shared with another page in the same directory.
#    Exempt: the whole Flow section (a reused wire draws the same diagram, legend
#    and components), Given/When lines (a shared precondition or action is a
#    fixture, not a copy), headings, labels and 'None' lines. Then/And lines,
#    Shows, Solution, Observed and References must be this page's own.
exempt='^(#|##|Shows:|Logs, non-error:|Events:|Alerts:|- None|- None new|None|None new|[[:space:]]*(Given|When) |[[:space:]]*[0-9]+\. \[)'
body="$(awk '
  /^## Flow/ {skip=1; next}
  /^## / {skip=0}
  !skip {print}
' "$page")"
for other in "$dir"/*.md; do
  [ "$other" = "$page" ] && continue
  [ -f "$other" ] || continue
  while IFS= read -r line; do
    [ -z "${line//[[:space:]]/}" ] && continue
    grep -qE "$exempt" <<<"$line" && continue
    [ "${#line}" -lt 24 ] && continue
    if grep -qFx -- "$line" "$other"; then
      say "line also in $(basename "$other"): ${line}"
    fi
  done <<<"$body"
done

exit "$bad"
