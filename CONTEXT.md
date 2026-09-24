# DM Realm

A general-purpose workspace for running D&D 2024 campaigns as Markdown notes, in the style of "DM Workspace" but usable by any DM, for any setting, in any language.

## Language

### Workspace

**Workspace**:
One DM's collection of notes, organised into Scopes, set up once in a single Workspace Language.
_Avoid_: Vault, repo, project

**Workspace Language**:
The language chosen at Setup; every folder name, file name, frontmatter key and generated note in the Workspace is written in it. Fixed after Setup. The Workspace's own documentation and the official sources are in English; the agent translates from them into the Workspace Language.
_Avoid_: Locale

**Workspace Config**:
The file where the DM sets the Workspace Language and the names of the top-level folders; read at Setup.
_Avoid_: Settings, preferences

**Setup**:
The one-time act that turns the documented, language-neutral structure into concrete folders named in the Workspace Language.
_Avoid_: Init, bootstrap, install

**Official Translation**:
The publisher's own translation of a game term into the Workspace Language. Always preferred; when none exists, the term is translated as faithfully as possible instead.

**Translation Glossary**:
The single Workspace note recording, for each game term, the translation chosen and whether it is an Official Translation or a fallback, so every note translates it the same way.

### Scopes

**Scope**:
The kind of content a note is — Reference, Adventure, Homebrew or Campaign — given by the top-level folder it lives in, and deciding what that note may link to.
_Avoid_: Context, category

**Reference**:
Official D&D 2024 material, imported faithfully from the published books, with no knowledge of any Campaign.
_Avoid_: World, Mondo, compendium

**Homebrew**:
DM-authored material that is not official and is meant to be reused across Campaigns. Homebrew made for a single Campaign belongs to that Campaign instead.
_Avoid_: Custom, house content

**Adventure**:
An official published adventure — its places, NPCs and items as the book describes them — kept apart from any Campaign that runs it.
_Avoid_: Module, scenario

**Setting**:
The lore of a game world — geography, pantheon, history. An official Setting is Reference; a world the DM invented is Homebrew; how a Campaign has changed it belongs to that Campaign.
_Avoid_: World, Mondo

**House Rules**:
Homebrew changes to the official rules, applying to every Campaign in the Workspace.

**Campaign**:
One ongoing game with its own party, Sessions and story; what actually happened at the table. May run any number of Adventures, and may draw on every other Scope.

**Template**:
A blank starting note for a kind of content, copied when a new note is created. Not a Scope.

**DM Tools**:
Notes that help the DM run the game — checklists, random tables, prep aids — which sit outside every Scope and may reference anything.
_Avoid_: DM resources, utilities

### Play

**Session**:
One real-world game meeting of a Campaign, with its prep and recap.
_Avoid_: Episode
