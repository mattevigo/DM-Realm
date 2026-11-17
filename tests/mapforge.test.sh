#!/bin/sh
# Tests the MapForge helper: what MapForge 2.x reads of a Workspace — its Bestiary, its Characters'
# notes, how its Party is linked, its Treasury — read, never written (ADR 0011).
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
  printf -- '---\nstatblock: inline\n---\n# %s\n\n```statblock\nname: %s\n%b\nac: 12\n```\n' "$2" "$2" "${3:-}" > "$1"
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
  fence "$W/Characters/Ayla/Ayla.md" Ayla "layout: DM Realm Character\nspecies: Elf\nclass: Ranger\nlevel: 3\nplayer: Baldu"
  fence "$W/Characters/Zharyn/Zharyn.md" Zharyn "layout: DM Realm Character\nspecies: Tiefling\nclass: Warlock\nlevel: 3"
  fence "$W/Characters/Ayla/Past_Builds/Ayla_01.md" Ayla "layout: DM Realm Character\nspecies: Elf\nclass: Ranger\nlevel: 1\nbestiary: false"
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

# The whole Workspace, whatever config.json says: every Monster, never a Character (any of its
# keys, `player` or not), a fence kept out with `bestiary: false`, or a note in a hidden folder.
for config in '' '{"bestiaryStatBlockPath": "Reference/Monsters", "other": 1}' '{"bestiaryStatBlockPath": "."}' '{"bestiaryStatBlockPath": "x",}' '["Reference"]' '{"bestiaryStatBlockPath": "../Elsewhere"}'; do
  new_ws 2; mapforge "$config"; BEFORE=$(snapshot)
  fence "$W/.trash/Old_Goblin.md" "Old Goblin"
  fence "$W/.obsidian/Plugin_Goblin.md" "Plugin Goblin"
  OUT=$(python3 "$HELPER" report "$W") || fail "workspace ($config): exit $?"
  [ "$(field "$OUT" "d['monsters']")" = "5" ] || fail "workspace ($config): 5 Monsters: $OUT"
  [ "$(field "$OUT" "'config' in d or 'scopes' in d or 'path' in d")" = "False" ] || fail "workspace ($config): no folder fields: $OUT"
  [ "$(snapshot)" = "$BEFORE" ] || fail "workspace ($config): .mapforge changed"
done
new_ws 3; mapforge ''
OUT=$(python3 "$HELPER" report "$W") || fail "no config: exit $?"
[ ! -e "$W/.mapforge/config.json" ] || fail "no config: created config.json"
# An unclosed fence is a note being typed: no Monster, and not skipped.
printf '# Draft\n\n```statblock\nname: Draft\n' > "$W/Campaigns/Heroes/NPCs/Draft.md"
OUT=$(python3 "$HELPER" report "$W") || fail "unclosed: exit $?"
[ "$(field "$OUT" "d['monsters']")" = "5" ] || fail "unclosed: no Monster: $OUT"

# `extends`: a Monster is its base with changes, a chain is followed, a list (block or flow) lays its
# bases in order, a base kept out with `bestiary: false` is still a base, a Character is never one.
# What cannot be read is skipped, by note and name, with its reason; the first `name` by path wins.
new_ws 20; mapforge ''
fence "$W/Reference/Monsters/Scout.md" Scout
fence "$W/Homebrew/Monsters/Hidden_Base.md" "Hidden Base" "bestiary: false"
fence "$W/Campaigns/Heroes/NPCs/Vinx.md" Vinx "extends: Scout"
fence "$W/Campaigns/Heroes/NPCs/Deep.md" Deep "extends: Vinx"
fence "$W/Campaigns/Heroes/NPCs/Ugof.md" Ugof "extends:\n  - Scout\n  - Hidden Base"
fence "$W/Campaigns/Heroes/NPCs/Kit.md" Kit "extends: [Scout, \"Hidden Base\"]"
fence "$W/Campaigns/Heroes/NPCs/Lost.md" Lost "extends: Nobody"
fence "$W/Campaigns/Heroes/NPCs/Fan.md" Fan "extends: Ayla"
fence "$W/Campaigns/Heroes/NPCs/Ping.md" Ping "extends: Pong"
fence "$W/Campaigns/Heroes/NPCs/Pong.md" Pong "extends: Ping"
fence "$W/Campaigns/Villains/NPCs/Goblin.md" Goblin
printf '# Nameless\n\n```statblock\nac: 12\n```\n' > "$W/Homebrew/Monsters/Nameless.md"
OUT=$(python3 "$HELPER" report "$W") || fail "extends: exit $?"
[ "$(field "$OUT" "d['monsters']")" = "10" ] || fail "extends: the 5, Scout, Vinx, Deep, Ugof and Kit: $OUT"
[ "$(field "$OUT" "sorted((s['file'], s['name'], s['reason'], s.get('base')) for s in d['skipped'])")" = "[('Campaigns/Heroes/NPCs/Fan.md', 'Fan', 'extends-missing', 'Ayla'), ('Campaigns/Heroes/NPCs/Lost.md', 'Lost', 'extends-missing', 'Nobody'), ('Campaigns/Heroes/NPCs/Ping.md', 'Ping', 'extends-loop', None), ('Campaigns/Heroes/NPCs/Pong.md', 'Pong', 'extends-loop', None), ('Homebrew/Monsters/Nameless.md', None, 'no-name', None), ('Reference/Monsters/Goblin.md', 'Goblin', 'duplicate', None)]" ] || fail "extends: skipped: $OUT"

