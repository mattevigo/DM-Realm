#!/bin/sh
# Tests the Adventure rendering helper on a Source Cache seeded with an INVENTED
# Adventure — invented names, books, pages and text; no real Trusted Source data (ADR 0003).
# Usage: sh tests/render-adventure.test.sh   (exit 0 = all pass)
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HELPER="$ROOT/skills/dmr-import/render-adventure.py"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
FAILS=0
fail() { echo "FAIL $1"; FAILS=$((FAILS+1)); }

export DMR_SOURCE_CACHE="$TMP/cache"
export DMR_SOURCE_API="http://127.0.0.1:9/latest"   # never online: everything is seeded
export DMR_SOURCE_RAW="http://127.0.0.1:9/raw"
export DMR_SOURCE_IMG="http://127.0.0.1:9/img"
unset EVAL_DMR_SOURCE_CACHE EVAL_DMR_SOURCE_API EVAL_DMR_SOURCE_RAW EVAL_DMR_SOURCE_IMG
DATA="$DMR_SOURCE_CACHE/v9.9.9/data"
mkdir -p "$DATA"
echo v9.9.9 > "$DMR_SOURCE_CACHE/release"
seed() { mkdir -p "$(dirname "$DATA/$1")"; cat > "$DATA/$1"; }
# seed_image <path in the image mirror>: invented bytes, never a real image (ADR 0003).
seed_image() { mkdir -p "$(dirname "$DMR_SOURCE_CACHE/v9.9.9/img/$1")"; printf 'IMG %s' "$1" > "$DMR_SOURCE_CACHE/v9.9.9/img/$1"; }

