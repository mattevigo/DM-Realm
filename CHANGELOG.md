# Changelog

What changed in each release of DM Realm. Claude Code updates an installed copy when a new version is published. The guide at [mattevigo.github.io/DM-Realm](https://mattevigo.github.io/DM-Realm/) always describes the latest release.

## 1.0.0 — 2026-11-26

### Added

- **Party State in full, on the Character Sheets.** Each Character's section of a Campaign's Party State now keeps everything a Session can end with still in effect:
  - hit points and temporary hit points;
  - spell slots, Hit Dice and the uses of limited features, a feat's or a species' included, and the spells cast once without a slot;
  - the charges spent from its magic items;
  - conditions and exhaustion;
  - Heroic Inspiration;
  - an effect still running when the Session ends, a concentration included;
  - death saving throws while at 0 hit points;
  - the Campaign homebrew it carries.

  Each is a line opened by its label (*Hit Points: 53 of 57*), with an "As of" line naming the Session it dates from. Anything else you write in Party State, such as a paragraph or a section of open questions, is yours, and every skill keeps it as you wrote it.
- **Where a Character stands, on its Character Sheet.** Beside the maximums, the Player Wiki's sheet now shows one block per Campaign whose Party State has the Character: its lines, without the notes you put in parentheses, as of the Session the Party State was last updated for. It never shows your own words, the shared treasure, the Campaign homebrew a Character carries, or anything under a DM-only heading. It is read-only.
- **Change Party State between Sessions** with `dmr-campaign` ("Brom drank a potion on the way home, he's at 30"). It changes only the lines you name.
- **A Campaign's README kept current.** Consolidation now proposes the README lines a Session's Live Notes show:
  - a new Current State;
  - an Adventure going from planned to running, or from running to finished;
  - a Character joining or leaving the party.

  It proposes them only when no later Session is consolidated. Between Sessions, `dmr-campaign` changes any section of the README in your words ("the tone of Heroes gets darker", "add a truth: the moon is hollow", "Ayla joins Heroes"). `dmr-character` offers to take a Character marked retired or dead out of the party, and to link a new Character into the Campaign it was made for. When no Adventure is running, `dmr-session-prepare` prepares from the first planned one.
- **MapForge: hit points outside a fight, and Long Rests.** `dmr-mapforge-import` now brings into the Live Notes each change to a Character's hit points, temporary hit points or exhaustion made outside a fight, and each Long Rest with what it restored. Consolidation reads them into Party State like the rest of the Live Notes.

### Changed

- **Rewriting an older Party State.** A Party State written before this release has no "As of" line. Consolidation offers to rewrite it into the new lines once, and so does `dmr-campaign` when you ask. The rewrite:
  - keeps every value;
  - keeps every other word where it was;
  - lists what belongs in a Character's Build instead (a potion count, an attunement) next to what the Build says, for you to settle with `dmr-character`.

  Until it is rewritten, the sheets show none of that Campaign's Party State.

- **Setup describes MapForge 2.0 and later.** MapForge now reads every note in your Workspace, takes each Character's AC, HP and initiative from its note, and leaves past Builds and Templates out of its Bestiary. When MapForge has adopted the folder, Setup's report now says:
  - how many monsters and Characters MapForge finds;
  - each stat block it skips, and why: a name another note already has, an `extends` naming a monster no note defines or looping back on itself, no `name`, or YAML MapForge cannot read (an unquoted `: ` in a value, say);
  - each Party Character with no note linked in MapForge, or linked to a note that is gone, since its Pawns get no numbers;
  - how many items its Treasury lists, as before.

  It no longer reports which folders MapForge misses. This needs MapForge 2.0 or later.

### Removed

- **Pointing MapForge's bestiary at a folder.** MapForge has no bestiary folder any more. Ask Setup for one and it explains why, and changes nothing in MapForge's files. A `bestiaryStatBlockPath` left in `.mapforge/config.json` does no harm, and Setup leaves it there.

## 0.5.0 — 2026-11-17

### Added

- **Design an Adventure of your own: `dmr-adventure`.** An adventure you write for any table to run is now an Adventure. It lives in Adventures, beside the official ones, and a Campaign runs it the same way, whole or in part, listed in its README's Adventures Run. What happens at the table stays the Campaign's, as it does for a published Adventure. You design it in four stages, in any order, as often as you like:
  - **Premise**: its README, with the pitch, level range, length, world, tone and hook. Only the sections you give are written.
  - **Structure**: its Parts. Each is a note with a summary, its scenes or nodes, the clues the party must find to go on, and the ways out to the next Parts.
  - **Content**: a Part's places, NPCs, encounters and items, each a note of its own. An encounter's difficulty is worked out from your Edition's *Dungeon Master's Guide*, with the page. A monster you invent goes into Homebrew › Monsters, so any Campaign can use it; an item you invent stays in the Adventure's Items.
  - **Review**: a report in the chat of what the Adventure lacks. It lists a conclusion with fewer than three clues, a Part with no way out, an encounter too hard or too easy for its levels, a name with no note, and a link the rules forbid, each with the practice or rule behind it. Review changes nothing.
  - Ask for ideas and Claude offers two or three, checked against your Adventure, its world and the rules. Ask for a draft and it shows you every note, with its path, before writing. Either way, only what you keep is written.
- **An `Adventure_Part` Template**, so you can also write a Part by hand. A new Workspace gets it at Setup. Run `/dm-realm:dmr-setup` again in an existing Workspace and it offers to add it.

### Changed

- **A Campaign's plot can become an Adventure.** Ask to turn a Campaign's place, NPC, quest or faction into an Adventure of its own, so another table can run it. Claude shows what moves and what is stripped of the Campaign, then creates the Adventure. A plot you write for one table, such as your own dungeon in place of an official chapter, stays the Campaign's until you ask.
- **A Campaign's NPC wanted by your Adventure** cannot be linked from it, since an Adventure knows no table. Claude offers to promote the NPC to your World first, as it does for a Character's backstory.
- `dmr-import-adventure` and `dmr-import` never write into a folder that holds an Adventure of your own. When an official Adventure's title matches yours, they stop and ask you to rename one of the two.
- The guide has a page for the new skill, and its glossary and its lessons on the Workspace, Setup and starting a Campaign now cover Adventures of your own.

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
