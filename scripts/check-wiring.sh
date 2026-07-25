#!/usr/bin/env bash
# Wiring lint: dead reference files, frontmatter/filename mismatches, missing template reads.
# Run from anywhere; exits non-zero on any failure.
set -u
cd "$(dirname "$0")/.."
fail=0

# 1. Every references/ file is named in its skill's SKILL.md.
for ref in plugins/advice/skills/*/references/*.md; do
  skill_md="$(dirname "$(dirname "$ref")")/SKILL.md"
  base="$(basename "$ref")"
  if ! grep -q "$base" "$skill_md"; then
    echo "FAIL: $ref is never mentioned in $skill_md"
    fail=1
  fi
done

# 2. Frontmatter name matches the skill directory / command filename.
for skill_md in plugins/advice/skills/*/SKILL.md; do
  dir_name="$(basename "$(dirname "$skill_md")")"
  fm_name="$(grep -m1 '^name:' "$skill_md" | cut -d' ' -f2)"
  if [ "$dir_name" != "$fm_name" ]; then
    echo "FAIL: $skill_md frontmatter name '$fm_name' != directory '$dir_name'"
    fail=1
  fi
done
for cmd in plugins/advice/commands/*.md; do
  file_name="$(basename "$cmd" .md)"
  fm_name="$(grep -m1 '^name:' "$cmd" | cut -d' ' -f2)"
  if [ "$file_name" != "$fm_name" ]; then
    echo "FAIL: $cmd frontmatter name '$fm_name' != filename '$file_name'"
    fail=1
  fi
done

# 3. Every command reads the focus template.
for cmd in plugins/advice/commands/*.md; do
  if ! grep -q 'shared/focus-template.md' "$cmd"; then
    echo "FAIL: $cmd never reads shared/focus-template.md"
    fail=1
  fi
done

# 4. Every gate file in calibrate's table appears in its focus's command file.
declare -A gates=(
  [life]='profile.md'
  [business]='portfolio.md'
  [money]='money/ledger.md'
  [story]='stories/charter.md'
  [software]='builds/<project>/scope.md'
)
for focus in "${!gates[@]}"; do
  gate="${gates[$focus]}"
  if ! grep -qF "$gate" "plugins/advice/commands/$focus.md"; then
    echo "FAIL: commands/$focus.md never names its gate file $gate"
    fail=1
  fi
  if ! grep -qF "$gate" plugins/advice/skills/calibrate/SKILL.md; then
    echo "FAIL: calibrate/SKILL.md never names $focus's gate file $gate"
    fail=1
  fi
done

# 5. Skill writes stay inside the skill's operating focus (reads are legal everywhere).
#    Shared files (profile.md, patterns.md) are exempt per the template's shared-files rule.
#    calibrate is exempt: it operates as whichever focus it onboards.
declare -A forbidden_writes=(
  [aim]='money/|plans/|stories/|builds/|initiatives/|portfolio\.md|decisions/'
  [confront]='money/|plans/|stories/|builds/|initiatives/|portfolio\.md|decisions/'
  [reflect]='money/|plans/|stories/|builds/'
  [drill]='money/|plans/|stories/|builds/|goals/|log/'
)
for skill in "${!forbidden_writes[@]}"; do
  hits=$(grep -nE "([Ss]ave|[Ww]rit|[Uu]pdat|[Aa]ppend|[Cc]reate|[Ff]old|[Ll]og)[^.]*\{kb_path\}/(${forbidden_writes[$skill]})" \
    "plugins/advice/skills/$skill/SKILL.md" | grep -viE 'profile\.md|patterns\.md')
  if [ -n "$hits" ]; then
    echo "FAIL: skills/$skill writes outside its operating focus:"
    echo "$hits"
    fail=1
  fi
done

# 6. Bookshelf paths stay keyed by focus name — no other vocabulary.
if grep -rn 'shelf/' plugins/advice --include='*.md' \
  | grep -v 'bookshelf/<focus>\|bookshelf/<author>\|bookshelf/life\|bookshelf/money\|bookshelf/story\|bookshelf/software\|bookshelf/business' \
  | grep 'shelf/'; then
  echo "FAIL: bookshelf path with unknown key (see lines above)"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "OK: wiring checks passed"
fi
exit "$fail"
