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
  world: World
  characters: Characters
  campaigns: Campaigns   # the campaigns
  dm_tools: DM_Tools
  templates: Templates
YML
  mkdir -p "$W/Reference" "$W/Adventures" "$W/Homebrew" "$W/World/Aerth/Places" "$W/Characters/Ayla" "$W/Campaigns/Heroes/Sessions" "$W/DM_Tools/Checklists" "$W/Templates" "$W/.obsidian"
  printf '# Session 1\n' > "$W/Campaigns/Heroes/Sessions/Session_01.md"
  printf '# Ayla\n' > "$W/Characters/Ayla/Ayla.md"
  printf '# Port Thief\n' > "$W/World/Aerth/Places/Port_Thief.md"
  printf '# Heroes\n\nParty: [[Characters/Ayla/Ayla|Ayla]]. Starts in [[World/Aerth/Places/Port_Thief|Port Thief]].\n' > "$W/Campaigns/Heroes/README.md"
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

# Renaming Characters: the key is known, the folder moves and links into it are rewritten.
new_ws 7
OUT=$(python3 "$HELPER" rename "$W" characters Party) || fail "characters: exit $? ($OUT)"
[ -f "$W/Party/Ayla/Ayla.md" ] && [ ! -e "$W/Characters" ] || fail "characters: folder not moved"
grep -qF '[[Party/Ayla/Ayla|Ayla]]' "$W/Campaigns/Heroes/README.md" || fail "characters: link not rewritten: $(cat "$W/Campaigns/Heroes/README.md")"
grep -q '^  characters: Party' "$W/workspace-config.yml" || fail "characters: config not updated"

# Renaming World: the key is known, the folder moves and links into it are rewritten.
new_ws 8
OUT=$(python3 "$HELPER" rename "$W" world Mondo) || fail "world: exit $? ($OUT)"
[ -f "$W/Mondo/Aerth/Places/Port_Thief.md" ] && [ ! -e "$W/World" ] || fail "world: folder not moved"
grep -qF '[[Mondo/Aerth/Places/Port_Thief|Port Thief]]' "$W/Campaigns/Heroes/README.md" || fail "world: link not rewritten: $(cat "$W/Campaigns/Heroes/README.md")"
grep -q '^  world: Mondo' "$W/workspace-config.yml" || fail "world: config not updated"

# Invalid names change nothing: a path, empty after the name rules, a duplicate.
for bad in "Games/Active" "::" "Homebrew" "Characters" "World"; do
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

# Renaming Homebrew renames every Campaign's Homebrew_<Type> folders to the new prefix,
# and rewrites the links into them; the DM's other Campaign subfolders stay.
homebrew_ws() {
  new_ws "$1"
  mkdir -p "$W/Homebrew/Spells/Level_2" "$W/Campaigns/Heroes/Homebrew_Spells/Level_3" "$W/Campaigns/Heroes/Homebrew_House_Rules" "$W/Campaigns/Heroes/Narrative" "$W/Campaigns/Villains/Homebrew_Magic_Items"
  printf '# Tidecall\n' > "$W/Homebrew/Spells/Level_2/Tidecall.md"
  printf '# Emberbolt\n' > "$W/Campaigns/Heroes/Homebrew_Spells/Level_3/Emberbolt.md"
  printf '# Short Rests\n' > "$W/Campaigns/Heroes/Homebrew_House_Rules/Short_Rests.md"
  printf '# Plot\n' > "$W/Campaigns/Heroes/Narrative/Plot.md"
  printf '# Ring\n\nKin of [[Campaigns/Heroes/Homebrew_Spells/Level_3/Emberbolt|Emberbolt]].\n' > "$W/Campaigns/Villains/Homebrew_Magic_Items/Ring.md"
  cat > "$W/Campaigns/Heroes/Sessions/Session_02.md" <<'MD'
# Session 2

Mira cast [[Campaigns/Heroes/Homebrew_Spells/Level_3/Emberbolt|Emberbolt]] ([recap](Campaigns/Heroes/Homebrew_Spells/Level_3/Emberbolt.md)).
Rule: ![[Campaigns/Heroes/Homebrew_House_Rules/Short_Rests]]. Also [[Homebrew/Spells/Level_2/Tidecall]].
Untouched: [[Campaigns/Heroes/Narrative/Plot]], [[Homebrew_Spells_Index]] and Campaigns/Heroes/Homebrew_Spells as prose.
MD
}
homebrew_ws 9
OUT=$(python3 "$HELPER" rename "$W" homebrew Brew) || fail "homebrew: exit $? ($OUT)"
[ -f "$W/Brew/Spells/Level_2/Tidecall.md" ] && [ ! -e "$W/Homebrew" ] || fail "homebrew: top-level folder not moved"
[ -f "$W/Campaigns/Heroes/Brew_Spells/Level_3/Emberbolt.md" ] && [ ! -e "$W/Campaigns/Heroes/Homebrew_Spells" ] || fail "homebrew: Heroes' Homebrew_Spells not renamed"
[ -f "$W/Campaigns/Heroes/Brew_House_Rules/Short_Rests.md" ] || fail "homebrew: Heroes' Homebrew_House_Rules not renamed"
[ -f "$W/Campaigns/Villains/Brew_Magic_Items/Ring.md" ] || fail "homebrew: Villains' Homebrew_Magic_Items not renamed"
[ -f "$W/Campaigns/Heroes/Narrative/Plot.md" ] || fail "homebrew: the DM's Narrative folder moved"
S="$W/Campaigns/Heroes/Sessions/Session_02.md"
for want in '[[Campaigns/Heroes/Brew_Spells/Level_3/Emberbolt|Emberbolt]]' '(Campaigns/Heroes/Brew_Spells/Level_3/Emberbolt.md)' '![[Campaigns/Heroes/Brew_House_Rules/Short_Rests]]' '[[Brew/Spells/Level_2/Tidecall]]' '[[Campaigns/Heroes/Narrative/Plot]]' '[[Homebrew_Spells_Index]]' 'Campaigns/Heroes/Homebrew_Spells as prose'; do
  grep -qF -- "$want" "$S" || fail "homebrew: '$want' missing from Session_02.md: $(cat "$S")"
