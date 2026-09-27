---
name: dmr-character
description: Characters in a DM Realm Workspace — create one ("a new character for Baldu", at any level), level it up or rebuild it ("Durga reaches level 6"), change its equipment, attunement, prepared spells, coins, backstory or status ("Durga attunes the belt", "Durga retires"), or transfer one from an old vault or another Workspace.
argument-hint: <what to do, e.g. create a character for Baldu, Durga reaches level 6>
allowed-tools: Read, Glob, Grep, Write, Edit, Skill, Bash(mkdir:*), Bash(cp:*), Bash(ls:*), Bash(sh:*), Bash(python3:*), Bash(DMR_SOURCE_CACHE=*)
---

# Characters

Create, level up, rebuild, update and transfer Characters. The rules — where a Character lives, what it may link to, its past Builds, Promotion, the Edition, translation and names — are the `dmr-workspace` skill's structure.md; this skill holds the procedures and the Character note's format. Speak to the DM in the Workspace Language.

## Start

1. **Load the rules and the data.** Invoke `dmr-workspace` (read its structure.md in full), then `dmr-trusted-source`.
2. **Find the Edition and the Workspace Language in use**, as structure.md's "Fixed after Setup" reads them.
3. **Pick the job** and read its file, next to this one:

   | The DM asks for | Job |
   | --- | --- |
   | A new Character, at any level | [create.md](create.md) |
   | A level gained, or a rebuild: another species, class, background or ability scores | [level-up.md](level-up.md) |
   | A change to the Character as it is: equipment, attunement, prepared spells, coins, backstory, appearance, personality, player, or status (retired, dead, back in play) | [update.md](update.md) |
   | A Character brought in from outside this Workspace: an old vault's note or another Workspace's Character folder | [transfer.md](transfer.md) |

   **What happened at a table is no job of this skill**: an item attuned *in Session 21*, a wound, an oath follow structure.md's "What happened to a Character belongs to the Campaign too". A job starts only when the DM asks to change the Character itself.

Done when the job's own completion line holds.

## The Character note

`<characters folder>/<Character>/<Character>.md`, the Character's name in the DM's words with the name rules applied. Every heading, label and value is in the Workspace Language; the English names below are the ones to translate.

### Frontmatter

Exactly four keys, nothing else:

| Key | Value |
| --- | --- |
| `player` | Who plays the Character, as the DM names them (free text; Players are not notes) |
| `status` | `active`, `retired` or `dead` |
| `level` | The Character's level |
| `statblock` | `inline` |

