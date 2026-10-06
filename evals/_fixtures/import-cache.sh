# A Source Cache seeded with INVENTED entries for Import cases, sourced by their scaffolds
# (ADR 0003: no real Trusted Source data in the repository; the eval sandbox has no
# network). Books, dates, names, pages and text are all made up, and the text differs
# between Editions, so a note proves which entry it came from. The cache sits in the
# sandbox home, outside the Workspace, where the case's EVAL_DMR_SOURCE_CACHE points.
#
#   2014 books: OLDC Old Codex of Rules (2015), LOTD Lanterns of the Deep (2016),
#               BOFI Beasts of the Far Isles (2021)
#   2024 books: EMBC Ember Codex (2025), FAR Far Reaches Bestiary (2025; listed, never cached)
#   Adventure:  SACR The Salt Crypt (2025)
#   Descriptions (fluff): only the Wisp Hound's, in bestiary/fluff-bestiary-embc.json
#   Images: only the Wisp Hound's, bestiary/EMBC/Wisps.webp — invented bytes, not an image
#               (no real 5etools image in the repository, ADR 0003)
CACHE="$HOME/.dm-realm/source-cache"
D="$CACHE/v3.0.0/data"
mkdir -p "$D/spells" "$D/bestiary" "$D/class"
echo v3.0.0 > "$CACHE/release"

cat > "$D/books.json" <<'JSON'
{"book": [
  {"name": "Old Codex of Rules", "id": "OLDC", "source": "OLDC", "published": "2015-01-20"},
  {"name": "Lanterns of the Deep", "id": "LOTD", "source": "LOTD", "published": "2016-05-10"},
  {"name": "Beasts of the Far Isles", "id": "BOFI", "source": "BOFI", "published": "2021-06-01"},
  {"name": "Player's Handbook (2024)", "id": "XPHB", "source": "XPHB", "published": "2024-09-17"},
  {"name": "Ember Codex", "id": "EMBC", "source": "EMBC", "published": "2025-03-04"},
  {"name": "Far Reaches Bestiary", "id": "FAR", "source": "FAR", "published": "2025-10-01"}
]}
JSON
cat > "$D/adventures.json" <<'JSON'
{"adventure": [{"name": "The Salt Crypt", "id": "SACR", "source": "SACR", "published": "2025-08-01"}]}
JSON

cat > "$D/conditionsdiseases.json" <<'JSON'
{"condition": [
  {"name": "Dazzled", "source": "OLDC", "page": 290, "reprintedAs": ["Dazzled|EMBC"],
   "entries": ["A dazzled creature sees only swirling colors and can't read."]},
  {"name": "Brittle", "source": "OLDC", "page": 291,
   "entries": ["A brittle creature has vulnerability to bludgeoning damage."]},
  {"name": "Dazzled", "source": "EMBC", "page": 361,
   "entries": ["A Dazzled creature has Disadvantage on attack rolls while drifting motes of light fill its eyes."]},
  {"name": "Smoldering", "source": "EMBC", "page": 365,
   "entries": ["A Smoldering creature takes {@damage 1d4} Fire damage at the start of each of its turns until a creature within 5 feet of it takes an action to beat out the embers."]}
]}
JSON
cat > "$D/actions.json" <<'JSON'
{"action": [{"name": "Brace", "source": "EMBC", "page": 362, "time": [{"number": 1, "unit": "action"}],
  "entries": ["You plant your feet. Until the start of your next turn, you can't be pushed or knocked {@condition Prone|EMBC}."]}]}
JSON

cat > "$D/spells/index.json" <<'JSON'
{"OLDC": "spells-oldc.json", "LOTD": "spells-lotd.json", "EMBC": "spells-embc.json"}
JSON
# The class spell lists (the Trusted Source's spell-to-class lookup).
cat > "$D/spells/sources.json" <<'JSON'
{"EMBC": {"Cinder Bloom": {"class": [{"name": "Lamplighter", "source": "EMBC"}]},
          "Whisper Veil": {"class": [{"name": "Lamplighter", "source": "EMBC"}]},
          "Glimmerlance": {"class": [{"name": "Lamplighter", "source": "EMBC"}]}},
 "OLDC": {"Cinder Bloom": {"class": [{"name": "Lamplighter", "source": "OLDC"}]}}}
