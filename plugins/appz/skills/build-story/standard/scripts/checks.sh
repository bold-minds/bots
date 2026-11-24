#!/usr/bin/env bash
# shellcheck disable=SC2016,SC2012  # backticks and $ in single quotes are literal text and JS; ls lists one glob
# The standard checks: one step per stage of a change, each runnable alone, all of them in order with `validate`.
# The same script runs on a laptop and in CI.
#
#   scripts/checks.sh <step>...   run these steps in order: env lint build unit integration e2e coverage docs
#   scripts/checks.sh pins        print the pinned web tools, one name@version per line
#
# Settings come from the environment; the Taskfile passes its vars (`task validate COVERAGE_MIN=85`):
#   MODE              local or ci (ci: a missing README fails, and packages are always installed fresh)
#   COVERAGE_MIN      the least coverage, in percent, for Go and for the web page
#   TEST_TIMEOUT      the longest a Go test run may take
#   WEB_DIR           the folder holding the web page's package.json
#   COVERAGE_EXCLUDE  a regex of Go file paths left out of the coverage number (wiring with no behaviour)
#   CHECKS_TOOLS      where pinned tools are installed when not already on the PATH
#
# Stacks: Go when go.mod is at the root; web (TypeScript and Svelte) when $WEB_DIR/package.json exists. A step
# runs only the checks of the stacks the repo has, and shows each missing stack as skipped, with the reason.
# Test layers: unit tests carry no build tag; integration tests start with `//go:build integration`, E2E tests
# with `//go:build e2e`; web unit tests are *.test.ts under tests/ or src/, web E2E tests run under the
# playwright.config.ts in $WEB_DIR.
set -u
cd "$(dirname "$0")/.." || exit 2
ROOT="$PWD"

MODE="${MODE:-local}"
COVERAGE_MIN="${COVERAGE_MIN:-80}"
TEST_TIMEOUT="${TEST_TIMEOUT:-10m}"
WEB_DIR="${WEB_DIR:-web}"
COVERAGE_EXCLUDE="${COVERAGE_EXCLUDE:-/cmd/}"
CHECKS_TOOLS="${CHECKS_TOOLS:-${XDG_CACHE_HOME:-$HOME/.cache}/checks}"

# Pinned tools. Go's own version comes from go.mod.
GOLANGCI_LINT_VERSION="v2.11.4"
NODE_MIN=22
WEB_PINS="@eslint/js@10.0.1 @sveltejs/vite-plugin-svelte@7.1.2 @vitest/coverage-v8@5.0.1 eslint@10.10.0
eslint-plugin-svelte@3.23.0 globals@17.12.0 jsdom@30.0.1 prettier@3.9.6 prettier-plugin-svelte@4.1.1 svelte@5.56.4
svelte-check@4.7.6 typescript@6.0.3 typescript-eslint@8.72.1 vite@8.3.8 vitest@5.0.1"
PLAYWRIGHT_PIN="@playwright/test@1.64.1" # needed only when $WEB_DIR has a playwright.config

ALL_STEPS="env lint build unit integration e2e coverage docs"
STATE="$ROOT/.checks" # this run's coverage files; gitignored
RUN_ID="${CHECKS_RUN_ID:-$$-$(date +%s)}"

if [ "${1:-}" = pins ]; then
  for p in $WEB_PINS $PLAYWRIGHT_PIN; do echo "$p"; done
  exit 0
fi

if [ -t 1 ] || [ -n "${CI:-}" ]; then
  RED=$'\e[0;31m' GREEN=$'\e[0;32m' YELLOW=$'\e[1;33m' BLUE=$'\e[0;34m' PURPLE=$'\e[0;35m' CYAN=$'\e[0;36m' NC=$'\e[0m'
else
  RED='' GREEN='' YELLOW='' BLUE='' PURPLE='' CYAN='' NC=''
fi
LINE="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

passed=0 failed=0 skipped=0 warnings=0 total=0
fixes=()
step=""
start="$(date +%s)"

# ---- output -------------------------------------------------------------------------------------------------------

# info and warn write to fd 3, which check() collects and prints under the check's result line.
info() { printf 'ℹ️  %s\n' "$*" >&3; }
warn() { printf '⚠️  %s\n' "$*" >&3; }