run() { python3 "$HELPER" "$@" 2>"$TMP/err"; }
# has <label> <text> <expected substring>
has() { case "$2" in *"$3"*) ;; *) fail "$1: expected '$3' in:
$2";; esac; }
hasnt() { case "$2" in *"$3"*) fail "$1: did not expect '$3' in:
$2";; esac; }
# note <rendered JSON> <note path>: that note's text
note() { printf '%s' "$1" | python3 -c '
import json, sys
for n in json.load(sys.stdin)["notes"]:
    if n["note"] == sys.argv[1]:
        sys.stdout.write(n["text"])' "$2"; }
# field <rendered JSON> <note path> <field>: one field of that note, as JSON
field() { printf '%s' "$1" | python3 -c '
import json, sys
for n in json.load(sys.stdin)["notes"]:
    if n["note"] == sys.argv[1]:
        print(json.dumps(n[sys.argv[2]]))' "$2" "$3"; }

seed books.json <<'JSON'
{"book": [
  {"name": "Old Handbook", "id": "PHB", "source": "PHB", "published": "2014-08-19"},
  {"name": "Old Bestiary", "id": "MM", "source": "MM", "published": "2014-09-30"},
  {"name": "Old Guide", "id": "DMG", "source": "DMG", "published": "2014-12-09"},
  {"name": "Player's Handbook (2024)", "id": "XPHB", "source": "XPHB", "published": "2024-09-17"},
  {"name": "New Bestiary", "id": "XMM", "source": "XMM", "published": "2025-02-18"}
]}
JSON
seed adventures.json <<'JSON'
{"adventure": [
  {"name": "The Salt Crypt", "id": "SLC", "source": "SLC", "published": "2016-05-01",
   "level": {"start": 1, "end": 4},
   "contents": [{"name": "Introduction"},
                {"name": "Saltmere", "ordinal": {"type": "chapter", "identifier": 1}},
                {"name": "The Crypt", "ordinal": {"type": "chapter", "identifier": 2}}]},
  {"name": "The Odd Box", "id": "ODB", "source": "ODB", "published": "2016-06-01",
   "contents": [{"name": "The Box"}]}
]}
JSON
seed adventure/adventure-slc.json <<'JSON'
{"data": [
 {"type": "section", "name": "Introduction", "page": 2, "id": "000", "entries": [
   "Saltmere is a drowned town, and {@creature Brine Imp|MM|brine imps} haunt it.",
   {"type": "image", "href": {"type": "internal", "path": "adventure/SLC/cover.webp"}},
   {"type": "entries", "name": "Running the Adventure", "id": "001", "entries": ["Read the boxes aloud."]}]},
 {"type": "section", "name": "Chapter 1: Saltmere", "page": 4, "id": "010", "entries": [
   "The town waits under the tide.",
   {"type": "entries", "name": "Areas of Saltmere", "id": "011", "entries": [
     {"type": "entries", "name": "S1. The Drowned Bell Inn", "id": "012", "page": 5, "entries": [
       "Brackish water fills the common room.",
       {"type": "entries", "name": "Mother Kelp", "id": "013", "entries": [
         "The innkeeper, a {@creature Salt Wight|SLC}, keeps the {@item Lantern of Tides|SLC}."]},
       {"type": "image", "href": {"type": "internal", "path": "adventure/SLC/inn.webp"}, "title": "Map 1.1: The Drowned Bell"}]},
     {"type": "entries", "name": "S2. Tidepool Shrine", "id": "014", "page": 6, "entries": [
       "A {@item wand of drizzle} lies on the altar. See {@area area S1|012|x} and {@area the crypt|020|x}.",
       {"type": "entries", "name": "Treasure", "id": "015", "entries": ["An {@item oar|PHB} and a {@item +1 oar}."]}]}]},
   {"type": "entries", "name": "Special Events", "id": "016", "entries": [
     {"type": "entries", "name": "The Low Tide", "id": "017", "entries": [
       "Two {@creature brine imp||brine imps} attack. Back to {@area the shrine's treasure|015|x}."]}]}]},
 {"type": "section", "name": "Chapter 2: The Crypt", "page": 8, "id": "020", "entries": [
   "Salt crusts every wall, and a {@creature Ghost Crab|SLC} scuttles.",
   {"type": "flowchart", "blocks": [
     {"type": "flowBlock", "name": "The Gate", "id": "021", "entries": ["Open it."]},
     {"type": "flowBlock", "name": "The Tomb", "id": "022", "entries": ["Rest there."]}]},
   {"type": "wrapper", "id": "024", "wrappeds": [
     {"type": "insetReadaloud", "id": "023", "entries": ["A cold wind rises."]},
     "Then the {@creature Salt Wight|SLC} stands."]},
   {"type": "spellcasting", "name": "Crypt Chant", "headerEntries": ["The wights chant together:"],
    "spells": {"1": {"slots": 2, "spells": ["{@spell Chill Ward}"]}}, "footerEntries": ["They stop at dawn."]}]}
]}
JSON
seed adventure/adventure-odb.json <<'JSON'
{"data": [
 {"type": "section", "name": "The Box", "page": 1, "id": "100", "entries": [
   "Fine so far.",
   {"type": "entries", "name": "The Lid", "id": "101", "entries": [{"type": "puzzlebox", "id": "102"}]}]}
]}
JSON
seed bestiary/index.json <<'JSON'
{"MM": "bestiary-mm.json", "XMM": "bestiary-xmm.json", "SLC": "bestiary-slc.json"}
JSON
seed bestiary/bestiary-mm.json <<'JSON'
{"monster": [{"name": "Brine Imp", "source": "MM", "page": 30, "reprintedAs": ["Brine Imp Scout|XMM"]}]}
JSON
seed bestiary/bestiary-xmm.json <<'JSON'
{"monster": [{"name": "Brine Imp Scout", "source": "XMM", "page": 31}]}
JSON
seed bestiary/bestiary-slc.json <<'JSON'
{"monster": [{"name": "Salt Wight", "source": "SLC", "page": 20}]}
JSON
seed items.json <<'JSON'
{"item": [
  {"name": "Lantern of Tides", "source": "SLC", "page": 21, "rarity": "rare", "wondrous": true},
  {"name": "Wand of Drizzle", "source": "DMG", "page": 210, "rarity": "uncommon", "type": "WD"}]}
JSON
seed items-base.json <<'JSON'
{"baseitem": [{"name": "Oar", "source": "PHB", "page": 149, "type": "M", "weapon": true, "rarity": "none"}]}
JSON
seed magicvariants.json <<'JSON'
{"magicvariant": [{"name": "+1 Weapon", "type": "GV", "requires": [{"weapon": true}],
  "inherits": {"namePrefix": "+1 ", "source": "DMG", "page": 213, "rarity": "uncommon", "entries": ["A bonus."]}}]}
JSON
seed_image adventure/SLC/inn.webp

# --- The Parts of an Adventure ---------------------------------------------------------
OUT=$(run SLC) || fail "parts: exit $?: $(cat "$TMP/err")"
has parts "$OUT" '"name": "Chapter 1: Saltmere"'
has parts "$OUT" '"index": 1'
has parts "$OUT" '"id": "010"'
has parts "$OUT" '"ordinal": "chapter 1"'
has parts "$OUT" '"title": "The Salt Crypt"'

# --- One Part: its headings, words and images, fetching nothing ------------------------
BEFORE=$(find "$DMR_SOURCE_CACHE" | sort)
OUT=$(run SLC --part 1 --list) || fail "list: exit $?: $(cat "$TMP/err")"
has list "$OUT" '"id": "012"'
has list "$OUT" '"name": "S1. The Drowned Bell Inn"'
has list "$OUT" '"depth": 2'
has list "$OUT" '"image": "adventure/SLC/inn.webp"'
has list "$OUT" '"size": 26'
OUT=$(run SLC --part 2 --list) || fail "list words: exit $?: $(cat "$TMP/err")"
has "list words" "$OUT" '"words": 42'
# An image not in the Source Cache is listed, with no size, and not fetched.
OUT=$(run SLC --part 0 --list) || fail "list uncached: exit $?: $(cat "$TMP/err")"
has "list uncached" "$OUT" '"image": "adventure/SLC/cover.webp"'
has "list uncached" "$OUT" '"size": null'
[ "$(find "$DMR_SOURCE_CACHE" | sort)" = "$BEFORE" ] || fail "list: the Source Cache changed"
OUT=$(run SLC --part 3 --list); [ $? -eq 2 ] || fail "list: a Part the Adventure lacks should exit 2"

# --- A split plan becomes notes, and the rest of the Part its Part note -----------------
A="Adventures/The_Salt_Crypt"
cat > "$TMP/plan1.json" <<JSON
{"part_note": "$A/Parts/Saltmere",
 "sections": [{"id": "012", "note": "$A/Places/The_Drowned_Bell_Inn"},
              {"id": "013", "note": "$A/NPCs/Mother_Kelp"},
              {"id": "014", "note": "$A/Places/Tidepool_Shrine"},
              {"id": "017", "note": "$A/Encounters/The_Low_Tide"}]}
JSON
cat > "$TMP/links.json" <<JSON
{"monster|Brine Imp Scout|XMM": "Reference/Monsters/Brine_Imp_Scout",
 "monster|Brine Imp|MM": "Reference/Monsters/Brine_Imp",
 "monster|Salt Wight|SLC": "Reference/Monsters/Salt_Wight",
 "item|Lantern of Tides|SLC": "$A/Items/Lantern_of_Tides",
 "item|Wand of Drizzle|DMG": "Reference/Magic_Items/Wand_of_Drizzle",
 "item|Oar|PHB": "Reference/Equipment/Oar",
 "item|+1 Weapon|DMG": "Reference/Magic_Items/+1_Weapon",
 "part|0": "$A/Parts/Introduction",
 "part|2": "$A/Parts/The_Crypt"}
JSON
OUT=$(run SLC --part 1 --plan "$TMP/plan1.json" --links "$TMP/links.json") || fail "plan: exit $?: $(cat "$TMP/err")"
PART=$(note "$OUT" "$A/Parts/Saltmere")
has "part note" "$PART" "# Chapter 1: Saltmere

The town waits under the tide.

## Areas of Saltmere

[[$A/Places/The_Drowned_Bell_Inn|S1. The Drowned Bell Inn]]

[[$A/Places/Tidepool_Shrine|S2. Tidepool Shrine]]

## Special Events

[[$A/Encounters/The_Low_Tide|The Low Tide]]"
hasnt "part note" "$PART" "Brackish water"
INN=$(note "$OUT" "$A/Places/The_Drowned_Bell_Inn")
has "nested" "$INN" "# S1. The Drowned Bell Inn

Brackish water fills the common room.

[[$A/NPCs/Mother_Kelp|Mother Kelp]]

![[The_Drowned_Bell_Inn.webp]]

*Map 1.1: The Drowned Bell*"
hasnt "nested" "$INN" "The innkeeper"
has "nested" "$(note "$OUT" "$A/NPCs/Mother_Kelp")" "# Mother Kelp

The innkeeper, a "
# A named block is always a heading, so an area link can reach it.
has "heading" "$(note "$OUT" "$A/Places/Tidepool_Shrine")" "## Treasure

An "
has "source" "$(field "$OUT" "$A/Places/The_Drowned_Bell_Inn" source_property)" '"SLC p. 5, v9.9.9, #012"'
has "source" "$(field "$OUT" "$A/NPCs/Mother_Kelp" source_property)" '"SLC p. 5, v9.9.9, #013"'
has "source" "$(field "$OUT" "$A/Parts/Saltmere" source_property)" '"SLC p. 4, v9.9.9, #010"'
IMAGES=$(field "$OUT" "$A/Places/The_Drowned_Bell_Inn" images)
has "images" "$IMAGES" '"file": "The_Drowned_Bell_Inn.webp"'
has "images" "$IMAGES" "\"cached\": \"$DMR_SOURCE_CACHE/v9.9.9/img/adventure/SLC/inn.webp\""

# --- Links: a creature, to its Reference note in the Workspace's Edition ----------------
has "creature" "$(note "$OUT" "$A/NPCs/Mother_Kelp")" "a [[Reference/Monsters/Salt_Wight|Salt Wight]], keeps"
# A 2014 monster the 2024 Edition reprints links to the reprint; in 2014, to itself.
has "reprint" "$(note "$OUT" "$A/Encounters/The_Low_Tide")" "Two [[Reference/Monsters/Brine_Imp_Scout|brine imps]] attack."
OUT14=$(run SLC --part 1 --plan "$TMP/plan1.json" --links "$TMP/links.json" --edition 2014) || fail "2014: exit $?: $(cat "$TMP/err")"
has "2014" "$(note "$OUT14" "$A/Encounters/The_Low_Tide")" "Two [[Reference/Monsters/Brine_Imp|brine imps]] attack."

# --- Links: an item, to the Adventure's Items when the Adventure introduces it ----------
has "adventure item" "$(note "$OUT" "$A/NPCs/Mother_Kelp")" "keeps the [[$A/Items/Lantern_of_Tides|Lantern of Tides]]."
SHRINE=$(note "$OUT" "$A/Places/Tidepool_Shrine")
has "core item" "$SHRINE" "A [[Reference/Magic_Items/Wand_of_Drizzle|wand of drizzle]] lies"
has "base item" "$SHRINE" "An [[Reference/Equipment/Oar|oar]] and"
# A specific magic weapon is no entry: it links to its generic variant (ADR 0007).
has "generic variant" "$SHRINE" "a [[Reference/Magic_Items/+1_Weapon|+1 oar]]."

# --- Links: an area, to the note holding it, or to the Part note of another Part --------
has "area own note" "$SHRINE" "See [[$A/Places/The_Drowned_Bell_Inn|area S1]] and"
has "area other Part" "$SHRINE" "and [[$A/Parts/The_Crypt|the crypt]]."
has "area heading" "$(note "$OUT" "$A/Encounters/The_Low_Tide")" "Back to [[$A/Places/Tidepool_Shrine#Treasure|the shrine's treasure]]."

# --- The link targets a Part needs, in the Workspace's Edition --------------------------
OUT=$(run SLC --part 1 --list) || fail "targets: exit $?: $(cat "$TMP/err")"
has targets "$OUT" '"key": "monster|Brine Imp Scout|XMM"'
has targets "$OUT" '"key": "item|Lantern of Tides|SLC"'
has targets "$OUT" '"folder": "adventures.<adventure>.items"'
has targets "$OUT" '"key": "item|+1 Weapon|DMG"'
has targets "$OUT" '"folder": "reference.magic_items"'
has targets "$OUT" '"key": "part|2"'
hasnt targets "$OUT" '"key": "monster|Brine Imp|MM"'
OUT=$(run SLC --part 1 --list --edition 2014) || fail "targets 2014: exit $?: $(cat "$TMP/err")"
has "targets 2014" "$OUT" '"key": "monster|Brine Imp|MM"'
# A tag the Trusted Source has no entry for is listed, and stays plain text.
OUT=$(run SLC --part 2 --list) || fail "unresolved: exit $?: $(cat "$TMP/err")"
has unresolved "$OUT" '"{@creature Ghost Crab|SLC}"'

# --- The links file must give every target a note: the helper names what it lacks -------
python3 -c 'import json, sys; d = json.load(open(sys.argv[1])); del d["part|2"]; print(json.dumps(d))' \
  "$TMP/links.json" > "$TMP/links-short.json"
OUT=$(run SLC --part 1 --plan "$TMP/plan1.json" --links "$TMP/links-short.json"); CODE=$?
[ "$CODE" -eq 2 ] || fail "missing link: expected exit 2, got $CODE"
[ -z "$OUT" ] || fail "missing link: printed $OUT"
has "missing link" "$(cat "$TMP/err")" "part|2"

# --- A flowchart, a wrapper and a spellcasting block render; an unresolved tag is text --
echo "{\"part_note\": \"$A/Parts/The_Crypt\", \"sections\": []}" > "$TMP/plan2.json"
OUT=$(run SLC --part 2 --plan "$TMP/plan2.json" --links "$TMP/links.json") || fail "types: exit $?: $(cat "$TMP/err")"
has "types" "$(note "$OUT" "$A/Parts/The_Crypt")" "# Chapter 2: The Crypt

Salt crusts every wall, and a Ghost Crab scuttles.

## The Gate

Open it.

## The Tomb

Rest there.

> A cold wind rises.

Then the [[Reference/Monsters/Salt_Wight|Salt Wight]] stands.

## Crypt Chant

The wights chant together:

- 1st level (2 slots): Chill Ward

They stop at dawn."

# --- --check renders the whole Part, prints nothing and fetches no image -----------------
echo "{\"part_note\": \"$A/Parts/Introduction\", \"sections\": [{\"id\": \"001\", \"note\": \"$A/Parts/Running_the_Adventure\"}]}" > "$TMP/plan0.json"
BEFORE=$(find "$DMR_SOURCE_CACHE" | sort)
OUT=$(run SLC --part 0 --plan "$TMP/plan0.json" --links "$TMP/links.json" --check) || fail "check: exit $?: $(cat "$TMP/err")"
[ -z "$OUT" ] || fail "check: printed $OUT"
[ "$(find "$DMR_SOURCE_CACHE" | sort)" = "$BEFORE" ] || fail "check: the Source Cache changed"
# The same Part rendered for real needs its uncached image, and the Trusted Source is unreachable here.
OUT=$(run SLC --part 0 --plan "$TMP/plan0.json" --links "$TMP/links.json"); CODE=$?
[ "$CODE" -eq 3 ] || fail "uncached image: expected exit 3, got $CODE"
[ -z "$OUT" ] || fail "uncached image: printed $OUT"
# An entry type the helper does not know fails the Part, naming its section and the Part.
echo '{"part_note": "Adventures/The_Odd_Box/Parts/The_Box", "sections": []}' > "$TMP/plan-odb.json"
echo '{}' > "$TMP/links-odb.json"
for mode in --check ""; do
  OUT=$(run ODB --part 0 --plan "$TMP/plan-odb.json" --links "$TMP/links-odb.json" $mode); CODE=$?
  [ "$CODE" -eq 7 ] || fail "unknown type $mode: expected exit 7, got $CODE"
  [ -z "$OUT" ] || fail "unknown type $mode: printed $OUT"
  has "unknown type $mode" "$(cat "$TMP/err")" "puzzlebox"
  has "unknown type $mode" "$(cat "$TMP/err")" "section 101 (The Lid)"
  has "unknown type $mode" "$(cat "$TMP/err")" "Part 0 (The Box)"
done

# --- A plan the helper refuses: it names what is wrong and prints nothing ---------------
refuse() { # refuse <label> <sections JSON> <expected in the message> [part note]
  echo "{\"part_note\": \"${4:-$A/Parts/Saltmere}\", \"sections\": $2}" > "$TMP/bad.json"
  OUT=$(run SLC --part 1 --plan "$TMP/bad.json" --links "$TMP/links.json"); CODE=$?
  [ "$CODE" -eq 2 ] || fail "$1: expected exit 2, got $CODE"
  [ -z "$OUT" ] || fail "$1: printed $OUT"
  has "$1" "$(cat "$TMP/err")" "$3"
}
refuse "not in Part" "[{\"id\": \"021\", \"note\": \"$A/Places/The_Gate\"}]" "021"
refuse "twice" "[{\"id\": \"012\", \"note\": \"$A/Places/Inn\"}, {\"id\": \"012\", \"note\": \"$A/Places/Bell\"}]" "012"
refuse "same name" "[{\"id\": \"012\", \"note\": \"$A/Places/Saltmere\"}]" "Saltmere"
refuse "same name, two folders" "[{\"id\": \"012\", \"note\": \"$A/Places/Inn\"}, {\"id\": \"013\", \"note\": \"$A/NPCs/Inn\"}]" "Inn"
refuse "not a heading" "[{\"id\": \"010\", \"note\": \"$A/Places/Saltmere_Again\"}]" "010"
refuse "bad name" "[{\"id\": \"012\", \"note\": \"$A/Places/The Inn\"}]" "The Inn"

[ "$FAILS" -eq 0 ] && echo "render-adventure: all pass" || { echo "render-adventure: $FAILS failed"; exit 1; }