JSON
cat > "$D/spells/spells-oldc.json" <<'JSON'
{"spell": [
  {"name": "Cinder Bloom", "source": "OLDC", "page": 221, "level": 3, "school": "V", "reprintedAs": ["Cinder Bloom|EMBC"],
   "time": [{"number": 1, "unit": "action"}], "range": {"type": "point", "distance": {"type": "feet", "amount": 90}},
   "components": {"v": true, "s": true, "m": "a burnt rose"}, "duration": [{"type": "instant"}],
   "entries": ["Ash rises in a 20-foot-radius sphere. Each creature in it makes a Constitution saving throw, taking {@damage 8d6} fire damage on a failed save, or half as much on a successful one."]}
]}
JSON
cat > "$D/spells/spells-embc.json" <<'JSON'
{"spell": [
  {"name": "Cinder Bloom", "source": "EMBC", "page": 211, "level": 3, "school": "V",
   "time": [{"number": 1, "unit": "action"}], "range": {"type": "point", "distance": {"type": "feet", "amount": 120}},
   "components": {"v": true, "s": true, "m": "a pinch of rose ash"}, "duration": [{"type": "instant"}],
   "entries": ["A bloom of cinders opens at a point you choose within range. Each creature in a 15-foot Emanation from that point makes a Dexterity saving throw, taking {@damage 7d6} Fire damage on a failed save or half as much damage on a successful one."],
   "entriesHigherLevel": [{"type": "entries", "name": "Using a Higher-Level Spell Slot",
     "entries": ["The damage increases by {@scaledamage 7d6|3-9|1d6} for each spell slot level above 3."]}]},
  {"name": "Whisper Veil", "source": "EMBC", "page": 214, "level": 2, "school": "I",
   "time": [{"number": 1, "unit": "action"}], "range": {"type": "point", "distance": {"type": "feet", "amount": 60}},
   "components": {"v": true, "s": true}, "duration": [{"type": "timed", "duration": {"type": "minute", "amount": 1}, "concentration": true}],
   "entries": ["Choose one creature you can see within range. It gains a Hushmark for the duration. While it bears the Hushmark, its voice can't rise above a whisper, and it has Disadvantage on Charisma checks."]},
  {"name": "Glimmerlance", "source": "EMBC", "page": 212, "level": 1, "school": "V",
   "time": [{"number": 1, "unit": "action"}], "range": {"type": "point", "distance": {"type": "feet", "amount": 60}},
   "components": {"v": true, "s": true}, "duration": [{"type": "instant"}],
   "entries": ["A lance of light strikes one creature: it takes {@damage 2d8} Radiant damage."]}
]}
JSON
cat > "$D/spells/spells-lotd.json" <<'JSON'
{"spell": [
  {"name": "Silver Hush", "source": "LOTD", "page": 33, "level": 1, "school": "E",
   "time": [{"number": 1, "unit": "reaction", "condition": "which you take when a creature you can see casts a spell"}],
   "range": {"type": "point", "distance": {"type": "feet", "amount": 30}}, "components": {"v": true},
   "duration": [{"type": "instant"}],
   "entries": ["The caster's words falter: it must succeed on a {@dc 13} Wisdom saving throw or its spell fails."]}
]}
JSON

cat > "$D/bestiary/index.json" <<'JSON'
{"OLDC": "bestiary-oldc.json", "EMBC": "bestiary-embc.json", "BOFI": "bestiary-bofi.json",
 "SACR": "bestiary-sacr.json", "FAR": "bestiary-far.json"}