# What MapForge's YAML reader refuses is skipped as unreadable, never counted: an unquoted `: ` in a
# value (top-level or in a list item), a tab in the indentation, a note that is not UTF-8. A `name`
# YAML reads as null or a boolean is no name. A quoted name in a flow list may hold a comma.
new_ws 23; mapforge ''
raw() { mkdir -p "$(dirname "$1")"; printf -- "$2" > "$1"; }
raw "$W/Homebrew/Monsters/Colon.md" '```statblock\nname: Bad: colon\nac: 12\n```\n'
raw "$W/Homebrew/Monsters/Desc.md" '```statblock\nname: Desc\nactions:\n  - name: Bite\n    desc: Melee Attack Roll: +5\n```\n'
raw "$W/Homebrew/Monsters/Tab.md" '```statblock\nname: Tab\nactions:\n\t- name: Bite\n```\n'
raw "$W/Homebrew/Monsters/Null.md" '```statblock\nname: null\nac: 12\n```\n'
raw "$W/Homebrew/Monsters/Bool.md" '```statblock\nname: true\nac: 12\n```\n'
raw "$W/Homebrew/Monsters/Quoted.md" '```statblock\nname: "Ok: quoted"\nactions:\n  - name: Bite\n    desc: "*Melee Attack Roll:* +5"\n```\n'
raw "$W/Homebrew/Monsters/Latin1.md" '```statblock\nname: Caf\351\n```\n'
raw "$W/Homebrew/Monsters/Comma.md" '```statblock\nname: "Comma, Lord"\n```\n'
raw "$W/Homebrew/Monsters/Heir.md" '```statblock\nname: Heir\nextends: ["Comma, Lord"]\n```\n'
OUT=$(python3 "$HELPER" report "$W") || fail "yaml: exit $?"
[ "$(field "$OUT" "d['monsters']")" = "8" ] || fail "yaml: the 5, Ok: quoted, Comma, Lord and Heir: $OUT"
[ "$(field "$OUT" "[(s['file'].split('/')[-1], s['reason']) for s in d['skipped']]")" = "[('Bool.md', 'no-name'), ('Colon.md', 'unreadable'), ('Desc.md', 'unreadable'), ('Latin1.md', 'unreadable'), ('Null.md', 'no-name'), ('Tab.md', 'unreadable')]" ] || fail "yaml: skipped: $OUT"

# Characters' notes: a fence with any Character key, `player` or not, that is not a past Build. A
# second note with a Character's `name` is skipped, the first by path winning, as for a Monster.
new_ws 21; mapforge ''
OUT=$(python3 "$HELPER" report "$W") || fail "characters: exit $?"
[ "$(field "$OUT" "d['characters']")" = "2" ] || fail "characters: Ayla and Zharyn, not the past Build: $OUT"
fence "$W/Characters/Ayla_Old/Ayla.md" Ayla "species: Elf\nclass: Ranger\nlevel: 2"
fence "$W/Characters/Brom/Brom.md" Brom "level: 4"
OUT=$(python3 "$HELPER" report "$W") || fail "characters dup: exit $?"
[ "$(field "$OUT" "d['characters']")" = "3" ] || fail "characters: level alone makes Brom one: $OUT"
[ "$(field "$OUT" "[(s['file'], s['reason']) for s in d['skipped']]")" = "[('Characters/Ayla_Old/Ayla.md', 'duplicate')]" ] || fail "characters: duplicate skipped: $OUT"
[ "$(field "$OUT" "d['monsters']")" = "5" ] || fail "characters: never Monsters: $OUT"

