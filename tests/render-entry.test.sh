#!/bin/sh
# Tests the Import rendering helper on a Source Cache seeded with INVENTED entries —
# invented names, books, pages and text; no real Trusted Source data (ADR 0003).
# Usage: sh tests/render-entry.test.sh   (exit 0 = all pass)
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HELPER="$ROOT/skills/dmr-import/render-entry.py"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
FAILS=0
fail() { echo "FAIL $1"; FAILS=$((FAILS+1)); }

export DMR_SOURCE_CACHE="$TMP/cache"
export DMR_SOURCE_API="http://127.0.0.1:9/latest"   # never online: everything is seeded
export DMR_SOURCE_RAW="http://127.0.0.1:9/raw"
unset EVAL_DMR_SOURCE_CACHE EVAL_DMR_SOURCE_API EVAL_DMR_SOURCE_RAW
DATA="$DMR_SOURCE_CACHE/v9.9.9/data"
mkdir -p "$DATA"
echo v9.9.9 > "$DMR_SOURCE_CACHE/release"
seed() { mkdir -p "$(dirname "$DATA/$1")"; cat > "$DATA/$1"; }

render() { python3 "$HELPER" "$@" 2>"$TMP/err"; }
# has <label> <text> <expected substring>
has() { case "$2" in *"$3"*) ;; *) fail "$1: expected '$3' in:
$2";; esac; }
hasnt() { case "$2" in *"$3"*) fail "$1: did not expect '$3' in:
$2";; esac; }

seed books.json <<'JSON'
{"book": [
  {"name": "Tome of Old Rules", "id": "TOR", "source": "TOR", "published": "2016-03-01"},
  {"name": "Player's Handbook (2024)", "id": "XPHB", "source": "XPHB", "published": "2024-09-17"},
  {"name": "Codex of New Rules", "id": "CNR", "source": "CNR", "published": "2025-02-11"}
]}
JSON

seed adventures.json <<'JSON'
{"adventure": [{"name": "The Dark Kennels", "id": "DRK", "source": "DRK", "published": "2025-06-01"}]}
JSON

# --- Generic entries: a condition --------------------------------------------------
seed conditionsdiseases.json <<'JSON'
{"condition": [
  {"name": "Dazzled", "source": "CNR", "page": 12,
   "entries": ["A Dazzled creature sees only bright spots.", "It ends at the end of its next turn."]}
]}
JSON
OUT=$(render data/conditionsdiseases.json Dazzled CNR) || fail "condition: exit $?: $(cat "$TMP/err")"
has condition "$OUT" "# Dazzled"
has condition "$OUT" "A Dazzled creature sees only bright spots.

It ends at the end of its next turn."
OUT=$(render data/conditionsdiseases.json Dazzled CNR --meta) || fail "meta: exit $?: $(cat "$TMP/err")"
has meta "$OUT" '"source_property": "CNR p. 12, v9.9.9"'
has meta "$OUT" '"key": "condition"'
has meta "$OUT" '"edition": "2024"'

# Statuses, senses and skills render like any rules entry.
seed senses.json <<'JSON'
{"sense": [{"name": "Glowsight", "source": "CNR", "page": 14, "entries": ["You see by glow."]}]}
JSON
seed skills.json <<'JSON'
{"skill": [{"name": "Lanterncraft", "source": "CNR", "page": 15, "ability": "int", "entries": ["Tending lamps."]}]}
JSON
python3 - "$DATA/conditionsdiseases.json" <<'PY'
import json, sys
p = sys.argv[1]; d = json.load(open(p))
d["status"] = [{"name": "Flickering", "source": "CNR", "page": 13, "entries": ["You are hard to see."]}]
json.dump(d, open(p, "w"))
PY
for e in "senses.json Glowsight You see by glow." "skills.json Lanterncraft Tending lamps." "conditionsdiseases.json Flickering You are hard to see."; do
  set -- $e; f=$1 n=$2; shift 2
  OUT=$(render "data/$f" "$n" CNR) || fail "$n: exit $?: $(cat "$TMP/err")"
  has "$n" "$OUT" "# $n

$*"
done

# --- Tags: plain text, never links ---------------------------------------------------
seed actions.json <<'JSON'
{"action": [
  {"name": "Glimmer", "source": "CNR", "page": 30, "entries": [
    "You become {@condition dazzled|CNR} and take {@damage 2d6} fire damage on a failed {@dc 15} save.",
    "Cast {@spell ember wall|CNR|the ember wall} or {@spell ember wall}; see {@creature quill hound|TOR|quill hounds}.",
    "Bonus {@hit 4}, penalty {@hit -1}, roll {@dice 1d20+2}, {@dice 3d4|three dice}, {@chance 25} to work, {@chance 10|a small chance}.",
    "{@b Bold {@i and italic}}, {@note a note}, {@filter spell list|spells|level=1}, {@quickref Cover||3||cover rules}.",
    "{@atk mw} {@hit 5} to hit. {@h}7 (2d6) damage. {@atkr m,r} {@recharge 5} {@recharge}",
    "{@actSave wis} {@actSaveFail} {@actSaveSuccess} {@actTrigger} {@actResponse} {@hom}half. {@m}none",
    "{@scaledamage 2d6|2-9|1d6} per level, {@classFeature Glow|Lamplighter||2} and {@subclassFeature Spark|Lamplighter||Ember||3||the spark}.",
    "{@dcYourSpellSave}, {@hitYourSpellAttack}, {@skill Perception}, {@variantrule Glow Sense|CNR|glow sense}, {@unknowntag first|CNR|shown}."
  ]}
]}
JSON
OUT=$(render data/actions.json Glimmer CNR) || fail "tags: exit $?: $(cat "$TMP/err")"
has tags "$OUT" "You become dazzled and take 2d6 fire damage on a failed DC 15 save."
has tags "$OUT" "Cast the ember wall or ember wall; see quill hounds."
has tags "$OUT" "Bonus +4, penalty -1, roll 1d20+2, three dice, 25 percent to work, a small chance."
has tags "$OUT" "**Bold *and italic***, a note, spell list, cover rules."
has tags "$OUT" "*Melee Weapon Attack:* +5 to hit. *Hit:* 7 (2d6) damage. *Melee or Ranged Attack Roll:* (Recharge 5–6) (Recharge 6)"
has tags "$OUT" "*Wisdom Saving Throw:* *Failure:* *Success:* *Trigger:* *Response:* *Hit or Miss:* half. *Miss:* none"
has tags "$OUT" "1d6 per level, Glow and the spark."
has tags "$OUT" "your spell save DC, your spell attack modifier, Perception, glow sense, shown."
hasnt tags "$OUT" "{@"
hasnt tags "$OUT" "[["

