# Changelog

What changed in each release of DM Realm. Claude Code updates an installed copy when a new version is published. The guide at [mattevigo.github.io/DM-Realm](https://mattevigo.github.io/DM-Realm/) always describes the latest release.

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
