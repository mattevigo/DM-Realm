---
name: dmr-character
description: Player Characters in a DM Realm Workspace — create one ("a new character for Baldu", at any level), level it up or rebuild it ("Durga reaches level 6"), change its equipment, attunement, prepared spells, coins, backstory or status ("Durga attunes the belt", "Durga retires"), or transfer one from an old vault or another Workspace.
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

   **A table event is the Campaign's, not a job.** When the DM asks to record what happened at a table — an item attuned *in Session 21*, a wound, an oath — write it in that Campaign's notes, linking to the Character, and leave the Character note as it is (structure.md's "Link rules"), even when the DM says to note it "on" the Character. A job changes the Character only when the DM asks to change the Character itself.

Done when the job's own completion line holds.

## The Character note

`<characters folder>/<Character>/<Character>.md`, the Character's name in the DM's words with the name rules applied. Every heading, label and value is in the Workspace Language; the English names below are the ones to translate.

### Frontmatter

Exactly three keys, nothing else:

| Key | Value |
| --- | --- |
| `player` | Who plays the Character, as the DM names them (free text; Players are not notes) |
| `status` | `active`, `retired` or `dead` |
| `level` | The Character's level |

Keys and `status` values are translated like any term and recorded in the Translation Glossary (structure.md's "Translating a term"); an English Workspace uses them as written.

### Body

1. `# <Character name>`
2. `## Identity` — the backstory, appearance and personality: the DM's words, naming no Campaign, Session or table event.
3. `## Build` — everything the Character is made of:
   - species, class with its level and subclass, background, each a link;
   - `### Ability Scores`: the method (standard array, point buy or rolled) and a table of each ability's base score, its increases with their source, the score and the modifier;
   - `### Hit Points`: the level 1 value and each later level's roll or fixed value, as the DM chose them;
   - `### Proficiencies`: saving throws, skills (with where each comes from), armor, weapons, tools, languages;
   - `### Features`: each feature by name and level, under a link to the note it comes from (class, subclass, species, background); each feat a link;
   - `### Spells`: cantrips and spells known or prepared, each a link;
   - `### Equipment`: each item a link, with what is worn or wielded; coins; and which items are attuned.
4. `## Statistics` — the derived numbers, in one self-contained section: Armor Class, Hit Point Maximum, Hit Dice, Initiative, Speed, Proficiency Bonus, Passive Perception, saving throws, skills, attacks, spellcasting (ability, save DC, attack bonus, spell slots per level), and the uses per rest of limited features. A later spec adds a Fantasy Statblocks fence generated from this section; nothing else in the note repeats these numbers.

**Maximums only.** A Character note records what the Build allows — slots per level, the Hit Point maximum, Hit Dice, uses per rest — never what is spent: no current hit points, spent slots, conditions or checkboxes. Those are a table's state and belong to its Campaign.

### Links

- **An official option** — class, subclass, species (and a 2014 subrace), background, feat, class option, spell, item — links to its Reference note, by the path structure.md's Reference section gives it. Class and subclass are two notes and the Build links both; a 2014 subrace links beside its race; a 2024 lineage is named after the species link; a specific magic item ("+1 Longsword") links its generic variant ("+1 Weapon") and names the item in the link's text.
- **A missing Reference note** is imported with the `dmr-import` skill before the Character note links to it, one entry at a time. Its Off-Edition rules apply as they stand: an Off-Edition player option is linked only after the DM's yes.
- **A Homebrew option** links to its Homebrew note. **Campaign homebrew** — an item or spell made for one Campaign — cannot be linked where it is: follow structure.md's "A Character gaining Campaign homebrew" (say so, ask to promote it, link it once promoted, and leave it unnamed until then).
- **Write every link the Obsidian way the Workspace uses** — `[[File_Name]]` or `[[File_Name|Shown name]]`, by file name alone; by its path from the Workspace root only when two notes share that file name.

### Numbers come from the Trusted Source

Every rules value — ability score methods and point costs, hit points per level, proficiency bonus, what a level brings, spell slots, starting equipment, and the formulas of the derived numbers — comes from the Source Cache, never from memory:

- **the entries**: class (Hit Die, saving throws, proficiencies, starting equipment, features by level, spell slots, cantrips and prepared spells by level, spellcasting ability), subclass, species, background, feats, spells (which classes have a spell: `data/spells/sources.json`), items (armor's AC, a weapon's damage and properties, a magic item's bonuses and attunement);
- **the Edition's Player's Handbook text**, `data/book/book-<code>.json` (the Edition's own book, e.g. `book-xphb.json`), for character creation and advancement: ability score methods, point costs, hit points, the proficiency bonus by level, and how the derived numbers are computed. Grep it for the heading ("Standard Array", "Hit Points", "Proficiency Bonus").

Dice are the DM's: when a value is rolled — ability scores, hit points, starting wealth — the DM rolls and gives the results, and the agent never rolls.

**Recompute** every number in Statistics from the Build and these rules whenever the Build changes, item bonuses included.

### Backstory and the DM's world

A backstory may name places, NPCs and factions:

- **One with a World note** is linked.
- **One that exists only in a Campaign** cannot be linked or named (structure.md's "Link rules"). Ask the DM which they prefer and write nothing until they answer (a choice already in the request counts): promote it to World, as structure.md's "Promotion to World" says, and link the World note; or keep the backstory generic ("a harbour town") and list the dropped name in your report. It never becomes Homebrew.
