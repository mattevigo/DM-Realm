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

# A path the pinned release does not have: exit 4, not "unreachable".
OUT=$(helper file data/spells/spells-test.json 2>&1); CODE=$?
[ "$CODE" -eq 4 ] || fail "missing: expected exit 4, got $CODE ($OUT)"
case "$OUT" in *"not in"*v1.0.0*) ;; *) fail "missing: message should say the file is not in v1.0.0: $OUT";; esac

# Unreachable and not cached: exit 3, a message naming the Trusted Source, no file.
OUT=$(DMR_SOURCE_RAW="http://127.0.0.1:9/raw" helper file data/spells/spells-test.json 2>&1); CODE=$?
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

# refresh: moves the pin to the latest release and re-fetches every cached file from it.
export DMR_SOURCE_CACHE="$TMP/cache2"
mkdir -p "$MIRROR/raw/v1.0.0/data/spells" "$MIRROR/raw/v1.1.0/data/spells"
printf '{"condition":[{"name":"Dazzled","source":"TEST","page":1}]}\n' > "$MIRROR/raw/v1.0.0/data/conditionsdiseases.json"
printf '{"spell":[{"name":"Spark","source":"TEST","page":10}]}\n' > "$MIRROR/raw/v1.0.0/data/spells/spells-test.json"
printf '{"spell":[{"name":"Spark","source":"TEST","page":20}]}\n' > "$MIRROR/raw/v1.1.0/data/spells/spells-test.json"
printf '{"tag_name": "v1.0.0"}\n' > "$MIRROR/latest.json"
helper file data/conditionsdiseases.json >/dev/null && helper file data/spells/spells-test.json >/dev/null || fail "refresh setup"
OUT=$(helper refresh) || fail "refresh up to date: exit $?"
case "$OUT" in *"up to date"*v1.0.0*) ;; *) fail "refresh up to date: got '$OUT'";; esac
printf '{"tag_name": "v1.1.0"}\n' > "$MIRROR/latest.json"
OUT=$(helper refresh) || fail "refresh: exit $?"
case "$OUT" in *v1.0.0*v1.1.0*) ;; *) fail "refresh: should report old and new release, got '$OUT'";; esac
[ "$(helper release)" = "v1.1.0" ] || fail "refresh: pin should be v1.1.0"
grep -q '"page":2' "$DMR_SOURCE_CACHE/v1.1.0/data/conditionsdiseases.json" 2>/dev/null || fail "refresh: conditions not re-fetched from v1.1.0"
grep -q '"page":20' "$DMR_SOURCE_CACHE/v1.1.0/data/spells/spells-test.json" 2>/dev/null || fail "refresh: spells not re-fetched from v1.1.0"
[ ! -e "$DMR_SOURCE_CACHE/v1.0.0" ] || fail "refresh: old release copy should be gone"

# refresh that cannot complete keeps the old pin and the old files intact.
printf '{"tag_name": "v1.2.0"}\n' > "$MIRROR/latest.json"
OUT=$(DMR_SOURCE_RAW="http://127.0.0.1:9/raw" helper refresh 2>&1); CODE=$?
[ "$CODE" -eq 3 ] || fail "refresh failing: expected exit 3, got $CODE"
[ "$(helper release)" = "v1.1.0" ] || fail "refresh failing: pin must stay v1.1.0"
[ -f "$DMR_SOURCE_CACHE/v1.1.0/data/spells/spells-test.json" ] || fail "refresh failing: old files must stay"
[ ! -e "$DMR_SOURCE_CACHE/v1.2.0" ] || fail "refresh failing: left a partial release"

# A cached file the new release no longer has is dropped, not a reason to stay behind.
mkdir -p "$MIRROR/raw/v1.2.0/data"
cp "$MIRROR/raw/v1.1.0/data/conditionsdiseases.json" "$MIRROR/raw/v1.2.0/data/"
OUT=$(helper refresh) || fail "refresh dropped file: exit $?"
[ "$(helper release)" = "v1.2.0" ] || fail "refresh dropped file: pin should be v1.2.0"
case "$OUT" in *"spells/spells-test.json"*) ;; *) fail "refresh dropped file: should name the dropped file: $OUT";; esac
[ -f "$DMR_SOURCE_CACHE/v1.2.0/data/conditionsdiseases.json" ] || fail "refresh dropped file: kept files must be re-fetched"

# --- Images: the image mirror, at the pinned data release's tag (ADR 0008) ----------
# Invented bytes stand in for images: no real 5etools image here (ADR 0003).
export DMR_SOURCE_CACHE="$TMP/cache5"
export DMR_SOURCE_IMG="file://$MIRROR/img"
mkdir -p "$MIRROR/img/v1.2.0/bestiary/TEST" "$MIRROR/img/v1.3.0/bestiary/TEST" "$MIRROR/img/v1.2.0/adventure/TEST"
printf 'IMG-1.2.0' > "$MIRROR/img/v1.2.0/bestiary/TEST/Quill Hound.webp"
printf 'MAP-1.2.0' > "$MIRROR/img/v1.2.0/adventure/TEST/map.png"
printf 'IMG-1.3.0' > "$MIRROR/img/v1.3.0/bestiary/TEST/Quill Hound.webp"
printf '{"tag_name": "v1.2.0"}\n' > "$MIRROR/latest.json"

