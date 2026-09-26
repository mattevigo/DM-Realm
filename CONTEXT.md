# DM Realm

A general-purpose way to run D&D 5th-edition campaigns (2014 or 2024 rules) as Markdown notes, in the style of "DM Workspace" but usable by any DM, for any setting, in any language.

## Language

### Workspace

**DM Realm**:
The Claude Code plugin whose skills set up and maintain Workspaces. It is installed once and serves any number of Workspaces; none of its files live in a Workspace.
_Avoid_: Template repo, framework

**Workspace**:
One DM's collection of notes, organised into Scopes, set up once in a single Workspace Language, and worked on in Obsidian (Obsidian opens it as its vault).
_Avoid_: Vault, repo, project

**Workspace Language**:
The language chosen at Setup; every folder name, file name, frontmatter key and generated note in the Workspace is written in it, except the keys an Obsidian plugin reads, which stay English ([ADR 0006](docs/adr/0006-keys-a-plugin-reads-stay-in-english.md)). Fixed after Setup. DM Realm's documentation and the official sources are in English; the agent translates from them into the Workspace Language.
_Avoid_: Locale

**Edition**:
The D&D rules a Workspace follows — 2014 or 2024 — chosen at Setup and fixed once the first official rules material is imported into Reference. It decides which official rules material is Reference (Adventures and Setting lore are not tied to an Edition), the default folder names, and which Official Translations apply.
_Avoid_: Ruleset, version, 5e/5.5e

**Off-Edition Material**:
Official rules material of the Edition the Workspace did not choose, as the Trusted Source dates its book. It enters only to fill a gap — something needed by name that the Edition has no version of — never in bulk, is always marked, and a player option (spell, feat, class, species…) needs the DM's informed consent first.
_Avoid_: Legacy, cross-edition content

**Workspace Config**:
The file recording the Workspace Language, the Edition and the names of the top-level folders, written by Setup from the DM's answers. It is the only DM Realm file in a Workspace, and its presence is what makes a folder a Workspace.
_Avoid_: Settings, preferences

**Setup**:
The one-time act that turns the documented, language-neutral structure into concrete folders named in the Workspace Language and prepares the Workspace for Obsidian. It starts by asking the DM for the Workspace Language, and is conducted in that language from then on; it then asks for the Edition.
_Avoid_: Init, bootstrap, install, configure the environment

**Official Translation**:
The publisher's own translation of a game term into the Workspace Language, as printed in the books of the Workspace's Edition. Always preferred; when none exists, the term is translated as faithfully as possible instead.

**Translation Glossary**:
The single Workspace note recording, for each game term, the translation chosen and whether it is an Official Translation or a fallback, so every note translates it the same way.

### Official data

**Trusted Source**:
The 5etools data, as published in its public source mirror: the only source from which official material is imported, translated and researched. Official material it does not contain cannot be Reference or Adventure content.
_Avoid_: The books, compendium, SRD, 5e.tools website

**Source Cache**:
The local copy of the Trusted Source that DM Realm keeps outside every Workspace and shares among them, pinned to one release and refreshed only when the DM asks. It holds only the English data; a Workspace's translation choices live in its Translation Glossary.
_Avoid_: Download, mirror, local data

**Import**:
Bringing one official entry from the Trusted Source into the Workspace as a note, translated into the Workspace Language — into Reference, or into an Adventure. It is the only way official material enters a Workspace.
_Avoid_: Download, copy, Transfer (which is only for Characters)

### Scopes

**Scope**:
The kind of content a note is — Reference, Adventure, Homebrew, World, Character or Campaign — given by the top-level folder it lives in, and deciding what that note may link to.
_Avoid_: Context, category

**Reference**:
Official material imported faithfully from the Trusted Source, with no knowledge of any Campaign. Its rules material is of the Workspace's Edition, with Off-Edition Material only filling a gap; Setting lore comes from any book.
_Avoid_: Compendium

**Homebrew**:
DM-authored game material with mechanics — rules, classes, species, backgrounds, feats, spells, items, monsters — that is not official and is meant to be reused across Campaigns. Homebrew made for a single Campaign belongs to that Campaign instead. Story elements with no mechanics are World.
_Avoid_: Custom, house content

**Adventure**:
An official published adventure — its places, NPCs and items as the book describes them — kept apart from any Campaign that runs it.
_Avoid_: Module, scenario

**Setting**:
The lore of a game world — geography, pantheon, history. An official Setting is Reference; the DM's own lore is World; how a Campaign has changed it belongs to that Campaign.

**World**:
The story elements the DM invented and reuses across Campaigns — places, NPCs, factions, pantheon, history — of a world the DM invented or added to an official Setting. No mechanics (those are Homebrew) and no table's story (that is a Campaign's).
_Avoid_: Homebrew Setting, lore, Mondo

**House Rules**:
Homebrew changes to the official rules, applying to every Campaign in the Workspace.

**Character**:
A player's character, kept apart from every Campaign so it can play in any of them: its identity and its current Build, with no knowledge of what happened at any table. NPCs are never Characters.
_Avoid_: PC, player character, hero, sheet

**Build**:
A Character's game statistics at one moment — species, class and level, abilities, features, spells, equipment. A Character has one current Build; before a level-up or rebuild the current one is kept as a past Build.
_Avoid_: Sheet, version, snapshot

**Transfer**:
Bringing an existing Character into the Workspace from outside it — another Workspace or an old vault's note — keeping its identity and Build but none of its table's story, and none of its official text, which comes from Reference instead.
_Avoid_: Import (which is only from the Trusted Source), copy, migrate

**Campaign**:
One ongoing game with its own party of Characters, Sessions and story; what actually happened at the table, including what happened to its Characters. May run any number of Adventures, and may draw on every other Scope.

**Template**:
A blank starting note for a kind of content, copied when a new note is created. Not a Scope.

**DM Tools**:
Notes that help the DM run the game — checklists, random tables, prep aids — which sit outside every Scope and may reference anything.
_Avoid_: DM resources, utilities

### Play

**Session**:
One real-world game meeting of a Campaign, with its prep and recap.
_Avoid_: Episode
