# The Import cases' Source Cache (import-cache.sh), extended with the INVENTED entries a
# Character needs: invented character creation rules filed under the Player's Handbook (2024),
# a whole Lamplighter class, species, backgrounds, feats, spells and gear (ADR 0003: no real
# Trusted Source data here). Sourced by Character case scaffolds, after workspace-setup.sh
# or a workspace fixture. Some rules differ from any real book on purpose — the standard
# array is 16, 14, 13, 11, 10, 8 and point buy has 28 points — so a Character's numbers
# prove they came from the cache.
. "$(dirname "$0")/../_fixtures/import-cache.sh"
mkdir -p "$D/book"

cat > "$D/book/book-xphb.json" <<'JSON'
{"data": [
 {"type": "section", "name": "Creating a Character", "page": 30, "entries": [
  {"type": "entries", "name": "Ability Scores", "page": 31, "entries": [
   "Generate your six ability scores with one of these methods, then assign them. Your background then increases them.",
   {"type": "entries", "name": "Standard Array", "entries": ["Use these six scores: 16, 14, 13, 11, 10, 8."]},
   {"type": "entries", "name": "Point Cost", "entries": [
    "You have 28 points to spend. Each score starts at 8 and can be at most 15 before increases.",
    {"type": "table", "colLabels": ["Score", "Cost"],
     "rows": [["8", "0"], ["9", "1"], ["10", "2"], ["11", "3"], ["12", "4"], ["13", "5"], ["14", "7"], ["15", "9"]]}]},
   {"type": "entries", "name": "Rolled Scores", "entries": ["Roll four d6 and add the three highest, six times."]},
   {"type": "entries", "name": "Ability Modifiers", "entries": ["An ability's modifier is its score minus 10, divided by 2, rounded down."]},
   "No score can go above 20 through a background or a feat."]},
  {"type": "entries", "name": "Hit Points", "page": 32, "entries": [
   "At level 1 your Hit Point maximum is the highest number on your Hit Die plus your Constitution modifier.",
   "Each level after the first adds a roll of your Hit Die, or the fixed value of half the Hit Die plus 1, plus your Constitution modifier. You have one Hit Die per level."]},
  {"type": "entries", "name": "Starting Equipment", "page": 33, "entries": [
   "Take either the equipment package of your class and of your background, or the gold each offers instead."]},
  {"type": "entries", "name": "Character Advancement", "page": 34, "entries": [
   {"type": "table", "colLabels": ["Level", "Proficiency Bonus"],
    "rows": [["1", "+2"], ["2", "+2"], ["3", "+2"], ["4", "+2"], ["5", "+3"], ["6", "+3"]]},
   "When you gain a level, you gain the features of your class for that level and one Hit Die, and your Hit Point maximum increases."]},
  {"type": "entries", "name": "Derived Numbers", "page": 35, "entries": [
   "Armor Class without armor is 10 plus your Dexterity modifier; armor sets its own formula.",
   "Initiative is your Dexterity modifier. A saving throw or skill adds your Proficiency Bonus if you are proficient in it. Passive Perception is 10 plus your Perception bonus.",
   "A spell's save DC is 8 plus your Proficiency Bonus plus your spellcasting ability modifier; your spell attack bonus is your Proficiency Bonus plus that modifier.",
   "You can be attuned to at most three magic items at once."]}
 ]}
]}
JSON

