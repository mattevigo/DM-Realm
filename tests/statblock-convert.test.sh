#!/bin/sh
# Tests the stat block module (skills/dmr-workspace/statblock.py): a note's statistics
# written once, as a Fantasy Statblocks fence or as DM Realm's Markdown (ADR 0009), and
# converted between the two with the same values. Every note here is INVENTED.
# Usage: sh tests/statblock-convert.test.sh   (exit 0 = all pass)
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HELPER="$ROOT/skills/dmr-workspace/statblock.py"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
FAILS=0
fail() { echo "FAIL $1"; FAILS=$((FAILS+1)); }
has() { case "$2" in *"$3"*) ;; *) fail "$1: expected '$3' in:
$2";; esac; }
hasnt() { case "$2" in *"$3"*) fail "$1: did not expect '$3' in:
$2";; esac; }
convert() { python3 "$HELPER" convert "$@" 2>"$TMP/err"; }

# --- A monster, fence to Markdown and back ------------------------------------------
cat > "$TMP/goblin.md" <<'MD'
---
source: EMBC p. 140, v3.0.0
statblock: inline
---

# Bog Goblin

## Description

![[Bog_Goblin.webp]]

Bog goblins live in reeds.

## Stat Block

```statblock
name: Bog Goblin
layout: DM Realm Monster 2014
size: Small
type: fey (goblinoid)
alignment: neutral
ac: 14
ac_class: natural armor
hp: 11
hit_dice: 2d6 + 4
speed: 30 ft., swim 30 ft.
initiative: 2
stats: [8, 15, 14, 9, 10, 8]
saves:
  - Dexterity: 4
skillsaves:
  - Stealth: 6
damage_resistances: poison
senses: darkvision 60 ft., passive Perception 10
languages: Common, Goblin
cr: 1/2
traits:
  - name: Reed Walker
    desc: The goblin moves through reeds without spending extra movement.
actions:
  - name: Multiattack
    desc: The goblin makes two attacks.
  - name: Reed Spear
    desc: "*Melee or Ranged Attack Roll:* +4, reach 5 ft. *Hit:* 6 (1d8 + 2) Piercing damage.\n\nIf the target is Prone, it takes 3 extra damage."
legendary_description: "Legendary Action Uses: 2"
legendary_actions:
  - name: Hide
    desc: The goblin takes the Hide action.
```
MD
cp "$TMP/goblin.md" "$TMP/goblin-original.md"
OUT=$(convert "$TMP/goblin.md" --to markdown) || fail "monster to markdown: exit $?: $(cat "$TMP/err")"
NOTE=$(cat "$TMP/goblin.md")
hasnt "monster markdown: no fence" "$NOTE" '```statblock'
hasnt "monster markdown: no flag" "$NOTE" "statblock: inline"
has "monster markdown: source kept" "$NOTE" "source: EMBC p. 140, v3.0.0"
has "monster markdown: description kept" "$NOTE" "![[Bog_Goblin.webp]]

Bog goblins live in reeds.

## Stat Block"
has "monster markdown: hidden keys" "$NOTE" "%% statblock
name: Bog Goblin
layout: DM Realm Monster 2014
%%"
has "monster markdown: kind" "$NOTE" "*Small fey (goblinoid), neutral*"
has "monster markdown: core" "$NOTE" "**Armor Class** 14 (natural armor)
**Hit Points** 11 (2d6 + 4)
**Speed** 30 ft., swim 30 ft.
**Initiative** +2 (12)"
has "monster markdown: abilities" "$NOTE" "| STR | DEX | CON | INT | WIS | CHA |
| --- | --- | --- | --- | --- | --- |
| 8 (-1) | 15 (+2) | 14 (+2) | 9 (-1) | 10 (+0) | 8 (-1) |"
has "monster markdown: details" "$NOTE" "**Saving Throws** Dexterity +4
**Skills** Stealth +6
**Damage Resistances** poison
**Senses** darkvision 60 ft., passive Perception 10
**Languages** Common, Goblin
**Challenge** 1/2 (XP 100; PB +2)"
has "monster markdown: traits" "$NOTE" "### Traits

- ***Reed Walker.*** The goblin moves through reeds without spending extra movement."
has "monster markdown: multi-paragraph action" "$NOTE" "- ***Reed Spear.*** *Melee or Ranged Attack Roll:* +4, reach 5 ft. *Hit:* 6 (1d8 + 2) Piercing damage.

  If the target is Prone, it takes 3 extra damage."
has "monster markdown: legendary" "$NOTE" "### Legendary Actions

Legendary Action Uses: 2

- ***Hide.*** The goblin takes the Hide action."
OUT=$(convert "$TMP/goblin.md" --to fence) || fail "monster to fence: exit $?: $(cat "$TMP/err")"
cmp -s "$TMP/goblin.md" "$TMP/goblin-original.md" || fail "monster round trip: the note changed:
$(diff "$TMP/goblin-original.md" "$TMP/goblin.md")"

