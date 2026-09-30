# Official material comes only from 5etools, through a shared Source Cache

Reference and Adventure content is imported, translated and researched only from the 5etools data as published in its public source mirror (`5etools-mirror-3/5etools-src`), never from a DM's books, another site or the agent's memory. A single machine-readable source makes every import repeatable and checkable, and lets a later errata be found and re-imported. The data is kept in one Source Cache per machine, outside every Workspace, pinned to one release and refreshed only when the DM asks; DM Realm never ships any of it.

*Amended by [ADR 0008](0008-an-imports-images-come-from-the-trusted-sources-image-mirror.md): the Trusted Source includes 5etools' image mirror at the same release, and an Import brings the entry's images.*

## Considered Options

- **The DM's own books (pasted text).** Rejected: not repeatable, not checkable, and a refresh has nothing to compare against.
- **A fallback source when the mirror is unreachable** (e.g. `dnd5eapi.co`, as DM Workspace did). Rejected: two sources can disagree. When an entry is neither cached nor reachable, the agent stops and tells the DM.
- **The cache inside each Workspace** (as DM Workspace keeps it in a visible folder). Rejected: the English data is the same for every Workspace, it would break [ADR 0002](0002-dm-realm-is-a-plugin-separate-from-the-workspace.md)'s "Workspace Config is the only DM Realm file", and the per-Workspace part — translations — already lives in the Translation Glossary.
- **Fetching each file from the latest release when first needed.** Rejected: files from different releases drift apart. Every file is fetched from the pinned release.
- **Bundling data with the plugin** (starter pack, eval fixtures). Rejected: the mirror's MIT license covers its code, not the Wizards of the Coast content it transcribes.

## Consequences

- The 5e.tools website itself is not used: it sits behind a bot challenge.
- The edition of a book is the one 5etools gives it (before or after the 2024 Player's Handbook), so DM Realm keeps no list of its own.
- The rule covers official content (rules text, stats, descriptions), not the names of translated game terms, which follow the Workspace's translation steps.
- The Edition gates only rules material; Adventures and Setting lore from any book are imported normally.
