# Workspace structure

How a DM Realm Workspace is organised: which folders exist, what each holds, and what each note may link to. This document is in English and independent of any Workspace Language and Edition. Terms follow [CONTEXT.md](../../CONTEXT.md); the Scope rule is [ADR 0001](../../docs/adr/0001-scope-by-top-level-folder.md), Characters as a Scope is [ADR 0004](../../docs/adr/0004-characters-are-a-scope-above-campaigns.md), World as a Scope is [ADR 0005](../../docs/adr/0005-the-dms-world-is-a-scope-apart-from-homebrew.md), what of a Character a Campaign keeps is [ADR 0010](../../docs/adr/0010-a-characters-spent-resources-are-the-campaigns.md), where official material comes from is [ADR 0003](../../docs/adr/0003-official-material-comes-only-from-5etools.md), and an Adventure the DM designs is [ADR 0020](../../docs/adr/0020-an-adventure-the-dm-designs-is-an-adventure.md).

Every folder has a **neutral key** (e.g. `reference.monsters`) and a **default English name**. Keys are English identifiers used only in this documentation and in the [Workspace Config](#workspace-config); they never appear as folder or file names. In a Workspace, the agent writes every folder and file name in the Workspace Language, translated from the default English name (see [Language and names](#language-and-names)); the eight top-level folder names can instead be set in the Workspace Config.

## Workspace root

A Workspace is a folder with the Workspace Config at its root: the Config's presence, and nothing else, makes one. Its root is the folder the DM opens in Obsidian. Every note lives inside one of the eight top-level folders; no note lives at the root.

The only other things at the root are the Workspace Config (`workspace-config.yml`, the only DM Realm file in a Workspace — [ADR 0002](../../docs/adr/0002-dm-realm-is-a-plugin-separate-from-the-workspace.md)) and dot-folders such as `.obsidian/`. They are not notes, not top-level folders, and are never translated.

- **A Config with top-level folders missing** is still a Workspace: running Setup there is a re-run, which recreates them.
- **Top-level folders without a Config** are not a Workspace: Setup refuses to run there and tells the DM the Workspace Config is missing.

## Top-level folders

| Key          | Default name | Scope       | Created | Holds                                                                    |
| ------------ | ------------ | ----------- | ------- | ------------------------------------------------------------------------ |
| `reference`  | Reference    | Reference   | Setup   | Official material imported from the Trusted Source; its rules material from the Workspace's Edition |
| `adventures` | Adventures   | Adventure   | Setup   | One folder per Adventure: an official published one, or one the DM designs |
| `homebrew`   | Homebrew     | Homebrew    | Setup   | DM-authored game material with mechanics, reused across Campaigns        |
| `world`      | World        | World       | Setup   | Story elements the DM invented and reuses across Campaigns, one folder per world |
| `characters` | Characters   | Character   | Setup   | One folder per Character, kept apart from every Campaign                 |
| `campaigns`  | Campaigns    | Campaign    | Setup   | One folder per Campaign                                                  |
| `dm_tools`   | DM_Tools     | not a Scope | Setup   | Aids for running the game that belong to no single Campaign              |
| `templates`  | Templates    | not a Scope | Setup   | Blank starting notes                                                     |

These eight are fixed: the DM may rename them — by re-running Setup, which moves the folder, rewrites the links into it and updates the Workspace Config (an edit to the Config alone takes effect at that re-run) — but may not add or remove a top-level folder. Material that seems to need a new one belongs inside an existing one (maps of a Campaign go in its Attachments, a reusable map of the DM's world in that world's Attachments, embedded in a note about the world).

Inside the top-level folders the DM is free to add, rename or remove subfolders. The subfolders documented below are the defaults the agent uses when it places a note and the DM has not organised that part differently.

## Scope

A note's Scope is the top-level folder it lives in, and nothing else ([ADR 0001](../../docs/adr/0001-scope-by-top-level-folder.md)). There is no Scope property in frontmatter. Moving a note to another top-level folder changes its Scope, and its links must then obey the new Scope's rules.

Each Adventure and each Campaign is a separate unit: "the same Adventure" means the Adventure folder the note is in, and another Adventure's notes are as foreign to it as a Campaign's.

## Link rules

A link is any wikilink, Markdown link or embed to another note or file in the Workspace, in the body or in frontmatter. An embedded query (Dataview, Bases) counts as a link to every note it can show: a note may hold one only if it may link to all of them. DM Realm never writes queries.

| From ↓ / to →            | Reference | Adventures             | Homebrew | World | Characters | Campaigns | DM Tools | Templates |
| ------------------------ | --------- | ---------------------- | -------- | ----- | ---------- | --------- | -------- | --------- |
| **Reference**            | yes       | no                     | no       | no    | no         | no        | no       | no        |
| **Adventure** (official) | yes       | its own Adventure only | no       | no    | no         | no        | no       | no        |
| **Adventure** (designed) | yes       | its own Adventure only | yes      | yes   | no         | no        | no       | no        |
| **Homebrew**             | yes       | no                     | yes      | no    | no         | no        | no       | no        |
| **World**                | yes       | no                     | yes      | yes   | no         | no        | no       | no        |
| **Character**            | yes       | yes (any)              | yes      | yes   | yes        | no        | no       | no        |
| **Campaign**             | yes       | yes (any)              | yes      | yes   | yes        | yes (any) | yes      | yes       |
| **DM Tools**             | yes       | yes (any)              | yes      | yes   | yes        | yes (any) | yes      | yes       |
| **Templates**            | no        | no                     | no       | no    | no         | no        | no       | no        |

- **Knowledge follows links.** A note that may not link to a Scope does not mention its content either, linked or not. Reference, Adventure, Homebrew and World notes never name a Campaign, a Character or anything that happened at a table; Homebrew notes never name a World note's content, and World notes never name an Adventure's. An official Adventure's notes name no Homebrew or World content; a [designed Adventure](#designed-adventures)'s may, and never name another Adventure's, official or designed. Character notes never name a Campaign, a Session or anything that happened at a table.
- **Forbidden links are refused.** When a forbidden link is asked for, the agent does not write it and says why. Without asking, it writes the fact on the side that is allowed to link, pointing the other way, and tells the DM which note it went in. That note is the one the request names on the allowed side (the Session 08 note, for "add to Fireball that the PCs first saw it in Session 08"); when the request names none, it is the Campaign's note about that thing, created in the matching default subfolder (its Places, NPCs…) when it does not exist yet. The agent asks only when it cannot tell which Campaign.
- **A name used twice is linked by its path.** Notes keep their natural names, even when another note in the Workspace has the same one (an Adventure's inn and a Campaign's note about it). A link to a note whose name is not unique in the Workspace is a path link: `[[Campaigns/Heroes/Places/Stonehill_Inn|Stonehill Inn]]`. Before creating a note whose name already exists, the agent rewrites every bare link to the older note as a path link to it.
- **"Who uses this" comes from backlinks.** Which Characters have a feat, who owns an item, which Session a monster appeared in: never written into the feat, item or monster note. The Character and Campaign notes link to it, and the target's backlinks answer the question. Only current Character notes count: a past Build (in a Character's Past_Builds) describes the Character as it was, so it never says who has something today.
- **What happened at the table belongs to the Campaign.** Events go in the Session note. A lasting change to something from another Scope — an Adventure's tavern burned down, a Setting's city conquered, a town of the DM's World sacked — goes in a Campaign note about it (e.g. in the Campaign's Places) that links to the original. The original note stays as it was.
- **What happened to a Character belongs to the Campaign too.** An item attuned in Session 21, a wound, an oath: the agent writes it in that Campaign's notes (usually the Session note), linking to the Character, and leaves the Character note unchanged, even when asked to note it "on" the Character. The Character's backlinks give its history. The Character note changes on two occasions only, and even then it names no Campaign or Session: when the DM asks to change the Character itself — its identity, its backstory, or its Build (a level gained, an item added to its equipment) — and at a Session's Consolidation, below.
- **A Character's Build and its spent resources are kept apart** ([ADR 0010](../../docs/adr/0010-a-characters-spent-resources-are-the-campaigns.md)). Its own items, coins and attunement are its Build: at a Session's Consolidation the agent shows the lasting changes that Session made to them (a sword found, 40 gp spent, a belt attuned) and, on the DM's yes, edits the Build, while the Session note keeps the event. What it has spent and the treasure the party holds in common are that table's, in the Campaign's [Party State](#campaigns--campaigns), never on the Character note, whenever they are recorded.

## Folders

