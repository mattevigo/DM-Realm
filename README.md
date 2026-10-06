# DM Realm

A [Claude Code](https://claude.com/claude-code) plugin for D&D 5th-edition Dungeon Masters. It sets up and maintains a **Workspace**: a folder of Markdown notes for your campaigns that you open in [Obsidian](https://obsidian.md) as a vault.

- **2014 or 2024 rules.** You choose the Edition at Setup.
- **Any language.** Every folder, file name and generated note is written in the language you choose, using the publisher's official translation of game terms where one exists.
- **Official material imported, not invented.** Spells, monsters, items, classes and the rest come from one machine-readable data source and are cited by book and page, never written from the model's memory.
- **The whole Session loop.** Prepare a Session, take live notes at the table, consolidate it into a recap and Character updates, then tell it as a Chapter for your players.

## Requirements

- Claude Code
- Obsidian, to read and edit the Workspace (optional, but it is what the Workspace is built for)
- `python3` and `curl` on your `PATH`
- Optional Obsidian community plugin: **Fantasy Statblocks**, which renders monsters, NPCs and Characters as stat blocks. Setup configures it when it is installed.
- Optional: **MapForge**, whose session log DM Realm can bring into a Session's notes

## Install

In Claude Code:

```
/plugin marketplace add mattevigo/DM-Realm
/plugin install dm-realm@dm-realm
```

## Getting started

1. Make an empty folder for your Workspace and start Claude Code in it.
2. Run `/dm-realm:dmr-setup`. It asks for the Workspace Language and the Edition, then creates the folders and the Obsidian settings.
3. Open the folder in Obsidian as a vault.
4. Ask in plain words: "start a new campaign called Heroes of the Border", "add the Goblin", "a new character for Baldu", "prepare the next session".

If you are not sure what to do next, ask: `/dm-realm:dmr-ask what should I do now?`

## Skills

You can run any skill with its command, `/dm-realm:<skill>`, or just describe what you want.

| Skill | What it does |
| --- | --- |
| `dmr-setup` | Turns the current folder into a Workspace. Run it again to rename top-level folders or reinstall the Obsidian settings and stat block layouts. |
| `dmr-ask` | Answers questions about DM Realm, your campaigns and the rules, without changing anything. |
| `dmr-import` | Imports official entries (spells, monsters, items, feats, classes, species, backgrounds, conditions, rules) into Reference, translated. |
| `dmr-campaign` | Starts a Campaign: its folder and a README with the pitch, world, party, tone and table limits. |
| `dmr-character` | Creates, levels up or changes a Character, or transfers one from an old vault. |
| `dmr-session-prepare` | Creates the next Session's note and fills in its prep from the loose threads and your idea. |
| `dmr-mapforge-import` | Brings MapForge's record of a played Session into its live notes. |
| `dmr-session-consolidate` | Closes a played Session: recap, loose threads, party state, diary and Character changes. |
| `dmr-session-narrate` | Tells a consolidated Session as prose for the players, in the voice you set. |

## Official data

Official material is fetched when first needed into a local **Source Cache**. The cache is shared by your Workspaces, pinned to one release, and refreshed only when you ask. DM Realm ships none of this data.

## Legal

DM Realm is unofficial Fan Content permitted under the Fan Content Policy. Not approved/endorsed by Wizards. Portions of the materials used are property of Wizards of the Coast. ©Wizards of the Coast LLC.

## Development

- `CONTEXT.md` defines the domain language, and `docs/adr/` records the design decisions.
- The Workspace rules live in one place: [`skills/dmr-workspace/structure.md`](skills/dmr-workspace/structure.md).
- Try a change locally: in an empty folder, run `claude --plugin-dir <path to this repo>`, then `/dm-realm:dmr-setup`.
- Fast script tests: `for t in tests/*.test.sh; do sh "$t"; done`
- Agent evals live in `evals/`. See `CLAUDE.md` for how to run them.

## License

[MIT](LICENSE)