# Converting to the form a note is already in changes nothing, and says so.
OUT=$(convert "$TMP/goblin.md" --to fence) || fail "already fence: exit $?"
has "already fence" "$OUT" "already"
cmp -s "$TMP/goblin.md" "$TMP/goblin-original.md" || fail "already fence: the note changed"

# --- Translated labels: the layouts' own labels, from the Translation Glossary -------
printf '{"Armor Class": "Classe Armatura", "Hit Points": "Punti Ferita", "Speed": "Velocità", "Initiative": "Iniziativa",
 "STR": "FOR", "DEX": "DES", "CON": "COS", "INT": "INT", "WIS": "SAG", "CHA": "CAR",
 "Saving Throws": "Tiri Salvezza", "Skills": "Abilità", "Damage Resistances": "Resistenze ai Danni",
 "Senses": "Sensi", "Languages": "Lingue", "Challenge": "Grado di Sfida", "XP": "PE", "PB": "BC",
 "Traits": "Tratti", "Actions": "Azioni", "Legendary Actions": "Azioni Leggendarie"}\n' > "$TMP/labels-it.json"
OUT=$(convert "$TMP/goblin.md" --to markdown --labels "$TMP/labels-it.json") || fail "italian labels: exit $?: $(cat "$TMP/err")"
NOTE=$(cat "$TMP/goblin.md")
has "italian labels" "$NOTE" "**Classe Armatura** 14 (natural armor)"
has "italian labels" "$NOTE" "| FOR | DES | COS | INT | SAG | CAR |"
has "italian labels" "$NOTE" "**Grado di Sfida** 1/2 (PE 100; BC +2)"
has "italian labels" "$NOTE" "### Azioni Leggendarie"
convert "$TMP/goblin.md" --to fence --labels "$TMP/labels-it.json" >/dev/null || fail "italian back: exit $?: $(cat "$TMP/err")"
cmp -s "$TMP/goblin.md" "$TMP/goblin-original.md" || fail "italian round trip: the note changed:
$(diff "$TMP/goblin-original.md" "$TMP/goblin.md")"

# --- Links: never only in a fence ------------------------------------------------------
cat > "$TMP/witch.md" <<'MD'
# Reed Witch

## Stat Block

%% statblock
name: Reed Witch
%%

*Medium humanoid, chaotic evil*

**Armor Class** 12
**Hit Points** 27 (6d8)
**Speed** 30 ft.

### Actions

- ***Spellcasting.*** The witch casts [[Reference/Spells/Level_1/Soft_Light|Soft Light]] or [[Tidecall]].
MD
OUT=$(convert "$TMP/witch.md" --to fence) || fail "links to fence: exit $?: $(cat "$TMP/err")"
NOTE=$(cat "$TMP/witch.md")
has "links: plain text in the fence" "$NOTE" "desc: The witch casts Soft Light or Tidecall."
has "links: kept under the fence" "$NOTE" '```

[[Reference/Spells/Level_1/Soft_Light|Soft Light]], [[Tidecall]]'
has "links: flag added" "$NOTE" "---
statblock: inline
---

# Reed Witch"
OUT=$(convert "$TMP/witch.md" --to markdown) || fail "links back: exit $?: $(cat "$TMP/err")"
NOTE=$(cat "$TMP/witch.md")
has "links: line kept in markdown" "$NOTE" "[[Reference/Spells/Level_1/Soft_Light|Soft Light]], [[Tidecall]]"
hasnt "links: no empty frontmatter" "$NOTE" "---
---"
OUT=$(convert "$TMP/witch.md" --to fence) || fail "links again: exit $?: $(cat "$TMP/err")"
[ "$(grep -c 'Tidecall\]\]' "$TMP/witch.md")" -eq 1 ] || fail "links: the line must not be doubled:
$(cat "$TMP/witch.md")"

# --- A Character: its Build keeps its links; only Statistics changes form ----------------
cat > "$TMP/wren.md" <<'MD'
---
player: Carla
status: active
level: 3
statblock: inline
---

# Wren

## Identity

Wren trims lamps.

## Build

- **Species:** [[Mothfolk]]

## Statistics

```statblock
layout: DM Realm Character
name: Wren
size: Small
species: Mothfolk
class: Lamplighter (Path of the Wick)
level: 3
player: Carla
ac: 13
hp: 24
hit_dice: 3d8
initiative: 2
speed: 30 ft., fly 30 ft.
stats: [8, 14, 14, 11, 18, 10]
saves:
  - Strength: -1
  - Wisdom ●: 6
skillsaves:
  - Perception: 6
senses: darkvision 60 ft., passive Perception 16
languages: Common, Lampish
actions:
  - name: Lantern Pole
    desc: "+4 to hit, reach 5 ft., 1d6 + 2 bludgeoning"
spells:
  - Wisdom, spell save DC 14, spell attack +6
  - 1st level: 4 slots
traits:
  - name: Kindle
    desc: Lights any wick she touches.
  - name: Night Owl
```
MD
cp "$TMP/wren.md" "$TMP/wren-original.md"
OUT=$(convert "$TMP/wren.md" --to markdown) || fail "character to markdown: exit $?: $(cat "$TMP/err")"
NOTE=$(cat "$TMP/wren.md")
has "character markdown: build kept" "$NOTE" "- **Species:** [[Mothfolk]]"
has "character markdown: kind" "$NOTE" "*Small Mothfolk, Lamplighter (Path of the Wick)*"
has "character markdown: core" "$NOTE" "**Level** 3
**Player** Carla
**Armor Class** 13
**Hit Point Maximum** 24
**Hit Dice** 3d8
**Initiative** +2
**Speed** 30 ft., fly 30 ft."
has "character markdown: saves" "$NOTE" "**Saving Throws** Strength -1, Wisdom ● +6"
has "character markdown: attacks" "$NOTE" "### Attacks