# check <label> <command>...: one check of the current step. Its notes are shown always, its output when it fails.
check() {
  local label="$1" out notes
  shift
  out="$(mktemp)" notes="$(mktemp)"
  total=$((total + 1))
  if "$@" >"$out" 2>&1 3>"$notes"; then
    passed=$((passed + 1))
    printf '  %s✅ %s%s\n' "$GREEN" "$label" "$NC"
  else
    failed=$((failed + 1))
    printf '  %s❌ %s%s\n' "$RED" "$label" "$NC"
    sed 's/^/       /' "$out"
    fixes+=("$step · $label  (rerun: task $step)")
  fi
  while IFS= read -r n; do
    case "$n" in
      ⚠️*) warnings=$((warnings + 1)); printf '     %s%s%s\n' "$YELLOW" "$n" "$NC" ;;
      *) printf '     %s%s%s\n' "$CYAN" "$n" "$NC" ;;
    esac
  done <"$notes"
  rm -f "$out" "$notes"
}

# skip <label> <reason>: a check that does not apply, counted and shown with why.
skip() {
  total=$((total + 1)) skipped=$((skipped + 1))
  printf '  %s⏭️  %s: skipped: %s%s\n' "$YELLOW" "$1" "$2" "$NC"
}

header() {
  local stacks="" mode_note=""
  if has_go; then stacks="go (go.mod)"; else stacks="go: none (no go.mod)"; fi
  if has_web; then stacks="$stacks | web ($WEB_DIR/)"; else stacks="$stacks | web: none (no $WEB_DIR/package.json)"; fi
  [ "$MODE" = ci ] && mode_note=" (strict)"
  printf '\n%s%s%s\n' "$PURPLE" "$LINE" "$NC"
  printf '%s🚀 Standard checks: %s%s\n' "$PURPLE" "$*" "$NC"
  printf '%sMode: %s%s%s | Coverage min: %s%s%%%s | Test timeout: %s%s%s\n' "$PURPLE" "$CYAN" "$MODE$mode_note" "$PURPLE" \
    "$CYAN" "$COVERAGE_MIN" "$PURPLE" "$CYAN" "$TEST_TIMEOUT" "$NC"
  printf '%sStacks: %s%s\n' "$PURPLE" "$stacks" "$NC"
  printf '%s%s%s\n' "$PURPLE" "$LINE" "$NC"
}

summary() {
  local secs=$(($(date +%s) - start)) f
  printf '\n%s%s%s\n' "$PURPLE" "$LINE" "$NC"
  printf '%s📈 Summary: %s%s\n' "$PURPLE" "$*" "$NC"
  printf '   %s✅ Passed:   %s%s\n' "$GREEN" "$passed" "$NC"
  printf '   %s❌ Failed:   %s%s\n' "$RED" "$failed" "$NC"
  printf '   %s⏭️  Skipped:  %s%s\n' "$YELLOW" "$skipped" "$NC"
  printf '   %s⚠️  Warnings: %s%s\n' "$YELLOW" "$warnings" "$NC"
  printf '   %s📝 Total:    %s%s\n' "$BLUE" "$total" "$NC"
  printf '   %s⏱️  Time:     %dm %ds%s\n' "$BLUE" $((secs / 60)) $((secs % 60)) "$NC"
  if [ "$failed" -eq 0 ]; then
    if [ "$*" = "$ALL_STEPS" ]; then
      printf '%s🎉 All checks passed: ready to ship.%s\n' "$GREEN" "$NC"
    else
      printf '%s🎉 %s passed. Run `task validate` before shipping.%s\n' "$GREEN" "$*" "$NC"
    fi
  else
    printf '%s💥 Not ready to ship. Fix these, then run `task validate`:%s\n' "$RED" "$NC"
    for f in "${fixes[@]}"; do printf '   %s❌ %s%s\n' "$RED" "$f" "$NC"; done
  fi
  printf '%s%s%s\n' "$PURPLE" "$LINE" "$NC"
}

# ---- what the repo holds ------------------------------------------------------------------------------------------

has_go() { [ -f go.mod ]; }
has_web() { [ -f "$WEB_DIR/package.json" ]; }
NO_GO="no go.mod at the repo root"
NO_WEB="no $WEB_DIR/package.json"

go_files() { git ls-files -co --exclude-standard -- '*.go'; }

