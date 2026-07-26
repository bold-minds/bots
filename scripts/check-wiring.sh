#!/usr/bin/env bash
# Wiring lint: dead reference files, frontmatter/filename mismatches, missing template reads.
# Run from anywhere; exits non-zero on any failure.
set -u
cd "$(dirname "$0")/.."
fail=0

# 1. Every references/ file is named in its skill's SKILL.md.
#    Matched by path relative to references/ (not bare basename): coding's
#    write-code nests references in subdirs (go/, frontend/, craft/, ...) where
#    several files share a basename (e.g. five different standards.md), so a
#    basename-only match could pass on the wrong file's mention.
while IFS= read -r ref; do
  skill_dir="${ref%/references/*}"
  skill_md="$skill_dir/SKILL.md"
  rel="${ref#*/references/}"
  if ! grep -qF "$rel" "$skill_md"; then
    echo "FAIL: $ref is never mentioned in $skill_md"
    fail=1
  fi
done < <(find plugins/*/skills/*/references -type f -name '*.md' 2>/dev/null | sort)

# 2. Frontmatter name matches the skill directory / command filename.
for skill_md in plugins/*/skills/*/SKILL.md; do
  dir_name="$(basename "$(dirname "$skill_md")")"
  fm_name="$(grep -m1 '^name:' "$skill_md" | cut -d' ' -f2)"
  if [ "$dir_name" != "$fm_name" ]; then
    echo "FAIL: $skill_md frontmatter name '$fm_name' != directory '$dir_name'"
    fail=1
  fi
