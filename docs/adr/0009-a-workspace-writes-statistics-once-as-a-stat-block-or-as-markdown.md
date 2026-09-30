# A Workspace writes statistics once, as a stat block or as Markdown

Each Workspace chooses, at Setup, whether its notes' game statistics are Fantasy Statblocks fences or Markdown, and every note with game statistics — Reference and Homebrew monsters, Adventure and Campaign NPCs, Characters — follows that choice, written once and never both. The choice is recorded in the Workspace Config (`stat_blocks: true` or `false`); Setup recommends stat blocks when Fantasy Statblocks is installed and Markdown when it is not. The statistics come last in a note, after its images and its description: a monster reads picture, lore, then numbers. This amends [ADR 0006](0006-keys-a-plugin-reads-stay-in-english.md), whose stat block was a view derived from the body, beside it.

## Considered Options

- **Both, the fence as a derived view of Markdown stat lines** (the earlier rule). Rejected: the DM reads every number twice, and the two copies must be kept in step at every Import, level-up and Promotion.
- **Always a fence.** Rejected: the plugin is optional, and without it the DM sees raw YAML.
- **Always Markdown.** Rejected: the plugin's rendering and bestiary, and MapForge, need a fence ([ADR 0006](0006-keys-a-plugin-reads-stay-in-english.md)).
- **The fence right under the heading**, where the plugin's own examples put it. Rejected: the DM wants the picture and the lore first, as a Monster Manual page reads.

## Consequences

- **Links never live only in a fence**, because Obsidian does not index them there. A Character's Build, with its links, stays in the body in both modes; only its Statistics section becomes the fence. A monster whose statistics link to other notes (the spells it casts) keeps those links on a line under the fence.
- **Changing the choice is a Setup re-run**, which converts every note with game statistics, like a folder rename: each note is converted from itself, with the same values and translations, between the fence and DM Realm's Markdown format. An edit to the Workspace Config alone changes nothing until then.
- **Markdown means no MapForge**: it places creatures from their stat blocks.
