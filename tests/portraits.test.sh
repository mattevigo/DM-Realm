#!/bin/sh
# Tests the Portrait helper (skills/dmr-workspace/portraits.py): every stat block whose
# note embeds its own picture names it as its Portrait (`image:`), by its full path, and
# one that already names one is left as it is; every item note says it is an item
# (`item: true`) and names its own picture in its frontmatter, found through the Workspace
# Config and the Translation Glossary. Every note and picture here is INVENTED.
# Usage: sh tests/portraits.test.sh   (exit 0 = all pass)
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HELPER="$ROOT/skills/dmr-workspace/portraits.py"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
FAILS=0
fail() { echo "FAIL $1"; FAILS=$((FAILS+1)); }
has() { case "$2" in *"$3"*) ;; *) fail "$1: expected '$3' in:
$2";; esac; }
hasnt() { case "$2" in *"$3"*) fail "$1: did not expect '$3' in:
$2";; esac; }
W="$TMP/ws"
note() { mkdir -p "$(dirname "$W/$1")"; cat > "$W/$1"; }
picture() { mkdir -p "$(dirname "$W/$1")"; printf 'INVENTED PICTURE' > "$W/$1"; }
field() { printf '%s' "$OUT" | python3 -c "import json, sys; r = json.load(sys.stdin); print($1)"; }

printf 'language: Italiano\nedition: 2024\nstat_blocks: true\nfolders:\n  reference: Riferimento\n  adventures: Avventure\n  homebrew: Homebrew\n  campaigns: Campagne\n  dm_tools: Strumenti_DM\n' > "$W.config"
mkdir -p "$W" && mv "$W.config" "$W/workspace-config.yml"

# An imported monster: two pictures, the first the Portrait; and one under the fence.
note Riferimento/Mostri/Drago_Lanterna.md <<'MD'
---
statblock: inline
---

# Drago Lanterna

## Descrizione

![[Drago_Lanterna_01.webp]]

![[Drago_Lanterna_02.webp]]

I draghi lanterna custodiscono i lampionai.

## Blocco Statistiche

```statblock
name: Drago Lanterna
layout: DM Realm Monster 2014
size: Piccola
ac: 13
hp: 9
```

![[Drago_Lanterna_03.webp]]
MD
picture Riferimento/Allegati/Drago_Lanterna_01.webp
picture Riferimento/Allegati/Drago_Lanterna_02.webp
picture Riferimento/Allegati/Drago_Lanterna_03.webp
picture .mapforge/faces/Drago_Lanterna_01.webp   # a hidden folder's file never makes a name ambiguous
# One whose only picture is in an action, under the fence: no Portrait.
note Riferimento/Mostri/Falena_di_Vetro.md <<'MD'
# Falena di Vetro

## Blocco Statistiche

```statblock
name: Falena di Vetro
size: Minuscola
```

![[Falena_di_Vetro.webp]]
MD
picture Riferimento/Allegati/Falena_di_Vetro.webp
# One that names its Portrait already, another picture: the DM's choice stays.
note Riferimento/Mostri/Segugio_di_Penne.md <<'MD'
# Segugio di Penne

## Descrizione

![[Segugio_di_Penne.webp]]

## Blocco Statistiche

```statblock
name: Segugio di Penne
image: [[Altro_Segugio.png]]
size: Media
```
MD
cp "$W/Riferimento/Mostri/Segugio_di_Penne.md" "$TMP/segugio-original.md"
picture Riferimento/Allegati/Segugio_di_Penne.webp
# A Campaign NPC that extends a monster, with no picture of its own: it inherits.
note Campagne/Eroi/PNG/Vinx.md <<'MD'
# Vinx

![[Mappa_della_Torre.webp]]

```statblock
name: Vinx
extends: Drago Lanterna
hp: 20
```
MD
picture Campagne/Eroi/Allegati/Mappa_della_Torre.webp
# A Homebrew monster in Markdown: the Portrait goes in its `%% statblock` comment.
note Homebrew/Mostri/Lucciola_Ardente.md <<'MD'
# Lucciola Ardente