JSON
cat > "$D/bestiary/bestiary-oldc.json" <<'JSON'
{"monster": [
  {"name": "Mire Goblin", "source": "OLDC", "page": 166, "reprintedAs": ["Bog Goblin|EMBC"],
   "size": ["S"], "type": {"type": "humanoid", "tags": ["goblinoid"]}, "alignment": ["N", "E"],
   "ac": [{"ac": 13, "from": ["hide armor"]}], "hp": {"average": 9, "formula": "2d6 + 2"}, "speed": {"walk": 30, "swim": 20},
   "str": 8, "dex": 14, "con": 12, "int": 9, "wis": 8, "cha": 8, "passive": 9, "languages": ["Goblin"], "cr": "1/4",
   "action": [{"name": "Muck Spear", "entries": ["{@atk mw} {@hit 4} to hit, reach 5 ft. {@h}5 ({@damage 1d6 + 2}) piercing damage."]}]}
]}
JSON
cat > "$D/bestiary/bestiary-embc.json" <<'JSON'
{"monster": [
  {"name": "Bog Goblin", "source": "EMBC", "page": 150,
   "size": ["S"], "type": {"type": "fey", "tags": ["goblinoid"]}, "alignment": ["N"],
   "ac": [14], "hp": {"average": 11, "formula": "2d6 + 4"}, "speed": {"walk": 30, "swim": 30},
   "initiative": {"proficiency": 1}, "str": 8, "dex": 15, "con": 14, "int": 9, "wis": 10, "cha": 8,
   "skill": {"stealth": "+6"}, "senses": ["darkvision 60 ft."], "passive": 10, "languages": ["Common", "Goblin"], "cr": "1/2",
   "trait": [{"name": "Reed Walker", "entries": ["The goblin moves through reeds and mud without spending extra movement."]}],
   "action": [{"name": "Reed Spear", "entries": ["{@atkr m,r} {@hit 4}, reach 5 ft. or range 20/60 ft. {@h}6 ({@damage 1d8 + 2}) Piercing damage."]}]},
  {"name": "Wisp Hound", "source": "EMBC", "page": 152, "hasFluff": true, "hasFluffImages": true,
   "size": ["M"], "type": "fey", "alignment": ["C", "N"],
   "ac": [13], "hp": {"average": 27, "formula": "5d8 + 5"}, "speed": {"walk": 40},
   "initiative": {"proficiency": 1}, "str": 12, "dex": 16, "con": 12, "int": 6, "wis": 14, "cha": 10,
   "senses": ["darkvision 120 ft."], "passive": 12, "languages": ["understands Sylvan but can't speak"], "cr": "1",
   "action": [{"name": "Cold Bite", "entries": ["{@atkr m} {@hit 5}, reach 5 ft. {@h}7 ({@damage 1d8 + 3}) Cold damage."]}]}
]}
JSON
cat > "$D/bestiary/fluff-index.json" <<'JSON'
{"EMBC": "fluff-bestiary-embc.json"}
JSON
cat > "$D/bestiary/fluff-bestiary-embc.json" <<'JSON'
{"monsterFluff": [
  {"name": "Wisps", "source": "EMBC", "entries": [{"type": "entries", "entries": [
    {"type": "section", "name": "Wisps", "entries": ["Wisps are lost lantern flames that learned to wander on their own."]}]}],
   "images": [{"type": "image", "href": {"type": "internal", "path": "bestiary/EMBC/Wisps.webp"}}]},
  {"name": "Wisp Hound", "source": "EMBC", "_copy": {"name": "Wisps", "source": "EMBC", "_mod": {
    "entries": {"mode": "prependArr", "items": {"type": "section", "entries": ["Wisp hounds follow travelers who whistle after dark, and never bark."]}}}}}
]}
JSON
mkdir -p "$CACHE/v3.0.0/img/bestiary/EMBC"
printf 'INVENTED IMAGE: bestiary/EMBC/Wisps.webp' > "$CACHE/v3.0.0/img/bestiary/EMBC/Wisps.webp"
cat > "$D/bestiary/bestiary-bofi.json" <<'JSON'
{"monster": [
  {"name": "Tidecaller Wyrm", "source": "BOFI", "page": 240,
   "size": ["H"], "type": "dragon", "alignment": ["C", "N"],
   "ac": [{"ac": 17, "from": ["natural armor"]}], "hp": {"average": 136, "formula": "13d12 + 52"}, "speed": {"walk": 40, "swim": 80},
   "str": 22, "dex": 10, "con": 18, "int": 12, "wis": 13, "cha": 15, "save": {"con": "+8", "wis": "+5"},
   "senses": ["blindsight 60 ft."], "passive": 11, "languages": ["Draconic", "Aquan"], "cr": "10",
   "trait": [{"name": "Tide Pull", "entries": ["Water within 30 feet of the wyrm flows toward it."]}],
   "action": [{"name": "Brine Breath {@recharge 5}", "entries": ["The wyrm exhales brine in a 60-foot line. Each creature in it makes a {@dc 16} Strength saving throw, taking 45 ({@damage 10d8}) cold damage on a failed save."]}]}
]}
JSON
cat > "$D/bestiary/bestiary-sacr.json" <<'JSON'
{"monster": [
  {"name": "Salt Wight", "source": "SACR", "page": 88,
   "size": ["M"], "type": "undead", "alignment": ["L", "E"],
   "ac": [15], "hp": {"average": 52, "formula": "8d8 + 16"}, "speed": {"walk": 30},
   "str": 15, "dex": 12, "con": 14, "int": 10, "wis": 13, "cha": 11,
   "immune": ["Poison"], "senses": ["darkvision 60 ft."], "passive": 11, "languages": ["Common"], "cr": "3",
   "action": [{"name": "Brine Touch", "entries": ["{@atkr m} {@hit 4}, reach 5 ft. {@h}9 ({@damage 2d6 + 2}) Necrotic damage, and the target's lips crust with salt."]}]},
  {"name": "Salt Goblin Boss", "source": "SACR", "page": 90,
   "hp": {"average": 33, "formula": "6d8 + 6"},
   "_copy": {"name": "Bog Goblin", "source": "EMBC", "_mod": {
     "*": {"mode": "replaceTxt", "replace": "the goblin", "with": "the boss", "flags": "i"},
     "action": {"mode": "appendArr", "items": {"name": "Rally", "entries": ["Each Bog Goblin within 30 feet of the boss can take a Reaction to move up to half its Speed."]}}}}}
]}
JSON

