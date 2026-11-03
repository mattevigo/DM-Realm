# An Adventure note links to what is not imported yet

An Adventure is imported one Part at a time, so its notes name things the Workspace may not hold yet: a monster the DM declined to bring in, or an area in a Part not imported (41% of *Curse of Strahd*'s area references reach another Part). An Adventure note writes these as links from the start, and each link begins to work when its target arrives. A monster or magic item links to the path its Reference note will have, always as a path link, and a reference into another Part links to that Part's note, whose path follows from the book's contents, so it reaches the Part and not the exact room. Nothing rewrites the older note, which by then is translated text.

This is the only place a link may point at a note that does not exist. Reference notes keep their rule of no links between them, and a Campaign README still names an Adventure not in the Workspace without linking it.

## Considered Options

- **Plain text, rewritten into a link when the target is imported.** Rejected: every Import would have to find a translated mention in notes it did not just write, and a miss leaves a mention that looks finished and never links.
- **Import everything a Part links to first.** Rejected: the 41% would pull in most of the book, which is what importing by Part avoids, and the DM may decline a monster.
- **Link a reference into another Part to the exact note.** Rejected: which note holds an area is only decided when that Part is imported.

## Consequences

- An unresolved link shows as one in Obsidian, and clicking it creates an empty note at that path. An Import therefore treats an empty note at its path as not imported, and writes over it.
- A link's path must be known before its target exists, so the translated name is chosen, and recorded in the Translation Glossary, when the link is written.
- Once a Part is imported, a reference to it from an older Part still lands on its Part note, one step from the room.