done
grep -qF '[[Campaigns/Heroes/Brew_Spells/Level_3/Emberbolt|Emberbolt]]' "$W/Campaigns/Villains/Brew_Magic_Items/Ring.md" || fail "homebrew: link inside a renamed folder not rewritten"
grep -q '^  homebrew: Brew' "$W/workspace-config.yml" || fail "homebrew: config not updated"
case "$OUT" in *"3 Campaign folder"*) ;; *) fail "homebrew: should report 3 Campaign folders renamed: $OUT";; esac

# The Campaigns folder is found by the name the Config gives it, with the name rules applied to the prefix.
homebrew_ws 10
mv "$W/Campaigns" "$W/Games"
sed -i.bak 's/^  campaigns: Campaigns.*/  campaigns: Games/' "$W/workspace-config.yml" && rm "$W/workspace-config.yml.bak"
python3 "$HELPER" rename "$W" homebrew "Our Brew" >/dev/null || fail "homebrew games: exit $?"
[ -d "$W/Games/Heroes/Our_Brew_Spells" ] && [ -d "$W/Games/Villains/Our_Brew_Magic_Items" ] || fail "homebrew games: prefixed folders not renamed under Games"

# A Campaign that already has a folder with the new prefixed name: nothing changes, exit 2.
homebrew_ws 11
mkdir -p "$W/Campaigns/Heroes/Brew_Spells"
OUT=$(python3 "$HELPER" rename "$W" homebrew Brew 2>&1); CODE=$?
[ "$CODE" -eq 2 ] || fail "homebrew clash: expected exit 2, got $CODE"
[ -d "$W/Homebrew" ] && [ -d "$W/Campaigns/Heroes/Homebrew_Spells" ] && [ -d "$W/Campaigns/Villains/Homebrew_Magic_Items" ] && grep -q '^  homebrew: Homebrew' "$W/workspace-config.yml" || fail "homebrew clash: something changed"
case "$OUT" in *"Brew_Spells"*) ;; *) fail "homebrew clash: should name the folder: $OUT";; esac

# Renaming another folder leaves the Campaigns' Homebrew_ folders alone.
homebrew_ws 12
python3 "$HELPER" rename "$W" campaigns Games >/dev/null || fail "campaigns with homebrew: exit $?"
[ -d "$W/Games/Heroes/Homebrew_Spells" ] || fail "campaigns with homebrew: Homebrew_Spells renamed"

[ "$FAILS" -eq 0 ] && echo "workspace-folders: all pass" || { echo "workspace-folders: $FAILS failure(s)"; exit 1; }
