#!/usr/bin/env bash
# selftest.sh — proves check.sh: every example passes, and one deliberately
# broken copy of each type fails on the line that was broken. Exit 0 when every
# assertion holds. Run it after any change to check.sh or a template.
set -u
here="$(cd "$(dirname "$0")" && pwd)"
check="$here/check.sh"
ex="$here/examples"
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
fail=0
ok()   { echo "ok    $*"; }
nope() { echo "FAIL  $*"; fail=1; }

expect_pass() {  # expect_pass <label> <check args…>
  local label="$1"; shift
  if out="$("$check" "$@" 2>&1)"; then ok "$label"; else nope "$label — $out"; fi
}
expect_fail() {  # expect_fail <label> <must-mention> <check args…>
  local label="$1" must="$2"; shift 2
  if out="$("$check" "$@" 2>&1)"; then nope "$label — passed, should have failed"
  elif grep -qF -- "$must" <<<"$out"; then ok "$label"
  else nope "$label — failed, but not on '$must': $out"; fi
}

# 1. Every example passes.
expect_pass "story 01" story "$ex/01-text-answered.md"
expect_pass "story 02" story "$ex/02-stranger-texts.md"
expect_pass "trd 01, reviewed" trd "$ex/01-text-answered.trd.md" --reviewed
expect_pass "trd 02, not yet reviewed" trd "$ex/02-stranger-texts.trd.md"
expect_pass "coverage against story 02" coverage "$ex/coverage.md" --story "$ex/02-stranger-texts.md"
expect_pass "pr" pr "$ex/pr.md"
expect_pass "card" card "$ex/card.md"

# 2. One broken copy per type fails on the break. Copies sit in a temp dir with
#    the sibling they need, so the shared-line check sees the same directory.
cp "$ex"/*.md "$tmp/"

# story: a technical section that belongs on the TRD
{ cat "$ex/01-text-answered.md"; printf '\n## Solution\n- Add a thing\n'; } > "$tmp/b1.md"
expect_fail "story with a Solution section" "on the TRD, not the story" story "$tmp/b1.md"
# story: a scenario with no requirement id
sed 's/^1\. \[A3\]$/1./' "$ex/01-text-answered.md" > "$tmp/b2.md"
expect_fail "story scenario without an id" "without a requirement id" story "$tmp/b2.md"
# story: an observability vendor named on the story
sed 's/^Shows: /Shows: PostHog sees that /' "$ex/01-text-answered.md" > "$tmp/b3.md"
expect_fail "story naming a vendor" "named on the story" story "$tmp/b3.md"
# story: over the cap
{ cat "$ex/01-text-answered.md"; for i in $(seq 1 50); do echo "And line $i of padding that is long enough."; done; } > "$tmp/b4.md"
expect_fail "story over 60 lines" "cap is 60" story "$tmp/b4.md"
# story: a Then line copied from a sibling story
{ sed '/^## Changelog/,$d' "$ex/01-text-answered.md"; echo '   Then it receives "That'"'"'s the three free previews for this number."'; echo; echo '## Changelog'; } > "$tmp/b5.md"
expect_fail "story sharing a Then line" "line also in" story "$tmp/b5.md"

# trd: --reviewed but no Reviewed: line
expect_fail "trd --reviewed without a Reviewed: line" "no 'Reviewed:" trd "$tmp/02-stranger-texts.trd.md" --reviewed
# trd: a Reviewed: line on an unreviewed TRD
expect_fail "trd with a Reviewed: line, checked unreviewed" "has not been reviewed" trd "$tmp/01-text-answered.trd.md"
# trd: a Review section — the review leaves nothing on the TRD
{ cat "$ex/01-text-answered.trd.md"; printf '\n## Review\n| 1 | a finding | sre | TRD: a line |\n'; } > "$tmp/b10.trd.md"
expect_fail "trd with a Review section" "a Review section" trd "$tmp/b10.trd.md" --reviewed
# trd: a References item with no ADR
sed 's/^- Hosting: ADR 2$/- Hosting: DigitalOcean/' "$ex/01-text-answered.trd.md" > "$tmp/b6.trd.md"
expect_fail "trd References without an ADR" "References item without" trd "$tmp/b6.trd.md" --reviewed
# trd: a vendor outside Observed/References
sed 's/^- App: our Go service/- App: our Go service, watched by Datadog,/' "$ex/01-text-answered.trd.md" > "$tmp/b7.trd.md"
expect_fail "trd vendor outside Observed" "outside Observed and References" trd "$tmp/b7.trd.md" --reviewed
# trd: Story: names a missing file
sed 's/^Story: .*/Story: 99-nothing.md/' "$ex/01-text-answered.trd.md" > "$tmp/b8.trd.md"
expect_fail "trd Story: pointing nowhere" "not there" trd "$tmp/b8.trd.md" --reviewed
# trd: headings out of order
sed 's/^## Solution$/## Solutions/' "$ex/01-text-answered.trd.md" > "$tmp/b9.trd.md"
expect_fail "trd heading misspelt" "expected 'Solution'" trd "$tmp/b9.trd.md" --reviewed
# trd: a group line carrying code
sed 's/^A text to our number reaches the app and gets a reply\.$/A text to our number reaches pkg\/infra\/texting and gets a reply./' "$ex/01-text-answered.trd.md" > "$tmp/b11.trd.md"
expect_fail "trd group line with a path in it" "group line with code" trd "$tmp/b11.trd.md" --reviewed
# trd: a bullet with no group line over it
sed 's/^A text to our number reaches the app and gets a reply\.$//' "$ex/01-text-answered.trd.md" > "$tmp/b12.trd.md"
expect_fail "trd bullet with no group line" "no group line above" trd "$tmp/b12.trd.md" --reviewed
# trd: a bullet that is a paragraph
sed 's/^- Go package pkg\/infra\/texting$/- Go package pkg\/infra\/texting which wraps the vendor client and holds the number and the retry policy and the parsing/' "$ex/01-text-answered.trd.md" > "$tmp/b13.trd.md"
expect_fail "trd bullet over 15 words" "15 at most" trd "$tmp/b13.trd.md" --reviewed
# trd: a group line that is not a sentence
sed 's/^Each vendor has its own credential\.$/Each vendor has its own credential/' "$ex/01-text-answered.trd.md" > "$tmp/b14.trd.md"
expect_fail "trd group line without a full stop" "not a sentence" trd "$tmp/b14.trd.md" --reviewed
# trd: the old numbered connection list in Flow
{ sed '/^## Solution/,$d' "$ex/01-text-answered.trd.md"; echo '1. Texting → App: inbound text webhook. New.'; echo; sed -n '/^## Solution/,$p' "$ex/01-text-answered.trd.md"; } > "$tmp/b15.trd.md"
expect_fail "trd Flow with a numbered connection list" "numbered connection list" trd "$tmp/b15.trd.md" --reviewed

