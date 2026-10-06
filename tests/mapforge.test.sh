#!/bin/sh
# Tests the MapForge helper: what MapForge's Bestiary reads of a Workspace, and
# setting its folder when the DM asks (ADR 0011).
# Usage: sh tests/mapforge.test.sh   (exit 0 = all pass)
set -u
HELPER="$(cd "$(dirname "$0")/.." && pwd)/skills/dmr-setup/mapforge.py"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
FAILS=0
fail() { echo "FAIL $1"; FAILS=$((FAILS+1)); }
# field <json> <python expression on d>: prints the value, for comparisons.
field() { printf '%s' "$1" | python3 -c "import json,sys; d=json.load(sys.stdin); print($2)"; }

fence() { # fence <file> <name> [extra yaml line]
  mkdir -p "$(dirname "$1")"
  printf -- '---\nstatblock: inline\n---\n# %s\n\n```statblock\nname: %s\n%s\nac: 12\n```\n' "$2" "$2" "${3:-}" > "$1"
}

new_ws() {
  W="$TMP/ws$1"; rm -rf "$W"; mkdir -p "$W"
  cat > "$W/workspace-config.yml" <<'YML'
language: English
edition: 2024
stat_blocks: true
folders:
  reference: Reference
  adventures: Adventures
  homebrew: Homebrew
  world: World
  characters: Characters
  campaigns: Campaigns   # the campaigns
  dm_tools: DM_Tools
  templates: Templates
YML
  mkdir -p "$W/Reference/Monsters" "$W/Adventures" "$W/Homebrew/Monsters" "$W/World" "$W/Characters" "$W/Campaigns" "$W/DM_Tools" "$W/Templates"
  fence "$W/Reference/Monsters/Goblin.md" Goblin
  fence "$W/Reference/Monsters/Orc.md" Orc
  fence "$W/Homebrew/Monsters/Bog_Goblin.md" "Bog Goblin"
  fence "$W/Campaigns/Heroes/NPCs/Sildar.md" Sildar
  fence "$W/Campaigns/Villains/NPCs/Vex.md" Vex
  fence "$W/Characters/Ayla/Ayla.md" Ayla
  fence "$W/Characters/Ayla/Builds/Ayla_Level_1.md" Ayla "bestiary: false"
  fence "$W/Templates/Homebrew_Monster.md" "—" "bestiary: false"
  printf '# Port Thief\n\nNo statistics.\n' > "$W/World/Port_Thief.md"
}
mapforge() { # mapforge <config.json content or "">: a MapForge Workspace, optionally configured
  mkdir -p "$W/.mapforge"
  printf '{ "version": 1, "createdAt": "2026-09-17T20:09:51Z", "createdBy": "1.2.0" }\n' > "$W/.mapforge/workspace.json"
  [ -n "$1" ] && printf '%s\n' "$1" > "$W/.mapforge/config.json"
  return 0
}
snapshot() { (cd "$W" && find .mapforge -type f -exec cksum {} + 2>/dev/null | sort); }

# No .mapforge/: nothing to report.
new_ws 1
OUT=$(python3 "$HELPER" report "$W") || fail "none: exit $?"
[ "$(field "$OUT" "d['mapforge']")" = "False" ] || fail "none: should say no MapForge: $OUT"
[ ! -e "$W/.mapforge" ] || fail "none: created .mapforge"

