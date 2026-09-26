# Workspace structure

How a DM Realm Workspace is organised: which folders exist, what each holds, and what each note may link to. This document is in English and independent of any Workspace Language and Edition. Terms follow [CONTEXT.md](../../CONTEXT.md); the Scope rule is [ADR 0001](../../docs/adr/0001-scope-by-top-level-folder.md), Characters as a Scope is [ADR 0004](../../docs/adr/0004-characters-are-a-scope-above-campaigns.md), and where official material comes from is [ADR 0003](../../docs/adr/0003-official-material-comes-only-from-5etools.md).

Every folder has a **neutral key** (e.g. `reference.monsters`) and a **default English name**. Keys are English identifiers used only in this documentation and in the [Workspace Config](#workspace-config); they never appear as folder or file names. In a Workspace, the agent writes every folder and file name in the Workspace Language, translated from the default English name (see [Language and names](#language-and-names)); the seven top-level folder names can instead be set in the Workspace Config.

## Workspace root

The Workspace root is the folder the DM opens in Obsidian. Every note lives inside one of the seven top-level folders; no note lives at the root.

The only other things at the root are the Workspace Config (`workspace-config.yml`, the only DM Realm file in a Workspace — [ADR 0002](../../docs/adr/0002-dm-realm-is-a-plugin-separate-from-the-workspace.md)) and dot-folders such as `.obsidian/`. They are not notes, not top-level folders, and are never translated.

## Top-level folders

| Key          | Default name | Scope       | Created | Holds                                                                    |
| ------------ | ------------ | ----------- | ------- | ------------------------------------------------------------------------ |
| `reference`  | Reference    | Reference   | Setup   | Official material imported from the Trusted Source; its rules material from the Workspace's Edition |
| `adventures` | Adventures   | Adventure   | Setup   | One folder per official published Adventure                              |
| `homebrew`   | Homebrew     | Homebrew    | Setup   | DM-authored material reused across Campaigns                             |
| `characters` | Characters   | Character   | Setup   | One folder per Character, kept apart from every Campaign                 |
| `campaigns`  | Campaigns    | Campaign    | Setup   | One folder per Campaign                                                  |
| `dm_tools`   | DM_Tools     | not a Scope | Setup   | Aids for running the game that belong to no single Campaign              |
| `templates`  | Templates    | not a Scope | Setup   | Blank starting notes                                                     |

These seven are fixed: the DM may rename them — by re-running Setup, which moves the folder, rewrites the links into it and updates the Workspace Config (an edit to the Config alone takes effect at that re-run) — but may not add or remove a top-level folder. Material that seems to need a new one belongs inside an existing one (maps of a Campaign go in its Attachments, a reusable map in Homebrew Setting).

Inside the top-level folders the DM is free to add, rename or remove subfolders. The subfolders documented below are the defaults the agent uses when it places a note and the DM has not organised that part differently.

## Scope

A note's Scope is the top-level folder it lives in, and nothing else ([ADR 0001](../../docs/adr/0001-scope-by-top-level-folder.md)). There is no Scope property in frontmatter. Moving a note to another top-level folder changes its Scope, and its links must then obey the new Scope's rules.

Each Adventure and each Campaign is a separate unit: "the same Adventure" means the Adventure folder the note is in, and another Adventure's notes are as foreign to it as a Campaign's.

## Link rules

A link is any wikilink, Markdown link or embed to another note or file in the Workspace, in the body or in frontmatter.

| From ↓ / to → | Reference | Adventures             | Homebrew | Characters | Campaigns | DM Tools | Templates |
| ------------- | --------- | ---------------------- | -------- | ---------- | --------- | -------- | --------- |
| **Reference** | yes       | no                     | no       | no         | no        | no       | no        |
| **Adventure** | yes       | its own Adventure only | no       | no         | no        | no       | no        |
| **Homebrew**  | yes       | no                     | yes      | no         | no        | no       | no        |
| **Character** | yes       | yes (any)              | yes      | yes        | no        | no       | no        |
| **Campaign**  | yes       | yes (any)              | yes      | yes        | yes (any) | yes      | yes       |
| **DM Tools**  | yes       | yes (any)              | yes      | yes        | yes (any) | yes      | yes       |

- **Knowledge follows links.** A note that may not link to a Scope does not mention its content either, linked or not. Reference, Adventure and Homebrew notes never name a Campaign, a Character or anything that happened at a table. Character notes never name a Campaign, a Session or anything that happened at a table.
- **Forbidden links are refused.** When a forbidden link is asked for, the agent does not write it, says why, and writes the fact on the side that is allowed to link, pointing the other way.
- **"Who uses this" comes from backlinks.** Which Characters have a feat, who owns an item, which Session a monster appeared in: never written into the feat, item or monster note. The Character and Campaign notes link to it, and the target's backlinks answer the question. Only current Character notes count: a past Build (in a Character's Past_Builds) describes the Character as it was, so it never says who has something today.
- **What happened at the table belongs to the Campaign.** Events go in the Session note. A lasting change to something from another Scope — an Adventure's tavern burned down, a Setting's city conquered — goes in a Campaign note about it (e.g. in the Campaign's Places) that links to the original. The original note stays as published.
- **What happened to a Character belongs to the Campaign too.** An item attuned in Session 21, a wound, an oath: the agent writes it in that Campaign's notes (usually the Session note), linking to the Character, and leaves the Character note unchanged, even when asked to note it "on" the Character. The Character's backlinks give its history. The Character note changes only when the DM asks to change the Build itself (a level gained, an item added to its equipment), and even then it names no Campaign or Session.

## Folders

For each folder: its neutral key, default English name, when it is created (see [Folder creation](#folder-creation)), and what lives there. Every subfolder has the Scope of its top-level folder. `<…>` stands for a name that varies: one the DM chooses, or a published Adventure's title.

### Reference — `reference`

Official material, imported faithfully from the Trusted Source. Its rules material is of the Workspace's Edition, plus any Off-Edition Material that fills a gap; Setting lore comes from any book (see [Edition](#edition)). Every official thing has exactly one home here; material an Adventure reprints from another book is linked, not copied.

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
| `reference.spells`                   | Spells            | first note | One subfolder per spell level, and nothing else                                        |
| `reference.spells.cantrips`          | Cantrips          | first note | Cantrips                                                                               |
| `reference.spells.level_1` … `_9`    | Level_1 … Level_9 | first note | Spells of that level                                                                   |
| `reference.equipment`                | Equipment         | first note | Weapons, armor, tools, gear                                                            |
| `reference.equipment.weapon_masteries` | Weapon_Masteries | first note | Weapon Mastery properties (2024 only; in a 2014 Workspace only as Off-Edition Material) |
| `reference.magic_items`              | Magic_Items       | first note | Magic items                                                                            |
| `reference.monsters`                 | Monsters          | first note | Every official stat block, including one printed only in an Adventure                  |
| `reference.setting`                  | Setting           | first note | Lore of official Settings — geography, pantheon, history — one subfolder per Setting   |

**One note per entry.** An Import brings one Trusted Source entry into one note, in the folder of its kind:

- **Rules.** Conditions go in Rules › Conditions and actions in Rules › Actions. Every other entry of the rules data — Rules Glossary entries, optional and variant rules, statuses (Bloodied, Concentration, Surprised), senses, skills — goes directly in Rules. Diseases, traps and hazards are not imported.
- **Classes.** The class note, Classes › `<Class>` › `<Class>`, holds the class table and every class feature to level 20, including the optional class features the class lists from another book, each headed with that book and page ("(optional; TCE p. 42)"); its source property stays the class's own book. Each subclass is its own note beside it, holding only what the subclass adds. Importing a subclass on its own creates its class's folder but not the class note.
- **A 2014 subclass listed again under the 2024 class** (the Trusted Source copies every 2014 subclass there) still has its own book's Edition: in a 2024 Workspace it is Off-Edition Material, and its note goes in the folder of the Edition's class.
- **Class options** — Fighting Styles (2014), Maneuvers, Eldritch Invocations, Metamagic and the other kinds — are one note each in Classes › Options › `<Kind>`. 2024 Fighting Styles are feats, in Feats. A class or subclass note names its options in plain text; importing it does not import them.
- **Species.** The same pattern as classes: Races › Dwarf › Dwarf, and beside it one note per named 2014 subrace (Hill_Dwarf), holding only what the subrace adds. An unnamed 2014 subrace is part of its race's note. 2024 species have no subraces: a lineage is part of its species' note, so asking for a 2024 lineage (Drow) imports its species (Elf).
- **Magic items.** A specific item the Trusted Source builds from a generic variant and a base item ("+1 Longsword", "Flame Tongue Greatsword") is not an entry: asking for one imports the generic variant ("+1 Weapon", "Flame Tongue") into Magic_Items, and the agent says so ([ADR 0007](../../docs/adr/0007-an-import-renders-only-what-the-data-contains.md)). Its DMG or XDMG copy follows the Edition like any other entry.
- **Mechanics only.** The Trusted Source's lore text about an entry (its "fluff") and its images are not imported.
- **One entry at a time.** The one set an Import brings in on request is every Condition, or every Action, of the Edition, one note each; any other bulk request is declined.
- **No links between Reference notes.** A note names other entries (a monster's spells, a class's options) in plain text, so it never depends on what else was imported.

The note's own format is in [Imported notes](#imported-notes).

### Adventures — `adventures`

One folder per official published Adventure, holding its content as the book describes it, never what happened at a table.

| Key                             | Default name     | Created    | Holds                                                         |
| ------------------------------- | ---------------- | ---------- | ------------------------------------------------------------- |
| `adventures.<adventure>`        | `<Adventure title>` | first note | One Adventure                                              |
| `adventures.<adventure>.readme` | README (a note)  | first note | Overview of the Adventure: premise, structure, chapters       |
| `adventures.<adventure>.places` | Places           | first note | Its locations                                                 |
| `adventures.<adventure>.npcs`   | NPCs             | first note | Its NPCs                                                      |
| `adventures.<adventure>.items`  | Items            | first note | Items it introduces (unique items, plot items, its treasure)  |
| `adventures.<adventure>.encounters` | Encounters   | first note | Its encounters                                                |

Monster stat blocks are the one exception: a monster printed in an Adventure — even one that appears in no other book — goes to Reference Monsters, and the Adventure's NPC and Encounter notes link to it. An item the Adventure reprints from a core book (a DMG magic item in its treasure) stays in Reference Magic_Items and is linked.

### Homebrew — `homebrew`

DM-authored game material meant to be reused across Campaigns. Homebrew is something that exists in play — a rule, class, spell, item, monster, place; an aid only the DM uses to run the game is DM Tools. Homebrew made for one Campaign belongs to that Campaign (see [Campaigns](#campaigns--campaigns)).

It mirrors Reference's type folders — Classes, Species (Races in 2014), Backgrounds, Feats, Spells (with the same level subfolders), Equipment (with Weapon_Masteries), Magic_Items, Monsters, Setting — under the keys `homebrew.<type>`, with House Rules in place of Rules:

| Key                   | Default name | Created    | Holds                                                                         |
| --------------------- | ------------ | ---------- | ----------------------------------------------------------------------------- |
| `homebrew.house_rules`| House_Rules  | first note | Changes to the official rules; they apply to every Campaign in the Workspace  |
| `homebrew.setting`    | Setting      | first note | Worlds the DM invented, one subfolder per Setting                             |
| `homebrew.<type>`     | as Reference | first note | The DM's own material of that type                                            |

Every Homebrew subfolder is created by its first note; an empty Workspace has none.

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
| `campaigns.<campaign>.readme`     | README (a note)    | Campaign start    | Overview: premise, party (linking to its Characters), current state, Adventures run |
| `campaigns.<campaign>.npcs`       | NPCs               | Campaign start    | NPCs as they are in this Campaign                        |
| `campaigns.<campaign>.sessions`   | Sessions           | Campaign start    | One note per Session, with its prep and recap            |
| `campaigns.<campaign>.places`     | Places             | Campaign start    | Places as they are in this Campaign                      |
| `campaigns.<campaign>.quests`     | Quests             | Campaign start    | Quests                                                   |
| `campaigns.<campaign>.factions`   | Factions           | Campaign start    | Factions                                                 |
| `campaigns.<campaign>.attachments`| Attachments        | Campaign start    | Images, maps, handouts and other non-note files          |
| `campaigns.<campaign>.homebrew_<type>` | Homebrew_`<Type>` (e.g. Homebrew_Spells) | first note | Homebrew made for this Campaign only: one folder per Homebrew type, with that type's subfolders (Homebrew_Spells › Level_3) |

- **Anything else the Campaign needs** goes in a subfolder the DM adds (e.g. Narrative, Finances). Notes about running this one Campaign — the DM's personal notes, a to-do board — live here, not in DM Tools.
- **The party is linked, not kept here.** A Campaign has no Characters folder: its Characters live in the Characters folder, and the Campaign's README lists its party by linking to them.
- **Promotion.** When Campaign homebrew is wanted in a second Campaign, the agent moves it to the matching Homebrew folder, removes every link to and mention of the first Campaign — and of its Characters — from it (anything worth keeping moves into that Campaign's notes), and updates the links to it.
- **A Character gaining Campaign homebrew** (an item it now carries, a spell it learns) cannot link to it where it is. The agent says so and asks the DM to promote it; on a yes it promotes it as above and the Character note links to the Homebrew note. Until then the Character note does not name it; the Campaign's notes record who holds it.

### DM Tools — `dm_tools`

Aids for running and preparing the game, reusable across Campaigns. Not a Scope.

| Key                             | Default name                  | Created           | Holds                                                         |
| ------------------------------- | ----------------------------- | ----------------- | ------------------------------------------------------------- |
| `dm_tools.translation_glossary` | Translation_Glossary (a note) | first entry       | The Translation Glossary (see [Language and names](#language-and-names)) |
| `dm_tools.checklists`           | Checklists                    | first note        | Prep and session checklists                                   |
| `dm_tools.random_tables`        | Random_Tables                 | first note        | Random tables (names, encounters, weather, loot…)             |

### Templates — `templates`

Blank starting notes, one per kind of note, copied when a new note is created. Not a Scope. Their content is not defined here.

## Folder creation

- **Setup** creates the seven top-level folders and nothing else. It does not touch the Source Cache. (The Translation Glossary note appears with its first entry — usually at Setup, when the top-level folder names are translated.)
- **Starting a Campaign** creates its folder with the core listed above.
- **Every other folder** — including an Adventure's folder and all its subfolders, and a Character's folder — is created when the first note that belongs in it is written. The agent never creates empty folders in advance.

## Edition

The Edition — 2014 or 2024 — is chosen at Setup and recorded in the [Workspace Config](#workspace-config). Setup offers both, recommends 2024, sets no default, and says the choice becomes permanent once official rules material is imported. It becomes fixed with the first rules material imported into Reference (see [Fixed after Setup](#fixed-after-setup)).

The Edition decides:

- **Which rules material is Reference**: rules, classes, species, backgrounds, feats, spells, equipment, magic items and monsters come from the Edition's books. Adventures and Setting lore are not tied to an Edition: an Adventure or a Setting from any book is imported normally, without a callout — including what lives in the Adventure's own folder, such as its unique items — and the rules material it points to in Reference follows the Edition.
- **Default folder names**: where the two Editions name a folder differently, its default English name follows the Edition (`reference.species` and `homebrew.species` are Races in 2014, Species in 2024). A folder for something the Edition does not have (`weapon_masteries` in 2014) appears only if Off-Edition Material needs it.
- **Official Translations**: taken from the Edition's books in the Workspace Language.

**A book's Edition is the one the Trusted Source gives it**: books published before the 2024 Player's Handbook are 2014, the rest are 2024. So *Xanathar's Guide* and *Mordenkainen Presents: Monsters of the Multiverse* are 2014. DM Realm keeps no list of its own.

### Off-Edition Material

Official rules material of the other Edition enters only to fill a gap:

- **A gap** is something needed by name — the DM asks for it, or a note being imported links to it — that the Edition has no version of. When the Edition has a version (the Trusted Source records the reprint), that version is used instead: a 2014 Adventure run in a 2024 Workspace links its goblins to the 2024 Goblin in Reference Monsters.
- **Never in bulk**: only the thing needed, one at a time.
- **Player options** — classes, subclasses, species, backgrounds, feats, spells, Weapon Mastery properties — need the DM's consent for each one before import, even when the DM asked for it by name: the agent says it is Off-Edition and which Edition it belongs to, and asks. Monsters and items do not.
- **Marked**: the note carries the Edition callout ([Imported notes](#imported-notes)). It goes in the folder its kind has in the Edition, which it creates if the Edition has none (Weapon_Masteries in a 2014 Workspace).

## Official data

### Trusted Source

The Trusted Source is the 5etools data as published in its public source mirror (`5etools-mirror-3/5etools-src` on GitHub), not the 5e.tools website ([ADR 0003](../../docs/adr/0003-official-material-comes-only-from-5etools.md)). It is the only source for:

- **Importing** Reference and Adventure content. Official material it does not contain cannot be in the Workspace. The DM may write their own version as Homebrew; the agent never copies official text into it. Text the DM copied from a published book, PDF or site is official text, whether or not the Trusted Source has it.
- **Translating** official text: the English original is always the Trusted Source's.
- **Research**: when the DM asks a rules question, the agent answers from the Source Cache in the Workspace's Edition and names the book and page. Answering creates no note unless the DM asks for one.

No official content — rules text, stats, descriptions — is ever written from memory or from another site. The names of translated game terms follow [Translating a term](#translating-a-term). When an entry is neither in the Source Cache nor reachable, the agent stops, tells the DM, and writes nothing.

DM Realm never ships any of this data, not even as examples or eval fixtures; it is only ever fetched on the DM's machine.

### Source Cache

The agent reaches the Trusted Source only through the Source Cache, with the `dmr-trusted-source` skill.

- **One per machine, outside every Workspace**, shared by all the Workspaces on it. It holds only the English data; translations live in each Workspace's Translation Glossary.
- **Pinned to one release** of the Trusted Source. Each file is fetched from that release the first time it is needed, so every cached file is from the same release. The first import or research that needs data creates it; Setup does not.
- **Refreshed only when the DM asks**: the pin moves to the latest release and the files already cached are fetched again. A refresh changes no note, in any Workspace.

### Source property

Every note imported from the Trusted Source records its source in a frontmatter property: book code, page and release, e.g. `XPHB p. 239, v2.36.1`. Its key, like every frontmatter key, is in the Workspace Language, recorded in the Translation Glossary like a term.

### Imported notes

- **Its file name** is the entry's name translated into the Workspace Language (see [Translating a term](#translating-a-term)), with the [name rules](#name-rules) applied: `Fireball.md`, `Palla_di_Fuoco.md`.
- **Its frontmatter** holds only the source property.
- **Its body** starts with the translated name as a `#` heading, then the entry's text, translated faithfully: every paragraph, list, table and number, nothing added. A monster's stat lines are one section of the note.
- **An Off-Edition note** has, right under its heading, an Obsidian callout in the Workspace Language naming the Edition it belongs to: `> [!warning] Off-Edition Material (2014)`.
- **It is found by its path.** The translated name comes from the Translation Glossary, so an entry always gets the same path. When a note is already at that path, an Import of the entry writes nothing and tells the DM; replacing it is the [update check](#checking-for-updates).

### Checking for updates

When the DM asks, in any Workspace, the agent compares each imported note's entry in the release it records with the same entry in the Source Cache's release (an older release is fetched from the mirror's release tag), lists the notes whose official content changed, and re-imports the ones the DM approves.

The check does not refresh the Source Cache: it states the release the cache is pinned to and whether a newer one exists, and offers to refresh first.

A re-import replaces the note's official content wholesale and records the new release. Reference and Adventure notes are not meant to be edited by the DM: a change to official material is a House Rule, Homebrew, or a Campaign note linking to it. If a note differs from its recorded import, the agent warns before overwriting it and offers to move the DM's addition where it belongs.

## Language and names

The Workspace Language is chosen at Setup and recorded in the [Workspace Config](#workspace-config). The documentation and the official sources are in English; the agent writes every folder name, file name and note in the Workspace Language, translating from them. DM Realm ships no per-language name tables: any language works.

### Translating a term

For every game term and every default folder name, the agent uses, in this order:

1. **The Translation Glossary**, if the term is already in it. A recorded translation is always reused, never re-translated.
2. **The Official Translation** — the term the publisher's own books of the Workspace's Edition, in the Workspace Language, use, as the agent knows it or finds it on the web. A term the agent is not sure is official is a fallback (step 3).
3. **A faithful translation**, when no Official Translation exists. The agent may search the web for an existing correspondence (fan wikis, community glossaries) before coining one.

Whenever it chooses a translation (steps 2 and 3), the agent adds it to the Translation Glossary before writing the note.

A fallback term — one recorded as a fallback, whether chosen now or taken from the Glossary — shows its English original at its first occurrence in each note that uses it — once per note: `Translated term (EN: Original term)`. Official Translations never do, and folder and file names never carry the English original.

### Translation Glossary

A single note at the root of DM Tools (`dm_tools.translation_glossary`), one row per term:

| English     | Translation      | Source                         | Key (folders only)   |
| ----------- | ---------------- | ------------------------------ | -------------------- |
| `<English>` | `<translation>`  | Official Translation / fallback / DM's choice | `<key>` or empty |

Names the DM chooses — a Campaign's name, a Session's title, an invented NPC, a Character's name — are the DM's words, not game terms, and are not recorded. The one exception is a top-level folder the DM named: its row records the name with the source *DM's choice*, so the Glossary lists every top-level folder in use.

In an English Workspace nothing is translated, so there is no Translation Glossary.

### Fixed after Setup

- **The Workspace Language** is fixed once Setup has happened, that is once the top-level folders exist.
- **The Edition** is fixed once the first rules material is imported into Reference. Until then nothing in the Workspace depends on it, and the Workspace Config's `edition` is the Edition.

Once fixed, if `language` or `edition` in the Workspace Config is edited, the agent does not act on it, keeps working in the value in use, and tells the DM that changing it is not supported.

Because the Workspace Config can be edited, the values in use are read from the Workspace itself:

- **Workspace Language** — the top-level folder names on disk and, in a non-English Workspace, the Translation Glossary.
- **Edition** — the [source property](#source-property) of the rules material imported into Reference: a book of the 2024 Edition (see [Edition](#edition)) means 2024, an earlier one 2014. Only rules material counts — not Setting lore, not Adventure notes, which come from books of either Edition, and not Off-Edition notes, which carry an Edition callout. With no such note yet, the Edition is not fixed and the Workspace Config's `edition` is the Edition.

### Name rules

- Words in file and folder names are joined with underscores: `Magic_Missile.md`, `Magic_Items`. Apostrophes become underscores too: `L_Imboscata`.
- Characters that break links or file names (`# ^ [ ] | \ / : * ? " < >`) are left out.
- Folders have no number prefixes: `Campaigns`, not `01_Campaigns`.
- Session notes are named `Session_<NN>_<Title>.md` — with the word "Session" and the title in the Workspace Language, the number zero-padded to two digits so they sort in play order: `Session_03_The_Ambush.md` in English, `Sessione_03_L_Imboscata.md` in Italian.

## Workspace Config

`workspace-config.yml` at the Workspace root. Setup writes it from the DM's answers; the agent reads it for the top-level folder names, and for the Workspace Language and Edition it records — confirmed against the Workspace itself as [Fixed after Setup](#fixed-after-setup) says.

| Field                | Meaning                                                                                        |
| -------------------- | ---------------------------------------------------------------------------------------------- |
| `language`           | The Workspace Language, as its name in any language (`English`, `Italiano`, `Deutsch`…). Fixed after Setup. |
| `edition`            | The Edition: `2014` or `2024`. Fixed once rules material is imported.                         |
| `folders.<key>`      | The name of the top-level folder with that key (`reference`, `adventures`, `homebrew`, `characters`, `campaigns`, `dm_tools`, `templates`). Empty means the agent's translation of the default English name. |

- **A top-level folder name is a single folder name directly under the Workspace root** — never a path (`Games/Active`, `../Games`), never empty after the [name rules](#name-rules) are applied, never the same as another top-level folder. On an invalid name the agent writes nothing and asks the DM for a valid one.
