#!/usr/bin/env bash
# Reply-shape lint regression test: asserts lint-reply.py flags every known-bad
# fixture and passes every known-good one. Run from anywhere; exits non-zero on
# any failure.
#
# The fixtures are anonymized reproductions of real replies the user rejected
# (and one they wrote themselves). They exist so a rule change that would let a
# rejected shape back through fails here in a second, instead of in a live
# session an hour later.
set -u
cd "$(dirname "$0")/.."
fail=0

command -v python3 >/dev/null 2>&1 || { echo "SKIP: python3 not found"; exit 0; }

# Known-bad: the linter must find at least one violation in each.
for f in scripts/fixtures/bad-*.md; do
  [ -e "$f" ] || continue
  if python3 scripts/lint-reply.py "$f" >/dev/null 2>&1; then
    echo "FAIL: $f is a known-bad fixture but linted clean"
    fail=1
  fi
done

# Known-good: the linter must find nothing.
for f in scripts/fixtures/good-*.md; do
  [ -e "$f" ] || continue
  if ! out=$(python3 scripts/lint-reply.py "$f" 2>&1); then
    echo "FAIL: $f is a known-good fixture but linted dirty"
    echo "$out" | sed 's/^/  /'
    fail=1
  fi
done

if [ "$fail" -eq 0 ]; then
  echo "reply-shape lint: all fixtures behave as expected"
fi
exit "$fail"
