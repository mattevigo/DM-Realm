# Keys a plugin reads stay in English

Every frontmatter key in a Workspace is in the Workspace Language, with one exception: the keys an Obsidian plugin or table tool reads stay in English. Stat blocks are rendered by Fantasy Statblocks (`obsidian-5e-statblocks`), and MapForge, the initiative tracker, reads the same stat blocks from the notes. Both, along with the plugin's dice parsing, look for fixed English keys: the `statblock` flag in frontmatter, and `name`, `ac`, `hp`, `initiative`, `size`, `stats`, `actions`… in the ```` ```statblock ```` fence. So those keys stay English, while every value is in the Workspace Language (`size: Piccola`, an action named "Scimitarra") and the layout's labels ("Classe Armatura", FOR DES COS) are translated through the Translation Glossary. DM Realm's own keys (`player`, `status`, `level`, the source property) are still translated.

## Considered Options

- **Translated keys, with custom layouts mapping them.** Rejected: a layout can read any property name, but MapForge, the dice parsing ("+4 to hit") and the plugin's importers cannot, so stat blocks would render and still fail at the table.
- **No stat blocks, only DM Realm's own translated keys.** Rejected: the DM wants the plugin's rendering and bestiary, and MapForge needs a stat block to put a creature on the map.

## Consequences

- **The exception is closed.** `structure.md` lists the plugin-owned keys; any other frontmatter key is in the Workspace Language.
- **The plugin is optional.** A note stays correct without it: the stat block is a view derived from the note's body, never the only place a value or a link lives, since Obsidian does not index links inside a fence.
- **Labels are game terms.** Translating a layout's labels records them in the Translation Glossary, so the stat block and the notes use the same words.
