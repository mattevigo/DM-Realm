# Workspace structure

How a DM Realm Workspace is organised: which folders exist, what each holds, and what each note may link to. This document is in English and independent of any Workspace Language. Terms follow [CONTEXT.md](../CONTEXT.md); the Scope rule is [ADR 0001](adr/0001-scope-by-top-level-folder.md).

Every folder has a **neutral key** (e.g. `reference.monsters`) and a **default English name**. Keys are English identifiers used only in this documentation and in the [Workspace Config](#workspace-config); they never appear as folder or file names. In a Workspace, the agent writes every folder and file name in the Workspace Language, translated from the default English name (see [Language and names](#language-and-names)); the six top-level folder names can instead be set in the Workspace Config.

## Workspace root

The Workspace root is the root of the cloned repository. Every note lives inside one of the six top-level folders; no note lives at the root.

DM Realm's own files at the root — `CLAUDE.md`, `CONTEXT.md`, `workspace-config.yml`, `docs/`, and dot-folders such as `.claude/` and `.obsidian/` — are not notes, not top-level folders, and are never translated.

## Top-level folders

| Key          | Default name | Scope       | Created | Holds                                                                    |
| ------------ | ------------ | ----------- | ------- | ------------------------------------------------------------------------ |
| `reference`  | Reference    | Reference   | Setup   | Official D&D 2024 material, imported faithfully from the published books |
| `adventures` | Adventures   | Adventure   | Setup   | One folder per official published Adventure                              |
| `homebrew`   | Homebrew     | Homebrew    | Setup   | DM-authored material reused across Campaigns                             |
| `campaigns`  | Campaigns    | Campaign    | Setup   | One folder per Campaign                                                  |
| `dm_tools`   | DM_Tools     | not a Scope | Setup   | Aids for running the game that belong to no single Campaign              |
| `templates`  | Templates    | not a Scope | Setup   | Blank starting notes                                                     |

These six are fixed: the DM may rename them in the Workspace Config, but may not add or remove a top-level folder. Material that seems to need a new one belongs inside an existing one (maps of a Campaign go in its Attachments, a reusable map in Homebrew Setting).

Inside the top-level folders the DM is free to add, rename or remove subfolders. The subfolders documented below are the defaults the agent uses when it places a note and the DM has not organised that part differently.

## Scope

A note's Scope is the top-level folder it lives in, and nothing else ([ADR 0001](adr/0001-scope-by-top-level-folder.md)). There is no Scope property in frontmatter. Moving a note to another top-level folder changes its Scope, and its links must then obey the new Scope's rules.

Each Adventure and each Campaign is a separate unit: "the same Adventure" means the Adventure folder the note is in, and another Adventure's notes are as foreign to it as a Campaign's.

## Link rules

A link is any wikilink, Markdown link or embed to another note or file in the Workspace, in the body or in frontmatter.

| From ↓ / to → | Reference | Adventures             | Homebrew | Campaigns | DM Tools | Templates |
| ------------- | --------- | ---------------------- | -------- | --------- | -------- | --------- |
| **Reference** | yes       | no                     | no       | no        | no       | no        |
| **Adventure** | yes       | its own Adventure only | no       | no        | no       | no        |
| **Homebrew**  | yes       | no                     | yes      | no        | no       | no        |
| **Campaign**  | yes       | yes (any)              | yes      | yes (any) | yes      | yes       |
| **DM Tools**  | yes       | yes (any)              | yes      | yes (any) | yes      | yes       |

- **Knowledge follows links.** A note that may not link to a Scope does not mention its content either, linked or not. Reference, Adventure and Homebrew notes never name a Campaign, a PC or anything that happened at a table.
- **Forbidden links are refused.** When a forbidden link is asked for, the agent does not write it, says why, and writes the fact on the side that is allowed to link, pointing the other way.
- **"Who uses this" comes from backlinks.** Which PCs have a feat, who owns an item, which Session a monster appeared in: never written into the feat, item or monster note. The Campaign notes link to it, and the target's backlinks answer the question.
- **What happened at the table belongs to the Campaign.** Events go in the Session note. A lasting change to something from another Scope — an Adventure's tavern burned down, a Setting's city conquered — goes in a Campaign note about it (e.g. in the Campaign's Places) that links to the original. The original note stays as published.

## Folders

For each folder: its neutral key, default English name, when it is created (see [Folder creation](#folder-creation)), and what lives there. Every subfolder has the Scope of its top-level folder. `<…>` stands for a name that varies: one the DM chooses, or a published Adventure's title.

### Reference — `reference`

Official D&D 2024 material only, imported faithfully. Every official thing has exactly one home here; material an Adventure reprints from another book is linked, not copied.

| Key                                  | Default name      | Created    | Holds                                                                                  |
| ------------------------------------ | ----------------- | ---------- | -------------------------------------------------------------------------------------- |
| `reference.rules`                    | Rules             | first note | Official rules and rule quick-references (e.g. Conditions, Actions)                    |
| `reference.classes`                  | Classes           | first note | Classes and their subclasses                                                           |
| `reference.species`                  | Species           | first note | Species                                                                                |
| `reference.backgrounds`              | Backgrounds       | first note | Backgrounds                                                                            |
| `reference.feats`                    | Feats             | first note | Feats                                                                                  |
| `reference.spells`                   | Spells            | first note | One subfolder per spell level, and nothing else                                        |
| `reference.spells.cantrips`          | Cantrips          | first note | Cantrips                                                                               |
| `reference.spells.level_1` … `_9`    | Level_1 … Level_9 | first note | Spells of that level                                                                   |
| `reference.equipment`                | Equipment         | first note | Weapons, armor, tools, gear                                                            |
| `reference.equipment.weapon_masteries` | Weapon_Masteries | first note | Weapon Mastery properties                                                             |
| `reference.magic_items`              | Magic_Items       | first note | Magic items                                                                            |
| `reference.monsters`                 | Monsters          | first note | Every official stat block, including one printed only in an Adventure                  |
| `reference.setting`                  | Setting           | first note | Lore of official Settings — geography, pantheon, history — one subfolder per Setting   |

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

It mirrors Reference's type folders — Classes, Species, Backgrounds, Feats, Spells (with the same level subfolders), Equipment (with Weapon_Masteries), Magic_Items, Monsters, Setting — under the keys `homebrew.<type>`, with House Rules in place of Rules:

| Key                   | Default name | Created    | Holds                                                                         |
| --------------------- | ------------ | ---------- | ----------------------------------------------------------------------------- |
| `homebrew.house_rules`| House_Rules  | first note | Changes to the official rules; they apply to every Campaign in the Workspace  |
| `homebrew.setting`    | Setting      | first note | Worlds the DM invented, one subfolder per Setting                             |
| `homebrew.<type>`     | as Reference | first note | The DM's own material of that type                                            |

Every Homebrew subfolder is created by its first note; an empty Workspace has none.

### Campaigns — `campaigns`

One folder per Campaign: everything that happens at that table, and everything made only for it.

| Key                               | Default name       | Created           | Holds                                                    |
| --------------------------------- | ------------------ | ----------------- | -------------------------------------------------------- |
| `campaigns.<campaign>`            | `<Campaign name>`  | Campaign start    | One Campaign                                             |
| `campaigns.<campaign>.readme`     | README (a note)    | Campaign start    | Overview: premise, party, current state, Adventures run  |
| `campaigns.<campaign>.characters` | Characters         | Campaign start    | The PCs                                                  |
| `campaigns.<campaign>.npcs`       | NPCs               | Campaign start    | NPCs as they are in this Campaign                        |
| `campaigns.<campaign>.sessions`   | Sessions           | Campaign start    | One note per Session, with its prep and recap            |
| `campaigns.<campaign>.places`     | Places             | Campaign start    | Places as they are in this Campaign                      |
| `campaigns.<campaign>.quests`     | Quests             | Campaign start    | Quests                                                   |
| `campaigns.<campaign>.factions`   | Factions           | Campaign start    | Factions                                                 |
| `campaigns.<campaign>.attachments`| Attachments        | Campaign start    | Images, maps, handouts and other non-note files          |
| `campaigns.<campaign>.homebrew_<type>` | Homebrew_`<Type>` (e.g. Homebrew_Spells) | first note | Homebrew made for this Campaign only: one folder per Homebrew type, with that type's subfolders (Homebrew_Spells › Level_3) |

- **Anything else the Campaign needs** goes in a subfolder the DM adds (e.g. Narrative, Finances). Notes about running this one Campaign — the DM's personal notes, a to-do board — live here, not in DM Tools.
- **Promotion.** When Campaign homebrew is wanted in a second Campaign, the agent moves it to the matching Homebrew folder, removes every link to and mention of the first Campaign from it (anything worth keeping moves into that Campaign's notes), and updates the links to it.

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

- **Setup** creates the six top-level folders and nothing else. (The Translation Glossary note appears with its first entry — usually at Setup, when the top-level folder names are translated.)
- **Starting a Campaign** creates its folder with the core listed above.
- **Every other folder** — including an Adventure's folder and all its subfolders — is created when the first note that belongs in it is written. The agent never creates empty folders in advance.

## Language and names

The Workspace Language is set in the [Workspace Config](#workspace-config) before Setup. The documentation and the official sources are in English; the agent writes every folder name, file name and note in the Workspace Language, translating from them. DM Realm ships no per-language name tables: any language works.

### Translating a term

For every game term and every default folder name, the agent uses, in this order:

1. **The Translation Glossary**, if the term is already in it. A recorded translation is always reused, never re-translated.
2. **The Official Translation** — the term the publisher's own books in the Workspace Language use.
3. **A faithful translation**, when no Official Translation exists. The agent may search the web for an existing correspondence (fan wikis, community glossaries) before coining one.

Whenever it chooses a translation (steps 2 and 3), the agent adds it to the Translation Glossary before writing the note.

A fallback term — one recorded as a fallback, whether chosen now or taken from the Glossary — shows its English original at its first occurrence in each note that uses it — once per note: `Translated term (EN: Original term)`. Official Translations never do, and folder and file names never carry the English original.

### Translation Glossary

A single note at the root of DM Tools (`dm_tools.translation_glossary`), one row per term:

| English     | Translation      | Source                         | Key (folders only)   |
| ----------- | ---------------- | ------------------------------ | -------------------- |
| `<English>` | `<translation>`  | Official Translation / fallback | `<key>` or empty    |

Names the DM chooses — a Campaign's name, a Session's title, an invented NPC — are the DM's words, not game terms, and are not recorded.

In an English Workspace nothing is translated, so there is no Translation Glossary.

### Fixed after Setup

Setup has happened once the top-level folders exist. From then on the Workspace Language cannot change: if `language` in the Workspace Config is edited, the agent does not act on it, keeps writing in the Setup language, and tells the DM that changing the Workspace Language is not supported.

### Name rules

- Words in file and folder names are joined with underscores: `Magic_Missile.md`, `Magic_Items`. Apostrophes become underscores too: `L_Imboscata`.
- Characters that break links or file names (`# ^ [ ] | \ / : * ? " < >`) are left out.
- Folders have no number prefixes: `Campaigns`, not `01_Campaigns`.
- Session notes are named `Session_<NN>_<Title>.md` — with the word "Session" and the title in the Workspace Language, the number zero-padded to two digits so they sort in play order: `Session_03_The_Ambush.md` in English, `Sessione_03_L_Imboscata.md` in Italian.

## Workspace Config

`workspace-config.yml` at the Workspace root. The DM fills it in before Setup; the agent reads it at Setup and whenever it needs a top-level folder's name.

| Field                | Meaning                                                                                        |
| -------------------- | ---------------------------------------------------------------------------------------------- |
| `language`           | The Workspace Language, as its name in any language (`English`, `Italiano`, `Deutsch`…). Fixed after Setup. |
| `folders.<key>`      | The name of the top-level folder with that key (`reference`, `adventures`, `homebrew`, `campaigns`, `dm_tools`, `templates`). Empty means the agent's translation of the default English name. |

- **A top-level folder name is a single folder name directly under the Workspace root** — never a path (`Games/Active`, `../Games`), never empty after the [name rules](#name-rules) are applied, never the same as another top-level folder. On an invalid name the agent writes nothing and asks the DM for a valid one.
