# Party State is known lines, and the DM's own words around them

A Character's section of Party State is made of **known lines**: one per kind of spent resource (hit points, temporary hit points, spell slots, Hit Dice, uses of limited features, casts without a slot, spent charges of its magic items, conditions, exhaustion, Inspiration, active effects, death saving throws, Campaign homebrew carried), each starting with its label from the Translation Glossary, then its value as written (`53 su 57`, `da 0 a 3 su 7`, `non indicato`), then, if the DM wants it, a note in parentheses. One more known line opens the note: the updated-at line, linking to the Session the state dates from, and saying when the DM has changed it since. A script reads the known lines by their labels. Everything else in the note — a paragraph, a line with another label, a section such as one for what is still to be settled, the section of a Character who died — is **the DM's own**: every skill keeps it byte for byte and no script reads it. What Party State holds, and that it keeps no history, is unchanged ([ADR 0010](0010-a-characters-spent-resources-are-the-campaigns.md)).

## Why

- **A script must read it.** The Character Sheet shows where a Character stands ([ADR 0022](0022-a-character-sheet-shows-where-the-character-stands-in-each-campaign.md)), and the Player Wiki is written by a script that gives the same page for the same notes ([ADR 0017](0017-the-player-wiki-is-a-copy-written-outside-the-workspace.md)). Free Markdown cannot be read that way.
- **The DM reads and edits it in Obsidian.** A labelled list renders as text; a YAML fence would show as raw YAML, since no plugin renders it.
- **Labels come from the Translation Glossary**, which `character-sheet.py` already reads for its own labels, so no frontmatter key or fence key has to stay English ([ADR 0006](0006-keys-a-plugin-reads-stay-in-english.md) is unchanged).
- **DMs write around the numbers.** The author's own Party State, after thirty Sessions, holds open questions, companions and a dead Character's line beside the numbers. A format that rejected them would lose what the DM wrote.

## Considered Options

- **A YAML fence per Character, with English keys.** Rejected: raw YAML in Obsidian, and a new exception to ADR 0006 for keys only DM Realm reads.
- **Free Markdown, with the agent putting the state on the sheet.** Rejected: the sheet would no longer be the same page for the same notes, and no test could check it.
- **Known lines only, nothing else allowed.** Rejected: it would throw away the DM's own notes at every write.

## Consequences

- **A known line the script cannot read is left off the sheet** and named in the report. Its note in parentheses never reaches the sheet.
- **An older Party State is rewritten once into this format**, after a preview and on the DM's yes: offered by the first skill about to write it, or asked for directly through `dmr-campaign`. Every value is kept; what is the Build's (item counts, attunement, what is worn, damage) stays where it was, as the DM's own words, and is listed against the Build for the DM to settle; a value with no known line is listed too; the DM's own words stay.
- **A value nobody recorded is written as not given** (in the Workspace Language), never guessed.
