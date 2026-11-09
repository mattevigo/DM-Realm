# A spell's Classes line follows Reference's classes

A spell note's Classes line names the classes of a core book (the Trusted Source's `core` group: the core rulebooks of either Edition, of which only the Player's Handbooks have classes, so an Off-Edition spell keeps its own Edition's classes) whose spell list has the spell, and every other class whose spell list has it only when Reference holds that class's note, matched by name and book (the note's source property). This is the one piece of Reference text that depends on what else is imported, an exception to "No links between Reference notes" (structure.md), which keeps a note from depending on what else was imported. So DM Realm keeps the line, as it keeps the Spell Indexes: Import rewrites every Classes line after it writes a spell or a class note, and again when the DM asks to bring the Spell Indexes up to date. The hook still rebuilds only the indexes, offline.

The cause is the Trusted Source's release v2.40.1. It adds *D&D: World of Warcraft* (`WoW`, a Setting book), whose thirteen classes now appear on the class lists of core spells. Sleep|XPHB lists Bard, Sorcerer, Wizard, Evoker and Mage. A line naming every class the Trusted Source lists put Azeroth's classes on every 2024 spell, a Spell Index for each of them, and a Glossary row for each before the line could be written. Each WoW class is built on a core class, so in Italian WoW's Mage and the Wizard would both be *Mago*.

## Considered Options

- **Every class the Trusted Source lists** (as before). Rejected: a Setting book's classes reach every Workspace, whether or not it plays in that Setting.
- **By book kind**: classes from core and supplement books, and a Setting book's classes only on its own spells. Rejected: the 2024 Artificer exists only in a Setting book (*Eberron: Forge of the Artificer*), so it would lose every core spell on its list.
- **By the Trusted Source's marker**: leave out an entry a class's own book put on another book's spell (`definedInSource`). Rejected: it matches today's data only by how 5etools happens to mark entries (the Artificer's entries carry no marker, WoW's do), and a later release can change that.
- **Name-only matching** of Reference's classes. Rejected: WoW has its own Druid, Paladin and Warlock, so the core Druid's note would put "Druid" on spells only WoW's Druid has.
- **The hook refreshing the lines** when Reference's classes change. Rejected: the hook would read the Source Cache on every tool call and must cope with a cache that is missing or offline. Import already runs where the classes change.

## Consequences

- Importing or deleting a class note can change spell notes it never touched. Their Classes lines are rewritten, and so are the Spell Indexes.
- A class note deleted outside DM Realm leaves the lines naming it until the next Import or refresh, as a spell deleted outside Claude leaves the indexes.
- The Classes-line backfill becomes a refresh: it rewrites every line, not only missing ones, so lines written since v2.40.1 with WoW's classes are corrected on the next run.
- An Import's renderer names only the core books' classes; the refresh that follows it adds the classes Reference holds.
- `classVariant` entries (classes that gain a spell through optional features) are still not read.
