# DM Realm workflows

How DM Realm's skills fit together: the order a DM uses them in, and what has no skill yet. What each skill does is its own description; the Workspace rules are structure.md's. The DM runs a skill by asking in plain words or with its command, `/dm-realm:<skill>`.

## Starting

1. `dmr-setup`, run only by its command, in the folder that is to become the Workspace. Run again in a Workspace, it is how top-level folders are renamed or added back, how DM Realm's Obsidian settings and stat block layouts are installed again, and how stat blocks and item notes written before DM Realm named their Portrait get one, item notes their `item: true`, and spell notes their Classes line, up to date.
2. `dmr-import` for the official entries the Campaign needs, as they are needed — an item an Adventure introduces goes into that Adventure — and `dmr-import-adventure` for the Adventure it runs, a Part at a time or whole.
3. `dmr-campaign` to start a Campaign.
4. `dmr-character` for each player's Character: created, or brought in by a Transfer.

## The Session loop

1. `dmr-session-prepare` before a Session — or a Side Session — is played, once the previous one is consolidated. The Adventure's next Part, when the party reaches it, comes in through `dmr-import-adventure`.
2. **Play**: the DM writes the Live Notes in the Session note, in Obsidian.
3. `dmr-mapforge-import`, when MapForge was used at the table.
4. `dmr-session-consolidate` once the Session is played.
5. `dmr-session-narrate`, when the DM keeps a Chronicle, once the Session is consolidated.

Between Sessions, a Character's level-ups and other changes go through `dmr-character`.

## Sharing with the players

- `dmr-player-wiki` writes the Player Wiki, a copy for the players of what the DM chooses (Reference, Homebrew, World, Characters, the Chronicles), outside the Workspace. It is written again whenever the DM asks, typically after a new Chapter.
- **Publishing it** as a website is not built yet: the DM builds the folder with a wiki generator (such as Quartz) and hosts it privately.

## Any time

- `dmr-ask` for a question.
- **Notes no skill writes** — a Campaign's NPCs, Places, Quests and Factions, Homebrew, World, House Rules, DM Tools — and **Promotion**: asked for in plain words; the agent writes them by the Workspace rules.
- **Refreshing the Source Cache**: asked for in plain words.

## Not built yet

- **Publishing the Player Wiki**, and putting a Campaign's NPCs, Places or other notes in it: no skill does either yet.
- **Migrate**: no skill does it. Its parts that have one, in a Workspace Setup already created: `dmr-import` for the official material, a Transfer through `dmr-character` for each Character. The DM's own notes have no skill to carry them over.
