---
name: dmr-trusted-source
description: Official D&D data for DM Realm — the Trusted Source (5etools data) through the Source Cache. Load before answering a question about official D&D material (a rule, an entry, an Adventure's or a Setting's text), or reading or writing any official rules text, stat block or game entry, in a DM Realm Workspace.
user-invocable: false
allowed-tools: Read, Grep, Bash(sh:*), Bash(DMR_SOURCE_CACHE=*)
---

# Trusted Source

How to reach the Trusted Source through the Source Cache. The rules that govern it — sources, the Edition, Off-Edition Material, research, refreshing — are in the `dmr-workspace` skill's structure.md, sections "Edition" and "Official data"; load `dmr-workspace` first and follow them.

**Writing an entry into the Workspace is an Import**: invoke the `dmr-import` skill, whose helper renders the entry. An entry's text is never written from the raw data by hand.

## Getting a file

Every file comes from the Source Cache helper next to this file, `source-cache.sh`. Run it with the cache directory below:

```sh
DMR_SOURCE_CACHE="${CLAUDE_PLUGIN_DATA}/source-cache" sh "<this skill's base directory>/source-cache.sh" file data/conditionsdiseases.json
```

- It prints the local path of the file, fetched from the pinned release the first time it is needed; read that path with Read and Grep.
- `image <path>` instead of `file …` does the same for an image, by the path an entry gives it (`bestiary/MM/Goblin.webp`), from the Trusted Source's image mirror at the pinned release. The Import's helper fetches an entry's images itself; call it directly only to look at one.
- `release` instead of `file …` prints the pinned release.
- `refresh` updates the Source Cache, its images included — run it only when the DM asks. It prints the old and the new release (or that the cache is up to date) and any cached file the new release no longer has; report that to the DM.
- **Exit 4**: the pinned release has no such file or image — check the path against the table below.
- **Exit 3**: the Trusted Source cannot be reached and the file is not cached (or a refresh could not complete, and the cache stays on its release): tell the DM so and stop there.

## Where things are

| Material | File (`data/…`) | Key |
| --- | --- | --- |
| Conditions, statuses, diseases | `conditionsdiseases.json` | `condition`, `status`, `disease` |
| Actions (Grapple, Dash…) | `actions.json` | `action` |
| Rules glossary entries, optional and variant rules | `variantrules.json`; the ones 5etools extracts from books (e.g. the XDMG's) in `generated/gendata-variantrules.json` | `variantrule` |
| Senses, skills | `senses.json`, `skills.json` | `sense`, `skill` |
| Spells | `spells/spells-<book>.json` (e.g. `spells-xphb.json`, `spells-phb.json`); `spells/index.json` lists the books | `spell` |
| Which classes have a spell (class spell lists) | `spells/sources.json` | by book, then spell name: `class` |
| Monsters | `bestiary/bestiary-<book>.json` (e.g. `bestiary-xmm.json`, or an Adventure's code); `bestiary/index.json` lists the books; `bestiary/template.json` holds the templates copies apply | `monster`; `monsterTemplate` |
| Magic items and special gear; mundane gear, weapons and Weapon Mastery properties | `items.json`; `items-base.json` | `item`; `baseitem`, `itemMastery` |
| Generic magic variants ("+1 Weapon", "Flame Tongue") | `magicvariants.json` (book and page under `inherits`) | `magicvariant` |
| Feats, backgrounds | `feats.json`, `backgrounds.json` | `feat`, `background` |
| Species (races) and subraces | `races.json` | `race`, `subrace` |
| Classes and subclasses | `class/class-<name>.json`; `class/index.json` | `class`, `subclass` |
| Class options (Maneuvers, Eldritch Invocations, Metamagic, 2014 Fighting Styles…) | `optionalfeatures.json` | `optionalfeature` |
| Books, Adventures and their publication dates | `books.json`, `adventures.json` | `book`, `adventure` |
| An entry's description ("fluff": what a monster, species, background, class or item is like) | `fluff-<its data file>` beside it (`bestiary/fluff-bestiary-xmm.json`, `fluff-races.json`); a base item's is in `fluff-items.json` | `<key>Fluff` (`monsterFluff`, `raceFluff`…) |
| An Adventure's text: its chapters, places, NPCs and events | `adventure/adventure-<id>.json`, the id lowercased (`adventure-lmop.json`); `adventures.json` lists the Adventures, their ids and chapters | `data`: sections by `name`, with `page` |
| A book's own text: character creation and advancement (ability score methods, point costs, hit points, proficiency bonus) and other rules no entry holds; a Setting book's lore | `book/book-<book>.json`, the code lowercased (`book-xphb.json`, `book-scag.json`); `books.json` lists the books | `data`: sections by `name` |

## Finding the entry for the Edition

1. Grep the file for `"name": "<English name>"`, then Read the lines around each match: each entry has `source` (a book code) and `page`.
2. For rules material, take the entry from a book of the Workspace's Edition in use (structure.md, "Fixed after Setup"). A book's Edition follows its `published` date in `books.json` (an Adventure's in `adventures.json`), as structure.md's "Edition" section defines it. A 2014 entry's `reprintedAs` names its 2024 version (`"Goblin Warrior|XMM"`, sometimes under another name); to go from a 2024 entry back to the 2014 one it reprints, Grep for `"<Name>|<BOOK>"` inside `reprintedAs`.
3. When the Edition has no version of it, structure.md's "Off-Edition Material" decides what happens.

An Adventure's or a Setting's text is not tied to an Edition: take it from its own book, whatever its date.

## Citing

Name the entry's book and page, e.g. "Player's Handbook (2024), p. 367 (XPHB)". Render 5etools tags as plain text: `{@condition incapacitated}` → incapacitated, `{@dc 15}` → DC 15, `{@damage 2d6}` → 2d6.

Done when every rules statement you give comes from an entry you read, cited by book and page.