# tagged_pkgs <tag>: each Go package holding a test file built only with that tag, as ./dir
tagged_pkgs() {
  git ls-files -co --exclude-standard -- '*_test.go' | xargs -r grep -lE "^//go:build .*\b$1\b" |
    xargs -r -n1 dirname | sort -u | sed 's#^#./#'
}

web_bin() { printf '%s/node_modules/.bin/%s' "$ROOT/$WEB_DIR" "$1"; }
in_web() { (cd "$ROOT/$WEB_DIR" && "$@"); }
playwright_config() { ls "$WEB_DIR"/playwright.config.* 2>/dev/null | head -1; }
web_test_files() {
  find "$WEB_DIR" -path "$WEB_DIR/node_modules" -prune -o \( -name '*.test.ts' -o -name '*.test.js' \) -print 2>/dev/null
}

# ---- env ----------------------------------------------------------------------------------------------------------

unfilled_spots() {
  local hits
  hits="$(grep -n 'FILL-ME' Taskfile.yml .golangci.yml .github/workflows/checks.yml \
    "$WEB_DIR"/eslint.config.js "$WEB_DIR"/vite.config.ts "$WEB_DIR"/vitest.config.ts 2>/dev/null)"
  [ -z "$hits" ] || { printf 'fill each per-repo spot marked FILL-ME:\n%s\n' "$hits"; return 1; }
}

go_toolchain() {
  command -v go >/dev/null || { echo "go is not on the PATH"; return 1; }
  info "$(go version | awk '{print $3}') (go.mod asks for go $(awk '/^go /{print $2; exit}' go.mod))"
  [ "$(go env CGO_ENABLED)" = 1 ] || { echo "the race detector needs cgo: set CGO_ENABLED=1 and install a C compiler"; return 1; }
  command -v "$(go env CC | awk '{print $1}')" >/dev/null || { echo "the race detector needs a C compiler ($(go env CC))"; return 1; }
}

# golangci_lint: the pinned golangci-lint, from the PATH when it is that version, else installed into CHECKS_TOOLS.
GOLANGCI=""
golangci_lint() {
  local dir="$CHECKS_TOOLS/golangci-lint-$GOLANGCI_LINT_VERSION"
  if command -v golangci-lint >/dev/null && [ "v$(golangci-lint version --short 2>/dev/null)" = "$GOLANGCI_LINT_VERSION" ]; then
    GOLANGCI="$(command -v golangci-lint)"
  elif [ -x "$dir/golangci-lint" ]; then
    GOLANGCI="$dir/golangci-lint"
  else
    info "installing golangci-lint $GOLANGCI_LINT_VERSION into $dir"
    GOBIN="$dir" go install "github.com/golangci/golangci-lint/v2/cmd/golangci-lint@$GOLANGCI_LINT_VERSION" || return 1
    GOLANGCI="$dir/golangci-lint"
  fi
}
golangci_ready() { golangci_lint && info "$GOLANGCI"; }

# node_modules can hold .go files; a go.mod of its own keeps the web folder out of Go's ./...
web_go_mod() {
  [ -f "$WEB_DIR/go.mod" ] || { echo "no $WEB_DIR/go.mod: add one (the standard's install.sh writes it) so ./... skips $WEB_DIR/"; return 1; }
}

web_node() {
  command -v node >/dev/null || { echo "node is not on the PATH"; return 1; }
  command -v npm >/dev/null || { echo "npm is not on the PATH"; return 1; }
  local major
  major="$(node -p 'process.versions.node.split(".")[0]')"
  info "node $(node --version), npm $(npm --version)"
  [ "$major" -ge "$NODE_MIN" ] || { echo "node $NODE_MIN or later is needed; this is $(node --version)"; return 1; }
}

