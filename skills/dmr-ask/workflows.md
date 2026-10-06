# DM Realm workflows

How DM Realm's skills fit together: the order a DM uses them in, and what has no skill yet. What each skill does is its own description; the Workspace rules are structure.md's. The DM runs a skill by asking in plain words or with its command, `/dm-realm:<skill>`.

## Starting

1. `dmr-setup`, run only by its command, in the folder that is to become the Workspace. Run again in a Workspace, it is how top-level folders are renamed or added back, and how DM Realm's Obsidian settings and stat block layouts are installed again.
2. `dmr-import` for the official entries the Campaign needs, as they are needed.
3. `dmr-campaign` to start a Campaign.
4. `dmr-character` for each player's Character: created, or brought in by a Transfer.

## The Session loop

1. `dmr-session-prepare` before a Session — or a Side Session — is played, once the previous one is consolidated.
2. **Play**: the DM writes the Live Notes in the Session note, in Obsidian.
3. `dmr-mapforge-import`, when MapForge was used at the table.
4. `dmr-session-consolidate` once the Session is played.
5. `dmr-session-narrate`, when the DM keeps a Chronicle, once the Session is consolidated.

Between Sessions, a Character's level-ups and other changes go through `dmr-character`.

## Any time

- `dmr-ask` for a question.
- **Notes no skill writes** — a Campaign's NPCs, Places, Quests and Factions, Homebrew, World, House Rules, DM Tools — and **Promotion**: asked for in plain words; the agent writes them by the Workspace rules.
- **Refreshing the Source Cache**: asked for in plain words.

## Not built yet

- **Migrate**: no skill does it. Its parts that have one, in a Workspace Setup already created: `dmr-import` for the official material, a Transfer through `dmr-character` for each Character. The DM's own notes have no skill to carry them over.
- **Importing an Adventure** into the Workspace: no skill does it yet. A question about an Adventure's text is still answered, by Research.