cat > "$D/class/class-lamplighter.json" <<'JSON'
{"class": [
 {"name": "Lamplighter", "source": "EMBC", "page": 100, "hd": {"number": 1, "faces": 8},
  "proficiency": ["dex", "wis"], "primaryAbility": [{"wis": true}],
  "spellcastingAbility": "wis", "casterProgression": "full",
  "cantripProgression": [1, 1, 1, 2, 2], "preparedSpellsProgression": [1, 2, 3, 4, 5],
  "startingProficiencies": {"armor": ["light"], "weapons": ["simple"],
   "skills": [{"choose": {"from": ["insight", "perception", "religion", "stealth"], "count": 2}}]},
  "startingEquipment": {"entries": ["Choose A or B: (A) {@item Lantern Pole|EMBC}, {@item Leather Coat|EMBC}, and 12 GP; or (B) 80 GP"]},
  "classTableGroups": [{"title": "Spell Slots per Spell Level", "colLabels": ["1st", "2nd", "3rd"],
   "rowsSpellProgression": [[2, 0, 0], [3, 0, 0], [4, 2, 0], [4, 3, 0], [4, 3, 2]]}],
  "classFeatures": ["Kindle|Lamplighter|EMBC|1", "Spellcasting|Lamplighter|EMBC|1",
   {"classFeature": "Lamplighter Path|Lamplighter|EMBC|2", "gainSubclassFeature": true},
   {"classFeature": "Path Feature|Lamplighter|EMBC|3", "gainSubclassFeature": true},
   "Ability Score Improvement|Lamplighter|EMBC|4", "Bright Wick|Lamplighter|EMBC|5"],
  "subclassTitle": "Lamplighter Path"},
 {"name": "Lamplighter", "source": "OLDC", "page": 60, "reprintedAs": ["Lamplighter|EMBC"], "hd": {"number": 1, "faces": 8},
  "proficiency": ["dex", "wis"], "spellcastingAbility": "wis", "casterProgression": "full",
  "classTableGroups": [{"colLabels": ["1st"], "rowsSpellProgression": [[2], [3]]}],
  "classFeatures": ["Old Kindle|Lamplighter|OLDC|1"], "subclassTitle": "Lamplighter Order"}],
 "classFeature": [
  {"name": "Kindle", "source": "EMBC", "page": 101, "className": "Lamplighter", "classSource": "EMBC", "level": 1, "entries": ["You light any wick you touch."]},
  {"name": "Spellcasting", "source": "EMBC", "page": 101, "className": "Lamplighter", "classSource": "EMBC", "level": 1, "entries": ["Wisdom is your spellcasting ability. You prepare spells from the Lamplighter spell list."]},
  {"name": "Lamplighter Path", "source": "EMBC", "page": 102, "className": "Lamplighter", "classSource": "EMBC", "level": 2, "entries": ["Choose a path."]},
  {"name": "Path Feature", "source": "EMBC", "page": 103, "className": "Lamplighter", "classSource": "EMBC", "level": 3, "entries": ["Your path grows."]},
  {"name": "Ability Score Improvement", "source": "EMBC", "page": 103, "className": "Lamplighter", "classSource": "EMBC", "level": 4, "entries": ["You gain a General feat of your choice for which you qualify."]},
  {"name": "Bright Wick", "source": "EMBC", "page": 104, "className": "Lamplighter", "classSource": "EMBC", "level": 5, "entries": ["Your Kindle can light a flame at a range of 30 feet."]},
  {"name": "Old Kindle", "source": "OLDC", "page": 61, "className": "Lamplighter", "classSource": "OLDC", "level": 1, "entries": ["You can light a candle by snapping your fingers."]}
 ],
 "subclass": [{"name": "Path of the Wick", "shortName": "Wick", "source": "EMBC", "page": 105, "className": "Lamplighter", "classSource": "EMBC",
   "subclassFeatures": ["Path of the Wick|Lamplighter|EMBC|Wick|EMBC|2", "Wick Burst|Lamplighter|EMBC|Wick|EMBC|3"]},
  {"name": "Path of the Moth", "shortName": "Moth", "source": "EMBC", "page": 107, "className": "Lamplighter", "classSource": "EMBC",
   "subclassFeatures": ["Path of the Moth|Lamplighter|EMBC|Moth|EMBC|2", "Dust Cloud|Lamplighter|EMBC|Moth|EMBC|3"]}],
 "subclassFeature": [
  {"name": "Path of the Wick", "source": "EMBC", "page": 105, "className": "Lamplighter", "classSource": "EMBC", "subclassShortName": "Wick",
   "subclassSource": "EMBC", "level": 2, "entries": ["Lamplighters of the Wick carry one flame from town to town."]},
  {"name": "Wick Burst", "source": "EMBC", "page": 106, "className": "Lamplighter", "classSource": "EMBC", "subclassShortName": "Wick",
   "subclassSource": "EMBC", "level": 3, "entries": ["Your flame flares: each creature within 10 feet of you takes {@damage 1d6} Fire damage."]},
  {"name": "Path of the Moth", "source": "EMBC", "page": 107, "className": "Lamplighter", "classSource": "EMBC", "subclassShortName": "Moth",
   "subclassSource": "EMBC", "level": 2, "entries": ["Lamplighters of the Moth follow the light wherever it wanders."]},
  {"name": "Dust Cloud", "source": "EMBC", "page": 108, "className": "Lamplighter", "classSource": "EMBC", "subclassShortName": "Moth",
   "subclassSource": "EMBC", "level": 3, "entries": ["You shake off a cloud of dust that lightly obscures a 10-foot radius around you."]}
 ]}