# web_pins: each pinned tool is in package.json; a different or unpinned version is a warning.
web_pins() {
  local pins="$WEB_PINS" line bad=0
  [ -n "$(playwright_config)" ] && pins="$pins $PLAYWRIGHT_PIN"
  # shellcheck disable=SC2086  # one pin per word on purpose
  while IFS= read -r line; do
    case "$line" in
      MISSING*) echo "${line#MISSING }"; bad=1 ;;
      DIFF*) warn "${line#DIFF }" ;;
    esac
  done < <(node -e '
    const pkg = require(process.argv[1]);
    const have = { ...(pkg.dependencies || {}), ...(pkg.devDependencies || {}) };
    for (const pin of process.argv.slice(2)) {
      const at = pin.lastIndexOf("@"), name = pin.slice(0, at), want = pin.slice(at + 1);
      if (!(name in have)) console.log(`MISSING ${name} is not in package.json; add it at ${want}: npm install -D -E ${pin}`);
      else if (have[name] !== want) console.log(`DIFF ${name} is ${have[name]} in package.json; the standard pins ${want}`);
    }' "$ROOT/$WEB_DIR/package.json" $pins)
  return "$bad"
}

web_packages() {
  [ -f "$WEB_DIR/package-lock.json" ] || { echo "no $WEB_DIR/package-lock.json: run npm install in $WEB_DIR and commit the lockfile"; return 1; }
  if [ "$MODE" = ci ] || ! [ "$WEB_DIR/node_modules/.package-lock.json" -nt "$WEB_DIR/package-lock.json" ]; then
    in_web npm ci --no-audit --no-fund || return 1
    info "installed from package-lock.json"
  else
    info "already installed from package-lock.json"
  fi
}

web_browser() { in_web "$(web_bin playwright)" install chromium; }

known_stack() {
  has_go || has_web || { echo "the standard checks cover Go (go.mod) and TypeScript/Svelte ($WEB_DIR/package.json); this repo has neither, so they would check nothing"; return 1; }
}

step_env() {
  check "repo: git" git rev-parse --git-dir
  check "repo: a stack the standard checks cover" known_stack
  check "repo: per-repo spots filled" unfilled_spots
  if has_go; then
    check "go: toolchain" go_toolchain
    check "go: golangci-lint $GOLANGCI_LINT_VERSION" golangci_ready
  else
    skip "go" "$NO_GO"
  fi
  if has_go && has_web; then
    check "go: $WEB_DIR/ kept out of ./..." web_go_mod
  fi
  if has_web; then
    check "web: node and npm" web_node
    check "web: pinned tools in package.json" web_pins
    check "web: packages" web_packages
    if [ -n "$(playwright_config)" ]; then check "web: browser for Playwright" web_browser; fi
  else
    skip "web" "$NO_WEB"
  fi
}

# ---- lint ---------------------------------------------------------------------------------------------------------

go_format() {
  local unformatted
  # shellcheck disable=SC2046  # one path per word on purpose
  unformatted="$(gofmt -l $(go_files))"
  [ -z "$unformatted" ] || { printf 'not gofmt-formatted (run gofmt -w on them):\n%s\n' "$unformatted"; return 1; }
}

go_lint() { golangci_lint && "$GOLANGCI" run ./...; }

step_lint() {
  if has_go; then
    check "go: format (gofmt)" go_format
    check "go: golangci-lint" go_lint
  else
    skip "go" "$NO_GO"
  fi
  if has_web; then
    check "web: format (prettier)" in_web "$(web_bin prettier)" --check .
    check "web: eslint" in_web "$(web_bin eslint)" . --max-warnings 0
  else
    skip "web" "$NO_WEB"
  fi
}

# ---- build --------------------------------------------------------------------------------------------------------

go_tidy() {
  go mod tidy -diff || { echo "go.mod or go.sum is not tidy: run go mod tidy and commit the result"; return 1; }
}

step_build() {
  # The web page first: a Go binary may embed it.
  if has_web; then
    check "web: types (svelte-check)" in_web "$(web_bin svelte-check)" --fail-on-warnings --output human
    check "web: types (tsc)" in_web "$(web_bin tsc)" --noEmit
    check "web: build (vite)" in_web "$(web_bin vite)" build
  else
    skip "web" "$NO_WEB"
  fi
  if has_go; then
    check "go: build" go build ./...
    check "go: go.mod tidy" go_tidy
  else
    skip "go" "$NO_GO"
  fi
}

# ---- tests --------------------------------------------------------------------------------------------------------

# go_test_notes: the per-package lines of a go test run, as notes.
go_test_notes() { grep -E '^(ok|\?|FAIL)\s' "$1" | while IFS= read -r l; do info "$l"; done; }