# The Party, as parties.json links it: a Character with no `noteName` is unlinked, and one whose
# `noteName` no Character's note has (a renamed note, a Monster's name) stamps no numbers either.
new_ws 22; mapforge ''
OUT=$(python3 "$HELPER" report "$W") || fail "party none: exit $?"
[ "$(field "$OUT" "(d['parties'], d['unlinked'], d['note_missing'])")" = "('missing', [], [])" ] || fail "party: no parties.json: $OUT"
cat > "$W/.mapforge/parties.json" <<'JSON'
{ "version": 1, "parties": [
  { "id": "p1", "name": "Lost Boys", "characters": [
    { "id": "c1", "name": "Ayla", "colorHex": "#D0342C", "sightSquares": 6, "noteName": "Ayla" },
    { "id": "c2", "name": "Durga", "colorHex": "#2C6BD0", "sightSquares": 6 },
    { "id": "c3", "name": "Brom", "colorHex": "#2CD06B", "sightSquares": 6, "noteName": "Brom Ironfist" } ] },
  { "id": "p2", "name": "Villains", "characters": [
    { "id": "c4", "name": "Gob", "colorHex": "#000000", "sightSquares": 6, "noteName": "Goblin" },
    { "id": "c5", "name": "Zed", "colorHex": "#000000", "sightSquares": 6, "noteName": "Zharyn" } ] } ] }
JSON
BEFORE=$(snapshot)
OUT=$(python3 "$HELPER" report "$W") || fail "party: exit $?"
[ "$(field "$OUT" "d['parties']")" = "ok" ] || fail "party: ok: $OUT"
[ "$(field "$OUT" "d['unlinked']")" = "[{'party': 'Lost Boys', 'character': 'Durga'}]" ] || fail "party: Durga unlinked: $OUT"
[ "$(field "$OUT" "d['note_missing']")" = "[{'party': 'Lost Boys', 'character': 'Brom', 'note': 'Brom Ironfist'}, {'party': 'Villains', 'character': 'Gob', 'note': 'Goblin'}]" ] || fail "party: Brom and Gob linked to no Character's note: $OUT"
[ "$(snapshot)" = "$BEFORE" ] || fail "party: .mapforge changed"
for bad in '{"version": 1, "parties": [' '["Lost Boys"]' '{"version": 1, "parties": 5}'; do
  printf '%s\n' "$bad" > "$W/.mapforge/parties.json"
  OUT=$(python3 "$HELPER" report "$W") || fail "party invalid: exit $?"
  [ "$(field "$OUT" "(d['parties'], d['unlinked'], d['note_missing'])")" = "('invalid', [], [])" ] || fail "party: invalid for $bad: $OUT"
done

