#!/usr/bin/env bash
# check.sh <type> <file> [--approved] [--reviewed] [--story <story.md>]
# One checker for every file the owner reads. Prints one line per defect;
# exit 0 when the file is clean, 1 when it is not, 2 when it cannot be read.
#   type        story | trd | coverage | pr | card | adr
#   --approved  story: approved, so the Changelog may be non-empty
#   --reviewed  trd: reviewed, so a 'Reviewed: <date>' line must be there
#   --story F   coverage: the story whose scenario numbers every row must match
set -u

type="${1:?usage: check.sh <story|trd|coverage|pr|card|adr> <file> [--approved] [--reviewed] [--story <file>]}"
page="${2:?usage: check.sh <type> <file>}"
shift 2
approved=0; reviewed=0; story=""
while [ $# -gt 0 ]; do
  case "$1" in
    --approved) approved=1 ;;
    --reviewed) reviewed=1 ;;
    --story) story="${2:?--story needs a file}"; shift ;;
    *) echo "unknown option: $1"; exit 2 ;;
  esac
  shift
done
[ -f "$page" ] || { echo "no such file: $page"; exit 2; }
page="$(cd "$(dirname "$page")" && pwd)/$(basename "$page")"
dir="$(dirname "$page")"

bad=0
say() { echo "$page: $*"; bad=1; }

# Caps, in lines (card: words after the dash). The owner reads these; a file
# over its cap is a file that was not cut.
CAP_STORY=60; CAP_TRD=100; CAP_COVERAGE_ROWS=20; CAP_PR=40; CAP_CARD_WORDS=40; CAP_ADR=40
# The TRD's cap counts every line, but what the owner reads is the group
# lines — ten a section at most — so the bullets under them can be many and
# short, which is the point.

# The repo root: from a linked worktree .git is a file, so ask git, and only
# walk when the file is not in a repo at all.
root="$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null)"
if [ -z "$root" ]; then
  root="$dir"; while [ "$root" != "/" ] && [ ! -e "$root/.git" ]; do root="$(dirname "$root")"; done
fi

# Observability vendors: named only in a TRD's Observed (or References). From
# the repo's .claude/slice-observability, one per line, else a default list.
vendors=()
if [ -f "$root/.claude/slice-observability" ]; then
  mapfile -t vendors < "$root/.claude/slice-observability"
else
  vendors=("Better Stack" "PostHog" "Datadog" "Sentry" "Grafana")
fi

section() {  # section <Heading> — the body under "## Heading"
  awk -v h="## $1" '
    $0 == h {on=1; next}
    /^## / {on=0}
    on {print}
  ' "$page"
}
nonblank() { grep -cvE '^[[:space:]]*$' || true; }
lines() { grep -cvE '^[[:space:]]*$' "$page" || true; }

headings_are() {  # headings_are <H1> <H2> … — exactly these ## headings, in order
  local want=("$@")
  mapfile -t have < <(grep -E '^## ' "$page" | sed -E 's/^## +//; s/ +$//')
  if [ "${#have[@]}" -ne "${#want[@]}" ]; then
    say "expected ${#want[@]} headings (${want[*]}), found ${#have[@]}: ${have[*]:-none}"
    return
  fi
  for i in "${!want[@]}"; do
    [ "${have[$i]}" = "${want[$i]}" ] || say "heading $((i+1)) is '${have[$i]}', expected '${want[$i]}'"
  done
}

# No line shared with a sibling of the same type. Given/When lines, headings,
# labels and None lines are exempt: a shared precondition is a fixture, a label
# is a label. Then/And lines and every technical line must be this file's own.
shared_lines() {  # shared_lines <glob> <exempt-regex> <body> [skip-name-regex]
  local glob="$1" exempt="$2" body="$3" skip="${4:-}" other line
  for other in "$dir"/$glob; do
    [ "$other" = "$page" ] && continue
    [ -f "$other" ] || continue
    [ -n "$skip" ] && grep -qE "$skip" <<<"$(basename "$other")" && continue
    while IFS= read -r line; do
      [ -z "${line//[[:space:]]/}" ] && continue
      grep -qE "$exempt" <<<"$line" && continue
      [ "${#line}" -lt 24 ] && continue
      grep -qFx -- "$line" "$other" && say "line also in $(basename "$other"): ${line}"
    done <<<"$body"
  done
}