## Descrizione

![[Lucciola_Ardente.webp|La lucciola]]

## Statistiche

%% statblock
name: Lucciola Ardente
%%

*Minuscola bestia, neutrale*
MD
picture Homebrew/Allegati/Lucciola_Ardente.webp
# A picture name used twice, and one that is nowhere: skipped, with the reason.
note Riferimento/Mostri/Goblin.md <<'MD'
# Goblin

![[Goblin.webp]]

```statblock
name: Goblin
```
MD
picture Riferimento/Allegati/Goblin.webp
picture Avventure/Le_Cucce/Allegati/Goblin.webp
note Riferimento/Mostri/Ombra.md <<'MD'
# Ombra

![[Ombra.webp]]

```statblock
name: Ombra
```
MD
# A Character: its Portrait is not this helper's.
note Personaggi/Ayla/Ayla.md <<'MD'
---
statblock: inline
---

# Ayla

![[Ayla.webp]]

```statblock
name: Ayla
layout: DM Realm Character
```
MD
picture Personaggi/Ayla/Allegati/Ayla.webp
cp "$W/Personaggi/Ayla/Ayla.md" "$TMP/ayla-original.md"

OUT=$(python3 "$HELPER" "$W" 2>"$TMP/err") || fail "portraits: exit $?: $(cat "$TMP/err")"
[ "$(field 'sorted(a["note"] for a in r["added"])')" = "['Homebrew/Mostri/Lucciola_Ardente.md', 'Riferimento/Mostri/Drago_Lanterna.md']" ] \
  || fail "portraits: added: $OUT"
[ "$(field 'sorted(s["note"] for s in r["skipped"])')" = "['Riferimento/Mostri/Goblin.md', 'Riferimento/Mostri/Ombra.md']" ] \
  || fail "portraits: skipped: $OUT"
has "portraits: ambiguous" "$(field '[s["why"] for s in r["skipped"] if s["note"].endswith("Goblin.md")][0]')" "Riferimento/Allegati/Goblin.webp"
has "portraits: missing" "$(field '[s["why"] for s in r["skipped"] if s["note"].endswith("Ombra.md")][0]')" "Ombra.webp"
has "portraits: fence" "$(cat "$W/Riferimento/Mostri/Drago_Lanterna.md")" '```statblock
name: Drago Lanterna
layout: DM Realm Monster 2014
image: "[[Riferimento/Allegati/Drago_Lanterna_01.webp]]"
size: Piccola'
has "portraits: embed kept" "$(cat "$W/Riferimento/Mostri/Drago_Lanterna.md")" "## Descrizione

![[Drago_Lanterna_01.webp]]"
has "portraits: markdown" "$(cat "$W/Homebrew/Mostri/Lucciola_Ardente.md")" '%% statblock
name: Lucciola Ardente
image: "[[Homebrew/Allegati/Lucciola_Ardente.webp]]"
%%'
hasnt "portraits: action picture" "$(cat "$W/Riferimento/Mostri/Falena_di_Vetro.md")" "image:"
hasnt "portraits: extends" "$(cat "$W/Campagne/Eroi/PNG/Vinx.md")" "image:"
cmp -s "$W/Riferimento/Mostri/Segugio_di_Penne.md" "$TMP/segugio-original.md" || fail "portraits: the DM's image: was changed"
cmp -s "$W/Personaggi/Ayla/Ayla.md" "$TMP/ayla-original.md" || fail "portraits: a Character was changed"

# Again: nothing left to add.
OUT=$(python3 "$HELPER" "$W" 2>"$TMP/err") || fail "portraits again: exit $?: $(cat "$TMP/err")"
[ "$(field 'r["added"]')" = "[]" ] || fail "portraits again: added: $OUT"