done
for cmd in plugins/*/commands/*.md; do
  file_name="$(basename "$cmd" .md)"
  fm_name="$(grep -m1 '^name:' "$cmd" | cut -d' ' -f2)"
  if [ "$file_name" != "$fm_name" ]; then
    echo "FAIL: $cmd frontmatter name '$fm_name' != filename '$file_name'"
    fail=1
  fi
done

# 3. Every command reads its plugin's engine file.
#    advice's four commands share shared/focus-template.md; coding's one
#    command reads shared/engine.md instead — a different file by design, not
#    a gap. foundations ships no commands and has no entry. Generalized to a
#    per-plugin map rather than left advice-only, so /software stays checked.
declare -A engine_files=(
  [advice]='shared/focus-template.md'
  [coding]='shared/engine.md'
)
for plug in "${!engine_files[@]}"; do
  engine="${engine_files[$plug]}"
  for cmd in "plugins/$plug/commands/"*.md; do
    [ -e "$cmd" ] || continue
    if ! grep -q "$engine" "$cmd"; then
      echo "FAIL: $cmd never reads $engine"
      fail=1
    fi
  done
done

# 4. Every gate file in calibrate-profile's table appears in its focus's command file.
#    software isn't here: it left calibrate-profile's map and onboards itself in coding.
declare -A gates=(
  [life]='profile.md'
  [business]='portfolio.md'
  [money]='money/ledger.md'
  [story]='stories/charter.md'
)
for focus in "${!gates[@]}"; do
  gate="${gates[$focus]}"
  if ! grep -qF "$gate" "plugins/advice/commands/$focus.md"; then
    echo "FAIL: commands/$focus.md never names its gate file $gate"
    fail=1
  fi
  if ! grep -qF "$gate" plugins/advice/skills/calibrate-profile/SKILL.md; then
    echo "FAIL: calibrate-profile/SKILL.md never names $focus's gate file $gate"
    fail=1
  fi
done

# 5. Skill writes stay inside the skill's operating focus (reads are legal everywhere).
#    Shared files (profile.md, patterns.md) are exempt per the template's shared-files rule.
#    calibrate-profile is exempt: it operates as whichever focus it onboards.
declare -A forbidden_writes=(
  [set-goals]='money/|plans/|stories/|builds/|initiatives/|portfolio\.md|decisions/'
  [hold-commitments]='money/|plans/|stories/|builds/|initiatives/|portfolio\.md|decisions/'
  [review-week]='money/|plans/|stories/|builds/'
  [demand-numbers]='money/|plans/|stories/|builds/|goals/|log/'
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
  | grep -v 'bookshelf/<focus>\|bookshelf/<author>\|bookshelf/life\|bookshelf/money\|bookshelf/story\|bookshelf/business' \
  | grep 'shelf/'; then
  echo "FAIL: bookshelf path with unknown key (see lines above)"
  fail=1
fi

# 7. ${CLAUDE_PLUGIN_ROOT} references resolve inside the referencing plugin.
for plug in advice foundations coding; do
  while IFS= read -r hit; do
    file="${hit%%:*}"; rel=$(echo "$hit" | grep -oE '\$\{CLAUDE_PLUGIN_ROOT\}/[A-Za-z0-9_./-]+' | head -1)
    rel="${rel#\$\{CLAUDE_PLUGIN_ROOT\}/}"
    [ -e "plugins/$plug/$rel" ] || { echo "FAIL: $file points at $rel, missing in plugins/$plug"; fail=1; }
  done < <(grep -rn 'CLAUDE_PLUGIN_ROOT' "plugins/$plug" 2>/dev/null)
done

# 8. Nothing personal ships, and no plugin references a retired skill name.
#    Split in two, because a hardcoded grep for a real person's name is
#    itself a disclosure and this script ships publicly:
#      - Public half (below, always runs): shapes that are objectively wrong
#        in a distributed plugin no matter whose repo it is — an absolute
#        home path, a real-looking email address — plus the retired
#        shake/cynic skill names. ynab stays here too: it's a product name,
#        not a person, and money.md's "MCP or equivalent" mention is a
#        legitimate generic-tool example that the narrower pattern exempts
#        rather than deletes.
#      - Local half (private_list below): this author's own name, handles,
#        and unreleased project names never appear in this file. They're
#        read at runtime from scripts/.private-identifiers if it exists —
#        one grep -E pattern per line, blank lines and #-comments ignored —
#        which is gitignored and never published. If that file is missing,
#        say so out loud rather than silently reporting a pass for a half
#        of the check that never ran.
path_hits=$(grep -rnE '/home/[A-Za-z0-9_.-]+|/Users/[A-Za-z0-9_.-]+' plugins/ 2>/dev/null)
email_hits=$(grep -rnE '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' plugins/ 2>/dev/null \
  | grep -v 'git@' | grep -viE '@x\.com|@example\.(com|org|net|test)')
ynab_hits=$(grep -rniE '\bynab\b' plugins/ 2>/dev/null | grep -viE 'MCP or equivalent')
if [ -n "$path_hits" ] || [ -n "$email_hits" ] || [ -n "$ynab_hits" ]; then
  echo "FAIL: personal identifier under plugins/"
  [ -n "$path_hits" ] && echo "$path_hits"
  [ -n "$email_hits" ] && echo "$email_hits"
  [ -n "$ynab_hits" ] && echo "$ynab_hits"
  fail=1
fi

private_list="scripts/.private-identifiers"
if [ -f "$private_list" ]; then
  private_pattern=$(grep -vE '^[[:space:]]*(#|$)' "$private_list" | paste -sd '|' -)
  if [ -n "$private_pattern" ]; then
    private_hits=$(grep -rniE "$private_pattern" plugins/ 2>/dev/null)
    if [ -n "$private_hits" ]; then
      echo "FAIL: private identifier under plugins/"
      echo "$private_hits"
      fail=1
    fi
  fi
else
  echo "WARN: $private_list not found — private-identifier patterns were not checked"
fi

if grep -rnE '/(shake|cynic)\b' plugins/ >/dev/null 2>&1; then
  echo "FAIL: retired skill reference"; grep -rnE '/(shake|cynic)\b' plugins/; fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "OK: wiring checks passed"
fi
exit "$fail"