vendors_outside() {  # vendors_outside <text> <where> — a vendor named in <text> is a defect
  local text="$1" where="$2" v
  for v in "${vendors[@]}"; do
    [ -n "$v" ] || continue
    grep -qF "$v" <<<"$text" && say "'$v' named $where"
  done
}

check_story() {
  head -1 "$page" | grep -qE '^# .+' || say "first line is not the slice title"
  grep -qE '^Shows: .+' "$page" || say "no 'Shows:' line"
  headings_are Journey Scenarios Changelog
  for h in Flow Solution Observed References; do
    grep -qE "^## $h" "$page" && say "'$h' is on the TRD, not the story"
  done

  local j s n line
  j="$(section Journey)"
  for k in Given When Then; do
    grep -qE "^[[:space:]]*(And )?$k " <<<"$j" || say "Journey has no '$k' line"
  done

  s="$(section Scenarios)"
  n="$(grep -cE '^[[:space:]]*[0-9]+\.' <<<"$s" || true)"
  [ "$n" -gt 0 ] || say "no scenarios"
  while IFS= read -r line; do
    grep -qE '^[[:space:]]*[0-9]+\.[[:space:]]*\[[^]]+\]' <<<"$line" || say "scenario without a requirement id: ${line}"
  done < <(grep -E '^[[:space:]]*[0-9]+\.' <<<"$s")
  [ "$n" -gt 10 ] && say "$n scenarios: split the story at ten"
  # Numbered 1..n in order: the coverage table and the tests key on these.
  local expect=1 got
  while IFS= read -r got; do
    [ "$got" -eq "$expect" ] || say "scenario numbered $got where $expect was expected"
    expect=$((expect+1))
  done < <(grep -oE '^[[:space:]]*[0-9]+\.' <<<"$s" | tr -dc '0-9\n')

  if [ "$approved" -eq 0 ] && [ "$(section Changelog | nonblank)" -gt 0 ]; then
    say "Changelog is not empty before approval"
  fi

  vendors_outside "$(cat "$page")" "on the story (observability lives on the TRD's Observed)"

  # Siblings that are TRDs are not stories; skip them.
  local exempt='^(#|##|Shows:|[[:space:]]*(Given|When) |[[:space:]]*[0-9]+\. \[)'
  shared_lines '*.md' "$exempt" "$(cat "$page")" '\.trd\.md$'
  local l; l="$(lines)"
  [ "$l" -le "$CAP_STORY" ] || say "$l lines; the story's cap is $CAP_STORY"
}