# Item notes: every note in the item folders says it is an item (`item: true`, in its
# frontmatter), and names its own picture as its Portrait (`image:`).
W="$TMP/en"
printf 'language: English\nedition: 2024\nstat_blocks: true\nfolders:\n  reference: Reference\n  adventures: Adventures\n  homebrew: Homebrew\n  world: World\n  characters: Characters\n  campaigns: Campaigns\n  dm_tools: DM_Tools\n  templates: Templates\n' > "$TMP/en.config"
mkdir -p "$W" && mv "$TMP/en.config" "$W/workspace-config.yml"
note Reference/Equipment/Lantern_Rope.md <<'MD'
---
source: XPHB p. 901, v2.36.1
---

# Lantern Rope

A rope that glows.
MD

item() { note "$1" <<MD
# $(basename "$1" .md)

An invented item.
MD
}
item Reference/Magic_Items/Glimmer_Cloak.md
item Adventures/The_Lamplighters/Items/Brass_Key.md
item Homebrew/Equipment/Kettle_Shield.md
item Homebrew/Magic_Items/Ember_Ring.md
item Campaigns/Heroes/Homebrew_Equipment/Thorn_Boots.md
item Campaigns/Heroes/Homebrew_Magic_Items/Moth_Lamp.md
# An item with its own picture names it as its Portrait, by its full path.
note Reference/Magic_Items/Ember_Lantern.md <<'MD'
---
source: XDMG p. 902, v2.36.1
---

# Ember Lantern

## Description

![[Ember_Lantern_01.webp]]

![[Ember_Lantern_02.webp]]

It burns without oil.
MD
picture Reference/Attachments/Ember_Lantern_01.webp
picture Reference/Attachments/Ember_Lantern_02.webp
# One with a picture in its own text, above its Description: the Description's first
# picture is its Portrait, as an Import numbers and names them.
note Reference/Magic_Items/Glowcap_Pouch.md <<'MD'
---
source: XDMG p. 905, v2.36.1
---

# Glowcap Pouch

It glows when shaken.

![[Glowcap_Pouch_01.webp]]

## Description

![[Glowcap_Pouch_02.webp]]

Mushroom farmers sew them.

![[Glowcap_Pouch_03.webp]]
MD
picture Reference/Attachments/Glowcap_Pouch_01.webp
picture Reference/Attachments/Glowcap_Pouch_02.webp
picture Reference/Attachments/Glowcap_Pouch_03.webp
# One whose Portrait the DM set: it stays, and the note still becomes an item.
note Homebrew/Magic_Items/Star_Ring.md <<'MD'
---
image: "[[Homebrew/Attachments/Other_Ring.png]]"
---

# Star Ring

## Description

![[Star_Ring_01.png]]
MD
picture Homebrew/Attachments/Star_Ring_01.png
# One that is an item already, with its Portrait: left as it is.
note Reference/Equipment/Flint_Box.md <<'MD'
---
source: XPHB p. 903, v2.36.1
item: true
image: "[[Reference/Attachments/Flint_Box.webp]]"
---

# Flint Box

![[Flint_Box.webp]]
MD
picture Reference/Attachments/Flint_Box.webp
cp "$W/Reference/Equipment/Flint_Box.md" "$TMP/flint-original.md"
# One whose only picture is named otherwise (a map): no Portrait, not reported.
note Adventures/The_Lamplighters/Items/Tower_Plan.md <<'MD'
# Tower Plan

![[Tower_Map.webp]]
MD
picture Adventures/The_Lamplighters/Attachments/Tower_Map.webp
# One with its own picture but no Description, and one whose picture is in a section
# after its Description: no Portrait, not reported (an Import would name none).
note Reference/Magic_Items/Bell_Whistle.md <<'MD'
# Bell Whistle

![[Bell_Whistle.webp]]
MD
picture Reference/Attachments/Bell_Whistle.webp
note Homebrew/Magic_Items/Moss_Cord.md <<'MD'
# Moss Cord