go_unit() {
  local log
  mkdir -p "$STATE"
  log="$(mktemp)"
  go test -race -timeout "$TEST_TIMEOUT" -covermode=atomic -coverprofile="$STATE/go-cover.out" ./... 2>&1 | tee "$log"
  local rc="${PIPESTATUS[0]}"
  [ "$rc" -eq 0 ] && echo "$RUN_ID" >"$STATE/go-cover.run" && go_test_notes "$log"
  rm -f "$log"
  return "$rc"
}

# tally_notes <log> <regex>: the tool's own count lines, as notes.
tally_notes() { sed 's/\x1b\[[0-9;]*m//g' "$1" | grep -E "$2" | sed 's/^ *//' | while IFS= read -r l; do info "$l"; done; }

web_unit() {
  local log rc
  mkdir -p "$STATE"
  rm -rf "$STATE/web-coverage"
  log="$(mktemp)"
  in_web "$(web_bin vitest)" run --coverage --coverage.reporter=json-summary --coverage.reporter=text \
    --coverage.reportsDirectory="$STATE/web-coverage" 2>&1 | tee "$log"
  rc="${PIPESTATUS[0]}"
  [ "$rc" -eq 0 ] && echo "$RUN_ID" >"$STATE/web-cover.run" && tally_notes "$log" '^ *(Test Files|Tests) '
  rm -f "$log"
  return "$rc"
}

web_e2e() {
  local log rc
  log="$(mktemp)"
  in_web "$(web_bin playwright)" test 2>&1 | tee "$log"
  rc="${PIPESTATUS[0]}"
  [ "$rc" -eq 0 ] && tally_notes "$log" '^ *[0-9]+ passed'
  rm -f "$log"
  return "$rc"
}

step_unit() {
  if has_go; then check "go: unit tests (race)" go_unit; else skip "go" "$NO_GO"; fi
  if has_web; then
    if [ -n "$(web_test_files)" ]; then check "web: unit tests (vitest)" web_unit; else skip "web: unit tests" "no *.test.ts in $WEB_DIR"; fi
  else
    skip "web" "$NO_WEB"
  fi
}

# go_tagged <tag> [race]: the packages with test files built only with that tag, tested with it.
go_tagged() {
  local tag="$1" race="${2:-}" pkgs log rc
  pkgs="$(tagged_pkgs "$tag")"
  log="$(mktemp)"
  # shellcheck disable=SC2086  # one package per word on purpose
  go test $race -count=1 -timeout "$TEST_TIMEOUT" -tags "$tag" $pkgs 2>&1 | tee "$log"
  rc="${PIPESTATUS[0]}"
  [ "$rc" -eq 0 ] && go_test_notes "$log"
  rm -f "$log"
  return "$rc"
}

step_integration() {
  if has_go; then
    if [ -n "$(tagged_pkgs integration)" ]; then
      check "go: integration tests (-tags integration, race)" go_tagged integration -race
    else
      skip "go: integration tests" "no Go test file starts with //go:build integration"
    fi
  else
    skip "go" "$NO_GO"
  fi
}

step_e2e() {
  if has_go; then
    if [ -n "$(tagged_pkgs e2e)" ]; then
      check "go: E2E tests (-tags e2e)" go_tagged e2e
    else
      skip "go: E2E tests" "no Go test file starts with //go:build e2e"
    fi
  else
    skip "go" "$NO_GO"
  fi
  if has_web; then
    if [ -n "$(playwright_config)" ]; then
      check "web: E2E tests (playwright)" web_e2e
    else
      skip "web: E2E tests" "no playwright.config in $WEB_DIR"
    fi
  else
    skip "web" "$NO_WEB"
  fi
}

# ---- coverage -----------------------------------------------------------------------------------------------------

# Coverage reads the unit run of this same `validate`; run alone, it runs the unit tests first.
go_coverage() {
  if [ "$(cat "$STATE/go-cover.run" 2>/dev/null)" != "$RUN_ID" ]; then
    go_unit >/dev/null 3>/dev/null || { echo "the unit tests fail: run task unit"; return 1; }
  fi
  local counted="$STATE/go-cover.counted" total
  grep -vE "$COVERAGE_EXCLUDE" "$STATE/go-cover.out" >"$counted"
  if [ "$(wc -l <"$counted")" -le 1 ]; then
    info "no Go statements to count (all are under $COVERAGE_EXCLUDE or untested packages hold none)"
    return 0
  fi
  total="$(go tool cover -func="$counted" | awk '/^total:/ { sub("%", "", $3); print $3 }')"
  info "Go coverage ${total}% (needs ${COVERAGE_MIN}%; leaves out $COVERAGE_EXCLUDE)"
  if ! awk -v t="$total" -v m="$COVERAGE_MIN" 'BEGIN { exit !(t >= m) }'; then
    echo "Go coverage ${total}% is below ${COVERAGE_MIN}%. The least-covered functions:"
    go tool cover -func="$counted" | grep -v '^total:' |
      awk '{ p = $NF; sub("%", "", p); if (p + 0 < 100) print p "\t" $0 }' | sort -n | head -10 | cut -f2-
    return 1
  fi
}

