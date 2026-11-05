#!/bin/sh
# Builds the guide site (site/) into a temporary folder: the build fails on a page
# missing from its NAV, a NAV entry with no page, or a link or anchor that does not
# resolve. Then checks that every DM-facing skill (every skills/dmr-*/SKILL.md not
# marked user-invocable: false) has its page, skills/<name>.html, so the site
# cannot fall behind the plugin.
# Usage: sh tests/site.test.sh   (exit 0 = all pass)
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT=$(mktemp -d)
trap 'rm -rf "$OUT"' EXIT
FAIL=0

if python3 "$ROOT/site/build.py" "$OUT/site" >"$OUT/log" 2>&1; then
  echo "ok   build: $(cat "$OUT/log")"
else
  echo "FAIL build:"; sed 's/^/     /' "$OUT/log"; FAIL=1
fi

for skill in "$ROOT"/skills/dmr-*/SKILL.md; do
  name=$(basename "$(dirname "$skill")")
  grep -q '^user-invocable: false' "$skill" && continue
  if [ -f "$ROOT/site/pages/skills/$name.html" ]; then
    echo "ok   $name has a page"
  else
    echo "FAIL $name has no page: add site/pages/skills/$name.html and its NAV entry in site/build.py"; FAIL=1
  fi
done

for page in "$ROOT"/site/pages/skills/dmr-*.html; do
  name=$(basename "$page" .html)
  if [ ! -f "$ROOT/skills/$name/SKILL.md" ]; then
    echo "FAIL site/pages/skills/$name.html describes a skill the plugin does not have"; FAIL=1
  fi
done

exit $FAIL