# The Reference monsters folder: reads its two, misses Homebrew and the Campaign, no Characters.
new_ws 2; mapforge '{"bestiaryStatBlockPath": "Reference/Monsters", "other": 1}'
BEFORE=$(snapshot)
OUT=$(python3 "$HELPER" report "$W") || fail "subfolder: exit $?"
[ "$(field "$OUT" "d['config']")" = "ok" ] || fail "subfolder: config: $OUT"
[ "$(field "$OUT" "d['path']")" = "Reference/Monsters" ] || fail "subfolder: path: $OUT"
[ "$(field "$OUT" "d['read']")" = "2" ] || fail "subfolder: should read 2: $OUT"
[ "$(field "$OUT" "d['scopes']['reference']['reads']")" = "part" ] || fail "subfolder: reference should be part: $OUT"
[ "$(field "$OUT" "d['scopes']['homebrew']['reads']")" = "none" ] || fail "subfolder: homebrew should be none: $OUT"
[ "$(field "$OUT" "d['scopes']['homebrew']['missed']")" = "1" ] || fail "subfolder: homebrew missed 1: $OUT"
[ "$(field "$OUT" "d['scopes']['campaigns']['missed']")" = "2" ] || fail "subfolder: campaigns missed 2: $OUT"
[ "$(field "$OUT" "d['scopes']['campaigns']['missed_in']")" = "{'Heroes': 1, 'Villains': 1}" ] || fail "subfolder: missed per Campaign: $OUT"
[ "$(field "$OUT" "d['scopes']['adventures']['folder']")" = "Adventures" ] || fail "subfolder: adventures folder name: $OUT"
[ "$(field "$OUT" "d['characters_read']")" = "0" ] || fail "subfolder: no Character read: $OUT"
[ "$(field "$OUT" "d['kept_out_read']")" = "0" ] || fail "subfolder: nothing kept out read: $OUT"
[ "$(field "$OUT" "'characters' in d['scopes']")" = "True" ] || fail "subfolder: characters scope listed: $OUT"
[ "$(snapshot)" = "$BEFORE" ] || fail "subfolder: .mapforge changed"

# One Campaign: part of Campaigns, the other Campaign named as missed; an unclosed fence is no Monster.
new_ws 12; mapforge '{"bestiaryStatBlockPath": "Campaigns/Heroes"}'
printf '# Draft\n\n```statblock\nname: Draft\n' > "$W/Campaigns/Heroes/NPCs/Draft.md"
OUT=$(python3 "$HELPER" report "$W") || fail "campaign: exit $?"
[ "$(field "$OUT" "d['scopes']['campaigns']['reads']")" = "part" ] || fail "campaign: part: $OUT"
[ "$(field "$OUT" "d['scopes']['campaigns']['missed_in']")" = "{'Villains': 1}" ] || fail "campaign: Villains missed: $OUT"
[ "$(field "$OUT" "d['read']")" = "1" ] || fail "campaign: reads Sildar only, not the unclosed fence: $OUT"

# The Workspace root: reads everything, Characters as Monsters, and the notes kept out of the bestiary.
new_ws 3; mapforge '{"bestiaryStatBlockPath": "."}'
OUT=$(python3 "$HELPER" report "$W") || fail "root: exit $?"
[ "$(field "$OUT" "d['scopes']['characters']['reads']")" = "all" ] || fail "root: characters all: $OUT"
[ "$(field "$OUT" "d['characters_read']")" = "1" ] || fail "root: one Character read: $OUT"
[ "$(field "$OUT" "d['kept_out_read']")" = "2" ] || fail "root: past Build and Template read: $OUT"
[ "$(field "$OUT" "sum(s['missed'] for s in d['scopes'].values())")" = "0" ] || fail "root: nothing missed: $OUT"
# MapForge reads hidden folders too: a note in .trash is listed at the root.
fence "$W/.trash/Old_Goblin.md" "Old Goblin"
OUT=$(python3 "$HELPER" report "$W") || fail "root trash: exit $?"
[ "$(field "$OUT" "d['read']")" = "8" ] || fail "root: 7 names plus the one in .trash: $OUT"

# A top-level folder by its name, with a trailing slash: all of that Scope.
new_ws 4; mapforge '{"bestiaryStatBlockPath": "Characters/"}'
OUT=$(python3 "$HELPER" report "$W") || fail "characters: exit $?"
[ "$(field "$OUT" "d['path']")" = "Characters" ] || fail "characters: path normalised: $OUT"
[ "$(field "$OUT" "d['scopes']['characters']['reads']")" = "all" ] || fail "characters: all: $OUT"
[ "$(field "$OUT" "d['characters_read']")" = "1" ] || fail "characters: one read: $OUT"