web_coverage() {
  if [ "$(cat "$STATE/web-cover.run" 2>/dev/null)" != "$RUN_ID" ]; then
    web_unit >/dev/null 3>/dev/null || { echo "the web unit tests fail: run task unit"; return 1; }
  fi
  local report
  report="$(node -e '
    const t = require(process.argv[1]).total, min = Number(process.argv[2]);
    let low = [];
    for (const k of ["lines", "statements", "functions", "branches"]) {
      console.log(`NOTE ${k} ${t[k].pct}%`);
      if (t[k].pct < min) low.push(`${k} ${t[k].pct}%`);
    }
    if (low.length) console.log(`LOW ${low.join(", ")} below ${min}%`);
  ' "$STATE/web-coverage/coverage-summary.json" "$COVERAGE_MIN")" || return 1
  info "web coverage $(echo "$report" | sed -n 's/^NOTE //p' | paste -sd, - | sed 's/,/, /g') (needs ${COVERAGE_MIN}% each)"
  if echo "$report" | grep -q '^LOW'; then
    echo "web coverage: $(echo "$report" | sed -n 's/^LOW //p'). The least-covered files:"
    node -e '
      const s = require(process.argv[1]);
      Object.entries(s).filter(([f]) => f !== "total")
        .sort((a, b) => a[1].lines.pct - b[1].lines.pct).slice(0, 10)
        .forEach(([f, v]) => console.log(`  ${v.lines.pct}% lines  ${f.replace(process.argv[2] + "/", "")}`));
    ' "$STATE/web-coverage/coverage-summary.json" "$ROOT"
    return 1
  fi
}

step_coverage() {
  if has_go; then check "go: coverage ≥ ${COVERAGE_MIN}%" go_coverage; else skip "go" "$NO_GO"; fi
  if has_web; then
    if [ -n "$(web_test_files)" ]; then
      check "web: coverage ≥ ${COVERAGE_MIN}%" web_coverage
    else
      skip "web: coverage" "no *.test.ts in $WEB_DIR"
    fi
  else
    skip "web" "$NO_WEB"
  fi
}

# ---- docs ---------------------------------------------------------------------------------------------------------

readme() {
  [ -f README.md ] && return 0
  if [ "$MODE" = ci ]; then echo "no README.md at the repo root"; return 1; fi
  warn "no README.md at the repo root (CI fails on this)"
}

step_docs() { check "repo: README.md" readme; }

# ---- main ---------------------------------------------------------------------------------------------------------

[ "$#" -gt 0 ] || { echo "usage: scripts/checks.sh <step>... (steps: $ALL_STEPS) | pins"; exit 2; }
for s in "$@"; do
  case " $ALL_STEPS " in *" $s "*) ;; *) echo "unknown step: $s (steps: $ALL_STEPS)"; exit 2 ;; esac
done
export CHECKS_RUN_ID="$RUN_ID"

header "$@"
stop=""
for s in "$@"; do
  if [ -n "$stop" ]; then
    total=$((total + 1)) skipped=$((skipped + 1))
    printf '\n%s▶ %s%s\n  %s⏭️  %s: skipped: %s%s\n' "$BLUE" "$s" "$NC" "$YELLOW" "$s" "$stop" "$NC"
    continue
  fi
  step="$s"
  printf '\n%s▶ %s%s\n' "$BLUE" "$s" "$NC"
  before="$failed"
  "step_$s"
  # The other steps need the tools env checks.
  [ "$s" = env ] && [ "$failed" -gt "$before" ] && stop="env failed; fix it first"
done
summary "$@"
[ "$failed" -eq 0 ]
