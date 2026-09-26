# Transfer a Character

Bring a Character into this Workspace from outside it: a free-form Markdown note from an old vault, or a Character folder from another DM Realm Workspace. What comes is its identity and its Build; its table's story, its play state and its copied official text stay behind. Other sources (PDF, HTML, D&D Beyond) are not supported: say so. The note's format, links and rules values are in [SKILL.md](SKILL.md).

**The source is read-only**: read it and leave every file in it as it was.

1. **Read the source**: the note, or the Character folder's note and its past Builds (another Workspace's Past_Builds, or an old vault's numbered copies of the note, such as an `Archivio/<Name>_0…4`), in their order.
2. **Check the name.** A Character folder of that name already in this Workspace: stop, say so, and ask for another name or to cancel. A Transfer never overwrites or merges into a Character.
3. **Sort the source**, line by line, into:
   - **Identity** — backstory, appearance, personality, the player. It comes, in the DM's words, and follows SKILL.md's "Backstory and the DM's world": a place, NPC or faction of a Campaign is asked about, never carried in silently.
   - **Build** — species, class and level, subclass, background, ability scores, proficiencies, features, feats, spells, equipment, coins, attunement. It comes, as options to link (step 4). Scores the source gives only as totals are kept as totals.
   - **Table story** — anything that happened at a table: Sessions, a Campaign's name, events, where an item was found, who owes whom. It is dropped, and listed for the DM.
   - **Play state** — current hit points, spent slots, checkboxes, conditions, uses left. It is dropped, and listed.
   - **Copied official text** — rules text, stats or descriptions copied from a book (a feature's or spell's text). It is dropped, and listed; the option links to its Reference note instead.
   What is dropped stays in the source; this Transfer writes it nowhere.
4. **Map the current Build's options** to this Workspace's Edition, one by one, finding each version as `dmr-import`'s step 4 does: the Edition's own, its reprint, or Off-Edition Material, whose player options need the DM's consent. A refused option is left out and listed, and the DM picks its replacement as a creation choice ([create.md](create.md), step 2). A multiclass Build keeps its classes as they are.
5. **Translate** everything into the Workspace Language, as structure.md's "Language and names" says: game terms through the Translation Glossary, headings, labels, frontmatter keys and values, and the identity's text. Names stay the DM's: the Character's, and those structure.md's Translation Glossary section lists.
6. **Preview**, in one message, and end your turn:
   - the path of the new Character note, and each past Build's;
   - what comes: the identity, and the Build with each option as it will be linked (its Edition's version, or Off-Edition), each Reference note to import;
   - what is dropped: the table story, the play state and the copied official text, item by item;
   - each question: Off-Edition consent, a refused option's replacement, a Campaign place in the backstory, any other choice the source leaves open.

   Continue on an explicit go-ahead from the DM, with every question answered; one already in the request counts ("go ahead", "no preview needed"). Until then the Workspace stays as it is.
7. **Write**:
   1. Import each missing Reference note with `dmr-import`, one at a time.
   2. The Character note, in SKILL.md's format: `status` active unless the source says retired or dead, `level` from the Build; every number in Statistics recomputed from the Build and the Trusted Source rules, not copied.
   3. The past Builds, as history, at the past Build paths structure.md's Characters section gives, numbered in the source's order. Each keeps what it said about the Build, with its options as plain-text names — no links, no official text, not mapped to the Edition, no consent asked — and the frontmatter `player` and `level` only, and the past Build callout linking to the current note (as [level-up.md](level-up.md), step 3, writes it). Drop its table story and play state as in step 3.
8. **Report**: the note's path and each past Build's, each Reference note imported, each option replaced by its Edition's version, each Off-Edition option, and everything dropped — table story, play state, copied official text — item by item. Say that the source was left as it was.

Done when the Character note and its past Builds are written as previewed, every dropped item is listed for the DM, and the source is unchanged.