# --- Structure: sections, lists, tables, insets and the other entry types ------------
seed variantrules.json <<'JSON'
{"variantrule": [
  {"name": "Lantern Law", "source": "CNR", "page": 40, "entries": [
    "Lanterns matter.",
    {"type": "entries", "name": "Lighting a Lantern", "entries": ["It takes an action.", "Oil lasts an hour."]},
    {"type": "section", "name": "Kinds of Light", "entries": [
      {"type": "list", "items": [
        "Candle",
        {"type": "item", "name": "Torch", "entry": "Bright and short."},
        {"type": "item", "name": "Glowstone.", "entries": ["Dim.", {"type": "list", "items": ["Never goes out"]}]}
      ]}
    ]},
    {"type": "table", "caption": "Lantern Mishaps", "colLabels": ["d6", "Mishap | Effect"], "colStyles": ["col-2", "col-10"],
     "rows": [[{"type": "cell", "roll": {"exact": 1}}, "The oil {@b spills}."],
              [{"type": "cell", "roll": {"min": 2, "max": 6}}, "Nothing\nhappens."]],
     "footnotes": ["Roll once per hour."]},
    {"type": "inset", "name": "Old Lanterns", "entries": ["They smoke."]},
    {"type": "quote", "entries": ["Light the way."], "by": "Aunt Hessa", "from": "Proverbs"},
    {"type": "inline", "entries": ["Half ", {"type": "link", "text": "linked", "href": {"type": "internal"}}, " text."]},
    {"type": "abilityDc", "name": "Lantern", "attributes": ["wis", "cha"]},
    {"type": "abilityAttackMod", "name": "Lantern", "attributes": ["int"]},
    {"type": "hr"},
    {"type": "image", "href": {"type": "internal", "path": "x.webp"}},
    {"type": "options", "count": 1, "entries": [{"type": "refOptionalfeature", "optionalfeature": "Bright Ward|CNR"},
                                                {"type": "refOptionalfeature", "optionalfeature": "Dim Ward"}]},
    {"type": "variant", "name": "Everburning Lanterns", "entries": ["They never go out."]},
    {"type": "statblock", "tag": "creature", "name": "Quill Hound", "source": "TOR"},
    {"type": "entries", "name": "Deep", "entries": [{"type": "entries", "name": "Deeper", "entries": [
      {"type": "list", "items": ["x"]}, {"type": "entries", "name": "Deepest", "entries": [{"type": "list", "items": ["y"]}]}]}]}
  ]}
]}
JSON
OUT=$(render data/variantrules.json "Lantern Law" CNR) || fail "structure: exit $?: $(cat "$TMP/err")"
has structure "$OUT" "# Lantern Law

Lanterns matter.

***Lighting a Lantern.*** It takes an action.

Oil lasts an hour.

## Kinds of Light

- Candle
- **Torch.** Bright and short.
- **Glowstone.** Dim.
  - Never goes out"
has structure "$OUT" "**Lantern Mishaps**

| d6 | Mishap \| Effect |
| --- | --- |
| 1 | The oil **spills**. |
| 2–6 | Nothing<br>happens. |

Roll once per hour."
has structure "$OUT" "> **Old Lanterns**
>
> They smoke."
has structure "$OUT" "> Light the way.
>
> — Aunt Hessa, *Proverbs*"
has structure "$OUT" "Half linked text."
has structure "$OUT" "**Lantern save DC** = 8 + your proficiency bonus + your Wisdom or Charisma modifier"
has structure "$OUT" "**Lantern attack modifier** = your proficiency bonus + your Intelligence modifier"
has structure "$OUT" "- Bright Ward
- Dim Ward"
has structure "$OUT" "> **Variant: Everburning Lanterns**
>
> They never go out."
has structure "$OUT" "Quill Hound"
has structure "$OUT" "## Deep

### Deeper

- x

#### Deepest

- y"
hasnt structure "$OUT" "x.webp"

# --- Spells ---------------------------------------------------------------------------
seed spells/spells-cnr.json <<'JSON'
{"spell": [
  {"name": "Cinder Bloom", "source": "CNR", "page": 88, "level": 3, "school": "V",
   "time": [{"number": 1, "unit": "action"}],
   "range": {"type": "point", "distance": {"type": "feet", "amount": 120}},
   "components": {"v": true, "s": true, "m": "a pinch of ash"},
   "duration": [{"type": "instant"}],
   "entries": ["Ash blooms into fire. Each creature makes a {@dc 14} Dexterity save, taking {@damage 6d6} fire damage."],
   "entriesHigherLevel": [{"type": "entries", "name": "Using a Higher-Level Spell Slot",
                           "entries": ["The damage increases by {@scaledamage 6d6|3-9|1d6} for each slot level above 3."]}]},
  {"name": "Quiet Glow", "source": "CNR", "page": 90, "level": 0, "school": "I",
   "time": [{"number": 1, "unit": "bonus"}],
   "range": {"type": "cone", "distance": {"type": "feet", "amount": 15}},
   "components": {"s": true, "m": {"text": "a firefly worth 5 gp", "cost": 500}},
   "duration": [{"type": "timed", "duration": {"type": "minute", "amount": 10}, "concentration": true}],
   "entries": ["A soft light."]},
  {"name": "Warding Hush", "source": "CNR", "page": 91, "level": 1, "school": "A", "meta": {"ritual": true},
   "time": [{"number": 1, "unit": "reaction", "condition": "which you take when a creature within 60 feet of you speaks"}],
   "range": {"type": "point", "distance": {"type": "self"}},
   "components": {"v": true},
   "duration": [{"type": "permanent", "ends": ["dispel", "trigger"]}, {"type": "timed", "duration": {"type": "hour", "amount": 1}}],
   "entries": ["Silence."]}
]}
JSON
OUT=$(render data/spells/spells-cnr.json "Cinder Bloom" CNR) || fail "spell: exit $?: $(cat "$TMP/err")"
has spell "$OUT" "# Cinder Bloom

