# The Table Record enters a Session as its Live Notes

What MapForge records of a played Session — its Table Record — is written into that Session's Live Notes, by a skill of its own that does nothing else, and Consolidation keeps one source: the Live Notes. The Table Record goes after the DM's own words, one subsection per MapForge Session Log, marked with the log's file name so it is never written twice: the DM's comments word for word, each change of Map, and each fight as it ended — rounds, each Combatant's hit points and conditions, who dropped to 0 — with Pawns under the labels MapForge gives them. Once written, it is Live Notes like the rest: kept word for word, and read by Consolidation as it reads the DM's shorthand.

## Considered Options

- **Consolidation reads the Table Record beside the Live Notes**, as two sources of truth (decided first, on #22). Rejected: Consolidation would need rules for matching, merging and settling disagreements between two sources, the DM could not see or correct what it would read before running it, and a Session's record would live partly outside the Workspace's notes.
- **Consolidation imports the Table Record as its first step.** Rejected: Consolidation is already one preview and one yes; bringing in the evening's record is a separate step the DM may want to read and edit first.
- **Every line of the Table Record** (moves, rolls, each Turn's changes). Rejected: Live Notes are what Consolidation reads for the Recap and Party State; moves and rolls tell neither, and they would bury the DM's comments.

## Consequences

- Live Notes have two authors, the DM and this skill, and one rule: they are never rewritten, summarised or deleted.
- Consolidation is unchanged by MapForge: a Session played without it has Live Notes as before.
- MapForge's files are only read ([ADR 0011](0011-dm-realm-reads-mapforges-files-and-writes-them-only-when-the-dm-asks.md)).
