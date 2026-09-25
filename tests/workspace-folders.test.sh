#!/bin/sh
# Tests the top-level folder rename helper against a temporary Workspace.
# Usage: sh tests/workspace-folders.test.sh   (exit 0 = all pass)
set -u
HELPER="$(cd "$(dirname "$0")/.." && pwd)/skills/dmr-setup/workspace-folders.py"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
FAILS=0
fail() { echo "FAIL $1"; FAILS=$((FAILS+1)); }

new_ws() {
  W="$TMP/ws$1"; rm -rf "$W"; mkdir -p "$W"
  cat > "$W/workspace-config.yml" <<'YML'
# DM Realm Workspace Config
language: English
edition: 2024
folders:
  reference: Reference
  adventures: Adventures
  homebrew: Homebrew
  campaigns: Campaigns   # the campaigns
  dm_tools: DM_Tools
  templates: Templates
YML
  mkdir -p "$W/Reference" "$W/Adventures" "$W/Homebrew" "$W/Campaigns/Heroes/Sessions" "$W/DM_Tools/Checklists" "$W/Templates" "$W/.obsidian"
  printf '# Session 1\n' > "$W/Campaigns/Heroes/Sessions/Session_01.md"
  cat > "$W/DM_Tools/Checklists/Prep.md" <<'MD'
---
campaign: "[[Campaigns/Heroes/README]]"
---
See [[Campaigns/Heroes/Sessions/Session_01|last session]] and ![[Campaigns/Heroes/map.png]].
Recap: [Session 1](Campaigns/Heroes/Sessions/Session_01.md), also [here](./Campaigns/Heroes/Sessions/Session_01.md).
Untouched: [[My_Campaigns_List]], [[Heroes]], CampaignsX/ and the word Campaigns.
MD
  printf '{"folder": "Templates", "dateFormat": "YYYY"}' > "$W/.obsidian/templates.json"
}

# Rename Campaigns -> Games: folder moved, path links rewritten, config updated.
new_ws 1
OUT=$(python3 "$HELPER" rename "$W" campaigns Games) || fail "rename: exit $? ($OUT)"
[ -f "$W/Games/Heroes/Sessions/Session_01.md" ] && [ ! -e "$W/Campaigns" ] || fail "rename: folder not moved"
P="$W/DM_Tools/Checklists/Prep.md"
for want in '[[Games/Heroes/README]]' '[[Games/Heroes/Sessions/Session_01|last session]]' '![[Games/Heroes/map.png]]' '(Games/Heroes/Sessions/Session_01.md)' '(./Games/Heroes/Sessions/Session_01.md)' '[[My_Campaigns_List]]' 'CampaignsX/' 'the word Campaigns.'; do
  grep -qF -- "$want" "$P" || fail "rename: '$want' missing from Prep.md"
done
grep -q '^  campaigns: Games' "$W/workspace-config.yml" || fail "rename: config not updated"
grep -q '^  reference: Reference' "$W/workspace-config.yml" || fail "rename: other config lines changed"
case "$OUT" in *"1 note"*) ;; *) fail "rename: should report 1 note rewritten: $OUT";; esac

# Renaming Templates also points Obsidian's template folder at it.
new_ws 2
python3 "$HELPER" rename "$W" templates Blueprints >/dev/null || fail "templates: exit $?"
grep -q '"folder": "Blueprints"' "$W/.obsidian/templates.json" && grep -q '"dateFormat": "YYYY"' "$W/.obsidian/templates.json" || fail "templates: templates.json not updated: $(cat "$W/.obsidian/templates.json")"

# Invalid names change nothing: a path, empty after the name rules, a duplicate.
for bad in "Games/Active" "::" "Homebrew"; do
  new_ws 3
  OUT=$(python3 "$HELPER" rename "$W" campaigns "$bad" 2>&1); CODE=$?
  [ "$CODE" -eq 2 ] || fail "invalid '$bad': expected exit 2, got $CODE"
  [ -d "$W/Campaigns" ] && grep -q '^  campaigns: Campaigns' "$W/workspace-config.yml" || fail "invalid '$bad': something changed"
done

# Name rules apply: spaces become underscores.
new_ws 4
python3 "$HELPER" rename "$W" campaigns "Our Games" >/dev/null || fail "name rules: exit $?"
[ -d "$W/Our_Games" ] && grep -q '^  campaigns: Our_Games' "$W/workspace-config.yml" || fail "name rules: expected Our_Games"

# A folder the config names but that is missing on disk: exit 3, nothing changed.
new_ws 5
rm -rf "$W/Homebrew"
OUT=$(python3 "$HELPER" rename "$W" homebrew Brew 2>&1); CODE=$?
[ "$CODE" -eq 3 ] || fail "missing: expected exit 3, got $CODE"

# The Config was edited to the new name before the folder moved: --from names the folder on disk.
new_ws 6
sed -i.bak 's/^  campaigns: Campaigns.*/  campaigns: Games/' "$W/workspace-config.yml" && rm "$W/workspace-config.yml.bak"
python3 "$HELPER" rename "$W" campaigns Games --from Campaigns >/dev/null || fail "from: exit $?"
[ -d "$W/Games" ] && [ ! -e "$W/Campaigns" ] && grep -qF '[[Games/Heroes/README]]' "$W/DM_Tools/Checklists/Prep.md" || fail "from: rename with --from failed"

[ "$FAILS" -eq 0 ] && echo "workspace-folders: all pass" || { echo "workspace-folders: $FAILS failure(s)"; exit 1; }