*Level 3 Evocation*

**Casting Time:** 1 action
**Range:** 120 feet
**Components:** V, S, M (a pinch of ash)
**Duration:** Instantaneous

Ash blooms into fire. Each creature makes a DC 14 Dexterity save, taking 6d6 fire damage.

***Using a Higher-Level Spell Slot.*** The damage increases by 1d6 for each slot level above 3."
OUT=$(render data/spells/spells-cnr.json "Cinder Bloom" CNR --meta)
has "spell meta" "$OUT" '"level": 3'
OUT=$(render data/spells/spells-cnr.json "Quiet Glow" CNR) || fail "cantrip: exit $?: $(cat "$TMP/err")"
has cantrip "$OUT" "*Illusion Cantrip*

**Casting Time:** 1 bonus action
**Range:** Self (15-foot cone)
**Components:** S, M (a firefly worth 5 gp)
**Duration:** Concentration, up to 10 minutes"
OUT=$(render data/spells/spells-cnr.json "Warding Hush" CNR) || fail "ritual: exit $?: $(cat "$TMP/err")"
has ritual "$OUT" "*Level 1 Abjuration (Ritual)*

**Casting Time:** 1 reaction, which you take when a creature within 60 feet of you speaks
**Range:** Self
**Components:** V
**Duration:** Until dispelled or triggered, or 1 hour"

# --- Monsters: the stat lines are one self-contained section --------------------------
seed bestiary/bestiary-tor.json <<'JSON'
{"monster": [
  {"name": "Quill Hound", "source": "TOR", "page": 7, "size": ["M"], "type": "beast", "alignment": ["U"],
   "ac": [{"ac": 13, "from": ["natural armor"]}], "hp": {"average": 22, "formula": "4d8 + 4"},
   "speed": {"walk": 40, "climb": 20, "fly": {"number": 30, "condition": "(hover)"}, "canHover": true},
   "str": 12, "dex": 15, "con": 12, "int": 3, "wis": 12, "cha": 7,
   "save": {"dex": "+4"}, "skill": {"perception": "+3", "sleight of hand": "+4"},
   "vulnerable": ["fire"],
   "resist": ["cold", {"resist": ["bludgeoning", "piercing", "slashing"], "note": "from nonmagical attacks", "cond": true}],
   "immune": ["poison"], "conditionImmune": ["poisoned", {"conditionImmune": ["charmed"], "note": "(while asleep)"}],
   "senses": ["darkvision 60 ft."], "passive": 13, "languages": ["understands Common but can't speak"], "cr": "1",
   "trait": [{"name": "Keen Smell", "entries": ["The hound has advantage on Wisdom ({@skill Perception}) checks that rely on smell."]}],
   "action": [{"name": "Quill Spray {@recharge 5}", "entries": ["{@atk rw} {@hit 4} to hit, range 20/60 ft. {@h}5 ({@damage 1d6 + 2}) piercing damage."]}],
   "legendary": [{"name": "Bristle", "entries": ["The hound bristles."]}], "legendaryActions": 2,
   "spellcasting": [{"name": "Innate Spellcasting", "headerEntries": ["The hound's spellcasting ability is Wisdom ({@dc 11})."],
                     "will": ["{@spell dancing sparks|TOR}"], "daily": {"1e": ["{@spell hush}", "{@spell glow}"], "3": ["{@spell blink step}"]},
                     "ability": "wis"}]},
  {"name": "Lantern Warden", "source": "TOR", "page": 9, "size": ["S", "M"],
   "type": {"type": "humanoid", "tags": ["lampkin", {"tag": "wizard", "prefix": "hedge"}]},
   "alignment": ["L", "NX", "C", "E"], "ac": [15], "hp": {"special": "equal to the lantern's light"},
   "speed": {"walk": 30}, "str": 8, "dex": 14, "con": 10, "int": 16, "wis": 10, "cha": 11,
   "languages": ["Common"], "cr": {"cr": "5", "lair": "6"}, "passive": 10,
   "spellcasting": [{"name": "Spellcasting", "headerEntries": ["The warden casts spells:"],
                     "spells": {"0": {"spells": ["{@spell spark}"]}, "1": {"slots": 4, "spells": ["{@spell glow}", "{@spell hush}"]}},
                     "footerEntries": ["It prefers light."], "ability": "int"}]}
]}
JSON
seed bestiary/bestiary-cnr.json <<'JSON'
{"monster": [
  {"name": "Ember Moth", "source": "CNR", "page": 50, "size": ["T"], "type": {"type": {"choose": ["beast", "elemental"]}},
   "alignment": ["N"], "ac": [12], "hp": {"average": 3, "formula": "1d4 + 1"}, "speed": {"walk": 5, "fly": 40},
   "initiative": {"proficiency": 1}, "str": 2, "dex": 15, "con": 12, "int": 2, "wis": 10, "cha": 6,
   "gear": ["ember lamp|cnr", {"item": "moth dust|cnr", "quantity": 2}], "passive": 10, "cr": "1/4",
   "action": [{"name": "Singe", "entries": ["{@atkr m} {@hit 4}, reach 5 ft. {@h}{@damage 1d4} fire damage."]}],
   "bonus": [{"name": "Flit", "entries": ["The moth moves."]}],
   "reaction": [{"name": "Flare", "entries": ["{@actTrigger} A creature hits the moth. {@actResponse} It flares."]}],
   "spellcasting": [{"name": "Spellcasting", "headerEntries": ["The moth casts:"], "will": ["{@spell glow}"], "displayAs": "action", "ability": "wis"}]}
]}
JSON
OUT=$(render data/bestiary/bestiary-tor.json "Quill Hound" TOR) || fail "monster: exit $?: $(cat "$TMP/err")"
has monster "$OUT" "# Quill Hound