check_trd() {
  head -1 "$page" | grep -qE '^# .+ — design$' || say "first line is not '# <story title> — design'"
  local st; st="$(grep -E '^Story: ' "$page" | head -1 | sed -E 's/^Story: +//; s/ +$//')"
  if [ -z "$st" ]; then say "no 'Story:' line"
  elif [ ! -f "$dir/$st" ] && [ ! -f "$st" ]; then say "Story: names a file that is not there: $st"
  fi
  headings_are Flow Solution Observed References
  for h in Journey Scenarios Changelog; do
    grep -qE "^## $h" "$page" && say "'$h' is on the story, not the TRD"
  done

  local f
  f="$(section Flow)"
  grep -qE '^Legend:' <<<"$f" || say "Flow has no Legend:"
  grep -qE '^Components:' <<<"$f" || say "Flow has no Components:"
  grep -qE '^[0-9]+\. .* → ' <<<"$f" && say "Flow carries a numbered connection list; the diagram and its + marks are the connections"

  # The size stop (Claire, 17 and 19 Sept 2026): infrastructure and business
  # trade off. A story may be infra-heavy — more than one new participant or
  # more than two new connections in the Flow — only when its business scope
  # is small: three scenarios or fewer on its story. A story with more
  # scenarios than that adds at most one participant and two connections.
  # Both large is the stop: the story is split before any lens reads it. A
  # new participant is a Name+ across the top of the diagram or in Components;
  # a new connection is an arrow label carrying + ("job+*-->", "<-link+-").
  local newparts newconns header scen
  header="$(grep -vE '^\s*\||^Legend|^Components|^- |^\s*$|^[+~*] ' <<<"$f" | head -1)"
  newparts="$(grep -oE '[A-Za-z]+\+' <<<"$header" | wc -l | tr -d ' ')"
  [ "$(grep -cE '^- [^:]*\+: ' <<<"$f" || true)" -gt "$newparts" ] && newparts="$(grep -cE '^- [^:]*\+: ' <<<"$f")"
  newconns="$(grep -E '^\s*\|' <<<"$f" | grep -oE '[A-Za-z][A-Za-z ]*\+[*~]*[-<>]' | wc -l | tr -d ' ')"
  scen=0
  if [ -f "$dir/$st" ]; then scen="$(grep -cE '^[0-9]+\. \[' "$dir/$st" || true)"
  elif [ -f "$st" ]; then scen="$(grep -cE '^[0-9]+\. \[' "$st" || true)"; fi
  if [ "${newparts:-0}" -gt 1 ] || [ "${newconns:-0}" -gt 2 ]; then
    [ "${scen:-0}" -le 3 ] || say "Flow: $newparts new participants and $newconns new connections against $scen scenarios; a story that adds more than one participant or two connections carries three scenarios or fewer — the size stop: split the story before the review"
  fi

  # Solution and Observed: group lines and their bullets. A group line is one
  # plain sentence the owner reads — no bullet, no code, no path, no flag —
  # and every bullet under it is one short fact the verifier holds the code
  # to. At most ten groups a section; a bullet before any group is a fact
  # with no sentence over it.
  local sec line groups words
  for sec in Solution Observed; do
    [ "$(section "$sec" | nonblank)" -gt 0 ] || say "$sec is empty (write 'None new.' or 'Nothing new is observed.' if so)"
    groups=0; local seen_group=0
    while IFS= read -r line; do
      [ -z "${line//[[:space:]]/}" ] && continue
      if grep -qE '^- ' <<<"$line"; then
        [ "$seen_group" -eq 1 ] || say "$sec: a bullet with no group line above it: ${line}"
        words="$(wc -w <<<"${line#- }")"
        [ "$words" -le 15 ] || say "$sec: a bullet of $words words; a bullet is one short fact, 15 at most: ${line}"
      else
        seen_group=1; groups=$((groups+1))
        grep -qE '[`$=/\\]' <<<"$line" && say "$sec: a group line with code in it (backtick, \$, =, / or \\); code goes in the bullets under it: ${line}"
        grep -qE '\.$' <<<"$line" || say "$sec: a group line that is not a sentence (no full stop): ${line}"
        words="$(wc -w <<<"$line")"
        [ "$words" -le 25 ] || say "$sec: a group line of $words words; 25 at most: ${line}"
      fi
    done <<<"$(section "$sec")"
    [ "$groups" -le 10 ] || say "$sec: $groups group lines; ten at most"
  done

  [ "$(section References | nonblank)" -gt 0 ] || say "References is empty (write 'None' if so)"
  while IFS= read -r line; do
    grep -qE '(: ADR [0-9]+|: ADR pending|: existing, no ADR|^- None$)' <<<"$line" \
      || say "References item without 'ADR <n>', 'ADR pending' or 'existing, no ADR': ${line}"
  done < <(section References | grep -E '^- ')

  # The review leaves one line — Reviewed: <date> — and nothing else: its
  # findings are folded into the sections, and the owner reads one draft.
  grep -qE '^## Review' "$page" && say "a Review section: the review's findings go into the sections, the trail goes to .claude/pipeline/reviews/, and nothing of it stays on the TRD"
  if [ "$reviewed" -eq 1 ]; then
    grep -qE '^Reviewed: [0-9]{4}-[0-9]{2}-[0-9]{2}$' "$page" || say "reviewed, but no 'Reviewed: <YYYY-MM-DD>' line"
  else
    grep -qE '^Reviewed: ' "$page" && say "a 'Reviewed:' line on a TRD that has not been reviewed"
  fi

  local outside
  outside="$(awk '
    /^## (Observed|References)/ {skip=1; next}
    /^## / {skip=0}
    !skip {print}
  ' "$page")"
  vendors_outside "$outside" "outside Observed and References"

  local exempt='^(#|##|Story:|Reviewed:|- None|None new\.|Nothing new is observed\.|None)'
  local body; body="$(awk '
    /^## Flow/ {skip=1; next}
    /^## / {skip=0}
    !skip {print}
  ' "$page")"
  shared_lines '*.trd.md' "$exempt" "$body"
  local l; l="$(lines)"
  [ "$l" -le "$CAP_TRD" ] || say "$l lines; the TRD's cap is $CAP_TRD"
}

check_coverage() {
  head -1 "$page" | grep -qE '^# Coverage — .+' || say "first line is not '# Coverage — <feature>'"
  grep -qE '^Story: .+' "$page" || say "no 'Story:' line"
  grep -qE '^\| *Scenario *\| *In the owner.s words' "$page" || say "table header is not '| Scenario | In the owner's words (short) | Task | Where in the task |'"
  grep -qE '^\| *Journey *\|' "$page" || say "no Journey row"
  local rows line n cell
  rows="$(grep -E '^\| *[0-9]+ \[' "$page" || true)"
  [ -n "$rows" ] || say "no scenario rows"
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    cell="$(awk -F'|' '{gsub(/^ +| +$/,"",$4); print $4}' <<<"$line")"
    [ -n "$cell" ] || say "row with no task: ${line}"
  done <<<"$rows"
  n="$(grep -cE '^\| *([0-9]+ \[|Journey)' "$page" || true)"
  [ "$n" -le "$CAP_COVERAGE_ROWS" ] || say "$n rows; the coverage table's cap is $CAP_COVERAGE_ROWS"
  if [ -n "$story" ]; then
    [ -f "$story" ] || { say "--story names a file that is not there: $story"; return; }
    local want have
    want="$(awk '/^## Scenarios/{on=1;next} /^## /{on=0} on' "$story" | grep -oE '^[[:space:]]*[0-9]+\.' | tr -dc '0-9\n' | sort -n)"
    have="$(grep -oE '^\| *[0-9]+ \[' "$page" | tr -dc '0-9\n' | sort -n)"
    for k in $want; do grep -qx "$k" <<<"$have" || say "scenario $k on the story has no row"; done
    for k in $have; do grep -qx "$k" <<<"$want" || say "row for scenario $k, which the story does not have"; done
    [ "$(sort <<<"$have" | uniq -d | wc -l)" -eq 0 ] || say "a scenario has more than one row"
  fi
}

check_pr() {
  # Why: the story and a checklist of the PRs it is split into, this one
  # ticked. What: one bullet per change, what it contributes, no paths.
  # How to check: what a colleague runs. (Claire, 15 Sept: "I can't review
  # quickly the way its written"; no cap on bullets.)
  local first; first="$(grep -vE '^[[:space:]]*$' "$page" | head -1)"
  [ "$first" = "## Why" ] || say "first line is not '## Why'"
  headings_are Why What "How to check"
  local w; w="$(section Why)"
  [ -n "$(grep -vE '^[[:space:]]*$|^- \[' <<<"$w")" ] || say "Why has no story line above the checklist"
  [ "$(grep -cE '^- \[[ x]\] PR [0-9]+: .+' <<<"$w" || true)" -gt 0 ] || say "Why has no '- [x] PR n: <what it does>' checklist line"
  [ "$(grep -cE '^- \[x\] PR [0-9]+: ' <<<"$w" || true)" -gt 0 ] || say "no PR in the checklist is ticked; this one is"
  while IFS= read -r line; do
    grep -qE '^- \[[ x]\] PR [0-9]+: .+' <<<"$line" || say "Why: a bullet that is not a '- [ ] PR n: …' line: ${line}"
  done < <(grep -E '^- ' <<<"$w")
  local t; t="$(section What)"
  [ "$(grep -cE '^- ' <<<"$t" || true)" -gt 0 ] || say "What holds no bullet"
  while IFS= read -r line; do
    grep -qE '(^|[^a-zA-Z])[a-zA-Z0-9_./-]+/[a-zA-Z0-9_.-]+\.(go|js|ts|svelte|md|json|yaml|yml|sh|mod|sum)([^a-zA-Z0-9]|$)' <<<"$line" && say "What: a file path in a bullet; say what it contributes, not where: ${line}"
    grep -qE '[0-9]+ lines' <<<"$line" && say "What: a line count in a bullet: ${line}"
    # Claire, 19 Sept: "Each bullet is too long … simple, plain and cut to
    # the bone." One short line each; the reason goes in the story, not here.
    [ "$(wc -w <<<"$line")" -le 13 ] || say "What: a bullet over 12 words; one short plain line each: ${line}"
  done < <(grep -E '^- ' <<<"$t")
  [ -n "$(section "How to check" | grep -vE '^[[:space:]]*$')" ] || say "How to check is empty"
}

check_adr() {
  head -1 "$page" | grep -qE '^# ADR [0-9]{4} — .+' || say "first line is not '# ADR NNNN — <the decision, one sentence>'"
  local n; n="$(head -1 "$page" | grep -oE 'ADR [0-9]{4}' | tr -dc '0-9')"
  [ -n "$n" ] && ! grep -qE "^$n-" <<<"$(basename "$page")" && say "file name does not start with $n-"
  grep -qE '^Decided: [0-9]{4}-[0-9]{2}-[0-9]{2} \(.+\)$' "$page" || say "no 'Decided: <YYYY-MM-DD> (<who>)' line"
  grep -qE '^## Reopens' "$page" && say "a 'Reopens if' section: an ADR is the decision, its options and why; reopening is the owner's, not a clause"
  headings_are Decision Options Why
  local sec line
  for sec in Decision Why; do
    [ "$(section "$sec" | grep -cE '^- ' || true)" -gt 0 ] || say "$sec has no bullet"
    while IFS= read -r line; do
      [ -z "${line//[[:space:]]/}" ] && continue
      grep -qE '^- ' <<<"$line" || say "$sec: a line that is not a bullet: ${line}"
      [ "$(wc -w <<<"$line")" -le 30 ] || say "$sec: a bullet over 30 words: ${line}"
    done <<<"$(section "$sec")"
  done
  # Options are grouped by platform and product: a group line "<Platform> —
  # <product>, <verdict>." then that option's facts, one per bullet.
  local seen=0 groups=0
  while IFS= read -r line; do
    [ -z "${line//[[:space:]]/}" ] && continue
    if grep -qE '^- ' <<<"$line"; then
      [ "$seen" -eq 1 ] || say "Options: a bullet with no platform line above it: ${line}"
      [ "$(wc -w <<<"$line")" -le 30 ] || say "Options: a bullet over 30 words: ${line}"
      grep -qE '^- (Pro|Con): ' <<<"$line" || say "Options: a bullet that is not 'Pro: …' or 'Con: …': ${line}"
    else
      seen=1; groups=$((groups+1))
      grep -qE '^[^-].* — .*, (chosen|rejected|the state before this|not evaluated)\.$' <<<"$line" \
        || say "Options: a platform line is '<Platform> — <product>, <chosen|rejected|the state before this|not evaluated>.': ${line}"
    fi
  done <<<"$(section Options)"
  [ "$groups" -ge 2 ] || say "Options: fewer than two platforms; a decision names what it beat"
  grep -qE ', chosen\.$' <<<"$(section Options)" || say "Options: no platform marked chosen"
  local l; l="$(lines)"
  [ "$l" -le "$CAP_ADR" ] || say "$l lines; an ADR's cap is $CAP_ADR"
}

check_card() {
  local n; n="$(lines)"
  [ "$n" -eq 1 ] || say "a card is one line; found $n"
  local c; c="$(grep -vE '^[[:space:]]*$' "$page" | head -1)"
  grep -qE '^[0-9]{2} (Requirements|Story|Design|Tasks|Building|Code Review|Test|Launched) (done|now|waiting-owner|waiting-dependency|not-started) [0-9]{4}-[0-9]{2}-[0-9]{2} — .+$' <<<"$c" \
    || say "card is not '<nn> <stop> <state> <YYYY-MM-DD> — <two sentences>'"
  local tail; tail="${c#* — }"
  local sentences; sentences="$(grep -oE '[^.]+\.' <<<"$tail" | wc -l)"
  [ "$sentences" -eq 2 ] || say "the card's text is $sentences sentence(s); it is two"
  local words; words="$(wc -w <<<"$tail")"
  [ "$words" -le "$CAP_CARD_WORDS" ] || say "$words words after the dash; the card's cap is $CAP_CARD_WORDS"
}

case "$type" in
  story) check_story ;;
  trd) check_trd ;;
  coverage) check_coverage ;;
  pr) check_pr ;;
  card) check_card ;;
  adr) check_adr ;;
  root) echo "$root" ;;   # the repo root the checker resolved for this file; for the self-test
  *) echo "unknown type: $type (story|trd|coverage|pr|card)"; exit 2 ;;
esac

exit "$bad"