## Description

A cord of living moss.

## Properties

![[Moss_Cord.webp]]
MD
picture Homebrew/Attachments/Moss_Cord.webp
# A picture name used twice, and one that is nowhere: skipped, with the reason.
note Adventures/The_Lamplighters/Items/Twin_Coin.md <<'MD'
# Twin Coin

## Description

![[Twin_Coin.webp]]
MD
picture Adventures/The_Lamplighters/Attachments/Twin_Coin.webp
picture Reference/Attachments/Twin_Coin.webp
note Campaigns/Heroes/Homebrew_Magic_Items/Lost_Charm.md <<'MD'
# Lost Charm

## Description

![[Lost_Charm.png]]
MD
# Not items: a Weapon Mastery is a property, a spell is a spell; nor a Campaign's NPC.
for n in Reference/Equipment/Weapon_Masteries/Sap.md Homebrew/Equipment/Weapon_Masteries/Snare.md \
    Campaigns/Heroes/Homebrew_Equipment/Weapon_Masteries/Trip.md Reference/Spells/Level_1/Glow.md \
    Homebrew/Spells/Level_1/Spark.md Campaigns/Heroes/NPCs/Ilsa.md Adventures/The_Lamplighters/NPCs/Orin.md; do
  item "$n"; cp "$W/$n" "$TMP/$(basename "$n").original"
done
OUT=$(python3 "$HELPER" "$W" 2>"$TMP/err") || fail "items: exit $?: $(cat "$TMP/err")"
has "items: equipment" "$(cat "$W/Reference/Equipment/Lantern_Rope.md")" '---
source: XPHB p. 901, v2.36.1
item: true
---

# Lantern Rope'
has "items: no frontmatter" "$(cat "$W/Reference/Magic_Items/Glimmer_Cloak.md")" '---
item: true
---

# Glimmer_Cloak'
[ "$(field 'sorted(a["note"] for a in r["items"]["added"] if a.get("item") is True)')" = "['Adventures/The_Lamplighters/Items/Brass_Key.md', 'Adventures/The_Lamplighters/Items/Tower_Plan.md', 'Adventures/The_Lamplighters/Items/Twin_Coin.md', 'Campaigns/Heroes/Homebrew_Equipment/Thorn_Boots.md', 'Campaigns/Heroes/Homebrew_Magic_Items/Lost_Charm.md', 'Campaigns/Heroes/Homebrew_Magic_Items/Moth_Lamp.md', 'Homebrew/Equipment/Kettle_Shield.md', 'Homebrew/Magic_Items/Ember_Ring.md', 'Homebrew/Magic_Items/Moss_Cord.md', 'Homebrew/Magic_Items/Star_Ring.md', 'Reference/Equipment/Lantern_Rope.md', 'Reference/Magic_Items/Bell_Whistle.md', 'Reference/Magic_Items/Ember_Lantern.md', 'Reference/Magic_Items/Glimmer_Cloak.md', 'Reference/Magic_Items/Glowcap_Pouch.md']" ] \
  || fail "items: added: $OUT"
[ "$(field '[(a["note"], a["image"]) for a in r["items"]["added"] if "image" in a]')" = "[('Reference/Magic_Items/Ember_Lantern.md', '[[Reference/Attachments/Ember_Lantern_01.webp]]'), ('Reference/Magic_Items/Glowcap_Pouch.md', '[[Reference/Attachments/Glowcap_Pouch_02.webp]]')]" ] \
  || fail "items: images added: $OUT"
has "items: portrait" "$(cat "$W/Reference/Magic_Items/Ember_Lantern.md")" '---
source: XDMG p. 902, v2.36.1
item: true
image: "[[Reference/Attachments/Ember_Lantern_01.webp]]"
---

# Ember Lantern

## Description