## Stat Block

*Medium beast, unaligned*

**Armor Class** 13 (natural armor)
**Hit Points** 22 (4d8 + 4)
**Speed** 40 ft., climb 20 ft., fly 30 ft. (hover)

| STR | DEX | CON | INT | WIS | CHA |
| --- | --- | --- | --- | --- | --- |
| 12 (+1) | 15 (+2) | 12 (+1) | 3 (-4) | 12 (+1) | 7 (-2) |

**Saving Throws** Dex +4
**Skills** Perception +3, Sleight of Hand +4
**Damage Vulnerabilities** fire
**Damage Resistances** cold; bludgeoning, piercing, and slashing from nonmagical attacks
**Damage Immunities** poison
**Condition Immunities** poisoned; charmed (while asleep)
**Senses** darkvision 60 ft., passive Perception 13
**Languages** understands Common but can't speak
**Challenge** 1 (XP 200; PB +2)

### Traits

***Keen Smell.*** The hound has advantage on Wisdom (Perception) checks that rely on smell.

***Innate Spellcasting.*** The hound's spellcasting ability is Wisdom (DC 11).

- At will: dancing sparks
- 3/day: blink step
- 1/day each: hush, glow

### Actions

***Quill Spray (Recharge 5–6).*** *Ranged Weapon Attack:* +4 to hit, range 20/60 ft. *Hit:* 5 (1d6 + 2) piercing damage.

### Legendary Actions

**Legendary Action Uses:** 2

***Bristle.*** The hound bristles."
OUT=$(render data/bestiary/bestiary-tor.json "Lantern Warden" TOR) || fail "monster 2: exit $?: $(cat "$TMP/err")"
has "monster 2" "$OUT" "*Small or Medium humanoid (lampkin, hedge wizard), any evil alignment*"
has "monster 2" "$OUT" "**Armor Class** 15
**Hit Points** equal to the lantern's light
**Speed** 30 ft."
has "monster 2" "$OUT" "**Senses** passive Perception 10
**Languages** Common
**Challenge** 5 (XP 1,800; PB +3), or 6 (XP 2,300) in its lair"
has "monster 2" "$OUT" "***Spellcasting.*** The warden casts spells:

- Cantrips (at will): spark
- 1st level (4 slots): glow, hush

It prefers light."
OUT=$(render data/bestiary/bestiary-cnr.json "Ember Moth" CNR) || fail "monster 2024: exit $?: $(cat "$TMP/err")"
has "monster 2024" "$OUT" "*Tiny beast or elemental, neutral*"
has "monster 2024" "$OUT" "**Speed** 5 ft., fly 40 ft.
**Initiative** +4 (14)"
has "monster 2024" "$OUT" "**Gear** ember lamp, moth dust (2)"
has "monster 2024" "$OUT" "**Challenge** 1/4 (XP 50; PB +2)"
has "monster 2024" "$OUT" "### Actions

***Singe.*** *Melee Attack Roll:* +4, reach 5 ft. *Hit:* 1d4 fire damage.

***Spellcasting.*** The moth casts:

- At will: glow

### Bonus Actions

***Flit.*** The moth moves.

### Reactions

***Flare.*** *Trigger:* A creature hits the moth. *Response:* It flares."

# --- Equipment, Weapon Masteries and magic items -------------------------------------
seed items-base.json <<'JSON'
{"baseitem": [
  {"name": "Hooked Blade", "source": "CNR", "page": 110, "type": "M|CNR", "rarity": "none", "weaponCategory": "martial",
   "weight": 3, "value": 1500, "dmg1": "1d8", "dmgType": "S", "dmg2": "1d10",
   "property": ["V|CNR", {"uid": "T|CNR", "note": "only when empty-handed"}], "range": "20/60", "mastery": ["Snag|CNR"],
   "entries": ["A curved blade."]},
  {"name": "Scale Coat", "source": "CNR", "page": 112, "type": "MA|CNR", "rarity": "none", "ac": 14,
   "strength": "13", "stealth": true, "weight": 45, "value": 5},
  {"name": "Hooked Blade", "source": "TOR", "page": 3, "type": "M", "rarity": "none", "dmg1": "1d6", "dmgType": "P"}
],
 "itemMastery": [{"name": "Snag", "source": "CNR", "page": 120, "entries": ["You pull the target 5 feet."]}]}
JSON
seed items.json <<'JSON'
{"item": [
  {"name": "Lamp of Echoes", "source": "CNR", "page": 200, "wondrous": true, "rarity": "rare",
   "reqAttune": "by a {@class bard}", "entries": ["It repeats sounds."]},
  {"name": "Rope of Mending", "source": "CNR", "page": 205, "type": "G|CNR", "rarity": "none", "entries": ["It fixes itself."]}
]}
JSON
seed magicvariants.json <<'JSON'
{"magicvariant": [
  {"name": "+2 Weapon", "type": "GV|CNR", "requires": [{"weapon": true}],
   "inherits": {"namePrefix": "+2 ", "source": "CNR", "page": 230, "rarity": "rare", "bonusWeapon": "+2",
                "entries": ["You have a {=bonusWeapon} bonus to attack rolls made with this {=baseName/l}."]}}
]}
JSON
OUT=$(render data/items-base.json "Hooked Blade" CNR) || fail "weapon: exit $?: $(cat "$TMP/err")"
has weapon "$OUT" "# Hooked Blade

*Martial Melee Weapon*

