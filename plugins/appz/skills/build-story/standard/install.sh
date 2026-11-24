#!/usr/bin/env bash
# install.sh <repo>: put the standard checks into a repo that has none.
# Copies each standard file the repo lacks and keeps each it already has, writes the module path into the Go lint's
# allow-list, adds each pinned web tool the web page's package.json lacks, gitignores the checks' own files, and
# lists the per-repo spots left to fill. Run it again after adding a stack (for example a web/package.json).
set -eu
std="$(cd "$(dirname "$0")" && pwd)"
repo="$(cd "${1:?usage: install.sh <repo>}" && pwd)"
web="${WEB_DIR:-web}"

put() { # put <path>: copy the standard's file to the same path in the repo, unless the repo has one
  if [ -e "$repo/$1" ]; then
    echo "kept   $1 (the repo has its own)"
  else
    mkdir -p "$(dirname "$repo/$1")"
    cp -p "$std/$1" "$repo/$1"
    echo "added  $1"
  fi
}

put Taskfile.yml
put scripts/checks.sh
put .github/workflows/checks.yml
if [ -f "$repo/go.mod" ]; then
  if [ -e "$repo/.golangci.yml" ]; then
    echo "kept   .golangci.yml (the repo has its own)"
  else
    module="$(awk '/^module /{print $2; exit}' "$repo/go.mod")"
    sed "s#FILL-ME/module/path#$module#" "$std/.golangci.yml" >"$repo/.golangci.yml"
    echo "added  .golangci.yml (depguard allows $module)"
  fi
fi

if [ -f "$repo/$web/package.json" ]; then
  for f in .npmrc .prettierrc.json .prettierignore eslint.config.js svelte.config.js tsconfig.json vite.config.ts vitest.config.ts; do
    if [ -e "$repo/$web/$f" ]; then echo "kept   $web/$f (the repo has its own)"; else cp -p "$std/web/$f" "$repo/$web/$f"; echo "added  $web/$f"; fi
  done
  if [ -f "$repo/go.mod" ] && [ ! -e "$repo/$web/go.mod" ]; then
    # node_modules can hold .go files; a module of its own keeps Go's ./... out of the web folder.
    printf '%s\nmodule %s/%s\n\ngo %s\n' "// Not Go code. This file keeps the Go tools out of this folder and its node_modules." \
      "$(awk '/^module /{print $2; exit}' "$repo/go.mod")" "$web" "$(awk '/^go /{print $2; exit}' "$repo/go.mod")" >"$repo/$web/go.mod"
    echo "added  $web/go.mod (keeps Go's ./... out of $web/)"
  fi
  added=0
  for pin in $(bash "$std/scripts/checks.sh" pins); do
    name="${pin%@*}" version="${pin##*@}"
    [ "$name" = "@playwright/test" ] && ! ls "$repo/$web"/playwright.config.* >/dev/null 2>&1 && continue
    if ! node -e 'const p = require(process.argv[1]), n = process.argv[2];
      process.exit((p.dependencies || {})[n] || (p.devDependencies || {})[n] ? 0 : 1)' "$repo/$web/package.json" "$name"; then
      (cd "$repo/$web" && npm pkg set "devDependencies.$name=$version")
      echo "pinned $web/package.json devDependencies $name $version"
      added=1
    fi
  done
  if [ "$added" = 1 ] || [ ! -f "$repo/$web/package-lock.json" ]; then
    # npm 10 fails writing a fresh lockfile for these pins (its resolver trips on vitest's optional peers);
    # it installs from the lockfile fine, so only this write uses a pinned npm 11.
    (cd "$repo/$web" && npx -y npm@11.21.3 install --no-audit --no-fund)
    echo "wrote  $web/package-lock.json"
  fi
fi

touch "$repo/.gitignore"
for ignore in /.checks/ "/$web/node_modules/" "/$web/dist/" "/$web/coverage/" "/$web/test-results/" "/$web/playwright-report/"; do
  case "$ignore" in "/$web/"*) [ -f "$repo/$web/package.json" ] || continue ;; esac
  grep -qxF "$ignore" "$repo/.gitignore" || { echo "$ignore" >>"$repo/.gitignore"; echo "ignore $ignore"; }
done

[ "$web" = web ] || echo "note   WEB_DIR is $web: set WEB_DIR in Taskfile.yml and the web/ paths in .github/workflows/checks.yml to it"
echo
echo "Per-repo spots (FILL-ME must be filled before \`task env\` passes):"
(cd "$repo" && grep -n 'FILL-ME\|PER-REPO' Taskfile.yml .golangci.yml .github/workflows/checks.yml \
  "$web"/eslint.config.js "$web"/vite.config.ts "$web"/vitest.config.ts 2>/dev/null || true)