# The Treasury: every note outside hidden folders whose frontmatter says `item: true`, wherever it
# is; a Portrait is its frontmatter `image:` (MapForge's ADR-0031).
item() { # item <file> <frontmatter lines>
  mkdir -p "$(dirname "$1")"
  printf -- '---\nsource: XPHB p. 225\n%b\n---\n\n# %s\n\nA thing.\n' "$2" "$(basename "$1" .md | tr _ ' ')" > "$1"
}
new_ws 13; mapforge ''
item "$W/Reference/Magic_Items/Fire_Gem.md" 'item: true\nimage: "[[Reference/Attachments/Fire_Gem.webp]]"'
item "$W/Reference/Equipment/Pouch.md" 'item: true'
item "$W/Adventures/Mine/Items/Lantern.md" 'item: true\nimage: "[[Adventures/Mine/Attachments/Lantern.webp]]"'
item "$W/World/Crown.md" 'item: true'
OUT=$(python3 "$HELPER" report "$W") || fail "treasury: exit $?"
[ "$(field "$OUT" "d['treasury']")" = "4" ] || fail "treasury: should read 4 items: $OUT"
[ "$(field "$OUT" "d['treasury_no_portrait']")" = "2" ] || fail "treasury: 2 without a Portrait: $OUT"
# Only a YAML boolean true is an item: a string, false, a nested key, the key in the body are not;
# hidden folders are skipped.
item "$W/Reference/Magic_Items/Quoted.md" 'item: "true"'
item "$W/Reference/Magic_Items/Single_Quoted.md" "item: 'true'"
item "$W/Reference/Magic_Items/Not_One.md" 'item: false'
item "$W/Reference/Magic_Items/Nested.md" 'tags:\n  item: true'
printf '# Loose\n\nitem: true\n' > "$W/Reference/Magic_Items/Loose.md"
item "$W/.trash/Old_Gem.md" 'item: true'
item "$W/Reference/.drafts/Draft_Gem.md" 'item: true\nimage: "[[x.webp]]"'
OUT=$(python3 "$HELPER" report "$W") || fail "treasury not items: exit $?"
[ "$(field "$OUT" "d['treasury']")" = "4" ] || fail "treasury: strings, false, nested, body and hidden not counted: $OUT"
[ "$(field "$OUT" "d['treasury_no_portrait']")" = "2" ] || fail "treasury: no-Portrait count unchanged: $OUT"
# Two notes with one name are one Item, the first by path (Homebrew's Pouch, with its Portrait,
# before Reference's, without); an empty `image:`, or one that is no wikilink, is no Portrait,
# and an unquoted wikilink is one.
item "$W/Homebrew/Magic_Items/Pouch.md" 'item: true\nimage: "[[Homebrew/Attachments/Pouch.webp]]"'
item "$W/Homebrew/Magic_Items/Bare_Ring.md" 'item: True\nimage:'
item "$W/Homebrew/Magic_Items/Web_Ring.md" 'item: true\nimage: https://example.com/ring.webp'
item "$W/Homebrew/Magic_Items/Plain_Ring.md" 'item: true # an item\nimage: [[Homebrew/Attachments/Plain_Ring.webp|200]]'
OUT=$(python3 "$HELPER" report "$W") || fail "treasury names: exit $?"
[ "$(field "$OUT" "d['treasury']")" = "7" ] || fail "treasury: one Pouch read, and the three Rings: $OUT"
[ "$(field "$OUT" "d['treasury_no_portrait']")" = "3" ] || fail "treasury: Crown, Bare Ring and Web Ring have no Portrait: $OUT"
# A leftover bestiaryStatBlockPath changes nothing; an empty Treasury is 0.
mapforge '{"bestiaryStatBlockPath": "Reference/Monsters"}'
OUT=$(python3 "$HELPER" report "$W") || fail "treasury configured: exit $?"
[ "$(field "$OUT" "d['treasury']")" = "7" ] || fail "treasury: read with a bestiary folder: $OUT"
new_ws 14; mapforge '{"bestiaryStatBlockPath": "."}'
OUT=$(python3 "$HELPER" report "$W") || fail "treasury empty: exit $?"
[ "$(field "$OUT" "(d['treasury'], d['treasury_no_portrait'])")" = "(0, 0)" ] || fail "treasury: empty: $OUT"

# Not a Workspace: exit 2.
python3 "$HELPER" report "$TMP/nowhere" >/dev/null 2>&1; [ $? -eq 2 ] || fail "no workspace: expected exit 2"

# There is no bestiary folder to set: set-bestiary is gone, and asking for it writes nothing.
new_ws 7; mapforge '{"theme": "dark"}'; BEFORE=$(snapshot)
python3 "$HELPER" set-bestiary "$W" Homebrew >/dev/null 2>&1; [ $? -eq 2 ] || fail "set-bestiary: expected the usage, exit 2"
[ "$(snapshot)" = "$BEFORE" ] || fail "set-bestiary: .mapforge changed"
new_ws 8
python3 "$HELPER" set-bestiary "$W" Homebrew >/dev/null 2>&1
[ ! -e "$W/.mapforge" ] || fail "set-bestiary: created .mapforge"

[ "$FAILS" -eq 0 ] && echo "mapforge: all pass" || { echo "mapforge: $FAILS failed"; exit 1; }