**Damage:** 1d8 slashing
**Properties:** Versatile (1d10), Thrown (range 20/60; only when empty-handed)
**Mastery:** Snag
**Weight:** 3 lb.
**Cost:** 15 gp

A curved blade."
OUT=$(render data/items-base.json "Scale Coat" CNR) || fail "armor: exit $?: $(cat "$TMP/err")"
has armor "$OUT" "*Medium Armor*

**Armor Class:** 14 + Dex modifier (max 2)
**Strength:** 13
**Stealth:** Disadvantage
**Weight:** 45 lb.
**Cost:** 5 cp"
OUT=$(render data/items-base.json Snag CNR) || fail "mastery: exit $?: $(cat "$TMP/err")"
has mastery "$OUT" "# Snag

You pull the target 5 feet."
OUT=$(render data/items-base.json Snag CNR --meta); has "mastery meta" "$OUT" '"key": "itemMastery"'
OUT=$(render data/items.json "Lamp of Echoes" CNR) || fail "magic item: exit $?: $(cat "$TMP/err")"
has "magic item" "$OUT" "# Lamp of Echoes

*Wondrous item, rare (requires attunement by a bard)*

It repeats sounds."
OUT=$(render data/items.json "Lamp of Echoes" CNR --meta); has "magic item meta" "$OUT" '"magic": true'
OUT=$(render data/items.json "Rope of Mending" CNR --meta); has "gear meta" "$OUT" '"magic": false'
OUT=$(render data/magicvariants.json "+2 Weapon" CNR) || fail "variant: exit $?: $(cat "$TMP/err")"
has variant "$OUT" "# +2 Weapon

*Generic variant, rare*

**Applies to:** any weapon

You have a +2 bonus to attack rolls made with this weapon."
OUT=$(render data/magicvariants.json "+2 Weapon" CNR --meta)
has "variant meta" "$OUT" '"source_property": "CNR p. 230, v9.9.9"'
has "variant meta" "$OUT" '"generic_variant": true'

# --- Feats, backgrounds, species and races, class options ----------------------------
seed feats.json <<'JSON'
{"feat": [
  {"name": "Lamplit Mind", "source": "CNR", "page": 60, "category": "G",
   "prerequisite": [{"level": 4, "ability": [{"int": 13}, {"wis": 13}]}, {"feat": ["lantern adept|cnr"]}],
   "ability": [{"choose": {"from": ["int", "wis"], "amount": 1}}],
   "entries": [{"type": "list", "style": "list-hang-notitle", "items": [
     {"type": "item", "name": "Ability Score Increase.", "entries": ["Increase your Intelligence or Wisdom by 1."]},
     {"type": "item", "name": "Bright Thought.", "entries": ["You think in light."]}]}]},
  {"name": "Old Watcher", "source": "TOR", "page": 20, "prerequisite": [{"race": [{"name": "lampkin"}], "spellcasting": true}],
   "ability": [{"wis": 1}], "entries": ["You watch."]}
]}
JSON
OUT=$(render data/feats.json "Lamplit Mind" CNR) || fail "feat: exit $?: $(cat "$TMP/err")"
has feat "$OUT" "# Lamplit Mind

*General Feat*

**Prerequisite:** Level 4+, Intelligence 13 or higher or Wisdom 13 or higher; or lantern adept

- **Ability Score Increase.** Increase your Intelligence or Wisdom by 1.
- **Bright Thought.** You think in light."
OUT=$(render data/feats.json "Old Watcher" TOR) || fail "feat 2014: exit $?: $(cat "$TMP/err")"
has "feat 2014" "$OUT" "# Old Watcher

**Prerequisite:** lampkin, the ability to cast at least one spell

**Ability Score Increase:** Wisdom +1

You watch."
seed backgrounds.json <<'JSON'
{"background": [{"name": "Lamplighter", "source": "CNR", "page": 70, "entries": [
  {"type": "list", "style": "list-hang-notitle", "items": [{"type": "item", "name": "Skill Proficiencies:", "entry": "Insight, Perception"}]},
  {"type": "entries", "name": "Feature: Night Rounds", "entries": ["You know every street."]}]}]}
JSON
OUT=$(render data/backgrounds.json Lamplighter CNR) || fail "background: exit $?: $(cat "$TMP/err")"
has background "$OUT" "# Lamplighter

- **Skill Proficiencies:** Insight, Perception

***Feature: Night Rounds.*** You know every street."
seed races.json <<'JSON'
{"race": [
  {"name": "Lampkin", "source": "TOR", "page": 30, "size": ["S"], "speed": 25, "ability": [{"dex": 2}],
   "entries": [{"type": "entries", "name": "Glow", "entries": ["You shed dim light."]}]},
  {"name": "Mothfolk", "source": "CNR", "page": 80, "size": ["S", "M"], "speed": {"walk": 30, "fly": 30},
   "creatureTypes": ["humanoid"], "entries": [{"type": "entries", "name": "Lineages", "entries": ["Pick one."]}]}
],
 "subrace": [
  {"name": "Wick", "source": "TOR", "page": 31, "raceName": "Lampkin", "raceSource": "TOR", "ability": [{"con": 1}],
   "entries": [{"type": "entries", "name": "Steady Flame", "entries": ["Your light never flickers."]}]},
  {"source": "TOR", "raceName": "Lampkin", "raceSource": "TOR",
   "entries": [{"type": "entries", "name": "Languages", "entries": ["Common and Lampish."]}]}
]}
JSON
OUT=$(render data/races.json Lampkin TOR) || fail "race: exit $?: $(cat "$TMP/err")"
has race "$OUT" "# Lampkin

**Ability Scores:** Dexterity +2
**Size:** Small
**Speed:** 25 ft.

***Glow.*** You shed dim light.

***Languages.*** Common and Lampish."
hasnt race "$OUT" "Steady Flame"
OUT=$(render data/races.json Mothfolk CNR) || fail "species: exit $?: $(cat "$TMP/err")"
has species "$OUT" "**Creature Type:** Humanoid
**Size:** Small or Medium
**Speed:** 30 ft., fly 30 ft."
OUT=$(render data/races.json Wick TOR) || fail "subrace: exit $?: $(cat "$TMP/err")"
has subrace "$OUT" "# Wick Lampkin