![[Ember_Lantern_01.webp]]'
has "items: the Description's picture, not the text's" "$(cat "$W/Reference/Magic_Items/Glowcap_Pouch.md")" '---
source: XDMG p. 905, v2.36.1
item: true
image: "[[Reference/Attachments/Glowcap_Pouch_02.webp]]"
---'
has "items: the DM's image: kept" "$(cat "$W/Homebrew/Magic_Items/Star_Ring.md")" '---
image: "[[Homebrew/Attachments/Other_Ring.png]]"
item: true
---'
cmp -s "$W/Reference/Equipment/Flint_Box.md" "$TMP/flint-original.md" || fail "items: an item note with both keys was changed"
hasnt "items: a map is no Portrait" "$(cat "$W/Adventures/The_Lamplighters/Items/Tower_Plan.md")" "image:"
hasnt "items: no Description, no Portrait" "$(cat "$W/Reference/Magic_Items/Bell_Whistle.md")" "image:"
hasnt "items: a picture after the Description is no Portrait" "$(cat "$W/Homebrew/Magic_Items/Moss_Cord.md")" "image:"
[ "$(field 'sorted(s["note"] for s in r["items"]["skipped"])')" = "['Adventures/The_Lamplighters/Items/Twin_Coin.md', 'Campaigns/Heroes/Homebrew_Magic_Items/Lost_Charm.md']" ] \
  || fail "items: skipped: $OUT"
has "items: ambiguous" "$(field '[s["why"] for s in r["items"]["skipped"] if s["note"].endswith("Twin_Coin.md")][0]')" "Reference/Attachments/Twin_Coin.webp"
has "items: missing" "$(field '[s["why"] for s in r["items"]["skipped"] if s["note"].endswith("Lost_Charm.md")][0]')" "no file is named Lost_Charm.png"
hasnt "items: skipped has no image:" "$(cat "$W/Adventures/The_Lamplighters/Items/Twin_Coin.md")" "image:"
for n in Reference/Equipment/Weapon_Masteries/Sap.md Homebrew/Equipment/Weapon_Masteries/Snare.md \
    Campaigns/Heroes/Homebrew_Equipment/Weapon_Masteries/Trip.md Reference/Spells/Level_1/Glow.md \
    Homebrew/Spells/Level_1/Spark.md Campaigns/Heroes/NPCs/Ilsa.md Adventures/The_Lamplighters/NPCs/Orin.md; do
  cmp -s "$W/$n" "$TMP/$(basename "$n").original" || fail "items: $n is not an item note, but was changed"
done


# Again: nothing left to add, nothing changed; what cannot be resolved is still reported.
tree() { (cd "$W" && find . -type f | sort | xargs cat | cksum); }
BEFORE=$(tree)
OUT=$(python3 "$HELPER" "$W" 2>"$TMP/err") || fail "items again: exit $?: $(cat "$TMP/err")"
[ "$(field 'r["items"]["added"]')" = "[]" ] || fail "items again: added: $OUT"
[ "$(field 'len(r["items"]["skipped"])')" = "2" ] || fail "items again: skipped: $OUT"
[ "$(tree)" = "$BEFORE" ] || fail "items again: a file changed"

# An Italian Workspace: the item folders are the Translation Glossary's.
W="$TMP/it"
printf 'language: Italiano\nedition: 2024\nstat_blocks: true\nfolders:\n  reference: Riferimento\n  adventures: Avventure\n  homebrew: Fatto_in_Casa\n  campaigns: Campagne\n  dm_tools: Strumenti_DM\n' > "$TMP/it.config"
mkdir -p "$W" && mv "$TMP/it.config" "$W/workspace-config.yml"
note Strumenti_DM/Glossario_delle_Traduzioni.md <<'MD'
| Inglese | Traduzione | Fonte | Chiave (solo cartelle di primo livello) |
| --- | --- | --- | --- |
| Reference | Riferimento | Traduzione Ufficiale | reference |
| Homebrew | Fatto in Casa | scelta del DM | homebrew |
| Equipment | Equipaggiamento | Traduzione Ufficiale | |
| Weapon Masteries | Maestrie nelle Armi | Traduzione Ufficiale | |
| Magic Items | Oggetti Magici | Traduzione Ufficiale | |
| Items | Oggetti | Traduzione Ufficiale | |
| Attachments | Allegati | Traduzione Ufficiale | |
| Description | Descrizione | Traduzione Ufficiale | |
MD
note Riferimento/Equipaggiamento/Borsa.md <<'MD'
---
fonte: XPHB p. 225, v2.36.1
---