# Fetched from the pinned tag, cached beside the data, printed as a local path.
OUT=$(helper image "bestiary/TEST/Quill Hound.webp") || fail "image: exit $?"
[ "$OUT" = "$DMR_SOURCE_CACHE/v1.2.0/img/bestiary/TEST/Quill Hound.webp" ] || fail "image: got '$OUT'"
[ "$(cat "$OUT" 2>/dev/null)" = "IMG-1.2.0" ] || fail "image: should hold the v1.2.0 image"

# Fetched only once: the mirror's copy gone, the cached one is still served.
rm "$MIRROR/img/v1.2.0/bestiary/TEST/Quill Hound.webp"
OUT=$(DMR_SOURCE_IMG="http://127.0.0.1:9/img" helper image "bestiary/TEST/Quill Hound.webp") || fail "image cached: exit $?"
[ "$(cat "$OUT" 2>/dev/null)" = "IMG-1.2.0" ] || fail "image cached: should serve the cached copy offline"

# No such image in the pinned release: exit 4; unreachable and not cached: exit 3, no file.
OUT=$(helper image bestiary/TEST/Nothing.webp 2>&1); CODE=$?
[ "$CODE" -eq 4 ] || fail "image missing: expected exit 4, got $CODE ($OUT)"
OUT=$(DMR_SOURCE_IMG="http://127.0.0.1:9/img" helper image adventure/TEST/map.png 2>&1); CODE=$?
[ "$CODE" -eq 3 ] || fail "image unreachable: expected exit 3, got $CODE"
[ ! -e "$DMR_SOURCE_CACHE/v1.2.0/img/adventure/TEST/map.png" ] || fail "image unreachable: left a file"

# Only paths inside the image mirror.
helper image ../x.webp >/dev/null 2>&1 && fail "image path: accepted '..'"
helper image /etc/passwd >/dev/null 2>&1 && fail "image path: accepted an absolute path"
helper image "" >/dev/null 2>&1 && fail "image path: accepted an empty path"

# refresh re-fetches cached images from the new tag, like the data.
helper image adventure/TEST/map.png >/dev/null || fail "image refresh setup"
mkdir -p "$MIRROR/raw/v1.3.0/data" "$MIRROR/img/v1.3.0/adventure/TEST"
printf 'MAP-1.3.0' > "$MIRROR/img/v1.3.0/adventure/TEST/map.png"
printf '{"tag_name": "v1.3.0"}\n' > "$MIRROR/latest.json"
OUT=$(helper refresh) || fail "image refresh: exit $?: $OUT"
[ "$(cat "$DMR_SOURCE_CACHE/v1.3.0/img/bestiary/TEST/Quill Hound.webp" 2>/dev/null)" = "IMG-1.3.0" ] || fail "image refresh: image not re-fetched from v1.3.0"
[ "$(cat "$DMR_SOURCE_CACHE/v1.3.0/img/adventure/TEST/map.png" 2>/dev/null)" = "MAP-1.3.0" ] || fail "image refresh: map not re-fetched from v1.3.0"
[ ! -e "$DMR_SOURCE_CACHE/v1.2.0" ] || fail "image refresh: old release copy should be gone"

# The eval override wins for the image mirror too.
OUT=$(EVAL_DMR_SOURCE_IMG="http://127.0.0.1:9/img" helper image bestiary/TEST/Other.webp 2>&1); CODE=$?
[ "$CODE" -eq 3 ] || fail "image eval precedence: EVAL_DMR_SOURCE_IMG should win, got exit $CODE"
unset DMR_SOURCE_IMG
printf '{"tag_name": "v1.2.0"}\n' > "$MIRROR/latest.json"

# No cache directory given at all: refuse rather than guess one.
OUT=$(env -u DMR_SOURCE_CACHE -u CLAUDE_PLUGIN_DATA -u EVAL_DMR_SOURCE_CACHE sh -c 'cd "$1" && sh "$2" release' _ "$WS" "$HELPER" 2>&1); CODE=$?
[ "$CODE" -eq 2 ] || fail "no cache dir: expected exit 2, got $CODE"

# EVAL_ overrides win for every setting (the eval runner sets only EVAL_*).
OUT=$(EVAL_DMR_SOURCE_API="file://$TMP/nowhere.json" DMR_SOURCE_CACHE="$TMP/cache4" helper release 2>&1); CODE=$?
[ "$CODE" -eq 3 ] || fail "eval precedence: EVAL_DMR_SOURCE_API should win, got exit $CODE"

# file:// endpoints may start with ~/ (evals pass them from case.yaml).
rm -rf "$TMP/home2"; mkdir -p "$TMP/home2/m"; cp "$MIRROR/latest.json" "$TMP/home2/m/latest.json"
OUT=$(HOME="$TMP/home2" DMR_SOURCE_CACHE="$TMP/cache3" DMR_SOURCE_API="file://~/m/latest.json" helper release) || fail "file ~: exit $?"
[ "$OUT" = "v1.2.0" ] || fail "file ~: got '$OUT'"

[ "$FAILS" -eq 0 ] && echo "source-cache: all pass" || { echo "source-cache: $FAILS failure(s)"; exit 1; }
