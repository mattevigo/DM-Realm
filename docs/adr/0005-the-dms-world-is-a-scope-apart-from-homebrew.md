# The DM's World is a Scope apart from Homebrew

The story elements a DM invents and reuses across Campaigns (places, NPCs, factions, pantheon, history) live in an eighth top-level folder, World, not in Homebrew. Homebrew holds only game material with mechanics: rules, classes, species, backgrounds, feats, spells, items, monsters. Porto Ladro, the harbour town a Character grew up in, is not an element of the game but of the story, and belongs to the world the DM defined. World is a Scope: a World note may link to Reference, Homebrew and World, never to an Adventure, a Campaign or a Character, and never mentions one; Campaigns, DM Tools and Characters may link to it. Official Setting lore stays in Reference, imported from the Trusted Source ([ADR 0003](0003-official-material-comes-only-from-5etools.md)); what the DM adds to an official world (a town invented in the Forgotten Realms) is World. This amends [ADR 0001](0001-scope-by-top-level-folder.md) and [ADR 0004](0004-characters-are-a-scope-above-campaigns.md): the top-level folders are eight, still fixed.

## Considered Options

- **Homebrew Setting** (the earlier `homebrew.setting`, "worlds the DM invented"). Rejected: it mixes story with mechanics, and a Campaign-only NPC or faction had no Homebrew kind to be promoted to.
- **A shared folder inside Campaigns, in the Campaign Scope.** Rejected for the reason ADR 0004 gives for Characters: a Campaign-Scope note may link to anything, so one table's story would leak into a world that other Campaigns use.
- **Official Setting lore in World too.** Rejected: official lore must stay faithful and re-importable, so it stays in Reference, and World links to it.

## Consequences

- **One subfolder per world.** An invented world is named in the DM's words; the DM's additions to an official Setting use the name of its Reference › Setting subfolder, so the two sit side by side.
- **Homebrew never links to World.** A homebrew spell stays usable in any world; its ties to an invented god are written in the World note, which may link to the spell.
- **An invented villain is split.** The NPC is a World note; its stat block is a Homebrew monster, which the World note links to.
- **Promotion reaches World.** A Campaign's place, NPC or faction wanted by a second Campaign, or by a Character's backstory, moves to World after the DM confirms, with every mention of the Campaign removed.
- **Setup and the Workspace Config gain an eighth folder**, with the key `world`. No Workspace predates this decision (DM Realm is unreleased), so none needs migrating.
