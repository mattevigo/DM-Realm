#!/bin/sh
# Tests the Source Cache helper against a fake Trusted Source mirror served over
# file:// — every entry below is invented; no real Trusted Source data (ADR 0003).
# Usage: sh tests/source-cache.test.sh   (exit 0 = all pass)
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HELPER="$ROOT/skills/dmr-trusted-source/source-cache.sh"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
FAILS=0
fail() { echo "FAIL $1"; FAILS=$((FAILS+1)); }

# Fake mirror: a "latest release" API answer and two releases of raw data.
MIRROR="$TMP/mirror"
mkdir -p "$MIRROR/raw/v1.0.0/data" "$MIRROR/raw/v1.1.0/data"
printf '{\n  "tag_name": "v1.0.0",\n  "name": "v1.0.0"\n}\n' > "$MIRROR/latest.json"
printf '{"condition":[{"name":"Dazzled","source":"TEST","page":1}]}\n' > "$MIRROR/raw/v1.0.0/data/conditionsdiseases.json"
printf '{"condition":[{"name":"Dazzled","source":"TEST","page":2}]}\n' > "$MIRROR/raw/v1.1.0/data/conditionsdiseases.json"

export DMR_SOURCE_API="file://$MIRROR/latest.json"
export DMR_SOURCE_RAW="file://$MIRROR/raw"
export DMR_SOURCE_CACHE="$TMP/cache"
WS="$TMP/workspace"; mkdir -p "$WS"; touch "$WS/workspace-config.yml"
helper() { (cd "$WS" && sh "$HELPER" "$@"); }

# First use pins the latest release and fetches the file from that release's tag.
OUT=$(helper file data/conditionsdiseases.json) || fail "file: exit $?"
[ "$(cat "$DMR_SOURCE_CACHE/release" 2>/dev/null)" = "v1.0.0" ] || fail "pin: release file should say v1.0.0"
[ -f "$OUT" ] && grep -q '"page":1' "$OUT" || fail "file: should print the path of the v1.0.0 copy, got '$OUT'"
[ "$(helper release)" = "v1.0.0" ] || fail "release: should print v1.0.0"

# A newer release upstream does not move the pin; the cached copy is served offline.
printf '{"tag_name": "v1.1.0"}\n' > "$MIRROR/latest.json"
rm -rf "$MIRROR/raw/v1.0.0"
OUT=$(helper file data/conditionsdiseases.json) || fail "cached: exit $?"
grep -q '"page":1' "$OUT" 2>/dev/null || fail "cached: should still serve the pinned v1.0.0 copy"
[ "$(helper release)" = "v1.0.0" ] || fail "cached: the pin must not move on its own"

# Unreachable and not cached: exit 3, a message naming the Trusted Source, no file.
OUT=$(helper file data/spells/spells-test.json 2>&1); CODE=$?
[ "$CODE" -eq 3 ] || fail "unreachable: expected exit 3, got $CODE"
case "$OUT" in *"Trusted Source"*) ;; *) fail "unreachable: message should name the Trusted Source: $OUT";; esac
[ ! -e "$DMR_SOURCE_CACHE/v1.0.0/data/spells/spells-test.json" ] || fail "unreachable: left a partial file"

# Unreachable before anything is pinned: exit 3 too.
rm -rf "$DMR_SOURCE_CACHE"
OUT=$(DMR_SOURCE_API="file://$TMP/nowhere.json" helper file data/conditionsdiseases.json 2>&1); CODE=$?
[ "$CODE" -eq 3 ] || fail "no pin, unreachable: expected exit 3, got $CODE"

# Only data/ paths, never outside the cache.
helper file ../etc/passwd >/dev/null 2>&1 && fail "path: accepted a path outside data/"
helper file data/../../x.json >/dev/null 2>&1 && fail "path: accepted '..'"

# The cache never lives inside a Workspace.
OUT=$(DMR_SOURCE_CACHE="$WS/.cache" helper file data/conditionsdiseases.json 2>&1) && fail "workspace: accepted a cache inside the Workspace"
[ ! -e "$WS/.cache" ] || fail "workspace: wrote into the Workspace"

# Nothing was written into the Workspace by any call above.
[ "$(ls -A "$WS")" = "workspace-config.yml" ] || fail "workspace: unexpected files: $(ls -A "$WS")"

# The eval override wins over DMR_SOURCE_CACHE, and a leading ~/ means $HOME.
rm -rf "$TMP/home"; mkdir -p "$TMP/home"
printf '{"tag_name": "v1.1.0"}\n' > "$MIRROR/latest.json"
OUT=$(HOME="$TMP/home" EVAL_DMR_SOURCE_CACHE="~/.dm-realm/source-cache" helper file data/conditionsdiseases.json) || fail "eval override: exit $?"
[ "$OUT" = "$TMP/home/.dm-realm/source-cache/v1.1.0/data/conditionsdiseases.json" ] || fail "eval override: got '$OUT'"

[ "$FAILS" -eq 0 ] && echo "source-cache: all pass" || { echo "source-cache: $FAILS failure(s)"; exit 1; }