**Ability Scores:** Constitution +1

***Steady Flame.*** Your light never flickers."
hasnt subrace "$OUT" "Glow"
OUT=$(render data/races.json Wick TOR --meta)
has "subrace meta" "$OUT" '"race": "Lampkin"'
has "subrace meta" "$OUT" '"title": "Wick Lampkin"'
seed optionalfeatures.json <<'JSON'
{"optionalfeature": [
  {"name": "Ember Tongue", "source": "TOR", "page": 45, "featureType": ["EI"], "prerequisite": [{"level": {"level": 5, "class": {"name": "Warlock"}}}],
   "entries": ["You speak in sparks."]},
  {"name": "Low Cut", "source": "TOR", "page": 46, "featureType": ["MV:B"], "entries": ["A sweeping cut."]}
]}
JSON
OUT=$(render data/optionalfeatures.json "Ember Tongue" TOR) || fail "option: exit $?: $(cat "$TMP/err")"
has option "$OUT" "# Ember Tongue

*Eldritch Invocation*

**Prerequisite:** Level 5+ Warlock

You speak in sparks."
OUT=$(render data/optionalfeatures.json "Ember Tongue" TOR --meta); has "option meta" "$OUT" '"option_kind": "Eldritch Invocations"'
OUT=$(render data/optionalfeatures.json "Low Cut" TOR --meta); has "option meta 2" "$OUT" '"option_kind": "Maneuvers"'

# --- Classes and subclasses -----------------------------------------------------------
seed class/class-lamplighter.json <<'JSON'
{"class": [{"name": "Lamplighter", "source": "CNR", "page": 100, "hd": {"number": 1, "faces": 8},
  "proficiency": ["dex", "wis"], "primaryAbility": [{"wis": true}],
  "startingProficiencies": {"armor": ["light", {"proficiency": "shields", "full": "shields (wooden only)"}], "weapons": ["simple"],
                            "tools": ["tinker's tools"], "skills": [{"choose": {"from": ["insight", "perception", "stealth"], "count": 2}}]},
  "startingEquipment": {"entries": ["Choose A or B: (A) a lantern; or (B) 50 GP"]},
  "classTableGroups": [{"colLabels": ["Wicks"], "rows": [["2"], [{"type": "bonus", "value": 3}], [{"type": "dice", "toRoll": [{"number": 1, "faces": 6}]}]]},
                       {"title": "Spell Slots", "colLabels": ["{@filter 1st|spells|level=1}", "2nd"], "rowsSpellProgression": [[2, 0], [3, 0], [4, 2]]}],
  "classFeatures": ["Kindle|Lamplighter|CNR|1", "Lamplighter Path|Lamplighter|CNR|2", "Hearth Craft|Lamplighter|CNR|2|TOR",
                    {"classFeature": "Path Feature|Lamplighter|CNR|3", "gainSubclassFeature": true}],
  "subclassTitle": "Lamplighter Path"}],
 "classFeature": [
  {"name": "Kindle", "source": "CNR", "page": 101, "className": "Lamplighter", "classSource": "CNR", "level": 1,
   "entries": ["You light things.", {"type": "refClassFeature", "classFeature": "Spark Rule|Lamplighter|CNR|1"},
               {"type": "options", "count": 1, "entries": [{"type": "refOptionalfeature", "optionalfeature": "Ember Tongue|TOR"}]}]},
  {"name": "Spark Rule", "source": "CNR", "page": 101, "className": "Lamplighter", "classSource": "CNR", "level": 1, "entries": ["Sparks fly."]},
  {"name": "Lamplighter Path", "source": "CNR", "page": 102, "className": "Lamplighter", "classSource": "CNR", "level": 2, "entries": ["Choose a path."]},
  {"name": "Hearth Craft", "source": "TOR", "page": 42, "className": "Lamplighter", "classSource": "CNR", "level": 2,
   "isClassFeatureVariant": true, "entries": ["Optional craft."]},
  {"name": "Path Feature", "source": "CNR", "page": 103, "className": "Lamplighter", "classSource": "CNR", "level": 3, "entries": ["Your path grows."]}
 ],
 "subclass": [{"name": "Path of the Wick", "shortName": "Wick", "source": "CNR", "page": 105, "className": "Lamplighter", "classSource": "CNR",
   "subclassFeatures": ["Path of the Wick|Lamplighter|CNR|Wick|CNR|2", "Wick Burst|Lamplighter|CNR|Wick|CNR|3"]}],
 "subclassFeature": [
  {"name": "Path of the Wick", "source": "CNR", "page": 105, "className": "Lamplighter", "classSource": "CNR", "subclassShortName": "Wick",
   "subclassSource": "CNR", "level": 2, "entries": ["Wick intro.", {"type": "refSubclassFeature", "subclassFeature": "Wick Sense|Lamplighter|CNR|Wick|CNR|2"}]},
  {"name": "Wick Sense", "source": "CNR", "page": 105, "className": "Lamplighter", "classSource": "CNR", "subclassShortName": "Wick",
   "subclassSource": "CNR", "level": 2, "entries": ["You sense wicks."]},
  {"name": "Wick Burst", "source": "CNR", "page": 106, "className": "Lamplighter", "classSource": "CNR", "subclassShortName": "Wick",
   "subclassSource": "CNR", "level": 3, "entries": ["Boom."]}
 ]}
JSON
OUT=$(render data/class/class-lamplighter.json Lamplighter CNR) || fail "class: exit $?: $(cat "$TMP/err")"
has class "$OUT" "# Lamplighter

**Hit Die:** d8
**Primary Ability:** Wisdom
**Saving Throws:** Dexterity, Wisdom
**Armor:** light, shields (wooden only)
**Weapons:** simple
**Tools:** tinker's tools
**Skills:** Choose 2: Insight, Perception, Stealth
**Starting Equipment:** Choose A or B: (A) a lantern; or (B) 50 GP

