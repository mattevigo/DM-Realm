#!/bin/sh
# Tests the Obsidian settings helper: merging DM Realm's keys and reading the
# installed version, against temporary folders and a fake installation.
# Usage: sh tests/obsidian-settings.test.sh   (exit 0 = all pass)
set -u
HELPER="$(cd "$(dirname "$0")/.." && pwd)/skills/dmr-setup/obsidian-settings.py"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
FAILS=0
fail() { echo "FAIL $1"; FAILS=$((FAILS+1)); }
json() { python3 -c "import json,sys; d=json.load(open(sys.argv[1])); print(eval(sys.argv[2]))" "$@"; }

# Fresh folder: the three files appear with exactly DM Realm's keys.
W="$TMP/fresh"; mkdir -p "$W/Modelli"
python3 "$HELPER" merge "$W" Modelli >/dev/null || fail "fresh: exit $?"
[ "$(json "$W/.obsidian/app.json" 'd["useMarkdownLinks"], d["newLinkFormat"]')" = "(False, 'shortest')" ] || fail "fresh: app.json keys"
[ "$(json "$W/.obsidian/core-plugins.json" 'type(d).__name__, d.get("templates")')" = "('dict', True)" ] || fail "fresh: core-plugins.json must be an object with templates true"
[ "$(json "$W/.obsidian/templates.json" 'd["folder"]')" = "Modelli" ] || fail "fresh: templates folder"
[ "$(ls -A "$W/.obsidian" | sort | tr '\n' ' ')" = "app.json core-plugins.json templates.json " ] || fail "fresh: unexpected files: $(ls -A "$W/.obsidian")"

# The DM's own settings stay as they are; only DM Realm's keys change.
W="$TMP/existing"; mkdir -p "$W/.obsidian"
printf '{"vimMode": true, "useMarkdownLinks": true}' > "$W/.obsidian/app.json"
printf '{"graph": false, "templates": false}' > "$W/.obsidian/core-plugins.json"
printf '{"dateFormat": "DD/MM/YYYY"}' > "$W/.obsidian/templates.json"
printf '{"theme": "moonstone"}' > "$W/.obsidian/appearance.json"
python3 "$HELPER" merge "$W" Templates >/dev/null || fail "existing: exit $?"
[ "$(json "$W/.obsidian/app.json" 'd["vimMode"], d["useMarkdownLinks"]')" = "(True, False)" ] || fail "existing: app.json"
[ "$(json "$W/.obsidian/core-plugins.json" 'd["graph"], d["templates"]')" = "(False, True)" ] || fail "existing: core-plugins.json"
[ "$(json "$W/.obsidian/templates.json" 'd["dateFormat"], d["folder"]')" = "('DD/MM/YYYY', 'Templates')" ] || fail "existing: templates.json"
[ "$(cat "$W/.obsidian/appearance.json")" = '{"theme": "moonstone"}' ] || fail "existing: appearance.json was touched"

# Legacy array form becomes the object form without changing which plugins are on.
W="$TMP/legacy"; mkdir -p "$W/.obsidian"
printf '["file-explorer", "global-search"]' > "$W/.obsidian/core-plugins.json"
python3 "$HELPER" merge "$W" Templates >/dev/null || fail "legacy: exit $?"
[ "$(json "$W/.obsidian/core-plugins.json" 'type(d).__name__, d["file-explorer"], d["global-search"], d["templates"], d["graph"], d["canvas"]')" = "('dict', True, True, True, False, False)" ] || fail "legacy: array not converted faithfully: $(cat "$W/.obsidian/core-plugins.json")"

# A settings file that is not valid JSON: touch nothing, exit 2.
W="$TMP/broken"; mkdir -p "$W/.obsidian"
printf '{"vimMode": true,' > "$W/.obsidian/app.json"
OUT=$(python3 "$HELPER" merge "$W" Templates 2>&1); CODE=$?
[ "$CODE" -eq 2 ] || fail "broken: expected exit 2, got $CODE"
[ "$(cat "$W/.obsidian/app.json")" = '{"vimMode": true,' ] || fail "broken: app.json was rewritten"
[ ! -e "$W/.obsidian/templates.json" ] || fail "broken: wrote templates.json anyway"

# Already as DM Realm needs it: no file is rewritten, and it says so.
W="$TMP/fresh"
stamps() { python3 -c "import os,sys; print([os.stat(p).st_mtime_ns for p in sorted(sys.argv[1:])])" "$W/.obsidian"/*.json; }
before=$(stamps); sleep 0.1
OUT=$(python3 "$HELPER" merge "$W" Modelli) || fail "no-op: exit $?"
[ "$before" = "$(stamps)" ] || fail "no-op: files were rewritten"
case "$OUT" in *"already"*) ;; *) fail "no-op: should say the settings are already right: $OUT";; esac

# Drift: it names what it restored.
printf '{"useMarkdownLinks": true, "newLinkFormat": "shortest", "vimMode": true}' > "$W/.obsidian/app.json"
OUT=$(python3 "$HELPER" merge "$W" Modelli) || fail "drift: exit $?"
case "$OUT" in *"app.json"*) ;; *) fail "drift: should name app.json: $OUT";; esac
case "$OUT" in *"templates.json"*) fail "drift: templates.json was already right but is named: $OUT";; esac

# Version: the higher of the installer version and the newest downloaded app package.
APP="$TMP/Info.plist"; CONF="$TMP/obsidian-config"; mkdir -p "$CONF"
cat > "$APP" <<'PL'
<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0"><dict><key>CFBundleShortVersionString</key><string>1.12.7</string></dict></plist>
PL
touch "$CONF/obsidian-1.13.2.asar" "$CONF/obsidian-1.13.10.asar" "$CONF/obsidian.json"
OUT=$(DMR_OBSIDIAN_PLIST="$APP" DMR_OBSIDIAN_CONFIG="$CONF" python3 "$HELPER" version) || fail "version: exit $?"
[ "$OUT" = "found 1.13.10" ] || fail "version: expected 'found 1.13.10', got '$OUT'"
rm "$CONF"/obsidian-1.13.*.asar
OUT=$(DMR_OBSIDIAN_PLIST="$APP" DMR_OBSIDIAN_CONFIG="$CONF" python3 "$HELPER" version)
[ "$OUT" = "found 1.12.7, older than 1.13.7" ] || fail "version older: got '$OUT'"
OUT=$(DMR_OBSIDIAN_PLIST="$TMP/none.plist" DMR_OBSIDIAN_CONFIG="$TMP/none" python3 "$HELPER" version); CODE=$?
[ "$OUT" = "not found" ] && [ "$CODE" -eq 0 ] || fail "version none: got '$OUT' exit $CODE"

[ "$FAILS" -eq 0 ] && echo "obsidian-settings: all pass" || { echo "obsidian-settings: $FAILS failure(s)"; exit 1; }