For each folder: its neutral key, default English name, when it is created (see [Folder creation](#folder-creation)), and what lives there. Every subfolder has the Scope of its top-level folder. `<…>` stands for a name that varies: one the DM chooses, or a published Adventure's title.

### Reference — `reference`

Official material, imported faithfully from the Trusted Source. Its rules material is of the Workspace's Edition, plus any Off-Edition Material that fills a gap; Setting lore comes from any book (see [Edition](#edition)). Every official entry has one home: Reference, or its Adventure for what only that Adventure describes — one note in each Adventure that describes it (see [Adventures](#adventures--adventures)); material an Adventure reprints from another book is linked, not copied.

| Key                                  | Default name      | Created    | Holds                                                                                  |
| ------------------------------------ | ----------------- | ---------- | -------------------------------------------------------------------------------------- |
| `reference.rules`                    | Rules             | first note | Official rules: Rules Glossary entries, optional and variant rules, statuses, senses, skills |
| `reference.rules.conditions`         | Conditions        | first note | Conditions, one note each                                                              |
| `reference.rules.actions`            | Actions           | first note | Actions (Dash, Grapple…), one note each                                                |
| `reference.classes`                  | Classes           | first note | One folder per class, and the class options                                            |
| `reference.classes.<class>`          | `<Class name>`    | first note | The class note and one note per subclass                                               |
| `reference.classes.options`          | Options           | first note | One subfolder per kind of class option                                                 |
| `reference.classes.options.<kind>`   | `<Kind>` (e.g. Eldritch_Invocations, Maneuvers) | first note | Class options of that kind, one note each                |
| `reference.species`                  | Species (2024) / Races (2014) | first note | One folder per species (race in 2014)                                      |
| `reference.species.<species>`        | `<Species name>`  | first note | The species note and, in 2014, one note per named subrace                              |
| `reference.backgrounds`              | Backgrounds       | first note | Backgrounds                                                                            |
| `reference.feats`                    | Feats             | first note | Feats                                                                                  |
| `reference.spells`                   | Spells            | first note | One subfolder per spell level and the [Spell Indexes](#spell-indexes), and nothing else |
| `reference.spells.cantrips`          | Cantrips          | first note | Cantrips                                                                               |
| `reference.spells.level_1` … `_9`    | Level_1 … Level_9 | first note | Spells of that level                                                                   |
| `reference.equipment`                | Equipment         | first note | Weapons, armor, tools, gear                                                            |
| `reference.equipment.weapon_masteries` | Weapon_Masteries | first note | Weapon Mastery properties (2024 only; in a 2014 Workspace only as Off-Edition Material) |
| `reference.magic_items`              | Magic_Items       | first note | Magic items                                                                            |
| `reference.monsters`                 | Monsters          | first note | Every official stat block, including one printed only in an Adventure                  |
| `reference.setting`                  | Setting           | first note | Lore of official Settings — geography, pantheon, history — one subfolder per Setting   |
| `reference.attachments`              | Attachments       | first file | The images its notes embed ([Attachments](#attachments))                                |

**One note per entry.** An Import brings one Trusted Source entry into one note, in the folder of its kind:

- **Rules.** Conditions go in Rules › Conditions and actions in Rules › Actions. Every other entry of the rules data — Rules Glossary entries, optional and variant rules, statuses (Bloodied, Concentration, Surprised), senses, skills — goes directly in Rules. Diseases, traps and hazards are not imported.
- **Classes.** The class note, Classes › `<Class>` › `<Class>`, holds the class table and every class feature to level 20, including the optional class features the class lists from another book, each headed with that book and page ("(optional; TCE p. 42)"); its source property stays the class's own book. Each subclass is its own note beside it, holding only what the subclass adds. Importing a subclass on its own creates its class's folder but not the class note.
- **A 2014 subclass listed again under the 2024 class** (the Trusted Source copies every 2014 subclass there) still has its own book's Edition: in a 2024 Workspace it is Off-Edition Material, and its note goes in the folder of the Edition's class.
- **Class options** — Fighting Styles (2014), Maneuvers, Eldritch Invocations, Metamagic and the other kinds — are one note each in Classes › Options › `<Kind>`. 2024 Fighting Styles are feats, in Feats. A class or subclass note names its options in plain text; importing it does not import them.
- **Species.** The same pattern as classes: Races › Dwarf › Dwarf, and beside it one note per named 2014 subrace (Hill_Dwarf), holding only what the subrace adds. An unnamed 2014 subrace is part of its race's note. 2024 species have no subraces: a lineage is part of its species' note, so asking for a 2024 lineage (Drow) imports its species (Elf).
- **Magic items.** A specific item the Trusted Source builds from a generic variant and a base item ("+1 Longsword", "Flame Tongue Greatsword") is not an entry: asking for one imports the generic variant ("+1 Weapon", "Flame Tongue") into Magic_Items, and the agent says so ([ADR 0007](../../docs/adr/0007-an-import-renders-only-what-the-data-contains.md)). Its DMG or XDMG version follows the Edition like any other entry. An item whose source is an Adventure is not Reference: it goes to that Adventure's Items ([Adventures](#adventures--adventures)).
- **Descriptions and images.** An entry's description — the Trusted Source's text about what it is, its "fluff" — is imported with it, into the same note, and so is every image the entry shows ([Imported notes](#imported-notes)).
- **One entry at a time.** The one set an Import brings in on request is every Condition, or every Action, of the Edition, one note each; any other bulk request is declined. The monsters and items an Adventure's Part names may also come in with it, on the DM's one yes ([Importing an Adventure](#importing-an-adventure)).
- **No links between Reference notes.** A note names other entries (a monster's spells, a class's options) in plain text, so it never depends on what else was imported. The only notes that link are the [Spell Indexes](#spell-indexes), which list only what is there. The one text that depends on what else was imported is a spell's [Classes line](#spell-indexes), which names a class from a book other than a core book only once Reference holds that class; DM Realm keeps it ([ADR 0016](../../docs/adr/0016-a-spells-classes-line-follows-references-classes.md)).

The note's own format is in [Imported notes](#imported-notes).

#### Spell Indexes

Notes in Spells, beside the level folders, listing Reference's spell notes by level — a section per level folder, headed with the folder's name, Cantrips first, each spell a link by its name:

- **One of every spell**, named after the folder: `Spells/Spells.md`, `Incantesimi/Incantesimi.md`.
- **One per class**, named after the folder and the class: `Spells_Wizard.md`, `Incantesimi_Mago.md`. It lists the spells whose note names that class, so a class has an index once one of its spells is imported, and only the imported ones are in it.

**The Classes line.** A spell note ends its own text — before its Description, when it has one — with the classes whose spell list has the spell, as the Trusted Source gives them: `**Classes:** Sorcerer, Wizard`. The label is the Glossary's term for Classes, the same as the folder's, and each class its Glossary term: `**Classi:** Mago, Stregone`. A spell on no class's list has no such line. The classes it names ([ADR 0016](../../docs/adr/0016-a-spells-classes-line-follows-references-classes.md)):

- **Every class of a core book** — a book the Trusted Source puts in its `core` group (the core rulebooks; of those, only the Player's Handbooks have classes) — whose list has the spell, in either Edition.
- **A class of any other book** only once Reference holds that class: its class note (the note named as its class folder) is that class, by English name, from that book, by its source property. So a Setting book's own classes (*World of Warcraft*'s Mage, Evoker…) stay out of every Workspace that has not imported them, while an imported Artificer is named on its spells.

It follows what Reference holds, so DM Realm keeps it as it keeps the indexes: `dmr-import`'s `spell-classes.py` helper rewrites every spell's line — adding, changing or removing it — after an Import writes a spell or a class note, at a Setup re-run, and whenever the DM asks to bring the Spell Indexes up to date. Never edit it by hand. A class note deleted outside DM Realm leaves its class in the lines until the next refresh.

The indexes are not imported, so they have no frontmatter, and they list Reference's spells only — never Homebrew's.

DM Realm keeps them, not the agent and not the DM: the `spell-index.py` helper next to this file writes them again from the spell notes on disk, and the plugin's hook runs that helper after every spell note written and every shell command. So an Import, a re-import, a renamed or deleted spell all leave them right. Never edit one by hand; after writing spell notes, run the helper and report what it says:

```sh
python3 "<the dmr-workspace skill's base directory>/spell-index.py" rebuild .
```

### Adventures — `adventures`

One folder per Adventure, holding its content, never what happened at a table. An Adventure is of one of two kinds ([ADR 0020](../../docs/adr/0020-an-adventure-the-dm-designs-is-an-adventure.md)):

- **Official**: a published Adventure, imported from the Trusted Source a Part at a time, as its book describes it ([Importing an Adventure](#importing-an-adventure)).
- **Designed**: one the DM designs, written in the DM's words, and the DM's to change at any time ([Designed Adventures](#designed-adventures)).

Both have the folders below, and a Campaign runs either the same way: whole or in part, down to a single Part, listed in its README's Adventures Run. **An Adventure is official when its README has a [source property](#source-property)**, as every note of it does; any other Adventure folder is designed, one the DM made by hand included.

| Key                             | Default name     | Created    | Holds                                                         |
| ------------------------------- | ---------------- | ---------- | ------------------------------------------------------------- |
| `adventures.<adventure>`        | `<Adventure title>` | first note | One Adventure                                              |
| `adventures.<adventure>.readme` | README (a note)  | first note | An official Adventure's title, book, level range and Parts ([The README](#the-readme)); a designed one's sections ([Designed Adventures](#designed-adventures)) |
| `adventures.<adventure>.parts`  | Parts            | first note | One note per Part: an official Adventure's imported Part, what of it no other note holds; a designed one's in [the Part format](#designed-adventures) |
| `adventures.<adventure>.places` | Places           | first note | Its locations                                                 |
| `adventures.<adventure>.npcs`   | NPCs             | first note | Its NPCs                                                      |
| `adventures.<adventure>.items`  | Items            | first note | Items it introduces (unique items, plot items, its treasure)  |
| `adventures.<adventure>.encounters` | Encounters   | first note | Its encounters                                                |
| `adventures.<adventure>.attachments` | Attachments | first file | Its maps and the other images its notes embed ([Attachments](#attachments)) |

Monster stat blocks are the one exception: a monster printed in an official Adventure — even one that appears in no other book — goes to Reference Monsters, and the Adventure's NPC and Encounter notes link to it. An NPC the Adventure changes ("a bandit captain with 90 hit points") gets a stat block that extends that monster ([Stat blocks](#stat-blocks)). An item the Adventure reprints from a core book (a DMG magic item in its treasure) stays in Reference Magic_Items and is linked. A designed Adventure's own monsters are Homebrew monsters ([Designed Adventures](#designed-adventures)).

**An item the Adventure introduces** — one whose source is the Adventure's — is always in that Adventure's Items, even when it is imported on its own ("add the Sunsword"): that Import creates the Adventure's folder and [README](#the-readme) with it. It is imported like any entry ([Imported notes](#imported-notes)), never into Reference.

An NPC, place or item that appears in two published Adventures has one note in each Adventure, each as its own book describes it; neither links to the other.

**An Import writes only into an official Adventure.** When the folder an official Adventure's title gives already holds a designed Adventure, the Import — of a Part, or of an item the Adventure introduces — writes nothing, says so, and asks the DM to rename one of the two; a rename moves the folder and rewrites the links into it.

#### Importing an Adventure

An official Adventure is imported a [Part](../../CONTEXT.md) at a time: one Import brings one or more Parts, and the whole Adventure is every Part.

- **One note per book heading.** Each note in Places, NPCs, Encounters or Items is exactly one heading of the book with everything under it, its text unchanged and in book order. The agent chooses which headings get a note, and the folder: a location (an inn, a keyed area of a dungeon) in Places, an event or an encounter (a timed event, random encounters) in Encounters, an item described under its own heading in Items. An item the Trusted Source has as an entry is imported as that entry instead (found by its path, like an item imported on its own), and its heading stays in the Part note, linking to it. A heading inside another note's heading may have its own note too: the outer note then links to it where it stood.
- **NPCs.** An NPC has a note only when the book gives it a heading of its own; that note links to its Reference monster as the [Adventure NPC](#which-notes-have-one) row says. An NPC the book describes inside other text stays in that text.
- **The Part note**, in Parts, holds the rest of the Part — its opening, its advice on running it, all the text no other note holds — in book order, and links to each of the Part's other notes where its heading stood. It is named after the Part, as the book titles it.
- **A Part is imported when its Part note exists and is not empty** — a link into the Part may have made an empty one. The Import writes the Part note last, after the Part's other notes. Asking again for an imported Part writes nothing and says so; replacing it is the [update check](#checking-for-updates). An Import that stopped midway resumes, skipping the notes already written.
- **Names are unique within one Adventure**, across all its subfolders, so that two of its notes never name the same Attachments file: a heading whose name another note of the Adventure already has is qualified by the note it sits in (`Stonehill_Inn_Treasure`). Otherwise a note's name is its heading's, translated, with the [name rules](#name-rules) applied.
- **A note is found by its section id**: the book's id for its heading, which its [source property](#source-property) records (`CoS p. 41, v2.36.1, #1a2`). The update check and a resumed Import find an Adventure note by it, not by its path.
- **Links reach notes not imported yet** ([ADR 0013](../../docs/adr/0013-an-adventure-note-links-to-what-is-not-imported-yet.md)). A creature the book names links to its Reference Monsters note — the Edition's version, as [Off-Edition Material](#off-edition-material) says — and an item to its Reference note, or to this Adventure's Items for one the Adventure introduces, always as path links. An area of the same Part links to the note, or the heading, that holds it; an area of another Part links to that Part's note. Each is written whether or not its target is in the Workspace yet, and works once the target is imported: these are the only links in a Workspace to a note that may not exist. Spells, conditions and every other name stay plain text.
- **What the Part names comes along on one yes.** Before writing, the Import tells the DM which Parts it brings, how long they are, how many images they show and how large, and how many of the monsters and items they name the Workspace lacks, and asks once whether to import those too. On a yes they come in as one batch, the one exception to [never in bulk](#off-edition-material); player options never do. On a no their links are written all the same.

#### The README

An official Adventure's README is written with the Adventure's first note — a Part, or an item imported on its own — and kept current by every Import. It holds only what the Trusted Source's list of Adventures gives, and nothing the agent writes: the data has no premise or summary, which stay in the book's own Parts.

- **Frontmatter**: the Adventure's source property, with no page (`CoS, v2.36.1`).
- **Body**: the title as a `#` heading; a Book line, its book code and year (`**Book:** CoS, 2016`); a Levels line, its level range (`**Levels:** 1–10`); then a Parts section, one numbered line per Part in book order, each as the book titles it, its ordinal first (`Chapter 1: Into the Mists`), and a link to its Part note once it is imported. The labels are translated like any term.

An Adventure's first Import also turns each plain mention of it in a Campaign README's Adventures Run into a link to this README, keeping the DM's words as the link's text. A mention that might be another Adventure stays as it is, and the Import names it in its report. Besides the Reference notes and Translation Glossary rows any Import adds, it is the one note outside the Adventure that importing one changes.

#### Designed Adventures

An Adventure the DM designs: a story any table could run, with no table in it. Which plot is an Adventure is the DM's call, by how they ask: one they design as an Adventure is one; a plot they write for one table stays its Campaign's ([Campaigns](#campaigns--campaigns)). It knows the rules, the DM's Homebrew and the world it is set in, and no table ([Link rules](#link-rules)).

- **Its folder** is named after its title, in the DM's words: not translated and not in the Translation Glossary, with the [name rules](#name-rules) applied. When an Adventure folder of that name already exists, official or designed, the agent writes nothing, names it, and asks for another name; a new Adventure never merges into or replaces one. Its notes' names are the DM's words too, unique within the Adventure across its subfolders, as an official Adventure's are.
- **No source property** on any of its notes, the README included. Nothing re-imports it and the [update check](#checking-for-updates) never reaches it: the DM edits it as they like.
- **The README** is its first note: `# <title>`, in the DM's words, then these sections in this order, each a `##` heading in the Workspace Language, each written only once the DM has given it:

  | Section | Holds |
  | --- | --- |
  | Pitch | The premise, in one to three sentences |
  | Level Range | The levels it is for (`3–5`) |
  | Length | Roughly how many Sessions it runs |
  | World | The world it is set in, named as a Campaign README's World names one (`Orsenna — World › Orsenna`); none, for an Adventure set in no world in particular |
  | Tone | Its themes and tone |
  | Hook | What draws a party in |
  | Parts | One numbered line per Part in the order it is meant to be played, each a link to its Part note and one line on it |

- **A Part note**, in Parts, is named after the Part in the DM's words and has these sections, `##` headings in the Workspace Language, as the [Adventure_Part Template](#templates--templates) gives them:
  - **Summary**: what happens in the Part.
  - **Structure**: its scenes or nodes, and how they connect.
  - **Clues**: each conclusion the party must reach, then the notes that give it — three, as the three-clue rule asks, or as many as the DM has written so far.
  - **Ways out**: how the Part leads to the next ones.

  Its Places, NPCs, Encounters and Items are notes of their own in the Adventure's folders, linked from the Part note where it names them; a place or an NPC note is made from its [Template](#templates--templates), as a Campaign's is.
- **Its mechanics** follow an official Adventure's split. An item it introduces is a note in its Items, an [item note](#item-notes) like any other. A monster it introduces is a Homebrew monster, in Homebrew › Monsters, and its NPC and Encounter notes link to it; its NPCs' statistics are as the [Adventure NPC](#which-notes-have-one) row says. The rules material it names — a monster, a spell, an encounter's difficulty — follows the Workspace's [Edition](#edition), and every official rule it relies on comes from the Trusted Source.
- **Its maps and images** are the files the DM gives, in its Attachments, embedded where a note shows them. The agent never makes one.
- **Ideas** for it are checked as [Ideas](#ideas) says for a designed Adventure, and only the ones the DM keeps are written.

### Homebrew — `homebrew`

DM-authored game material with mechanics, meant to be reused across Campaigns: rules, classes, species, backgrounds, feats, spells, items, monsters. Only material with mechanics is Homebrew: a story element with none — a place, an NPC, a faction, a god — is [World](#world--world), and an aid only the DM uses to run the game is DM Tools. Homebrew made for one Campaign belongs to that Campaign (see [Campaigns](#campaigns--campaigns)).

It mirrors Reference's rules type folders — Classes, Species (Races in 2014), Backgrounds, Feats, Spells (with the same level subfolders), Equipment (with Weapon_Masteries), Magic_Items, Monsters — under the keys `homebrew.<type>`, with House Rules in place of Rules:

| Key                   | Default name | Created    | Holds                                                                         |
| --------------------- | ------------ | ---------- | ----------------------------------------------------------------------------- |
| `homebrew.house_rules`| House_Rules  | first note | Changes to the official rules; they apply to every Campaign in the Workspace  |
| `homebrew.<type>`     | as Reference | first note | The DM's own material of that type                                            |
| `homebrew.attachments`| Attachments  | first file | The images its notes embed ([Attachments](#attachments))                      |

Every Homebrew subfolder is created by its first note or file; an empty Workspace has none.

Homebrew never links to or names World, so it stays usable in any world: a homebrew spell granted by an invented god says nothing of the god; the god's World note links to the spell.

### World — `world`

The story elements the DM invented and reuses across Campaigns — places, NPCs, factions, pantheon, history — of a world the DM invented, or added to an official Setting. No mechanics (those are Homebrew) and no table's story (that is a Campaign's). A Setting's lore has three homes: the official lore is Reference Setting, the DM's own is World, and how a Campaign has changed either belongs to that Campaign.

| Key                     | Default name   | Created    | Holds                                              |
| ----------------------- | -------------- | ---------- | -------------------------------------------------- |
| `world.<world>`         | `<World name>` | first note | One world, and notes about the whole of it (an overview) |
| `world.<world>.places`  | Places         | first note | Its places, one note each                          |
| `world.<world>.npcs`    | NPCs           | first note | Its NPCs                                           |
| `world.<world>.factions`| Factions       | first note | Its factions and organisations                     |
| `world.<world>.pantheon`| Pantheon       | first note | Its gods                                           |
| `world.<world>.history` | History        | first note | Its eras and events                                |
| `world.<world>.attachments` | Attachments | first file | Its maps and the other files its notes embed ([Attachments](#attachments)) |

- **A world's folder name.** A world the DM invented is named in the DM's words: not translated and not in the Translation Glossary, with the [name rules](#name-rules) applied — Aerth is `Aerth/` in every Workspace Language. The DM's additions to an official Setting use the name that Setting's subfolder has in Reference › Setting (or would have, as [Translating a term](#translating-a-term) gives it), so the two sit side by side: a town the DM invented in the Forgotten Realms is World › Forgotten_Realms › Places, while the official lore stays in Reference › Setting › Forgotten_Realms.
- **Links point into World, never out of it to a table** (see [Link rules](#link-rules)). A Character's backstory links to the World place it comes from; the place does not name the Character. What a Campaign did to a World place is written in that Campaign, linking to it.
- **An invented villain is split.** Who they are is an NPC note in World; their stat block is a monster in Homebrew › Monsters. The World note links to the stat block, never the other way.
- **A Campaign's place, NPC or faction becomes World** by [Promotion](#campaigns--campaigns), when another Campaign or a Character's backstory needs it.

### Characters — `characters`

One folder per Character: a player's character, kept apart from every Campaign so it can play in any of them. A Character note holds its identity and current Build, and none of any table's story (see [Link rules](#link-rules)). NPCs are never Characters.

| Key                                  | Default name                 | Created             | Holds                                                         |
| ------------------------------------ | ---------------------------- | ------------------- | ------------------------------------------------------------- |
| `characters.<character>`             | `<Character name>`           | with its note       | One Character                                                 |
| `characters.<character>.note`        | `<Character name>` (a note)  | with its folder     | The Character: identity and current Build                     |
| `characters.<character>.past_builds` | Past_Builds                  | first past Build    | Its past Builds, one note each: `<Character name>_<NN>.md`, numbered from 01 in the order they were kept |
| `characters.<character>.attachments` | Attachments                  | first file          | Its portrait, a PDF export of the Character and other non-note files |

- **A Character's name is the DM's words**: not translated and not in the Translation Glossary, with the [name rules](#name-rules) applied: Durga's folder and note are `Durga/` and `Durga.md` in every Workspace Language.
- **One Character, one current Build.** Before a level-up or rebuild, the current Build is kept as a past Build (`Past_Builds/Durga_01.md`, then `Durga_02.md`). A one-shot that plays Durga at another level uses a separate Character.
- **The Character note's format** is the `dmr-character` skill's.

### Campaigns — `campaigns`

One folder per Campaign: everything that happens at that table, and everything made only for it.

| Key                               | Default name       | Created           | Holds                                                    |
| --------------------------------- | ------------------ | ----------------- | -------------------------------------------------------- |
| `campaigns.<campaign>`            | `<Campaign name>`  | Campaign start    | One Campaign                                             |
| `campaigns.<campaign>.readme`     | README (a note)    | Campaign start    | Overview, in the `dmr-campaign` skill's format: among others its world, the Adventures it runs and its party (linking to its Characters) |
| `campaigns.<campaign>.npcs`       | NPCs               | Campaign start    | NPCs as they are in this Campaign                        |
| `campaigns.<campaign>.sessions`   | Sessions           | Campaign start    | One note per Session, with its prep, Live Notes and recap |
| `campaigns.<campaign>.places`     | Places             | Campaign start    | Places as they are in this Campaign                      |
| `campaigns.<campaign>.quests`     | Quests             | Campaign start    | Quests                                                   |
| `campaigns.<campaign>.factions`   | Factions           | Campaign start    | Factions                                                 |
| `campaigns.<campaign>.attachments`| Attachments        | Campaign start    | Images, maps, handouts and other non-note files          |
| `campaigns.<campaign>.diary`      | Diary (a note)     | first entry       | The Campaign's Sessions in play order, an entry each     |
| `campaigns.<campaign>.party_state`| Party_State (a note) | first written   | Where the party stands now: each Character's spent resources, and the treasure held in common |
| `campaigns.<campaign>.chronicle`  | Chronicle          | first Chapter     | The Campaign told as prose for its players: one Chapter per consolidated Session, and its Voice |
| `campaigns.<campaign>.chronicle.voice` | Voice (a note) | first instruction kept | The DM's narration instructions for this Campaign's Chapters |
| `campaigns.<campaign>.homebrew_<type>` | Homebrew_`<Type>` (e.g. Homebrew_Spells) | first note | Homebrew made for this Campaign only: one folder per Homebrew type, with that type's subfolders (Homebrew_Spells › Level_3) |
| `campaigns.<campaign>.homebrew_house_rules` | Homebrew_House_Rules | first note | House Rules for this Campaign only: they apply to it alone, until Promotion moves them to Homebrew › House_Rules |

- **Anything else the Campaign needs** goes in a subfolder the DM adds (e.g. Handouts). Notes about running this one Campaign — the DM's personal notes, a to-do board — live here, not in DM Tools: in the DM's subfolder for them, or, when there is none, at the Campaign root next to the README.
- **The `Homebrew_` prefix** is the name the Homebrew top-level folder has in use, then `_` and the type's folder name in the Workspace Language: `Homebrew_Incantesimi` in Italian, `Brew_Spells` when the DM named Homebrew `Brew`. The whole name is not a Translation Glossary row. When a Setup re-run renames Homebrew, it renames every Campaign's prefixed folders with it.
- **A plot the DM writes for this table is the Campaign's**, in its Quests, Places, NPCs and Factions: it reaches World, or a new Adventure, only by Promotion. So is a change the DM makes to an Adventure it runs (their own dungeon in place of chapter 3), as [What happened at the table belongs to the Campaign](#link-rules) says. Only a plot the DM designs as an Adventure, for any table, is one ([Designed Adventures](#designed-adventures)).
- **A Session is any note under the Campaign's Sessions folder**, whatever its name, and belongs to that Campaign alone. Its format is the Session [Template](#templates--templates)'s: the `number` and `date` properties, the Present line linking the Characters who played, then Prep, Live Notes, Recap and Loose threads. Its name follows the [name rules](#name-rules).
- **Live Notes are kept word for word.** What the DM wrote while the Session was played is never rewritten, summarised or deleted, and it is the only source of the Recap: Prep is what was planned, not what was played. MapForge's Table Record of the Session joins them, after the DM's own words, one subsection per MapForge Session Log marked `%% mapforge <log file> %%`, and is Live Notes from then on ([ADR 0012](../../docs/adr/0012-the-table-record-enters-a-session-as-its-live-notes.md)).
- **A Side Session** is a Session of the same Campaign played outside its numbered run, often with only some of its Characters (the Present line says which). Its note drops the `number` property, is named in the DM's words, and takes its place among the others by its `date`. The next Session's number is the highest number in use plus one, counting only numbered Sessions and starting at 01, so a Side Session never shifts the run. A side story that grows its own party and Sessions is another Campaign.
- **The Diary** is one note at the Campaign root, an entry per Session in `date` order: the Session's number (a Side Session's name), its date, a link to the Session note and one or two sentences. The detail stays in the Session's Recap, and the README still names no Session. A Session is consolidated when the Diary has its entry, which Consolidation writes last.
- **Party State** is one note at the Campaign root: a section per Character of the party, linking to it, with its current hit points, spent spell slots, spent class uses and conditions, and a Party treasure section for the coins and items the party holds in common. It holds the current state only: a change overwrites the Character's section, and the history is in the Session notes. A Character who plays in two Campaigns has a section in each one's Party State. An item a Character takes from the Party treasure leaves it for that Character's Build, as [the link rules](#link-rules) say.
- **The Chronicle** tells the Campaign as prose for its players, a Chapter per Session, written by the `dmr-session-narrate` skill once the Session is consolidated. A Chapter is a Campaign note and links as the Campaign may; the line under its heading links to its Session, and the Session note does not link back: its backlinks show its Chapter. A Chapter tells only what the party saw or learned, faithful to its Session's Live Notes and Recap, the Live Notes winning where the two disagree. Only the telling is invented — the setting, light and sound, the mood, the pace, the wording of a line the notes record — never an event or an outcome (no fight, find, meeting, wound or death the notes do not give, and none ending differently), nor what a Character decides, thinks or feels beyond what its player gave it at the table. A Character missing from the Session's Present line is not in its Chapter, and its absence is explained only as the Live Notes explain it. A Side Session's Chapter takes its place among the others by its Session's `date`.
- **The Voice** is one note in the Chronicle: the DM's narration instructions for that Campaign, in the DM's words, one per line, which the DM may also edit by hand. It holds only what the DM asked for, never the skill's default telling. It is created when the DM first asks to keep an instruction; one given for a single Chapter is not written into it. It may change any way of telling — person, tense, length, game mechanics, links — and open up what only the DM knows; it never lifts the rule above on what is invented.
- **The party is linked, not kept here.** A Campaign has no Characters folder: its Characters live in the Characters folder, and the Campaign's README lists its party by linking to them.
- **Promotion.** When Campaign homebrew is wanted outside its Campaign, the agent first shows the DM a preview — which notes move, where to, and what is stripped from each — and promotes on a yes; a request that already says to use the homebrew elsewhere ("I want the ring in my Villains campaign too") is the go-ahead. It moves each note — its stat block intact, an item its `item: true` — to the matching Homebrew folder (its [Portrait](#the-portrait) moves with its picture or is dropped), removes every link to and mention of the first Campaign — and of its Characters — from it (anything worth keeping moves into that Campaign's notes), and updates the links to it.
- **The chain moves together.** Promotion moves every Campaign-only homebrew note the promoted note links to or names, and every one those link to or name, in the same preview. A dependency on a Campaign place, NPC or faction is not part of the chain: it is a separate Promotion to World, asked for on its own.
- **A name clash in the target folder.** When the Homebrew folder already has a note with the same name: if the two notes' mechanics are identical, the homebrew is already promoted, and on the DM's yes the agent repoints the links to the Homebrew note and deletes the Campaign copy; otherwise it writes nothing and asks the DM for another name.
- **Promotion to World.** When a Campaign's Places, NPCs or Factions note is wanted by a second Campaign, by a Character's backstory or by a [designed Adventure](#designed-adventures) that wants it in its own story (neither of which can link to a Campaign; a fact of what happened at the table stays the Campaign's, as [Forbidden links are refused](#link-rules) says), the agent asks the DM to promote it to World; on a yes it moves the note to the matching World folder (World › `<world>` › Places, NPCs or Factions, in the world the Campaign is set in, as its README's World section names it — the agent asks when it cannot tell), removes from it every link to and mention of the Campaign, its Characters and its Sessions, as for Homebrew (anything worth keeping moves into that Campaign's notes), and updates the links to it. An NPC's mechanics — its stat block — do not go to World: they become a Homebrew Monsters note that the World note links to. Until then the note stays in the Campaign, and a Character or a designed Adventure does not name it.
- **Promotion to an Adventure.** When the DM wants a Campaign's plot — its Places, NPCs, Quests or Factions notes — to be runnable by another table, the agent shows a preview and promotes on a yes, as for Homebrew — a request that already says another table will run it is the go-ahead. It creates a [designed Adventure](#designed-adventures) with the title the DM gives (asking for one when the request has none) and a README holding only that title, and moves each note into the Adventure's folder of the same kind — Places, NPCs, or a Quests or Factions subfolder created for it — removes every link to and mention of the Campaign, its Characters and its Sessions, as for Homebrew (anything worth keeping moves into that Campaign's notes), and updates the links to it. The Campaign-only homebrew the notes depend on comes along in the same preview: a monster to Homebrew › Monsters, an item to the Adventure's Items. Then it offers to list the Adventure in the Campaign's Adventures Run.
- **A Character gaining Campaign homebrew** (an item it now carries, a spell it learns) cannot link to it where it is. The agent says so and asks the DM to promote it; on a yes it promotes it as above and the Character note links to the Homebrew note. Until then the Character note does not name it; the Campaign's notes record who holds it.

### DM Tools — `dm_tools`

Aids for running and preparing the game, reusable across Campaigns. Not a Scope.

| Key                             | Default name                  | Created           | Holds                                                         |
| ------------------------------- | ----------------------------- | ----------------- | ------------------------------------------------------------- |
| `dm_tools.translation_glossary` | Translation_Glossary (a note) | first entry       | The Translation Glossary (see [Language and names](#language-and-names)) |
| `dm_tools.checklists`           | Checklists                    | first note        | Prep and session checklists                                   |
| `dm_tools.random_tables`        | Random_Tables                 | first note        | Random tables (names, encounters, weather, loot…)             |
| `dm_tools.attachments`          | Attachments                   | first file        | Files no note embeds (a reusable map of no world, a handout) and the files DM Tools notes embed |

### Templates — `templates`

Blank starting notes, copied when a new note is created. Not a Scope. There is one for each kind of note that no skill formats; Characters, imported notes, the Campaign README and Chapters have none, since their skills give their format.

| Key                          | Default name               | Created     | Holds                                         |
| ---------------------------- | -------------------------- | ----------- | --------------------------------------------- |
| `templates.session`          | Session (a note)           | first Setup | A Session: its properties, who was present, prep, Live Notes and recap |
| `templates.npc`              | NPC (a note)               | first Setup | An NPC                                        |
| `templates.place`            | Place (a note)             | first Setup | A place                                       |
| `templates.faction`          | Faction (a note)           | first Setup | A faction                                     |
| `templates.quest`            | Quest (a note)             | first Setup | A quest                                       |
| `templates.house_rule`       | House_Rule (a note)        | first Setup | A House Rule                                  |
| `templates.homebrew_spell`   | Homebrew_Spell (a note)    | first Setup | A homebrew spell                              |
| `templates.homebrew_item`    | Homebrew_Item (a note)     | first Setup | A homebrew item                               |
| `templates.homebrew_monster` | Homebrew_Monster (a note)  | first Setup | A homebrew monster, with empty [statistics](#stat-blocks) in the Workspace's form |
| `templates.adventure_part`   | Adventure_Part (a note)    | first Setup | A Part of a [designed Adventure](#designed-adventures): its Summary, Structure, Clues and Ways out |

- **The first Setup writes them**, in the Workspace Language; their content is the `dmr-setup` skill's. A Setup re-run never overwrites one: it offers to add a missing one, and adds it only on the DM's yes.
- **A Template is a body with nothing filled in**: no `#` heading, no Obsidian template variables, and no frontmatter but the Session Template's, which holds its `number` and `date` properties, empty, their keys in the Workspace Language like every frontmatter key; `—` marks a value to fill in. The Homebrew monster's empty statistics carry `bestiary: false`, so the Template never enters the bestiary; a Setup re-run that changes `stat_blocks` converts it with the other notes.
- **The agent creates a note of these kinds from the Template in use**, the DM's edits included: its `#` heading first (under the frontmatter, in a Session note), then the Template's body filled in, replacing each `—` and each empty property it has a value for. A monster made from the Template drops `bestiary: false` and takes the Workspace's frontmatter flag, as any monster note does; an item made from the Homebrew_Item Template, which has no frontmatter, takes `item: true`, and its [Portrait](#the-portrait) when its Description has a picture, as any [item note](#item-notes) does. A Template links to nothing ([Link rules](#link-rules)); if the DM's Template holds a link anyway, the new note keeps it only where its own Scope allows it, and the agent says which it left out.
- **The DM changes a Template by asking**: the agent edits the Template and leaves the notes already made from it as they are.

### Attachments

A non-note file the agent places — an image, a map, a handout, a PDF — goes in the Attachments folder of the Scope whose note embeds it: Reference › Attachments, the Adventure's, Homebrew's, the world's in World, the Character's or the Campaign's, as the tables above list them. A file no note embeds, and a file a DM Tools note embeds, goes in DM Tools › Attachments.

Files the DM adds in Obsidian land in an Attachments subfolder beside the note they are pasted into: Setup sets Obsidian's attachment location to "In subfolder under current folder" with the subfolder named Attachments in the Workspace Language, and a Setup re-run repairs it. Such a subfolder is inside the note's Scope, so the agent leaves those files where they are.

## Folder creation

- **Setup** creates the eight top-level folders, and no other folder; the first Setup also writes the [Templates](#templates--templates) into Templates. It does not touch the Source Cache. (The Translation Glossary note appears with its first entry — usually at Setup, when the top-level folder names are translated.)
- **Starting a Campaign** creates its folder with the core listed above, empty folders included.
- **Every other folder** — including an Adventure's folder and all its subfolders, a Character's folder, a world's folder and every Attachments folder but a Campaign's — is created when the first note or file that belongs in it is written. Apart from Setup and Campaign start, the agent never creates empty folders in advance.

## Edition

The Edition — 2014 or 2024 — is chosen at Setup and recorded in the [Workspace Config](#workspace-config). Setup offers both, recommends 2024, sets no default, and says the choice becomes permanent once official rules material is imported. It becomes fixed with the first rules material imported into Reference (see [Fixed after Setup](#fixed-after-setup)).

The Edition decides:

- **Which rules material is Reference**: rules, classes, species, backgrounds, feats, spells, equipment, magic items and monsters come from the Edition's books. Official Adventures and Setting lore are not tied to an Edition: an Adventure or a Setting from any book is imported normally, without a callout — including what lives in the Adventure's own folder, such as its unique items — and the rules material it points to in Reference follows the Edition. A designed Adventure's rules material follows the Edition too.
- **Default folder names**: where the two Editions name a folder differently, its default English name follows the Edition (`reference.species` and `homebrew.species` are Races in 2014, Species in 2024). A folder for something the Edition does not have (`weapon_masteries` in 2014) appears only if Off-Edition Material needs it.
- **Official Translations**: taken from the Edition's books in the Workspace Language.

**A book's Edition is the one the Trusted Source gives it**: books published before the 2024 Player's Handbook are 2014, the rest are 2024. So *Xanathar's Guide* and *Mordenkainen Presents: Monsters of the Multiverse* are 2014. DM Realm keeps no list of its own.

### Off-Edition Material

Official rules material of the other Edition enters only to fill a gap:

- **A gap** is something needed by name — the DM asks for it, or a note being imported links to it — that the Edition has no version of. When the Edition has a version (the Trusted Source records the reprint), that version is used instead: a 2014 Adventure run in a 2024 Workspace links its goblins to the 2024 Goblin in Reference Monsters.
- **Never in bulk**: only the thing needed, one at a time — except the monsters and items an Adventure's Part names, which may come in with it on the DM's one yes ([Importing an Adventure](#importing-an-adventure)).
- **Player options** — classes, subclasses, species, backgrounds, feats, spells, Weapon Mastery properties — need the DM's consent for each one before import, even when the DM asked for it by name: the agent says it is Off-Edition and which Edition it belongs to, and asks. Monsters and items do not.
- **Marked**: the note carries the Edition callout ([Imported notes](#imported-notes)). It goes in the folder its kind has in the Edition, which it creates if the Edition has none (Weapon_Masteries in a 2014 Workspace).

## Official data

### Trusted Source

The Trusted Source is the 5etools data as published in its public source mirror (`5etools-mirror-3/5etools-src` on GitHub), and its images as published in the image mirror (`5etools-mirror-3/5etools-img`) at the same release tag — not the 5e.tools website ([ADR 0003](../../docs/adr/0003-official-material-comes-only-from-5etools.md), [ADR 0008](../../docs/adr/0008-an-imports-images-come-from-the-trusted-sources-image-mirror.md)). It is the only source for:

- **Importing** Reference and official Adventure content. Official material it does not contain cannot be in the Workspace. The DM may write their own version as Homebrew; the agent never copies official text into it. Text the DM copied from a published book, PDF or site is official text, whether or not the Trusted Source has it.
- **Translating** official text: the English original is always the Trusted Source's.
- **Research**: when the DM asks about official material — a rule, an entry, an Adventure's or a Setting's text — the agent answers from the Source Cache, in the Workspace Language, with the official text translated faithfully, and names the book and page. Rules material comes in the Workspace's Edition, as [Edition](#edition) says; an Adventure or a Setting from any book. Material the Workspace has not imported is answered the same way. Its terms come from the Translation Glossary; a term not yet in it is translated as [Translating a term](#translating-a-term) says and shown as a fallback term is, with its English original, but not recorded. A rules answer then names the House Rules that change the rule, as [House Rules in an answer](#house-rules-in-an-answer) says. Answering changes nothing in the Workspace — no note, no Glossary row — unless the DM asks for a note.

No official content — rules text, stats, descriptions — is ever written from memory or from another site. The names of translated game terms follow [Translating a term](#translating-a-term). When an entry is neither in the Source Cache nor reachable, the agent stops, tells the DM, and writes nothing.

DM Realm never ships any of this data, not even as examples or eval fixtures; it is only ever fetched on the DM's machine.

### House Rules in an answer

Every rule the agent gives the DM — in Research, in advice, in an [Idea](#ideas) — is the official rule, cited as Research cites it, followed by each House Rule that changes it, named and linked as the DM's own, never cited as a book. Which House Rules apply:

- **Homebrew's** (Homebrew › House_Rules) always.
- **A Campaign's own** (its Homebrew_House_Rules) when the question names that Campaign or it is the Workspace's only one. Where both change the same rule, the Campaign's wins for that Campaign, and the answer names both.
- **With several Campaigns and none named**, the answer gives the Homebrew version and says which Campaigns have their own House Rule on that rule, linking each.

### Source Cache

The agent reaches the Trusted Source only through the Source Cache, with the `dmr-trusted-source` skill.

- **One per machine, outside every Workspace**, shared by all the Workspaces on it. It holds only the English data and its images; translations live in each Workspace's Translation Glossary.
- **Pinned to one release** of the Trusted Source. Each file — data or image — is fetched from that release the first time it is needed, one file at a time, so every cached file is from the same release. The image mirror is never cloned whole. The first import or research that needs data creates it; Setup does not.
- **Refreshed only when the DM asks**: the pin moves to the latest release and the files already cached are fetched again. A refresh changes no note, in any Workspace.

### Source property

Every note imported from the Trusted Source records its source in a frontmatter property: book code, page and release, e.g. `XPHB p. 239, v2.36.1`. A note made from an official Adventure's text — a Part note, or one of its headings — adds the heading's section id after a `#`: `CoS p. 41, v2.36.1, #1a2`. Its key, like every frontmatter key, is in the Workspace Language, recorded in the Translation Glossary like a term. A [designed Adventure](#designed-adventures)'s notes have none: that is how they are told from an official Adventure's.

### Imported notes

- **Its file name** is the entry's name translated into the Workspace Language (see [Translating a term](#translating-a-term)), with the [name rules](#name-rules) applied: `Fireball.md`, `Palla_di_Fuoco.md`.
- **Its frontmatter** holds only the source property — and, for a monster in a Workspace that writes stat blocks, the `statblock` flag ([Stat blocks](#stat-blocks)); for an item, `item: true` and its [Portrait](#the-portrait) ([Item notes](#item-notes)), after the source property.
- **Its body** starts with the translated name as a `#` heading, then the entry's text, translated faithfully: every paragraph, list, table and number, nothing added. A monster's body is its description, then its [statistics](#stat-blocks), last.
- **Its description**, when the Trusted Source has one, is a section of the body headed Description (translated): its images first, then its text; for a monster before its statistics, for any other entry at the end of the note. A subrace's holds only what it adds to its race's. It is never in the statistics.
- **Its images** — every image the entry shows, such as a monster's picture or an Adventure's map — are fetched through the Source Cache, copied into the [Attachments](#attachments) folder of the note's Scope (Reference › Attachments, or the Adventure's), and embedded where the Trusted Source places them: a description's first, an image in the entry's text where it stands. One inside a monster's statistics goes under its stat block fence, which cannot show it. Each file is named after its note, with the image's own extension: `Palla_di_Fuoco.webp`, or `Palla_di_Fuoco_01.webp`, `Palla_di_Fuoco_02.webp` when there are several. A note never embeds a remote URL. A monster's statistics, and an item's frontmatter, also name the first image of its description, its [Portrait](#the-portrait).
- **An Off-Edition note** has, right under its heading, an Obsidian callout in the Workspace Language naming the Edition it belongs to: `> [!warning] Off-Edition Material (2014)`.
- **It is found by its path** — a note made from an Adventure's text by its section id instead ([Importing an Adventure](#importing-an-adventure)). The translated name comes from the Translation Glossary, so an entry always gets the same path. When a note is already at that path, an Import of the entry writes nothing and tells the DM; replacing it is the [update check](#checking-for-updates). An empty note there — one Obsidian creates when the DM clicks a link whose note is not imported yet — counts as no note: the Import writes over it.

### Checking for updates

When the DM asks, in any Workspace, the agent compares each imported note's entry — every note with a source property, so never a designed Adventure's — in the release it records with the same entry in the Source Cache's release (an older release is fetched from the mirror's release tag) — for a note made from an Adventure's text, the heading with the same section id — lists the notes whose official content changed, and re-imports the ones the DM approves.

The check does not refresh the Source Cache: it states the release the cache is pinned to and whether a newer one exists, and offers to refresh first.

A re-import replaces the note's official content wholesale, and its images with it, and records the new release. Reference notes and an official Adventure's are not meant to be edited by the DM: a change to official material is a House Rule, Homebrew, or a Campaign note linking to it. If a note differs from its recorded import, the agent warns before overwriting it and offers to move the DM's addition where it belongs.

## Ideas

An Idea is story content the agent invents at the DM's request for a Campaign, or for a [designed Adventure](#designed-adventures) — a twist, an NPC's next move, an encounter, a room — for the DM to use or drop. The agent reads every note the limits below name, drafts the Idea, checks the draft against every limit, and reworks it until nothing contradicts; only then does the DM see it. Several Ideas are each checked on their own.

- **Hard limits**, which an Idea never contradicts:
  - the official rules in the Workspace's Edition, and the House Rules that change them, as [House Rules in an answer](#house-rules-in-an-answer) says;
  - what happened: the Sessions' Live Notes and Recaps, weighed as the Live Notes and Chronicle rules in [Campaigns](#campaigns--campaigns) weigh them — the dead stay dead, the spent stays spent, the known stays known;
  - where things stand: the Party State and the Characters' current Builds — an Idea counts only on hit points, spell slots, uses and abilities the party has now;
  - the Campaign's NPCs, Places, Quests and Factions notes, their secrets included;
  - the world's lore: the DM's World notes, the official Setting in Reference, and how the Campaign has changed either.
- **Soft limits**, which an Idea may depart from, saying where and how: the Adventure the Campaign runs, and the Prep of a Session not yet played.
- **For a designed Adventure**, which knows no table, the limits are its own: the hard limits are the official rules and Homebrew's House Rules, the Adventure's own notes, their secrets included, and the lore of the world its README names (the DM's World notes and the official Setting in Reference); no Campaign's notes are a limit or a source. The soft limits are the Adventure's own README — its Pitch, Level Range and Tone — which an Idea may depart from, saying where and how.
- **The Chronicle is never a source**: its telling is invented.
- **Gaps.** What the Workspace does not say may be invented, and the Idea marks each such thing as new. Every mechanic it relies on — a DC, a CR, a spell, a condition — comes from the Trusted Source, cited, or from a House Rule, named; one that neither holds is left out.
- **What the DM sees**: the Idea alone, then a short list headed "Checked against" (in the Workspace Language) naming the notes and rules that shaped it, by their names in the Workspace, each with the fact it gave (Session 07: the bridge fell; House Rule Flanking; Mira's Build). Rejected drafts stay unshown.
- **An Idea is no fact of the Campaign** until it is played: no source for what happened, and written only where a skill's procedure writes the one the DM picks. An Idea for a designed Adventure is part of it only once the DM keeps it.

## Stat blocks

A note with game statistics — a monster, an NPC's mechanics — writes them once, last in the note, in the form the Workspace chose at Setup: the Workspace Config's `stat_blocks` ([ADR 0009](../../docs/adr/0009-a-workspace-writes-statistics-once-as-a-stat-block-or-as-markdown.md)). A Character is outside that choice ([Characters' stat blocks](#characters-stat-blocks)).

- **`true` — a stat block** for Fantasy Statblocks (`obsidian-5e-statblocks`), the Obsidian plugin that renders it and keeps a bestiary; MapForge (the DM's table tool) reads the same fences. The format is the plugin's inline mode: the frontmatter flag `statblock: inline` and one ```` ```statblock ```` fence of YAML as the note's statistics section.
- **`false` — Markdown**: the same statistics as DM Realm's Markdown, with no fence and no flag.

A monster's statistics section is headed Stat Block (translated). As a stat block:

````markdown
---
statblock: inline
---

# Bog Goblin

## Description

![[Bog_Goblin.webp]]

Bog goblins nest in the reeds of the southern marshes.

## Stat Block

```statblock
name: Bog Goblin
size: Small
type: fey (goblinoid)
alignment: neutral
ac: 14
hp: 11
hit_dice: 2d6 + 4
speed: 30 ft., swim 30 ft.
initiative: 4
stats: [8, 15, 14, 9, 10, 8]
skillsaves:
  - Stealth: 6
senses: darkvision 60 ft., passive Perception 10
languages: Common, Goblin
cr: 1/2
traits:
  - name: Reed Walker
    desc: The goblin moves through reeds and mud without spending extra movement.
actions:
  - name: Reed Spear
    desc: "*Melee or Ranged Attack Roll:* +4, reach 5 ft. or range 20/60 ft. *Hit:* 6 (1d8 + 2) Piercing damage."
```
````

As Markdown, the same section reads:

```markdown
## Stat Block

%% statblock
name: Bog Goblin
%%

*Small fey (goblinoid), neutral*

**Armor Class** 14
**Hit Points** 11 (2d6 + 4)
**Speed** 30 ft., swim 30 ft.
**Initiative** +4 (14)

| STR | DEX | CON | INT | WIS | CHA |
| --- | --- | --- | --- | --- | --- |
| 8 (-1) | 15 (+2) | 14 (+2) | 9 (-1) | 10 (+0) | 8 (-1) |

**Skills** Stealth +6
**Senses** darkvision 60 ft., passive Perception 10
**Languages** Common, Goblin
**Challenge** 1/2 (XP 100; PB +2)

### Traits

- ***Reed Walker.*** The goblin moves through reeds and mud without spending extra movement.

### Actions

- ***Reed Spear.*** *Melee or Ranged Attack Roll:* +4, reach 5 ft. or range 20/60 ft. *Hit:* 6 (1d8 + 2) Piercing damage.
```

- **One set of statistics, in two forms.** Both hold the same keys ([Keys and values](#keys-and-values)); the Markdown's labels are the layouts' own ([Layouts](#layouts)), translated through the Translation Glossary, and its `%% statblock` comment, which Obsidian does not show, keeps the keys it does not display (`name`, `layout`, `extends`, `bestiary`). The `statblock.py` helper next to this file writes the Markdown from a fence and converts a note between the two, with the same values and translations.
- **Written once, and last.** A note never holds both forms, and nothing else in it repeats their numbers. They come after everything else: a monster's images and description. Whenever the note changes (an Import, a Promotion), its statistics are written again, in the Workspace's form.
- **No link lives only in a fence**: Obsidian does not index links inside one. Statistics that name other notes (the spells a Homebrew monster casts) name them as plain text in the fence, and the links stand on one line right under it. The one link a fence holds is its [Portrait](#the-portrait), a picture the body embeds already.
- **Changing the form is a [Setup](#workspace-config) re-run**, which converts every note with statistics but a Character's, after a preview. An edit to `stat_blocks` alone changes nothing until then.
- **The plugin is optional.** DM Realm never installs it, and never uses its own 5etools import or its bundled SRD ([ADR 0003](../../docs/adr/0003-official-material-comes-only-from-5etools.md)): Setup turns the SRD off. Without it a fence shows as a YAML code block, so Setup recommends Markdown when the plugin is not installed; without fences, MapForge has no creature to place.
- **Game statistics only.** A monster's description stays in the body, never in its statistics.

### Which notes have one

Each of these statistics is a fence or Markdown, as the Workspace chose.

| Note | Statistics |
| --- | --- |
| Reference monster | All of them, rendered by the Import's helper from the Trusted Source entry, then translated |
| Homebrew monster, and a Campaign-only monster (a Campaign's Homebrew_Monsters) | All of them, written by the agent. Promotion moves them intact |
| Adventure NPC | A link to its monster (a real link, in the body): in Reference Monsters, or for a designed Adventure in Reference or Homebrew Monsters. Statistics only when the Adventure changes something: `extends:` the monster plus the changed values alone. No change, no statistics — and no bestiary entry |
| Campaign NPC | The same as an Adventure NPC. A unique NPC may have full statistics written from scratch; its mechanics stay in the Campaign until Promotion moves them to Homebrew Monsters |
| World NPC | None: World has no mechanics ([ADR 0005](../../docs/adr/0005-the-dms-world-is-a-scope-apart-from-homebrew.md)). The World note links to the Homebrew or Reference monster that holds them (see [World](#world--world)) |
| Character | A fence in the Character layout, whatever `stat_blocks` says ([Characters' stat blocks](#characters-stat-blocks)) |
| A Character's past Build, kept at a level-up or rebuild | Its copy of the fence stays, as a snapshot, with `bestiary: false`; its frontmatter drops the `statblock` flag |
| A past Build brought by a Transfer | None: it is plain history, with no computed numbers |
| The Homebrew monster [Template](#templates--templates) | Empty statistics, filled in the note made from it |

A Promotion to World moves a Campaign NPC's statistics out of the NPC note into a new Homebrew Monsters note, which the World note then links to.

### Characters' stat blocks

A Character note keeps its stat block whatever `stat_blocks` says, and a Setup re-run never converts it: the frontmatter flag `statblock: inline` and one ```` ```statblock ```` fence in the `DM Realm Character` layout, right under the `#` heading (and its callout, if any). The fence is a view derived from the note's Build and its Statistics section, which stay the source of truth: the same numbers, written again whenever they change, and never the only place a value or a link lives. The note's format is the `dmr-character` skill's.

### Keys and values

The keys the plugin (and MapForge) read stay English; every value is in the Workspace Language ([ADR 0006](../../docs/adr/0006-keys-a-plugin-reads-stay-in-english.md)). These are the only English keys in a Workspace:

- **Frontmatter:** `statblock`, and an [item note](#item-notes)'s `item` and `image`. `item` is always `true`, the YAML boolean, never a translated word.
- **In the fence:** `name`, `layout`, `extends`, `bestiary`, `image`, `size`, `type`, `alignment`, `ac`, `ac_class`, `hp`, `hit_dice`, `initiative`, `speed`, `stats`, `saves`, `skillsaves`, `damage_vulnerabilities`, `damage_resistances`, `damage_immunities`, `condition_immunities`, `gear`, `senses`, `languages`, `cr`, `traits`, `actions`, `bonus_actions`, `reactions`, `legendary_description`, `legendary_actions`, `mythic_description`, `mythic_actions`, `lair_actions`, `regional_effects`, `spells`, and in each list item `name` and `desc`; for a Character also `species`, `class`, `level`, `player`.

Every other frontmatter key stays in the Workspace Language. In the fence:

- **Values are translated** term by term as [Translating a term](#translating-a-term) says, the Glossary shared with the note's body: `size: Piccola`, an action named "Lancia di Canna". The names in `saves` and `skillsaves` are values too — an ability or skill name as the Glossary translates it (`- Destrezza: 4`), the same word the layouts' labels use.
- **Numbers stay numbers**, so the table tools can read them: `ac`, `hp`, `initiative` (a bonus: `4`, `-1`), the six `stats` in ability order, each save and skill bonus, and `cr` as the book gives it (`1/2`, `"3"`). What the book says besides a number goes in the text keys: `ac_class` beside `ac`, `hit_dice` beside `hp`. Only when the book gives no number at all ("equal to the lantern's light") is `ac` or `hp` that text.
- **A value YAML would misread is quoted**: one starting with a character other than a letter or digit, or holding `: ` or ` #` (`"*Melee Attack Roll:* +4…"`), or reading as a number or `true`/`false` when it is text.
- **`layout:` names a layout** and is never translated.
- **Lists of traits and actions** are items with a `name` and a `desc`; `desc` is the item's full text, as in the body.

### Layouts

DM Realm ships three layouts, named in English and never renamed; Setup installs them into the plugin with their labels ("Armor Class", STR, "Actions"…) translated through the Translation Glossary, like any term:

| Layout | For |
| --- | --- |
| `DM Realm Monster 2014` | 2014 monsters: the plugin's Basic 5e layout |
| `DM Realm Monster 2024` | 2024 monsters, in the style of the 2025 Monster Manual: initiative with its score, abilities and saving throws in one table, passive Perception in the senses |
| `DM Realm Character` | Characters: what matters in combat — AC, Hit Point maximum, Hit Dice, initiative, speed, abilities and saves, proficient skills, senses and languages, attacks, spellcasting, features |

Each is one column as wide as a note at Obsidian's readable line length. The 2024 layout's abilities table takes the stat block's colours, never the theme's table colours.

The Workspace's Edition sets the default layout, so a monster of the Edition names none. An [Off-Edition](#off-edition-material) monster names its own Edition's (`layout: DM Realm Monster 2014`), and a Character's fence names `DM Realm Character`.

### Names in the bestiary

The plugin's bestiary is keyed by `name`: a second fence with the same name silently replaces the first, and an `extends` naming no stat block is silently ignored. So, before writing a fence:

- **Its `name` is unique** among the Workspace's statistics in the bestiary (every one without `bestiary: false`), in either form, so that a later change of form cannot clash: Grep the Workspace for a `name:` line with it inside a `statblock` fence or a `%% statblock` comment. On a clash the agent writes nothing and asks the DM for another name — an NPC called "Bog Goblin" when a Reference monster already is. The same monster imported again is not a clash: it is already imported.
- **Its `extends` target exists**: the `name` of a fence already in the Workspace, importing the Reference monster first when it is missing.

### Item notes

An item has no statistics, so no stat block or `statblock` flag. Its note says it is an item in its frontmatter, which MapForge reads to list it in its Treasury, the items a Treasure Pawn on a Map may be ([ADR 0014](../../docs/adr/0014-an-item-note-says-so-in-its-frontmatter.md)). In an Italian Workspace:

```yaml
---
fonte: XPHB p. 225, v2.36.1
item: true
image: "[[Riferimento/Allegati/Borsa.webp]]"
---
```

- **Which notes are item notes**: every note in these folders or below them, and no other — Reference's Equipment and Magic_Items, Homebrew's Equipment and Magic_Items, an Adventure's Items, and a Campaign's Homebrew_Equipment and Homebrew_Magic_Items (`reference.equipment`, `reference.magic_items`, `homebrew.equipment`, `homebrew.magic_items`, `adventures.<adventure>.items`, `campaigns.<campaign>.homebrew_equipment`, `campaigns.<campaign>.homebrew_magic_items`). A Weapon_Masteries folder and the notes in it are not items: a Weapon Mastery is a property. The folders are found by their names in use, the top-level ones from the [Workspace Config](#workspace-config) and the rest from the [Translation Glossary](#translation-glossary) (a Campaign's with [the `Homebrew_` prefix](#campaigns--campaigns)), as the `spell-index.py` helper finds Spells. The list is DM Realm's alone: MapForge reads only the keys.
- **`item: true` is on every item note**, picture or not, after the source property when it has one, so the DM can still pick an item with no picture. An Import writes it, the agent writes it for a Homebrew, Campaign or designed Adventure item (one made from the [Homebrew_Item Template](#templates--templates) included), and a Promotion keeps it.
- **`image:` names its [Portrait](#the-portrait)**, and is absent when its Description has no picture.
- **A note with neither yet** — imported before DM Realm wrote them — gets them from the `portraits.py` helper ([The Portrait](#the-portrait)).

### The Portrait

The Portrait is the one picture MapForge cuts a Pawn's Face from, named with the `image` key: a monster's or an NPC's statistics name it with the plugin's key, and an [item note](#item-notes) names it in its frontmatter, the Face a Treasure Pawn wears.

- **Which picture**: the first one of the note's Description, which an Import places above its text. A note whose Description has none names none; a picture elsewhere in the note — in an action, under the statistics, a lair, a map — is never its Portrait.
- **Its value is a wikilink with the picture's full path** from the Workspace root, quoted as [Keys and values](#keys-and-values) says: `image: "[[Riferimento/Allegati/Nothic.webp]]"`. Never a bare name — MapForge gives no Face for a name two files share, and Obsidian, which does not index a fence, would not update a monster's link — and never a URL. A folder rename at Setup rewrites it like any path link; Obsidian indexes frontmatter, so a rename in Obsidian also keeps an item's up to date.
- **The picture stays embedded in the body**, so the link does not live only in the fence or the frontmatter. In Markdown statistics, `image` is kept in the `%% statblock` comment, and a change of form keeps it.
- **An NPC that `extends` a monster inherits its Portrait**, and names one only when its own Description has its own picture. An NPC with no statistics has none: MapForge places its monster.
- **Written, never changed**: an Import writes it, a re-import writes it again with the rest of the official content, the agent writes it for a Homebrew, Campaign or designed Adventure monster, NPC or item whose Description has a picture, and a Promotion keeps it when the picture moves with the note, its path rewritten. Statistics or an item that move without their picture — at a Promotion to World, into a new Homebrew Monsters note — name none: a Homebrew note may not link to a World or Campaign file. An `image:` already in a note the DM owns — another picture, or one set by hand — is the DM's choice and stays as it is.
- **Notes imported before DM Realm wrote these keys** get them from the `portraits.py` helper next to this file, which every Import and Setup re-run runs:

  ```sh
  python3 "<the dmr-workspace skill's base directory>/portraits.py" .
  ```

  It adds `item: true` to every [item note](#item-notes) without it, and `image:` wherever a note embeds its own picture — named after the note, as an Import names it — a monster's before its statistics, an item's in its Description. It never touches an `image:` already there, and lists what it added and what it skipped, with why (no file by that name, or several).
- **A Character's stat block** names no Portrait yet, and the helper leaves it as it is.

### MapForge

MapForge, the DM's table tool, is independent of DM Realm ([ADR 0011](../../docs/adr/0011-dm-realm-reads-mapforges-files-and-writes-them-only-when-the-dm-asks.md)). It owns `.mapforge/` at the Workspace root (its Manifest `workspace.json`, `config.json`, `parties.json`, `preferences.json`, its Session Logs) and the files beside a Map (`<map>.fog.json`, `<map>.combat/`). The agent reads them and, on its own initiative, never creates, edits or deletes any of them, nor offers to: it writes one only when the DM's own request names that change ("remove the old bestiary folder from MapForge's config.json"). Nor does it move or arrange the Workspace's folders to suit MapForge.

MapForge 2.0 and later reads the whole Workspace, once when it opens: every `.md` outside hidden folders, with no folder to configure (a `bestiaryStatBlockPath` left in `.mapforge/config.json` is ignored). A note's first ```` ```statblock ```` fence is:

- **a Character's** when it has any of `species`, `class`, `level` or `player`, unless it is marked `bestiary: false`. MapForge reads its `name`, `ac`, `hp` (the maximum), `initiative` and `size`. The DM links each Party Character to its note in MapForge, which keeps the fence's `name` as the Character's `noteName` in `parties.json`, a link DM Realm never writes; a Character whose note is gone or renamed stamps its Pawns with no numbers. The Party itself is chosen in MapForge: a Campaign README's party and a Character's `status` do not decide it.
- **out of its Bestiary** when it is marked `bestiary: false`, though a Monster may still extend it unless it is a Character's (a past Build).
- **otherwise a Monster**, `extends` resolved by the base's exact `name`: each key the NPC writes replaces the base's whole, lists included, a chain is followed, and a list of bases (`extends: [A, B]`) is laid in order, the later winning. A Character's fence is never a base.

The first `name` by path wins, and MapForge skips and lists a later fence with that name, as it does a fence that is not valid YAML, one with no `name`, and a Monster whose `extends` names no fence or comes back to itself. `ac`, `hp` and `initiative` count only as an integer, alone or followed by a bracket (`67 (9d8 + 27)`); a text value (see [Keys and values](#keys-and-values)) leaves that number empty, and the Monster is still listed.

DM Realm guarantees the plugin's standard keys, `initiative`, `size` and the [Portrait](#the-portrait)'s `image` included, an [item note](#item-notes)'s `item` and `image`, and these three, which MapForge relies on to tell its notes apart:

- a Character's fence always has `species`, `class` and `level`, whether or not it has a `player`;
- a Character's past Builds and the Homebrew monster Template's fence are marked `bestiary: false`;
- an NPC whose statistics change a monster's is written as `extends:` that monster's exact `name`, plus the changed values.

It guarantees nothing else of MapForge. Setup tells the DM what MapForge reads of the Workspace: its Monsters and Characters, the fences it skips and why, the Party Characters whose Pawns get no numbers, and how many items its Treasury reads and how many of them have no Portrait.

MapForge's Session Logs (`.mapforge/sessions/`) and the Combat Logs they point at are a Session's Table Record. It reaches the Workspace only by being written into that Session's Live Notes, when the DM asks.

## Player Wiki

A copy of the parts of the Workspace the DM chose, for the players to read: written outside the Workspace, as plain Obsidian Markdown a wiki generator (Quartz, MkDocs…) can build into a site ([ADR 0017](../../docs/adr/0017-the-player-wiki-is-a-copy-written-outside-the-workspace.md)). One per Workspace. The `player-wiki.py` helper next to this file writes it, every rule below included; the agent never writes into it by hand.

- **What can go in**, chosen as whole parts in the [Workspace Config](#workspace-config)'s `player_wiki`:
  - Reference, Homebrew, World and Characters;
  - the Chronicle of each Campaign named.
- **What never goes in:**
  - Adventures;
  - a Campaign's other notes: its Sessions, NPCs, Places, Quests, Factions, homebrew, README, Diary and Party State;
  - the Chronicle's Voice;
  - a Character's Past Builds;
  - DM Tools, the Translation Glossary included;
  - Templates.

  When the DM asks for one of these, the agent refuses and says why.
- **Copied as they are:** Reference, Characters and Chronicles. Knowledge follows links, so none of them holds a table's secrets: a Character note holds only identity and Build, and a Chronicle is written for the players.
- **World and Homebrew lose what is the DM's only:**
  - every section headed by one of the Config's `dm_only_headings`, matched whole and ignoring case, up to the next heading of the same or a higher level;
  - every `%% … %%` comment.

  The default headings are the Templates' Secrets heading and DM Notes, in the Workspace Language: `Segreti` and `Note del DM` in Italian. A DM who keeps secrets under another heading adds it to the list. The filter is by heading only, so a secret written anywhere else goes out.
- **Every note keeps its path and name.** It also gets these mechanical changes, and no other:
  - **Links:**
    - a link to a note not in the wiki becomes plain text: its alias, else its name with `_` shown as spaces;
    - an embed of such a note is dropped;
    - a file a note links to or embeds is copied at its own path, and no other file is.
  - **Stat blocks:**
    - a monster's or an NPC's fence becomes DM Realm's [Markdown](#stat-blocks), with the Translation Glossary's labels;
    - a Character's fence is dropped, because its Build is already Markdown.
  - **The title:** the `#` heading becomes the frontmatter `title:`.
- **Each Character gets a Character Sheet** ([ADR 0019](../../docs/adr/0019-a-character-sheet-is-a-page-the-player-wiki-writes-from-the-stat-block.md)): a static HTML page beside the Character's note, `<Character>_<Character Sheet>.html` (`Durga_Scheda_del_Personaggio.html`), for every Character note (`<Character>/<Character>.md`) the wiki copies, whatever its status.
  - It is rendered from the Character's stat block alone, in DM Realm's own design in the D&D character sheet's conventions, arranged by the Edition: in 2024 each ability shows its saving throw, in 2014 the saving throws are a list. It lists all eighteen skills, each with the ability it uses: a proficient one marked, with the total the stat block gives it, any other with its ability's modifier. It shows only maximums, never what is spent in play.
  - Its labels are the Translation Glossary's (the Character layout's, plus "Character Sheet", "Proficiency Bonus" and the skills' names); a label the Glossary lacks is written in English, and the report lists it.
  - It loads nothing from another server and runs no script; light or dark follows the reader's system, and it fits a phone. All the sheets share one stylesheet, `<Character Sheet>.css` at the root of the Characters folder. It shows the Portrait the stat block names, copied like any embedded file, and links back to the Character's note.
  - The Character's note gains one link to it, as the first line of its body, and no other change.
  - A Character note whose stat block is missing or cannot be read gets no sheet and no link; the report names it.
  - Nothing of it is kept in the Workspace: it is written again at every update.
- **`index.md` at the root is its home page.** It is headed with the Workspace folder's name, and links the front doors of each part:
  - Reference's Spell Indexes;
  - Homebrew's House Rules (else every Homebrew note);
  - each world's overview notes (else every note of that world);
  - each Character;
  - under the Campaigns folder's name, each Campaign's Chapters.
- **The folder:**
  - It is outside the Workspace and does not hold it.
  - It is rewritten from scratch at every update, keeping only its dot-entries (a `.git`, the generator's settings).
  - It is marked by a `.dm-realm-player-wiki` file. A folder that holds files but no marker is never emptied.
- **It is written only when the DM asks**, never by a hook. The Workspace is never changed by it, except for the `player_wiki` key the agent records.

### The Player Wiki site

When the Workspace Config says `quartz: true` (Setup asks), every update of the Player Wiki also builds it as a website with [Quartz](https://quartz.jzhao.xyz/): a folder of static HTML, `player_wiki.site`, that the DM uploads wherever they choose ([ADR 0018](../../docs/adr/0018-the-player-wiki-site-is-built-with-a-pinned-quartz.md)). Publishing it is the DM's choice and responsibility; DM Realm hosts, guards and deploys nothing. The `player-wiki-site.py` helper next to this file builds it.

- **Quartz** is the release DM Realm pins, kept once per machine in the plugin's data (`${CLAUDE_PLUGIN_DATA}/quartz/<version>`) beside the Source Cache, and downloaded with its npm dependencies and plugins at the first build. It needs **Node 22 or later**. Without it the Markdown wiki is still written and the site is not.
- **Its configuration is DM Realm's**, written at every build: the Workspace Language's locale, the Workspace folder's name as title, no analytics, only the files the notes use, fonts served by the site itself, no social images, no CNAME, no formula rendering, no footer links. Nothing the site shows comes from another server.
- **The Character Sheets** are put in the site by the helper after Quartz, at the path Quartz links each one, plus `.html` as Quartz's own pages; Quartz's copy of the sheet without `.html` is removed. Its stylesheet and Portrait go at the paths the sheet names, its link back leads to the Character's page, and every link to a sheet opts out of Quartz's in-page navigation and previews.
- **The site folder** follows the Markdown folder's rules: outside the Workspace, holding neither the Workspace nor the Markdown folder and inside neither, marked by a `.dm-realm-player-wiki-site` file, its dot-entries kept. It is built in a temporary folder beside it and replaces the previous site only when the build succeeds.

## Language and names

The Workspace Language is chosen at Setup and recorded in the [Workspace Config](#workspace-config). The documentation and the official sources are in English; the agent writes every folder name, file name and note in the Workspace Language, translating from them. DM Realm ships no per-language name tables: any language works.

### Translating a term

For every game term and every default folder name, the agent uses, in this order:

1. **The Translation Glossary**, if the term is already in it. A recorded translation is always reused, never re-translated; only the DM corrects it ([Correcting the Glossary](#correcting-the-glossary)).
2. **The Official Translation** — the term the publisher's own books of the Workspace's Edition, in the Workspace Language, use, as the agent knows it or finds it on the web. A term the agent is not sure is official is a fallback (step 3).
3. **A faithful translation**, when no Official Translation exists. The agent may search the web for an existing correspondence (fan wikis, community glossaries) before coining one.

Whenever it chooses a translation (steps 2 and 3) for a note, the agent adds it to the Translation Glossary before writing the note.

A fallback term — one recorded as a fallback, whether chosen now or taken from the Glossary — shows its English original at its first occurrence in each note that uses it — once per note: `Translated term (EN: Original term)`. Official Translations never do, and folder and file names never carry the English original.

### Translation Glossary

A single note at the root of DM Tools (`dm_tools.translation_glossary`), one row per term:

| English     | Translation      | Source                         | Key (top-level folders only) |
| ----------- | ---------------- | ------------------------------ | ---------------------------- |
| `<English>` | `<translation>`  | Official Translation / fallback / DM's choice | `<key>` or empty |

Every folder name below the top level is an ordinary term row, one per English term: Monsters has one row, whether it names Reference's folder or Homebrew's.

Names the DM chooses — a Campaign's name, a Session's title, an invented NPC, a Character's name, an invented world's name, a designed Adventure's title and its notes' names — are the DM's words, not game terms, and are not recorded. The one exception is a top-level folder the DM named: its row records the name with the source *DM's choice*, so the Glossary lists every top-level folder in use.

In an English Workspace nothing is translated, so there is no Translation Glossary.

#### Correcting the Glossary

A recorded translation changes only when the DM asks, for instance because an Official Translation has appeared for a fallback. The agent updates the row and its source, then lists the folder and file names and the notes that use the old term. On the DM's yes it renames those folders and files (rewriting the links to them) and replaces the term in the notes' text. When a fallback becomes an Official Translation, it also drops the term's `(EN: …)` from those notes.

### Fixed after Setup

- **The Workspace Language** is fixed once Setup has happened, that is once the Workspace Config exists.
- **The Edition** is fixed once the first rules material is imported into Reference. Until then nothing in the Workspace depends on it, and the Workspace Config's `edition` is the Edition.

Once fixed, if `language` or `edition` in the Workspace Config is edited, the agent does not act on it, keeps working in the value in use, and tells the DM that changing it is not supported.

Because the Workspace Config can be edited, the values in use are read from the Workspace itself:

- **Workspace Language** — the top-level folder names on disk and, in a non-English Workspace, the Translation Glossary.
- **Edition** — the [source property](#source-property) of the rules material imported into Reference: a book of the 2024 Edition (see [Edition](#edition)) means 2024, an earlier one 2014. Only rules material counts — not Setting lore, not Adventure notes, which come from books of either Edition, and not Off-Edition notes, which carry an Edition callout. With no such note yet, the Edition is not fixed and the Workspace Config's `edition` is the Edition.

### Name rules

- Words in file and folder names are joined with underscores: `Magic_Missile.md`, `Magic_Items`. Apostrophes become underscores too: `L_Imboscata`.
- Characters that break links or file names (`# ^ [ ] | \ / : * ? " < >`) are left out.
- Folders have no number prefixes: `Campaigns`, not `01_Campaigns`.
- Session notes are named `Session_<NN>_<Title>.md` by default — the word "Session" in the Workspace Language, the title as the DM gave it (with the name rules applied, never translated), the number zero-padded to two digits so they sort in play order: `Session_03_The_Ambush.md` in English, `Sessione_03_L_Imboscata.md` for the title «L'Imboscata» in Italian, `Sessione_03_The_Ambush.md` for the title "The Ambush" in an Italian Workspace. A Session with no title yet is `Session_<NN>.md`, renamed when it gets one, with the links to it rewritten. A name or naming scheme the DM gives ("call it The_Mystery_of_Ambika", "name them by their date") is used as given, with only the rules above applied, and never renamed.
- A Chapter note is named after its Session's note: the word "Chapter" in the Workspace Language in place of the name's leading word "Session" (in the Workspace Language), or before the whole name when it has none — `Chapter_03_The_Ambush.md` for `Session_03_The_Ambush.md`, `Capitolo_03_L_Imboscata.md` for `Sessione_03_L_Imboscata.md`, `Chapter_Interlude_The_Long_Night.md` for the Side Session `Interlude_The_Long_Night.md`. When a Session is renamed, its Chapter is renamed with it, with the links to it rewritten.

## Workspace Config

`workspace-config.yml` at the Workspace root. Setup writes it from the DM's answers; the agent reads it for the top-level folder names, and for the Workspace Language and Edition it records — confirmed against the Workspace itself as [Fixed after Setup](#fixed-after-setup) says.

| Field                | Meaning                                                                                        |
| -------------------- | ---------------------------------------------------------------------------------------------- |
| `language`           | The Workspace Language, as its name in any language (`English`, `Italiano`, `Deutsch`…). Fixed after Setup. |
| `edition`            | The Edition: `2014` or `2024`. Fixed once rules material is imported.                         |
| `stat_blocks`        | `true`: monsters' and NPCs' statistics are Fantasy Statblocks fences; `false`: Markdown ([Stat blocks](#stat-blocks)). Characters keep their fence either way. Setup asks, recommending `true` when the plugin is installed. A Config without it counts as `true` until a Setup re-run asks. |
| `folders.<key>`      | The name of the top-level folder with that key (`reference`, `adventures`, `homebrew`, `world`, `characters`, `campaigns`, `dm_tools`, `templates`). Empty means the agent's translation of the default English name. |
| `quartz`             | `true`: every update of the Player Wiki also builds it as a website with Quartz ([The Player Wiki site](#the-player-wiki-site)); `false`: the Markdown wiki only. Setup asks. A Config without it counts as `false` until a Setup re-run asks. |
| `player_wiki`        | Optional: the [Player Wiki](#player-wiki). `output`, the absolute path of its folder, outside the Workspace; `site`, with `quartz: true`, the absolute path of the site's folder; `include`, a list of `reference`, `homebrew`, `world`, `characters`; `chronicles`, a list of the Campaign folders whose Chronicle goes in; `dm_only_headings`, the headings that mark a World or Homebrew section as the DM's only, in the Workspace Language. Written by the agent when the DM first asks for the Player Wiki, and changed when the DM changes what goes in. |

- **A top-level folder name is a single folder name directly under the Workspace root** — never a path (`Games/Active`, `../Games`), never empty after the [name rules](#name-rules) are applied, never the same as another top-level folder. On an invalid name the agent writes nothing and asks the DM for a valid one.