# coverage: a scenario on the story with no row
grep -v '^| 2 \[G7\]' "$ex/coverage.md" > "$tmp/c1.md"
expect_fail "coverage missing scenario 2" "scenario 2 on the story has no row" coverage "$tmp/c1.md" --story "$ex/02-stranger-texts.md"
# coverage: a row with no task
sed 's/| 03-taking-longer-text |/|  |/' "$ex/coverage.md" > "$tmp/c2.md"
expect_fail "coverage row without a task" "row with no task" coverage "$tmp/c2.md" --story "$ex/02-stranger-texts.md"
# coverage: no Journey row
grep -v '^| Journey' "$ex/coverage.md" > "$tmp/c3.md"
expect_fail "coverage without Journey" "no Journey row" coverage "$tmp/c3.md"

# pr: a test line with no result
sed 's/ — PASS$//' "$ex/pr.md" > "$tmp/p1.md"
expect_fail "pr test line without PASS/RED" "without '— PASS'" pr "$tmp/p1.md"
# pr: prose above the Tests heading
{ echo "Here is what I did today."; cat "$ex/pr.md"; } > "$tmp/p2.md"
expect_fail "pr with prose first" "first line is not '## Tests'" pr "$tmp/p2.md"
# pr: verdict missing
sed 's/^# PASS$/PASS/' "$ex/pr.md" > "$tmp/p3.md"
expect_fail "pr verdict not a verdict line" "does not open with" pr "$tmp/p3.md"

# card: three sentences
sed 's/Next is 03, the preview link itself\./Next is 03. The preview link itself./' "$ex/card.md" > "$tmp/k1.md"
expect_fail "card with three sentences" "it is two" card "$tmp/k1.md"
# card: a state the board does not have
sed 's/^02 Launched done /02 Launched finished /' "$ex/card.md" > "$tmp/k2.md"
expect_fail "card with a made-up state" "card is not" card "$tmp/k2.md"
# card: two lines
{ cat "$ex/card.md"; echo "And a second line."; } > "$tmp/k3.md"
expect_fail "card of two lines" "one line" card "$tmp/k3.md"

# adr: the example passes; a prose line, a Reopens section, missing Options, a bad title each fail
expect_pass "adr" adr "$ex/0001-ci-on-github-actions.md"
mkdir -p "$tmp/adr"
{ sed '/^## Why/,$d' "$ex/0001-ci-on-github-actions.md"; echo "## Why"; echo "Because it is cheaper and safer."; } > "$tmp/adr/0001-x.md"
expect_fail "adr with a prose line" "not a bullet" adr "$tmp/adr/0001-x.md"
{ cat "$ex/0001-ci-on-github-actions.md"; printf '\n## Reopens if\n- something changes\n'; } > "$tmp/adr/0001-y.md"
expect_fail "adr with a Reopens if section" "Reopens if" adr "$tmp/adr/0001-y.md"
sed '/^## Options/,/^## Why/{/^## Why/!d}' "$ex/0001-ci-on-github-actions.md" > "$tmp/adr/0001-w.md"
expect_fail "adr without Options" "expected 3 headings" adr "$tmp/adr/0001-w.md"
sed 's/^# ADR 0001 — /# /' "$ex/0001-ci-on-github-actions.md" > "$tmp/adr/0001-z.md"
expect_fail "adr with no number in the title" "first line is not" adr "$tmp/adr/0001-z.md"
# 3. The repo root from inside a linked worktree is the worktree, not nothing.
repo="$tmp/repo"; git init -q "$repo" && git -C "$repo" commit -q --allow-empty -m init
git -C "$repo" worktree add -q "$tmp/wt" -b wt 2>/dev/null
mkdir -p "$tmp/wt/docs/product/stories" && cp "$ex/01-text-answered.md" "$tmp/wt/docs/product/stories/"
got="$("$check" root "$tmp/wt/docs/product/stories/01-text-answered.md")"
if [ "$(cd "$got" && pwd -P)" = "$(cd "$tmp/wt" && pwd -P)" ]; then ok "root from a linked worktree"; else nope "root from a linked worktree — got '$got'"; fi

[ "$fail" -eq 0 ] && echo "all assertions hold" || echo "assertions failed"
exit "$fail"