JSON

# Spells of the Lamplighter list (the Trusted Source's spell-to-class lookup), and the
# ones spells-embc.json lacks.
cat > "$D/spells/sources.json" <<'JSON'
{"EMBC": {
  "Spark Wick": {"class": [{"name": "Lamplighter", "source": "EMBC"}]},
  "Moth Dust": {"class": [{"name": "Lamplighter", "source": "EMBC"}]},
  "Glimmerlance": {"class": [{"name": "Lamplighter", "source": "EMBC"}]},
  "Soft Light": {"class": [{"name": "Lamplighter", "source": "EMBC"}]},
  "Whisper Veil": {"class": [{"name": "Lamplighter", "source": "EMBC"}]},
  "Cinder Bloom": {"class": [{"name": "Lamplighter", "source": "EMBC"}]}},
 "OLDC": {"Cinder Bloom": {"class": [{"name": "Lamplighter", "source": "OLDC"}]}}}
JSON
python3 - "$D/spells/spells-embc.json" <<'PY'
import json, sys
path = sys.argv[1]
data = json.load(open(path))
common = {"source": "EMBC", "time": [{"number": 1, "unit": "action"}], "components": {"v": True, "s": True},
          "duration": [{"type": "instant"}]}
data["spell"] += [
    dict(common, name="Spark Wick", page=215, level=0, school="V", range={"type": "point", "distance": {"type": "feet", "amount": 60}},
         entries=["A spark leaps to one creature you can see within range: it takes {@damage 1d8} Fire damage."]),
    dict(common, name="Moth Dust", page=216, level=0, school="C", range={"type": "point", "distance": {"type": "feet", "amount": 30}},
         entries=["A puff of dust makes one creature sneeze; it has Disadvantage on its next attack roll."]),
    dict(common, name="Soft Light", page=217, level=1, school="A", range={"type": "point", "distance": {"type": "touch"}},
         entries=["One creature you touch regains {@dice 1d8} Hit Points plus your spellcasting ability modifier."]),
]
json.dump(data, open(path, "w"))
PY

cat > "$D/races.json" <<'JSON'
{"race": [
  {"name": "Lampkin", "source": "OLDC", "page": 30, "size": ["S"], "speed": 25, "ability": [{"dex": 2}],
   "entries": [{"type": "entries", "name": "Glow", "entries": ["You shed dim light in a 5-foot radius."]}]},
  {"name": "Mothfolk", "source": "EMBC", "page": 80, "size": ["S", "M"], "speed": {"walk": 30, "fly": 30},
   "creatureTypes": ["humanoid"], "entries": [{"type": "entries", "name": "Dustwings", "entries": ["You can fly while you wear no heavy armor."]}]},
  {"name": "Emberkin", "source": "EMBC", "page": 82, "size": ["M"], "speed": 35,
   "creatureTypes": ["humanoid"], "entries": [{"type": "entries", "name": "Warm Blood", "entries": ["You have Resistance to Cold damage."]}]}
],
 "subrace": [
  {"name": "Wick", "source": "OLDC", "page": 31, "raceName": "Lampkin", "raceSource": "OLDC", "ability": [{"con": 1}],
   "entries": [{"type": "entries", "name": "Steady Flame", "entries": ["Your light never flickers, even in a gale."]}]}
]}
JSON

