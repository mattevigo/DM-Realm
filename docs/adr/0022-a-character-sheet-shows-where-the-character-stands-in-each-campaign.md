# A Character Sheet shows where the Character stands in each Campaign

A Character Sheet shows, beside the Build's maximums, where the Character stands now: one block per Campaign whose Party State has a section for it, named by that Campaign, rendered by `player-wiki.py` from that section's known lines ([ADR 0021](0021-party-state-is-known-lines-and-the-dms-own-words.md)). It is a snapshot as Party State last recorded it, read-only, rewritten at every Player Wiki update. A Character in no Party State gets the sheet as before.

*Amends [ADR 0019](0019-a-character-sheet-is-a-page-the-player-wiki-writes-from-the-stat-block.md), whose sheet showed maximums only, and [ADR 0017](0017-the-player-wiki-is-a-copy-written-outside-the-workspace.md) and structure.md's Player Wiki, under which no part of Party State reached the wiki. Party State itself is still never copied as a note.*

## Where the script reads it

- **The notes**: the Party State note (named by the Translation Glossary) of every Campaign folder, whatever the Config's `player_wiki` lists. `chronicles` decides which Chronicles are copied, not which Campaigns' state reaches a sheet, and no Config key is added.
- **The Character's section**: the section that links to the Character's note, the link resolved like any other, never matched by the heading's text. A section that links to no Character, or to one the wiki does not copy, is not read.
- **The lines**: that section's known lines, after the DM-only filter below, and the Party State's own updated-at line, which says which Session the state dates from.
- **The block's name**: the Campaign README's title.
- **Nothing else of the Campaign** is read for the sheet, and Party State is never copied into the wiki as a note. Only Characters the wiki copies get a sheet, so a wiki without `characters` shows no Party State at all.

## Why

- **The players want to see where their Character stands**, not only what it could be at full.
- **ADR 0019's objection was to a tracker**: a sheet players edit would keep a separate truth in each browser. A read-only page from Party State keeps one truth, in the Workspace.
- **One block per Campaign** keeps ADR 0010's split: a Character in two Campaigns is wounded in one and whole in the other, and the sheet says which is which.

## Considered Options

- **One sheet per Campaign.** Rejected: the Build is one, and the players would get several sheets for one Character.
- **The current state written on the Character note or its fence.** Rejected by [ADR 0010](0010-a-characters-spent-resources-are-the-campaigns.md): one table's wounds would follow the Character into another, and MapForge reads the fence's `hp` as the maximum.

## Consequences

- **Party State is filtered as World and Homebrew are** before the script reads it: sections under the Config's `dm_only_headings` and `%% … %%` comments are dropped.
- **Only a Character's known lines reach its sheet**: never the DM's own words, the notes in parentheses, the Party treasure, or the Campaign homebrew a Character carries, which the whole table would see.
- **The sheet can be stale by one Session**: it shows the last Consolidation, or the DM's last direct change.
