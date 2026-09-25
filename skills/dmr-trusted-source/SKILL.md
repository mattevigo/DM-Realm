---
name: dmr-trusted-source
description: Official D&D data for DM Realm — the Trusted Source (5etools data) through the Source Cache. Load before answering a D&D rules question, or reading or writing any official rules text, stat block or game entry, in a DM Realm Workspace.
user-invocable: false
allowed-tools: Read, Grep, Bash(sh:*), Bash(DMR_SOURCE_CACHE=*)
---

# Trusted Source

Official D&D material comes only from the Trusted Source, read through the Source Cache. The rules — no other source, no memory, what the Edition decides, never shipping data — are in the `dmr-workspace` skill's structure.md, sections "Edition" and "Official data"; load `dmr-workspace` first if it is not loaded yet. This skill is how to reach the data.

## Getting a file

Every file comes from the Source Cache helper next to this file, `source-cache.sh`. Run it with the cache directory below:

```sh
DMR_SOURCE_CACHE="${CLAUDE_PLUGIN_DATA}/source-cache" sh "<this skill's base directory>/source-cache.sh" file data/conditionsdiseases.json
```

- It prints the local path of the file, fetched from the pinned release the first time it is needed; read that path with Read and Grep.
- `release` instead of `file …` prints the pinned release.
- **Exit 3** means the Trusted Source cannot be reached and the file is not cached: tell the DM so and stop. The answer comes from the Trusted Source or not at all.

## Where things are

| Material | File (`data/…`) | Key |
| --- | --- | --- |
| Conditions, diseases | `conditionsdiseases.json` | `condition`, `disease` |
| Actions (Grapple, Dash…) | `actions.json` | `action` |
| Rules glossary entries | `variantrules.json` | `variantrule` |
| Spells | `spells/spells-<book>.json` (e.g. `spells-xphb.json`, `spells-phb.json`); `spells/index.json` lists the books | `spell` |
| Monsters | `bestiary/bestiary-<book>.json` (e.g. `bestiary-xmm.json`); `bestiary/index.json` lists the books | `monster` |
| Magic items; mundane gear and weapons | `items.json`; `items-base.json` | `item`; `baseitem`, `itemMastery` |
| Feats, species, backgrounds | `feats.json`, `races.json`, `backgrounds.json` | `feat`, `race`, `background` |
| Classes and subclasses | `class/class-<name>.json`; `class/index.json` | `class`, `subclass` |
| Books and their publication dates | `books.json` | `book` |

## Finding the entry for the Edition

1. Grep the file for `"name": "<English name>"`, then Read the lines around each match: each entry has `source` (a book code) and `page`.
2. Take the entry from a book of the Workspace's Edition (Workspace Config `edition`): 2024 books are those `books.json` dates on or after the 2024 Player's Handbook (XPHB, 2024-09-17) — XPHB, XDMG, XMM…; 2014 books are the earlier ones — PHB, DMG, MM…. A 2014 entry's `reprintedAs` names its 2024 version.
3. Only when the Edition has no version of it is the other Edition's entry used, and then say so (Off-Edition Material).

## Answering a rules question

Answer from the entry, in the Workspace Language, and name its book and page, e.g. "Player's Handbook (2024), p. 367 (XPHB)". Render 5etools tags as plain text: `{@condition incapacitated}` → incapacitated, `{@dc 15}` → DC 15, `{@damage 2d6}` → 2d6. Writing a note is a separate request; answering creates none.

Done when every rules statement in the answer comes from an entry you read, cited by book and page.