cat > "$D/items-base.json" <<'JSON'
{"baseitem": [
  {"name": "Longsword", "source": "EMBC", "page": 149, "type": "M|EMBC", "rarity": "none", "weaponCategory": "martial",
   "weight": 3, "value": 1500, "dmg1": "1d8", "dmgType": "S", "dmg2": "1d10", "property": ["V|EMBC"], "mastery": ["Snare|EMBC"]}
],
 "itemMastery": [
  {"name": "Snare", "source": "EMBC", "page": 216,
   "entries": ["If you hit a creature with this weapon, you can reduce its Speed by 15 feet until the start of your next turn."]}
]}
JSON
cat > "$D/items.json" <<'JSON'
{"item": [
  {"name": "Lamp of Echoes", "source": "EMBC", "page": 280, "wondrous": true, "rarity": "rare", "reqAttune": true,
   "entries": ["While you hold this lamp, you can hear anything spoken within 10 feet of its light."]}
]}
JSON
cat > "$D/magicvariants.json" <<'JSON'
{"magicvariant": [
  {"name": "+1 Weapon", "type": "GV|OLDC", "requires": [{"weapon": true}],
   "inherits": {"namePrefix": "+1 ", "source": "OLDC", "page": 213, "rarity": "uncommon", "bonusWeapon": "+1",
                "entries": ["You have a {=bonusWeapon} bonus to attack and damage rolls made with this magic weapon, which glows faintly."]}},
  {"name": "+1 Weapon", "type": "GV|EMBC", "requires": [{"weapon": true}],
   "inherits": {"namePrefix": "+1 ", "source": "EMBC", "page": 301, "rarity": "uncommon", "bonusWeapon": "+1",
                "entries": ["You have a {=bonusWeapon} bonus to attack rolls and damage rolls made with this magic weapon, which hums when drawn."]}}
]}
JSON

