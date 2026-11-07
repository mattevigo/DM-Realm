# An item note says so in its frontmatter

MapForge can say which item a Treasure Pawn is, and the Treasure then wears the item's Portrait as its Face. The list it picks from, its Treasury, is every note in the Workspace that says it is an item (MapForge ADR-0031). So every DM Realm item note says so, in two English frontmatter keys: `item: true` on every one, picture or not, and `image:` naming its Portrait, the first picture of its Description, as a wikilink with the picture's full path, exactly as a monster's statistics name theirs. The picture stays embedded in the body. Which notes are item notes — Equipment but its Weapon_Masteries, Magic_Items, an Adventure's Items, and their Homebrew and Campaign counterparts — is DM Realm's rule; MapForge reads only the keys.

## Considered Options

- **A stat block fence for items.** Rejected: an item has no statistics, and every Fantasy Statblocks fence enters the plugin's bestiary, so the Borsa would be listed, and placed, as a monster. Frontmatter is where a note says what it is, and Obsidian indexes a link there, so a rename in Obsidian keeps `image:` up to date, which it does not do inside a fence.
- **Translated keys** (`oggetto: vero`, `immagine:`). Rejected for the reason of [ADR 0006](0006-keys-a-plugin-reads-stay-in-english.md): a tool reads fixed keys, and MapForge reads these in every Workspace Language. `item` is the YAML boolean `true`, never a translated word.
- **MapForge finds items by their folder.** Rejected: folder names are translated and the DM may rename them, so MapForge would need DM Realm's layout and every Translation Glossary; MapForge refuses to guess an item from where it sits, as it refuses to guess a Portrait from a note's body (MapForge ADR-0028).

## Consequences

- An item note's frontmatter holds the source property, when it has one, then `item: true`, then its Portrait. An item made from the Homebrew_Item Template, which has no frontmatter, gains both keys.
- An item with no picture is still in the Treasury, and its Treasure keeps its colour.
- Item notes imported before this change get the keys from the same helper that backfills monsters' Portraits, which every Import and Setup re-run runs; an `image:` the DM set is kept.
- A note moved into or out of an item folder by hand keeps or lacks the keys until the helper runs; the helper only adds, so a note moved out of one keeps `item: true` until the DM removes it.
- ADR 0006's closed list of English keys gains `item` and `image` in frontmatter.
