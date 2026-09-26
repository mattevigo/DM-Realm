# An Import renders only what the Trusted Source contains, with DM Realm's own helper

An Import turns one 5etools entry into Markdown with a rendering helper that DM Realm ships and tests, never with 5etools' own JavaScript and never with the agent's memory. The helper resolves the entries 5etools defines as copies of others (`_copy` with `_mod`, about a quarter of all monsters, most of an Adventure's bestiary) for the modifiers the data uses, and refuses an entry whose modifier it does not know: the agent then writes nothing, rather than a half-resolved note. For the same reason an Import never builds an entry the data does not hold: 5etools generates "+1 Longsword" or "Flame Tongue Greatsword" at runtime from a generic variant and a base item, so asking for one imports the generic variant ("+1 Weapon", "Flame Tongue"), and the agent says so. This applies [ADR 0003](0003-official-material-comes-only-from-5etools.md): every note's text is text the Trusted Source contains, at the book and page its source property records.

## Considered Options

- **Run 5etools' own loader (Node) from the Source Cache.** Rejected: an exact resolution, but it adds a Node dependency and runs code fetched from the internet on the DM's machine.
- **Refuse every `_copy` entry.** Rejected: it would block most Adventure monsters.
- **Build specific magic items as 5etools displays them.** Rejected: the note's text would exist in no book, and each generic variant would have dozens of homes.

## Consequences

- **A new modifier in a later release makes an Import fail loudly**, not wrongly; supporting it is a change to the helper and its script tests.
- **The helper renders in English and deterministically**; the agent only translates its output.