cat > "$D/feats.json" <<'JSON'
{"feat": [
  {"name": "Glimmerlance", "source": "EMBC", "page": 203, "category": "G", "prerequisite": [{"level": 4}],
   "entries": ["You can hurl light: once per Short Rest, make a ranged attack that deals {@damage 2d6} Radiant damage."]},
  {"name": "Lamplit Mind", "source": "LOTD", "page": 70,
   "entries": ["You can read by the faintest light, and you can't be blinded by bright light."]}
]}
JSON
cat > "$D/races.json" <<'JSON'
{"race": [
  {"name": "Lampkin", "source": "OLDC", "page": 30, "size": ["S"], "speed": 25, "ability": [{"dex": 2}],
   "entries": [{"type": "entries", "name": "Glow", "entries": ["You shed dim light in a 5-foot radius."]}]},
  {"name": "Mothfolk", "source": "EMBC", "page": 80, "size": ["S", "M"], "speed": {"walk": 30, "fly": 30},
   "creatureTypes": ["humanoid"], "entries": [{"type": "entries", "name": "Dustwings", "entries": ["You can fly while you wear no heavy armor."]}]}
],
 "subrace": [
  {"name": "Wick", "source": "OLDC", "page": 31, "raceName": "Lampkin", "raceSource": "OLDC", "ability": [{"con": 1}],
   "entries": [{"type": "entries", "name": "Steady Flame", "entries": ["Your light never flickers, even in a gale."]}]}
]}
JSON

cat > "$D/class/index.json" <<'JSON'
{"lamplighter": "class-lamplighter.json"}
JSON
cat > "$D/class/class-lamplighter.json" <<'JSON'
{"class": [{"name": "Lamplighter", "source": "EMBC", "page": 100, "hd": {"number": 1, "faces": 8}, "proficiency": ["dex", "wis"],
  "classTableGroups": [{"colLabels": ["Wicks"], "rows": [["2"], ["2"], ["3"]]}],
  "classFeatures": ["Kindle|Lamplighter|EMBC|1", "Lamplighter Path|Lamplighter|EMBC|2", "Path Feature|Lamplighter|EMBC|3"],
  "subclassTitle": "Lamplighter Path"}],
 "classFeature": [
  {"name": "Kindle", "source": "EMBC", "page": 101, "className": "Lamplighter", "classSource": "EMBC", "level": 1, "entries": ["You light any wick you touch."]},
  {"name": "Lamplighter Path", "source": "EMBC", "page": 102, "className": "Lamplighter", "classSource": "EMBC", "level": 2, "entries": ["Choose a path."]},
  {"name": "Path Feature", "source": "EMBC", "page": 103, "className": "Lamplighter", "classSource": "EMBC", "level": 3, "entries": ["Your path grows."]}
 ],
 "subclass": [{"name": "Path of the Wick", "shortName": "Wick", "source": "EMBC", "page": 105, "className": "Lamplighter", "classSource": "EMBC",
   "subclassFeatures": ["Path of the Wick|Lamplighter|EMBC|Wick|EMBC|2", "Wick Burst|Lamplighter|EMBC|Wick|EMBC|3"]}],
 "subclassFeature": [
  {"name": "Path of the Wick", "source": "EMBC", "page": 105, "className": "Lamplighter", "classSource": "EMBC", "subclassShortName": "Wick",
   "subclassSource": "EMBC", "level": 2, "entries": ["Lamplighters of the Wick carry one flame from town to town."]},
  {"name": "Wick Burst", "source": "EMBC", "page": 106, "className": "Lamplighter", "classSource": "EMBC", "subclassShortName": "Wick",
   "subclassSource": "EMBC", "level": 3, "entries": ["Your flame flares: each creature within 10 feet of you takes {@damage 1d6} Fire damage."]}
 ]}
JSON
cat > "$D/optionalfeatures.json" <<'JSON'
{"optionalfeature": [
  {"name": "Glow Pact", "source": "EMBC", "page": 155, "featureType": ["EI"],
   "prerequisite": [{"level": {"level": 2, "class": {"name": "Warlock"}}}],
   "entries": ["Your patron's light marks you: you can cast Light at will without expending a spell slot."]}
]}
JSON