## Class Table

| Level | Proficiency Bonus | Features | Wicks | 1st | 2nd |
| --- | --- | --- | --- | --- | --- |
| 1 | +2 | Kindle | 2 | 2 | — |
| 2 | +2 | Lamplighter Path | +3 | 3 | — |
| 3 | +2 | Path Feature | 1d6 | 4 | 2 |

## Level 1

### Kindle

You light things.

***Spark Rule.*** Sparks fly.

- Ember Tongue

## Level 2

### Lamplighter Path

Choose a path.

### Hearth Craft (optional; TOR p. 42)

Optional craft.

## Level 3

### Path Feature

Your path grows."
hasnt class "$OUT" "Wick intro"
OUT=$(render data/class/class-lamplighter.json "Path of the Wick" CNR) || fail "subclass: exit $?: $(cat "$TMP/err")"
has subclass "$OUT" "# Path of the Wick

*Lamplighter subclass*

## Level 2

### Path of the Wick

Wick intro.

***Wick Sense.*** You sense wicks.

## Level 3

### Wick Burst

Boom."
hasnt subclass "$OUT" "Kindle"
OUT=$(render data/class/class-lamplighter.json "Path of the Wick" CNR --meta)
has "subclass meta" "$OUT" '"class": "Lamplighter"'
has "subclass meta" "$OUT" '"class_source": "CNR"'

# --- Copies: _copy with _mod, across files, _templates ---------------------------------
seed bestiary/index.json <<'JSON'
{"TOR": "bestiary-tor.json", "CNR": "bestiary-cnr.json", "DRK": "bestiary-drk.json"}
JSON
seed bestiary/template.json <<'JSON'
{"monsterTemplate": [{"name": "Ashen", "source": "CNR",
  "apply": {"_root": {"vulnerable": ["cold"]}, "_mod": {"trait": {"mode": "appendArr", "items": {"name": "Ashen Body", "entries": ["It crumbles."]}}}}}]}
JSON
seed bestiary/bestiary-drk.json <<'JSON'
{"monster": [
  {"name": "Quill Hound Alpha", "source": "DRK", "page": 52,
   "hp": {"average": 40, "formula": "8d8 + 4"},
   "_copy": {"name": "Quill Hound", "source": "TOR", "_mod": {
     "*": {"mode": "replaceTxt", "replace": "the (hound)", "with": "the alpha $1", "flags": "i"},
     "trait": [{"mode": "appendArr", "items": {"name": "Pack Leader", "entries": ["Allies rally."]}},
               {"mode": "prependArr", "items": {"name": "Big", "entries": ["It is big."]}},
               {"mode": "insertArr", "index": 1, "items": [{"name": "Loud", "entries": ["It howls."]}]}],
     "action": [{"mode": "replaceArr", "replace": "Quill Spray {@recharge 5}", "items": {"name": "Quill Storm", "entries": ["Quills everywhere."]}},
                {"mode": "replaceOrAppendArr", "replace": "Bite", "items": {"name": "Bite", "entries": ["Chomp."]}}],
     "senses": {"mode": "appendIfNotExistsArr", "items": ["darkvision 60 ft.", "tremorsense 10 ft."]},
     "spellcasting": {"mode": "removeArr", "names": "Innate Spellcasting"},
     "legendary": "remove"}}},
  {"name": "Quill Pup", "source": "DRK", "_copy": {"name": "Quill Hound Alpha", "source": "DRK", "_mod": {
     "trait": {"mode": "removeArr", "names": ["Big", "Loud"]}}}},
  {"name": "Ashen Quill Hound", "source": "DRK", "page": 53, "_copy": {"name": "Quill Hound", "source": "TOR", "_templates": [{"name": "Ashen", "source": "CNR"}]}},
  {"name": "Odd Hound", "source": "DRK", "page": 54, "_copy": {"name": "Quill Hound", "source": "TOR", "_mod": {"_": {"mode": "addSkills", "skills": {"stealth": 1}}}}},
  {"name": "Lost Hound", "source": "DRK", "page": 55, "_copy": {"name": "Nowhere Hound", "source": "TOR"}}
]}
JSON
OUT=$(render data/bestiary/bestiary-drk.json "Quill Hound Alpha" DRK) || fail "copy: exit $?: $(cat "$TMP/err")"
has copy "$OUT" "# Quill Hound Alpha"
has copy "$OUT" "**Hit Points** 40 (8d8 + 4)"
has copy "$OUT" "*Medium beast, unaligned*"
has copy "$OUT" "### Traits

***Big.*** It is big.

***Loud.*** It howls.

***Keen Smell.*** the alpha hound has advantage on Wisdom (Perception) checks that rely on smell.

***Pack Leader.*** Allies rally.

### Actions

***Quill Storm.*** Quills everywhere.

***Bite.*** Chomp."
has copy "$OUT" "**Senses** darkvision 60 ft., tremorsense 10 ft., passive Perception 13"
hasnt copy "$OUT" "Legendary"
hasnt copy "$OUT" "Innate Spellcasting"
OUT=$(render data/bestiary/bestiary-drk.json "Quill Hound Alpha" DRK --meta)
has "copy meta" "$OUT" '"source_property": "DRK p. 52, v9.9.9"'
has "adventure edition" "$OUT" '"edition": "2024"'
OUT=$(render data/bestiary/bestiary-drk.json "Quill Pup" DRK) || fail "chained copy: exit $?: $(cat "$TMP/err")"
has "chained copy" "$OUT" "### Traits

