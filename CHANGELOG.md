# Changelog

What changed in each release of DM Realm. Claude Code updates an installed copy when a new version is published. The guide at [mattevigo.github.io/DM-Realm](https://mattevigo.github.io/DM-Realm/) always describes the latest release.

## 0.4.4 — 2026-11-16

### Fixed

- **A Character Sheet lists every skill.** It used to show only the skills the Character is proficient in. Now it lists all eighteen, each with the ability it uses (Stealth (DEX)): a proficient skill is marked and shows the total from the stat block, any other shows its ability's modifier. Skill names come from your Translation Glossary like the other labels; one the Glossary lacks stays in English, and the report lists it.

## 0.4.3 — 2026-11-16

### Added

- **A Character Sheet for each Character in the Player Wiki.** Every time you update the Player Wiki, each Character gets a page of its own in the style of a D&D character sheet, for its player. The Character's page in the wiki links to it from its first line.
  - It is made from the Character's stat block: abilities and modifiers, saving throws and skills with their proficiency marks, Armor Class, Hit Point maximum, Hit Dice, Initiative, Speed, Proficiency Bonus, attacks, spellcasting with its slots, and features with a one-line summary each. It shows the Character's Portrait when it has one.
  - It follows your Edition: on a 2024 sheet each ability shows its saving throw, on a 2014 sheet the saving throws are a list of their own.
  - It reads well on a phone, a tablet or a laptop, in light or dark following the reader's settings. It loads nothing from other servers and runs no scripts.
  - It shows maximums only (hit points, spell slots), never what was spent at the table, and it is written again at every update, so it always matches the Character.
  - Its labels come from your Translation Glossary. A label the Glossary lacks stays in English, and the report lists it. A Character without a readable stat block gets no sheet, and the report names it.
  - With the website, each sheet becomes a page of the site, reached from its Character's page.

### Changed

- The guide's "Share with your players" lesson, the `dmr-player-wiki` page and the glossary describe Character Sheets.

## 0.4.2 — 2026-11-16

### Added

- **A wiki for your players: `dmr-player-wiki`.** Ask for it ("make a wiki for my players", "update the Player Wiki") and DM Realm writes a copy of the parts of your Workspace you choose into a folder outside it. The parts are Reference, Homebrew, World, Characters and each Campaign's Chronicle.
  - The copy is made by a script, not by Claude, so nothing is reworded, and your Workspace is never changed. The folder is rewritten from scratch at every update, so a note you delete leaves the wiki too.
  - Some things never go in: Adventures, Sessions, a Campaign's other notes, the Voice, Past Builds, DM Tools and the Templates. A link to a note left out becomes plain text, so the wiki has no broken links.
  - World and Homebrew notes lose their *Secrets* and *DM Notes* sections and their `%% comments %%`. You can add your own DM-only headings, and after each update the report lists every section removed, note by note.
  - Monsters' stat blocks become readable Markdown with your Glossary's labels. Characters keep their Build and lose the stat block fence. A home page links each part.
  - The first time, Claude proposes what goes in and where the folder goes, and saves your answer in the Workspace Config's new `player_wiki` key.
- **The Player Wiki as a website.** Setup now asks whether you want the Player Wiki built as a website. If you say yes, every update also builds it with Quartz into a folder of HTML pages, with search, backlinks and a graph, in your Workspace's language.
  - It needs Node 22 or later. Setup checks for it and tells you how to install it, and installs nothing itself. Without Node, the Markdown wiki is still written.
  - The first build downloads Quartz once for every Workspace, at the version DM Realm was tested with.
  - The site loads nothing from other servers: no analytics, no fonts or scripts from a CDN.
  - A failed build leaves your previous site as it was. The report gives you the command to preview the site locally.
  - Publishing it is yours: upload the folder wherever you like. Reference holds official text, so where the site goes and who can read it is your responsibility.

### Changed

- Setup's Workspace Config has a new `quartz` field. Running Setup again in an existing Workspace asks the website question once.
- The guide has a new lesson, "Share with your players", a page for `dmr-player-wiki`, and the website question on the Setup pages.

## 0.4.1 — 2026-11-15

### Fixed

- Importing an Adventure works again with the current official data. Since 5etools v2.40 changed the layout of an Adventure's file, `dmr-import-adventure` stopped at every Adventure, saying it "has no Parts". It now reads both the old and the new layout.

## 0.4.0 — 2026-11-15

### Added

- **Import an official Adventure: `dmr-import-adventure`.** Ask for a chapter ("import chapter 2 of Curse of Strahd"), the next one ("bring in the next part of Lost Mine"), or the whole book. An Adventure comes in a **Part** at a time: a chapter, an appendix, a dungeon level.
  - Each place, NPC, encounter and item the book gives its own heading becomes its own note, in the Adventure's Places, NPCs, Encounters and Items. The rest of the chapter stays in its Part note, with a link where each of those headings stood. Its maps and pictures go in the Adventure's Attachments folder, and the Adventure's README lists every Part, linking the ones imported.
  - Before writing anything, Claude tells you how long the chapter is, how many images it has, and how many of the monsters and items it names your Workspace is missing. It asks once whether to bring those too. For a single chapter of ordinary length where you already said yes or no, it tells you and goes on. Several chapters, or the whole book, always ask.
  - Links work ahead of time. A monster, an item or a room in a later chapter is linked even before it is in your Workspace, and the link starts working the day you import it. Monsters link to your Edition's version: a 2014 Adventure in a 2024 Workspace links its goblins to the 2024 Goblin.
  - In a non-English Workspace every note is translated, with each name recorded in the Translation Glossary, so a place or NPC reads the same in every note.
  - A chapter already imported is left as it is. An import that stopped midway picks up where it left off, keeping the notes already written. A chapter that uses something DM Realm cannot render yet writes nothing, and Claude names the section.
  - The first import of an Adventure links it from each Campaign README that names it, keeping your wording.

### Changed

- `dmr-import` hands a request for an Adventure, or one of its chapters, over to `dmr-import-adventure`. An item an Adventure introduces, asked for on its own ("add the Sunsword"), still comes in through `dmr-import`.
- `dmr-session-prepare` offers to import the Adventure's next chapter once the party reaches it.
- `dmr-campaign` tells you that an Adventure not in the Workspace yet can be imported. The README's Adventures Run counts an Adventure's Parts, as the book names them (`chapters 1–2`).
- `dmr-ask` offers to import the chapter an answer about an Adventure's text came from.
- The guide has a page for the new skill, and its lessons on importing, the Workspace tour and preparing a Session now cover Adventures.

## 0.3.2 — 2026-11-09

### Changed

- A spell's Classes line names the Player's Handbook classes, and a class from any other book only once you have imported that class. Setting books' own classes no longer appear on core spells.
- Running `/dm-realm:dmr-setup` again brings every spell's Classes line, and the Spell Indexes, up to date.

## 0.3.1 — 2026-11-07

### Added

- Item notes say `item: true` in their frontmatter and name their picture as their Portrait, so MapForge's Treasury lists them and a Treasure on the Map can wear their picture. A Setup re-run adds both to items imported earlier.
- Setup's MapForge report counts the items the Treasury reads, and how many have no Portrait.
- `dmr-mapforge-import` brings in the moves made on the Map, and each fight's notes, rolls and moves in the order they happened.

## 0.3.0 — 2026-11-05

### Added

- The guide site, [mattevigo.github.io/DM-Realm](https://mattevigo.github.io/DM-Realm/): lessons from installing to your first narrated Chapter, a page per skill, and a glossary.
- An item an Adventure introduces ("add the Sunsword") goes into that Adventure's Items folder instead of Reference, and the Adventure's README (title, book, level range, Parts) is written the first time.

## 0.2.0 — 2026-10-15

### Added

- A monster's or NPC's stat block names its Portrait (`image:`), the picture MapForge cuts a Pawn's face from.
- An Idea Claude offers for a Campaign is checked against it: it contradicts no rule your table plays by and nothing the Campaign has made true, and it marks what it invents. A rules answer names the House Rules that change the rule.

## 0.1.0 — 2026-10-06

The first public release.

- `dmr-setup` turns a folder into a Workspace, in any language, with the 2014 or 2024 rules, and installs its Obsidian settings, Templates and Fantasy Statblocks layouts.
- `dmr-import` brings in official spells, monsters, items, feats, classes, species, backgrounds, conditions and rules, with their images, translated and cited by book and page. The Spell Indexes list every imported spell by level and by class.
- `dmr-campaign` starts a Campaign; `dmr-character` creates, levels up, rebuilds, updates and transfers Characters.
- The Session loop: `dmr-session-prepare`, `dmr-mapforge-import`, `dmr-session-consolidate` and `dmr-session-narrate`.
- `dmr-ask` answers questions about DM Realm, your Campaigns and the rules, changing nothing.