# No config.json, no key, invalid JSON, a folder not there, a path outside: reported, nothing written.
new_ws 5; mapforge ''
OUT=$(python3 "$HELPER" report "$W") || fail "no config: exit $?"
[ "$(field "$OUT" "d['config']")" = "missing" ] || fail "no config: $OUT"
[ ! -e "$W/.mapforge/config.json" ] || fail "no config: created config.json"
for case in 'no-key|{"somethingElse": true}' 'invalid|{"bestiaryStatBlockPath": "x",}' 'invalid|["Reference"]' 'invalid|{"bestiaryStatBlockPath": 5}' 'no-key|{"bestiaryStatBlockPath": null}' 'not-found|{"bestiaryStatBlockPath": "Bestiary"}' 'outside|{"bestiaryStatBlockPath": "../Elsewhere"}' 'outside|{"bestiaryStatBlockPath": "Reference/../../x"}' 'outside|{"bestiaryStatBlockPath": "/Users/dm/Bestiary"}' 'outside|{"bestiaryStatBlockPath": ""}'; do
  want=${case%%|*}; json=${case#*|}
  new_ws 6; mapforge "$json"; BEFORE=$(snapshot)
  OUT=$(python3 "$HELPER" report "$W") || fail "$want: exit $?"
  [ "$(field "$OUT" "d['config']")" = "$want" ] || fail "$want: got $OUT for $json"
  [ "$(snapshot)" = "$BEFORE" ] || fail "$want: .mapforge changed"
done

# Not a Workspace: exit 2.
python3 "$HELPER" report "$TMP/nowhere" >/dev/null 2>&1; [ $? -eq 2 ] || fail "no workspace: expected exit 2"

# set-bestiary merges the one key, keeps every other, leaves the Manifest alone.
new_ws 7; mapforge '{"bestiaryStatBlockPath": "Old", "theme": "dark"}'
MANIFEST=$(cksum < "$W/.mapforge/workspace.json")
OUT=$(python3 "$HELPER" set-bestiary "$W" "Reference/Monsters/") || fail "set: exit $? ($OUT)"
C="$W/.mapforge/config.json"
[ "$(python3 -c "import json; print(json.load(open('$C')))")" = "{'bestiaryStatBlockPath': 'Reference/Monsters', 'theme': 'dark'}" ] || fail "set: config is $(cat "$C")"
[ "$(cksum < "$W/.mapforge/workspace.json")" = "$MANIFEST" ] || fail "set: Manifest changed"

# set-bestiary with no config.json creates it, and never a Manifest.
new_ws 8
python3 "$HELPER" set-bestiary "$W" Homebrew >/dev/null || fail "set new: exit $?"
[ "$(python3 -c "import json; print(json.load(open('$W/.mapforge/config.json')))")" = "{'bestiaryStatBlockPath': 'Homebrew'}" ] || fail "set new: $(cat "$W/.mapforge/config.json")"
[ ! -e "$W/.mapforge/workspace.json" ] || fail "set new: wrote a Manifest"

# set-bestiary refuses, changing nothing: invalid config, a path outside, a folder not there.
new_ws 9; mapforge '{"bestiaryStatBlockPath": "x",}'; BEFORE=$(snapshot)
python3 "$HELPER" set-bestiary "$W" Homebrew >/dev/null 2>&1; [ $? -eq 2 ] || fail "set invalid: expected exit 2"
[ "$(snapshot)" = "$BEFORE" ] || fail "set invalid: changed"
for bad in "../x" "/abs" "" "Reference/../.."; do
  new_ws 10; mapforge '{"theme": "dark"}'; BEFORE=$(snapshot)
  python3 "$HELPER" set-bestiary "$W" "$bad" >/dev/null 2>&1; [ $? -eq 2 ] || fail "set '$bad': expected exit 2"
  [ "$(snapshot)" = "$BEFORE" ] || fail "set '$bad': changed"
done
new_ws 11; mapforge '{"theme": "dark"}'; BEFORE=$(snapshot)
python3 "$HELPER" set-bestiary "$W" Bestiary >/dev/null 2>&1; [ $? -eq 3 ] || fail "set missing folder: expected exit 3"
[ "$(snapshot)" = "$BEFORE" ] || fail "set missing folder: changed"

[ "$FAILS" -eq 0 ] && echo "mapforge: all pass" || { echo "mapforge: $FAILS failed"; exit 1; }
