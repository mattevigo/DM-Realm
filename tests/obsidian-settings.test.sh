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
# Run in an empty environment with a fake HOME and PATH, so the machine's own
# Obsidian is never seen; each case adds only its fake installation.
PY=$(python3 -c 'import sys; print(sys.executable)')  # the interpreter itself, not a shim
BIN="$TMP/bin"; mkdir -p "$BIN"
version() { env -i HOME="$TMP/home" PATH="$BIN" DMR_OBSIDIAN_PLIST="$TMP/none.plist" "$@" "$PY" "$HELPER" version; }
fake() { printf '#!/bin/sh\n%s\n' "$2" > "$BIN/$1"; chmod +x "$BIN/$1"; }

APP="$TMP/Info.plist"; CONF="$TMP/obsidian-config"; mkdir -p "$CONF"
cat > "$APP" <<'PL'
<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0"><dict><key>CFBundleShortVersionString</key><string>1.12.7</string></dict></plist>
PL
touch "$CONF/obsidian-1.13.2.asar" "$CONF/obsidian-1.13.10.asar" "$CONF/obsidian.json"
OUT=$(version DMR_OBSIDIAN_PLIST="$APP" DMR_OBSIDIAN_CONFIG="$CONF") || fail "version: exit $?"
[ "$OUT" = "found 1.13.10" ] || fail "version: expected 'found 1.13.10', got '$OUT'"
rm "$CONF"/obsidian-1.13.*.asar
OUT=$(version DMR_OBSIDIAN_PLIST="$APP" DMR_OBSIDIAN_CONFIG="$CONF")
[ "$OUT" = "found 1.12.7, older than 1.13.7" ] || fail "version older: got '$OUT'"
OUT=$(version); CODE=$?
[ "$OUT" = "not found" ] && [ "$CODE" -eq 0 ] || fail "version none: got '$OUT' exit $CODE"

# Linux installers: a fresh install has no downloaded package yet, so the installer
# version comes from the package manager, or from an AppImage's file name.
fake dpkg-query 'echo "install ok installed 1.13.7"'
OUT=$(version); [ "$OUT" = "found 1.13.7" ] || fail "version deb: got '$OUT'"
fake dpkg-query 'echo "hold ok installed 1.13.7"'
OUT=$(version); [ "$OUT" = "found 1.13.7" ] || fail "version deb held: got '$OUT'"
fake dpkg-query 'echo "deinstall ok config-files 1.13.7"'
OUT=$(version); [ "$OUT" = "not found" ] || fail "version deb removed: got '$OUT'"
rm "$BIN/dpkg-query"

fake pacman 'echo "obsidian 1.13.7-1"'
OUT=$(version); [ "$OUT" = "found 1.13.7" ] || fail "version pacman: got '$OUT'"
rm "$BIN/pacman"

fake snap 'printf "Name      Version  Rev  Tracking       Publisher     Notes\nobsidian  1.12.4   52   latest/stable  obsidianmd*   classic\n"'
OUT=$(version); [ "$OUT" = "found 1.12.4, older than 1.13.7" ] || fail "version snap: got '$OUT'"
rm "$BIN/snap"

# Flatpak keeps its downloaded packages in its own config folder.
fake flatpak 'printf "Obsidian - Markdown-based knowledge base\n\n          ID: md.obsidian.Obsidian\n     Version: 1.12.4\n     Runtime: org.freedesktop.Platform/x86_64/24.08\n"'
OUT=$(version); [ "$OUT" = "found 1.12.4, older than 1.13.7" ] || fail "version flatpak: got '$OUT'"
mkdir -p "$TMP/home/.var/app/md.obsidian.Obsidian/config/obsidian"
touch "$TMP/home/.var/app/md.obsidian.Obsidian/config/obsidian/obsidian-1.13.8.asar"
OUT=$(version); [ "$OUT" = "found 1.13.8" ] || fail "version flatpak updated: got '$OUT'"
rm -rf "$TMP/home/.var"

# Package managers translate their labels: an Italian desktop must still be read.
fake flatpak '[ "${LC_ALL:-}" = C ] && echo "     Version: 1.13.7" || echo "    Versione: 1.13.7"'
OUT=$(version LANG=it_IT.UTF-8 LC_ALL=it_IT.UTF-8); [ "$OUT" = "found 1.13.7" ] || fail "version flatpak Italian: got '$OUT'"
rm "$BIN/flatpak"

# A command that fails (package not installed) counts as no installation.
fake flatpak 'echo "error: md.obsidian.Obsidian/*unspecified*/*unspecified* not installed" >&2; exit 1'
OUT=$(version); [ "$OUT" = "not found" ] || fail "version flatpak absent: got '$OUT'"
rm "$BIN/flatpak"

mkdir -p "$TMP/home/Applications"; touch "$TMP/home/Applications/Obsidian-1.11.5.AppImage"
OUT=$(version); [ "$OUT" = "found 1.11.5, older than 1.13.7" ] || fail "version AppImage: got '$OUT'"
touch "$TMP/home/Applications/Obsidian-1.13.7-arm64.AppImage"
OUT=$(version); [ "$OUT" = "found 1.13.7" ] || fail "version AppImage arm64: got '$OUT'"
rm -rf "$TMP/home/Applications"

[ "$FAILS" -eq 0 ] && echo "obsidian-settings: all pass" || { echo "obsidian-settings: $FAILS failure(s)"; exit 1; }