- ***Lantern Pole.*** +4 to hit, reach 5 ft., 1d6 + 2 bludgeoning"
has "character markdown: spells" "$NOTE" "### Spellcasting

- Wisdom, spell save DC 14, spell attack +6
- 1st level: 4 slots"
has "character markdown: name-only trait" "$NOTE" "- ***Night Owl.***"
convert "$TMP/wren.md" --to fence >/dev/null || fail "character to fence: exit $?: $(cat "$TMP/err")"
cmp -s "$TMP/wren.md" "$TMP/wren-original.md" || fail "character round trip: the note changed:
$(diff "$TMP/wren-original.md" "$TMP/wren.md")"

# A past Build (bestiary: false) never carries the frontmatter flag, in either form.
cat > "$TMP/past.md" <<'MD'
---
player: Carla
level: 2
---

# Wren

## Statistics

```statblock
layout: DM Realm Character
name: Wren
bestiary: false
level: 2
hp: 17
```
MD
convert "$TMP/past.md" --to markdown >/dev/null && convert "$TMP/past.md" --to fence >/dev/null || fail "past build: exit $?: $(cat "$TMP/err")"
hasnt "past build: no flag" "$(cat "$TMP/past.md")" "statblock: inline"
has "past build: bestiary kept" "$(cat "$TMP/past.md")" "bestiary: false"

# An NPC's extends fence: only the changed values, as Markdown too.
cat > "$TMP/npc.md" <<'MD'
---
statblock: inline
---

# Grisk

Leader of the reed band. Uses the [[Bog_Goblin|Bog Goblin]] statistics, changed.

## Stat Block

```statblock
name: Grisk
extends: Bog Goblin
hp: 22
```
MD
cp "$TMP/npc.md" "$TMP/npc-original.md"
convert "$TMP/npc.md" --to markdown >/dev/null || fail "extends: exit $?: $(cat "$TMP/err")"
NOTE=$(cat "$TMP/npc.md")
has "extends: hidden" "$NOTE" "%% statblock
name: Grisk
extends: Bog Goblin
%%"
has "extends: changed value" "$NOTE" "**Hit Points** 22"
hasnt "extends: nothing else" "$NOTE" "Armor Class"
convert "$TMP/npc.md" --to fence >/dev/null || fail "extends back: exit $?: $(cat "$TMP/err")"
cmp -s "$TMP/npc.md" "$TMP/npc-original.md" || fail "extends round trip: the note changed:
$(diff "$TMP/npc-original.md" "$TMP/npc.md")"

# --- Rendering a fence read from standard input, for a note being written ----------------
OUT=$(printf 'name: Mote\nsize: Tiny\ntype: elemental\nac: 11\nhp: 3\n' | python3 "$HELPER" markdown 2>"$TMP/err") || fail "markdown stdin: exit $?: $(cat "$TMP/err")"
has "markdown stdin" "$OUT" "*Tiny elemental*"
has "markdown stdin" "$OUT" "**Hit Points** 3"

# --- Errors ---------------------------------------------------------------------------
printf '# Plain\n\nNo statistics here.\n' > "$TMP/plain.md"
convert "$TMP/plain.md" --to markdown >/dev/null; CODE=$?
[ "$CODE" -eq 4 ] || fail "no statistics: expected exit 4, got $CODE"
printf '# Odd\n\n```statblock\nname: Odd\nweird_list:\n  - x: 1\n```\n' > "$TMP/odd.md"
cp "$TMP/odd.md" "$TMP/odd-original.md"
convert "$TMP/odd.md" --to markdown >/dev/null; CODE=$?
[ "$CODE" -eq 6 ] || fail "unknown list key: expected exit 6, got $CODE"
cmp -s "$TMP/odd.md" "$TMP/odd-original.md" || fail "unknown list key: the note changed"
convert "$TMP/goblin.md" --to sideways >/dev/null 2>&1; [ $? -eq 2 ] || fail "bad --to: expected exit 2"
printf 'not json' > "$TMP/bad.json"
convert "$TMP/goblin.md" --to markdown --labels "$TMP/bad.json" >/dev/null 2>&1; [ $? -eq 2 ] || fail "bad labels: expected exit 2"

[ "$FAILS" -eq 0 ] && echo "statblock-convert: all pass" || { echo "statblock-convert: $FAILS failure(s)"; exit 1; }
