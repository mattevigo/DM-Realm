# A Character's spent resources are the Campaign's, its items and coins the Build's

Consolidation has to put somewhere what the Session did to the party: items gained and lost, coins, attunement, and the hit points, spell slots and class uses spent. They are split by kind. A Character's own items, coins and attunement are its Build: Consolidation shows the DM the lasting changes and, on a yes, edits the Character note, which still names no Campaign and no Session, while the Session note keeps the event. What the Character has spent — hit points, spell slots, class uses, conditions — and the treasure the party holds in common are that table's state: they live in the Campaign's Party State, one note that holds only where the party stands now, and never on the Character note. This amends [ADR 0004](0004-characters-are-a-scope-above-campaigns.md), under which a Session never changed a Character note; its boundary stands: a Character still carries no table's story.

## Considered Options

- **Everything in the Campaign** (one Campaign note for all of it; Consolidation never touches a Character note). Rejected: the Build would go stale after the first Session, the stat block derived from it would be wrong at the table, and a second Campaign would get the Character without the sword it won.
- **Everything on the Character** (spent slots and current hit points on its note, with a line per Session). Rejected: it reverses ADR 0004. A Character who plays in two Campaigns would bring one table's wounds and story into the other, and its note would have to name Sessions.

## Consequences

- **One Party State note per Campaign, with a section per Character.** A Character in two Campaigns is wounded in one and whole in the other; its items and coins, being its Build, are the same in both.
- **Party State keeps no history.** Each change overwrites the Character's section; what was spent when is in the Session notes.
- **Shared treasure is the Campaign's** until a Character takes it, when it moves to that Character's Build.
- **Campaign homebrew a Character gains** still needs Promotion first, as ADR 0004 says.