***Keen Smell.*** the alpha hound"
hasnt "chained copy" "$OUT" "It howls."
OUT=$(render data/bestiary/bestiary-drk.json "Quill Pup" DRK --meta)
has "copy page" "$OUT" '"source_property": "DRK, v9.9.9"'
OUT=$(render data/bestiary/bestiary-drk.json "Ashen Quill Hound" DRK) || fail "template: exit $?: $(cat "$TMP/err")"
has template "$OUT" "**Damage Vulnerabilities** cold"
has template "$OUT" "***Ashen Body.*** It crumbles."
OUT=$(render data/bestiary/bestiary-drk.json "Odd Hound" DRK); CODE=$?
[ "$CODE" -eq 6 ] || fail "unsupported modifier: expected exit 6, got $CODE"
[ -z "$OUT" ] || fail "unsupported modifier: printed '$OUT'"
has "unsupported modifier" "$(cat "$TMP/err")" "addSkills"
render data/bestiary/bestiary-drk.json "Lost Hound" DRK >/dev/null; CODE=$?
[ "$CODE" -eq 7 ] || fail "missing copied entry: expected exit 7, got $CODE"

# A 2014 subclass listed again under the 2024 version of its class.
python3 - "$DATA/class/class-lamplighter.json" <<'PY'
import json, sys
p = sys.argv[1]; d = json.load(open(p))
d["subclass"] += [
  {"name": "Path of Soot", "shortName": "Soot", "source": "TOR", "page": 47, "className": "Lamplighter", "classSource": "TOR",
   "subclassFeatures": ["Path of Soot|Lamplighter|TOR|Soot|TOR|2"]},
  {"name": "Path of Soot", "shortName": "Soot", "source": "TOR", "className": "Lamplighter", "classSource": "CNR",
   "_copy": {"name": "Path of Soot", "shortName": "Soot", "source": "TOR", "className": "Lamplighter", "classSource": "TOR",
             "_preserve": {"page": True}}}]
d["subclassFeature"].append({"name": "Path of Soot", "source": "TOR", "page": 47, "className": "Lamplighter", "classSource": "TOR",
  "subclassShortName": "Soot", "subclassSource": "TOR", "level": 2, "entries": ["Soot everywhere."]})
json.dump(d, open(p, "w"))
PY
render data/class/class-lamplighter.json "Path of Soot" TOR >/dev/null; CODE=$?
[ "$CODE" -eq 8 ] || fail "subclass twice: expected exit 8, got $CODE"
has "subclass twice" "$(cat "$TMP/err")" "--class-source"
OUT=$(render data/class/class-lamplighter.json "Path of Soot" TOR --class-source CNR) || fail "subclass copy: exit $?: $(cat "$TMP/err")"
has "subclass copy" "$OUT" "Soot everywhere."
OUT=$(render data/class/class-lamplighter.json "Path of Soot" TOR --class-source CNR --meta)
has "subclass copy meta" "$OUT" '"class_source": "CNR"'
has "subclass copy meta" "$OUT" '"source_property": "TOR p. 47, v9.9.9"'
has "subclass copy meta" "$OUT" '"edition": "2014"'

# --- Errors: each has its exit code and prints nothing -------------------------------
expect_exit() { # label code args…
  label=$1 code=$2; shift 2
  OUT=$(render "$@"); CODE=$?
  [ "$CODE" -eq "$code" ] || fail "$label: expected exit $code, got $CODE ($(cat "$TMP/err"))"
  [ -z "$OUT" ] || fail "$label: printed '$OUT'"
}
expect_exit "no such entry" 5 data/conditionsdiseases.json Nowhere CNR
expect_exit "wrong book" 5 data/conditionsdiseases.json Dazzled TOR
python3 - "$DATA/items-base.json" <<'PY'
import json, sys
p = sys.argv[1]; d = json.load(open(p))
d["baseitem"].append({"name": "Snag", "source": "CNR", "page": 121, "type": "G|CNR", "rarity": "none", "entries": ["A hook."]})
json.dump(d, open(p, "w"))
PY
expect_exit "several kinds" 8 data/items-base.json Snag CNR
has "several kinds" "$(cat "$TMP/err")" "itemMastery"
OUT=$(render data/items-base.json Snag CNR --key itemMastery) || fail "--key: exit $?"
has "--key" "$OUT" "You pull the target 5 feet."
seed monstrous.json <<'JSON'
{"condition": [
  {"name": "Broken Entries", "source": "CNR", "page": 1, "entries": "not a list"},
  {"name": "Odd Type", "source": "CNR", "page": 2, "entries": [{"type": "whirligig"}]},
  {"name": "Open Tag", "source": "CNR", "page": 3, "entries": ["A {@spell glow never closes."]},
  {"name": "Ragged Table", "source": "CNR", "page": 4, "entries": [{"type": "table", "rows": ["not a row"]}]}
],
 "spell": [{"name": "No Level", "source": "CNR", "page": 5, "entries": ["x"]}]}
JSON
expect_exit "entries not a list" 7 data/monstrous.json "Broken Entries" CNR
expect_exit "unknown entry type" 7 data/monstrous.json "Odd Type" CNR
expect_exit "unclosed tag" 7 data/monstrous.json "Open Tag" CNR
expect_exit "ragged table" 7 data/monstrous.json "Ragged Table" CNR
expect_exit "spell without level" 7 data/monstrous.json "No Level" CNR
printf '{"condition": [' > "$DATA/broken.json"
expect_exit "invalid JSON" 7 data/broken.json Dazzled CNR
expect_exit "not cached, unreachable" 3 data/spells/spells-zzz.json Glow CNR
has "not cached, unreachable" "$(cat "$TMP/err")" "Trusted Source"
mkdir -p "$TMP/mirror/v9.9.9/data"   # reachable, but without the file
DMR_SOURCE_RAW="file://$TMP/mirror"
expect_exit "no such file" 4 data/spells/spells-zzz.json Glow CNR
DMR_SOURCE_RAW="http://127.0.0.1:9/raw"
expect_exit "usage" 2 data/conditionsdiseases.json Dazzled
expect_exit "path outside data" 2 ../x.json Dazzled CNR

[ "$FAILS" -eq 0 ] && echo "render-entry: all pass" || { echo "render-entry: $FAILS failure(s)"; exit 1; }