`player`, `status`, `level` and the `status` values are translated like any term and recorded in the Translation Glossary (structure.md's "Translating a term"); an English Workspace uses them as written. `statblock: inline` is the plugin's flag, always English (structure.md's "Stat blocks").

### Body

1. `# <Character name>`, then the [stat block](#stat-block).
2. `## Identity` — the backstory, appearance and personality: the DM's words, naming no Campaign, Session or table event.
3. `## Build` — everything the Character is made of:
   - species, class with its level and subclass, background, each a link;
   - `### Ability Scores`: the method (standard array, point buy or rolled) and a table of each ability's base score, its increases with their source, the score and the modifier;
   - `### Hit Points`: the level 1 value and each later level's roll or fixed value, as the DM chose them;
   - `### Proficiencies`: saving throws, skills (with where each comes from), armor, weapons, tools, languages;
   - `### Features`: each feature by name and level, under a link to the note it comes from (class, subclass, species, background); each feat a link;
   - `### Spells`: cantrips and spells known or prepared, each a link;
   - `### Equipment`: each item a link, with what is worn or wielded; coins; and which items are attuned.
4. `## Statistics` — the derived numbers, in one self-contained section: Armor Class, Hit Point Maximum, Hit Dice, Initiative, Speed, Proficiency Bonus, Passive Perception, saving throws, skills, attacks, spellcasting (ability, save DC, attack bonus, spell slots per level), and the uses per rest of limited features. Nothing else in the note repeats these numbers, except the stat block derived from them.

**Maximums only.** A Character note records what the Build allows — slots per level, the Hit Point maximum, Hit Dice, uses per rest — never what is spent: no current hit points, spent slots, conditions or checkboxes. Those are a table's state and belong to its Campaign.

### Stat block

The compact view of the Character for the table, as structure.md's "Stat blocks" defines it: one ```` ```statblock ```` fence right under the `#` heading, in the `DM Realm Character` layout, written from the Build and Statistics — the same numbers, never others — and written again whenever they change. Keys and values follow structure.md's "Keys and values". In this order, leaving out a key the Character has nothing for:

| Key | Value |
| --- | --- |
| `layout` | `DM Realm Character` |
| `name` | The Character's name, unique among the Workspace's stat blocks (structure.md's "Names in the bestiary") |
| `size` | Its size (Small, Medium) |
| `species` | Its species (a 2014 subrace, a 2024 lineage named after it) |
| `class` | Its class and, once chosen, subclass: `Lamplighter (Path of the Wick)`; a multiclass lists each with its level |
| `level` | Its level, a number |
| `player` | Its player |
| `ac`, `hp`, `hit_dice`, `initiative`, `speed` | Armor Class, Hit Point maximum and initiative bonus as numbers; Hit Dice (`3d8`) and speed as text |
| `stats` | The six ability scores, in order: `[8, 14, 14, 11, 18, 10]` |
| `saves` | All six saving throws, in ability order, each `- <Ability>: <bonus>`; a proficient one's name ends with ` ●` (`- Wisdom ●: 6`) |
| `skillsaves` | Each proficient skill with its total: `- Perception: 6` |
| `senses` | Its senses, ending with its passive Perception: `darkvision 60 ft., passive Perception 16` |
| `languages` | Its languages |
| `actions` | Its attacks, weapons and attack cantrips: `- name: Lantern Pole` with `desc: +4 to hit, reach 5 ft., 1d6 + 2 Bludgeoning` |
| `spells` | Spellcasting: first the ability, save DC and attack bonus as one line, then one line per slot level, maximums only: `1st level: 4 slots` |
| `traits` | Each feature and trait by name, with a one-line summary of what it does in play |

No backstory, equipment list, full spell list or full feature text: those stay in the body. Nothing spent, as for Statistics.

### Links

- **An official option** — class, subclass, species (and a 2014 subrace), background, feat, class option, spell, item — links to its Reference note, by the path structure.md's Reference section gives it. Class and subclass are two notes and the Build links both; a 2014 subrace links beside its race; a 2024 lineage is named after the species link; a specific magic item ("+1 Longsword") links its generic variant ("+1 Weapon") and names the item in the link's text.
- **A missing Reference note** is imported with the `dmr-import` skill before the Character note links to it, one entry at a time. Its Off-Edition rules apply as they stand: an Off-Edition player option is linked only after the DM's yes.
- **A Homebrew option** links to its Homebrew note. **Campaign homebrew** — an item or spell made for one Campaign — follows structure.md's "A Character gaining Campaign homebrew".

### Numbers come from the Trusted Source

Every rules value — ability score methods and point costs, hit points per level, proficiency bonus, what a level brings, spell slots, starting equipment, and the formulas of the derived numbers — is read from the Source Cache, where `dmr-trusted-source`'s table puts it:

- **the entries**: class (Hit Die, saving throws, proficiencies, starting equipment, features, spell slots, cantrips and prepared spells by level, spellcasting ability), subclass, species, background, feats, spells and the class spell lists, items (armor's AC, a weapon's damage and properties, a magic item's bonuses and attunement);
- **the Edition's Player's Handbook text**, for character creation and advancement: ability score methods, point costs, hit points, the proficiency bonus by level, and how the derived numbers are computed.

Dice are the DM's: a rolled value — ability scores, hit points, starting wealth — is the result the DM gives.

**Recompute** every number in Statistics from the Build and these rules whenever the Build changes, item bonuses included, then write the stat block again from them.

### Backstory and the DM's world

A backstory may name places, NPCs and factions:

- **One with a World note** is linked.
- **One that exists only in a Campaign** is not named until it is in World (structure.md's "Promotion to World"). Ask the DM to choose, as a [choice](#choices): promote it to World and link the World note, or keep the backstory generic ("a harbour town") and list the dropped name in your report. It never becomes Homebrew.

## Choices

What the DM decides — an option, a method, a roll, a consent — is a choice:

- **A choice the DM's request already makes counts.**
- **Ask once, then stop.** Gather every open choice you can ask now into one message, each with its options by name from the Trusted Source, and end your turn. A choice that depends on an answer waits for that answer. Off-Edition consent (structure.md's consent rule) is asked in the same message.
- **Check each answer** against the Trusted Source rules — prerequisites, counts, the point-buy budget, the score cap — and ask again about what does not fit.
- **Write once every choice is made**; until then the Workspace stays as it is.
