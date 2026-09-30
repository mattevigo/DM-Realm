# A Workspace writes statistics once, as a stat block or as Markdown

Each Workspace chooses, at Setup, whether its monsters' and NPCs' game statistics are Fantasy Statblocks fences or Markdown, and every monster's and NPC's statistics — Reference and Homebrew monsters, Adventure and Campaign NPCs — follow that choice, written once and never both. Characters are left out of it: a Character note keeps its stat block fence under its heading, derived from its Build, whatever the Workspace chose. The choice is recorded in the Workspace Config (`stat_blocks: true` or `false`); Setup asks for it, recommending stat blocks when Fantasy Statblocks is installed and Markdown when it is not. The statistics come last in a note, after its images and its description: a monster reads picture, lore, then numbers. This amends [ADR 0006](0006-keys-a-plugin-reads-stay-in-english.md), whose stat block was a view derived from the body, beside it.

## Considered Options

- **Both, the fence as a derived view of Markdown stat lines** (the earlier rule). Rejected: the DM reads every number twice, and the two copies must be kept in step at every Import, level-up and Promotion.
- **Always a fence.** Rejected: the plugin is optional, and without it the DM sees raw YAML.
- **Always Markdown.** Rejected: the plugin's rendering and bestiary, and MapForge, need a fence ([ADR 0006](0006-keys-a-plugin-reads-stay-in-english.md)).
- **The fence right under the heading**, where the plugin's own examples put it. Rejected: the DM wants the picture and the lore first, as a Monster Manual page reads.

## Consequences

- **Links never live only in a fence**, because Obsidian does not index them there. A monster whose statistics link to other notes (the spells it casts) keeps those links on a line under the fence.
- **Changing the choice is a Setup re-run**, which converts every monster and NPC note, like a folder rename: each note is converted from itself, with the same values and translations, between the fence and DM Realm's Markdown format. An edit to the Workspace Config alone changes nothing until then.
- **Markdown means no MapForge**: it places creatures from their stat blocks.