# Borsa

## Descrizione

![[Borsa.webp]]
MD
picture Riferimento/Allegati/Borsa.webp
# A picture in its own text above its Descrizione: the Descrizione's is its Portrait.
note Riferimento/Oggetti_Magici/Borsa_Funghi.md <<'MD'
# Borsa dei Funghi

Brilla quando viene scossa.

![[Borsa_Funghi_01.webp]]

## Descrizione

![[Borsa_Funghi_02.webp]]
MD
picture Riferimento/Allegati/Borsa_Funghi_01.webp
picture Riferimento/Allegati/Borsa_Funghi_02.webp
item Riferimento/Oggetti_Magici/Gemma_di_Fuoco.md
item Avventure/Le_Cucce/Oggetti/Chiave_di_Ottone.md
item Fatto_in_Casa/Oggetti_Magici/Anello_di_Brace.md
item Campagne/Eroi/Fatto_in_Casa_Equipaggiamento/Stivali_di_Spine.md
item Campagne/Eroi/Fatto_in_Casa_Oggetti_Magici/Lampada_Falena.md
item Riferimento/Equipaggiamento/Maestrie_nelle_Armi/Fiaccare.md
cp "$W/Riferimento/Equipaggiamento/Maestrie_nelle_Armi/Fiaccare.md" "$TMP/fiaccare-original.md"
OUT=$(python3 "$HELPER" "$W" 2>"$TMP/err") || fail "it: exit $?: $(cat "$TMP/err")"
[ "$(field 'sorted(a["note"] for a in r["items"]["added"])')" = "['Avventure/Le_Cucce/Oggetti/Chiave_di_Ottone.md', 'Campagne/Eroi/Fatto_in_Casa_Equipaggiamento/Stivali_di_Spine.md', 'Campagne/Eroi/Fatto_in_Casa_Oggetti_Magici/Lampada_Falena.md', 'Fatto_in_Casa/Oggetti_Magici/Anello_di_Brace.md', 'Riferimento/Equipaggiamento/Borsa.md', 'Riferimento/Oggetti_Magici/Borsa_Funghi.md', 'Riferimento/Oggetti_Magici/Gemma_di_Fuoco.md']" ] \
  || fail "it: added: $OUT"
has "it: Borsa" "$(cat "$W/Riferimento/Equipaggiamento/Borsa.md")" '---
fonte: XPHB p. 225, v2.36.1
item: true
image: "[[Riferimento/Allegati/Borsa.webp]]"
---'
has "it: the Descrizione's picture, not the text's" "$(cat "$W/Riferimento/Oggetti_Magici/Borsa_Funghi.md")" '---
item: true
image: "[[Riferimento/Allegati/Borsa_Funghi_02.webp]]"
---'
cmp -s "$W/Riferimento/Equipaggiamento/Maestrie_nelle_Armi/Fiaccare.md" "$TMP/fiaccare-original.md" \
  || fail "it: a Weapon Mastery was changed"

# Not a Workspace: exit 2, nothing changed.
mkdir -p "$TMP/plain"
python3 "$HELPER" "$TMP/plain" >/dev/null 2>&1; [ $? -eq 2 ] || fail "not a Workspace: expected exit 2"

[ "$FAILS" -eq 0 ] && echo "portraits: all pass" || { echo "portraits: $FAILS failure(s)"; exit 1; }