cat > "$D/backgrounds.json" <<'JSON'
{"background": [
  {"name": "Lantern Keeper", "source": "EMBC", "page": 60,
   "ability": [{"choose": {"weighted": {"from": ["wis", "con", "dex"], "weights": [2, 1]}}}],
   "feats": [{"night owl|embc": true}], "skillProficiencies": [{"perception": true, "insight": true}],
   "startingEquipment": [{"A": [{"item": "tinderbox|embc"}, {"value": 800}], "B": [{"value": 5000}]}],
   "entries": [{"type": "list", "style": "list-hang-notitle", "items": [
     {"type": "item", "name": "Ability Scores:", "entry": "Wisdom, Constitution, Dexterity"},
     {"type": "item", "name": "Feat:", "entry": "{@feat Night Owl|EMBC}"},
     {"type": "item", "name": "Skill Proficiencies:", "entry": "{@skill Insight} and {@skill Perception}"},
     {"type": "item", "name": "Equipment:", "entry": "Choose A or B: (A) {@item Tinderbox|EMBC}, 8 GP; or (B) 50 GP"}]},
    "You kept a town's lamps lit through the long nights."]},
  {"name": "Lamp Scholar", "source": "OLDC", "page": 127, "reprintedAs": ["Lantern Keeper|EMBC"],
   "skillProficiencies": [{"history": true, "insight": true}],
   "entries": [{"type": "list", "style": "list-hang-notitle", "items": [
     {"type": "item", "name": "Skill Proficiencies:", "entry": "{@skill History} and {@skill Insight}"}]},
    "You studied the old lamps and the wicks that burned in them."]}
]}
JSON

cat > "$D/feats.json" <<'JSON'
{"feat": [
  {"name": "Glimmerlance", "source": "EMBC", "page": 203, "category": "G", "prerequisite": [{"level": 4}],
   "entries": ["You can hurl light: once per Short Rest, make a ranged attack that deals {@damage 2d6} Radiant damage."]},
  {"name": "Night Owl", "source": "EMBC", "page": 201, "category": "O",
   "entries": ["You have Darkvision with a range of 60 feet."]},
  {"name": "Wickwright", "source": "EMBC", "page": 204, "category": "G", "prerequisite": [{"level": 4}],
   "ability": [{"choose": {"from": ["wis", "dex"], "amount": 1}}],
   "entries": ["Increase your Wisdom or Dexterity score by 1, to a maximum of 20. Your Kindle can light two wicks at once."]},
  {"name": "Lamplit Mind", "source": "LOTD", "page": 70,
   "entries": ["You can read by the faintest light, and you can't be blinded by bright light."]}
]}
JSON

cat > "$D/items-base.json" <<'JSON'
{"baseitem": [
  {"name": "Longsword", "source": "EMBC", "page": 149, "type": "M|EMBC", "rarity": "none", "weaponCategory": "martial",
   "weight": 3, "value": 1500, "dmg1": "1d8", "dmgType": "S", "dmg2": "1d10", "property": ["V|EMBC"], "mastery": ["Snare|EMBC"]},
  {"name": "Lantern Pole", "source": "EMBC", "page": 150, "type": "M|EMBC", "rarity": "none", "weaponCategory": "simple",
   "weight": 4, "value": 300, "dmg1": "1d6", "dmgType": "B", "property": ["F|EMBC"]},
  {"name": "Leather Coat", "source": "EMBC", "page": 152, "type": "LA|EMBC", "rarity": "none", "ac": 11,
   "weight": 8, "value": 1000},
  {"name": "Tinderbox", "source": "EMBC", "page": 160, "type": "G|EMBC", "rarity": "none", "weight": 1, "value": 50}
],
 "itemProperty": [
  {"abbreviation": "F", "source": "EMBC", "page": 146, "name": "Finesse",
   "entries": ["When you make an attack with a Finesse weapon, use your choice of your Strength or Dexterity modifier for the attack and damage rolls."]}
],
 "itemMastery": [
  {"name": "Snare", "source": "EMBC", "page": 216,
   "entries": ["If you hit a creature with this weapon, you can reduce its Speed by 15 feet until the start of your next turn."]}
]}
JSON
cat > "$D/items.json" <<'JSON'
{"item": [
  {"name": "Lamp of Echoes", "source": "EMBC", "page": 280, "wondrous": true, "rarity": "rare", "reqAttune": true,
   "entries": ["While you hold this lamp, you can hear anything spoken within 10 feet of its light."]},
  {"name": "Ward Lantern", "source": "EMBC", "page": 284, "wondrous": true, "rarity": "rare", "reqAttune": true,
   "bonusAc": "+1", "bonusSavingThrow": "+1",
   "entries": ["While you carry this lit lantern and are attuned to it, you gain a +1 bonus to Armor Class and saving throws."]}
]}
JSON
