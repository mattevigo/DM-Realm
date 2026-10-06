# Transfer sources, sourced by Transfer case scaffolds after a workspace fixture. An old
# vault's free-form Character notes in .old-vault/ and another DM Realm Workspace in
# .other-workspace/: dot-folders, which are no part of the Workspace (Obsidian ignores
# them), stand in for folders outside it so the graders can read them. INVENTED content;
# the old notes copy official text from character-cache.sh on purpose, as DMs do.
mkdir -p .old-vault .other-workspace/Characters/Oren/Past_Builds

# A 2024 Character with a table's story, play state and copied rules text mixed in.
cat > .old-vault/Tamsin_Reed.md <<'MD'
---
type: pc
player: Dario
campaign: Heroes of the Borderlands
class: Lamplighter
level: 1
hp: 10
ac: 13
---

# Tamsin Reed

Small Mothfolk Lamplighter, level 1, Lantern Keeper background.

## Abilities

| STR | DEX | CON | INT | WIS | CHA |
| --- | --- | --- | --- | --- | --- |
| 8 | 14 | 14 | 11 | 18 | 10 |

Standard array, +2 WIS and +1 CON from the background.
Skills: Insight, Perception (background); Religion, Stealth (class).

## Features

**Kindle.** You light any wick you touch.
**Dustwings.** You can fly while you wear no heavy armor.
**Night Owl.** You have Darkvision with a range of 60 feet.

## Spells

- Spark Wick (cantrip): a spark leaps to one creature you can see within range: it takes 1d8 Fire damage.
- Soft Light (1st level)

Slots used:
- [x] 1st
- [ ] 1st

## Equipment

- Lantern Pole, Leather Coat, Tinderbox
- 15 GP (5 GP spent on rope in Session 2)

## Backstory

Tamsin grew up in a harbour town, the youngest of five, and left home to follow the lamplighters' road.

## Campaign log

- Session 1: joined the party at the Gull's Rest.
- Session 2: lost her lantern in the Mire; Mira Vell owes her a favour.
MD

# A 2014 Character: its class and background have 2024 versions, its race and feat do not.
cat > .old-vault/Pip_Ashwick.md <<'MD'
---
player: Elena
level: 1
---

# Pip Ashwick

Level 1 Lampkin (Wick) Lamplighter. Background: Lamp Scholar. Feat: Lamplit Mind.

Ability scores: STR 8, DEX 16, CON 14, INT 12, WIS 15, CHA 10.
Skills: History, Insight (background); Perception, Stealth (class).
Equipment: Lantern Pole, Leather Coat, 12 GP.

Pip ran away from a guild of lamp-makers to see what the lamps were for.
MD

# A second Wren, whose name clashes with the Workspace's Wren (character-wren.sh).
cat > .old-vault/Wren.md <<'MD'
---
player: Dario
level: 2
---

# Wren

Level 2 Mothfolk Lamplighter, Lantern Keeper background.

Wren sold lamp oil in a mountain village until the oil ran out.
MD

# Another Workspace's Character, with two past Builds that link their options.
cat > .other-workspace/workspace-config.yml <<'YML'
language: English
edition: 2024
YML
cat > .other-workspace/Characters/Oren/Oren.md <<'MD'
---
player: Farid
status: active
level: 1
---

# Oren

## Identity

**Backstory.** Oren tends the beacon of a lonely headland.

## Build

- **Species:** [[Emberkin]]
- **Class:** [[Lamplighter]] 1
- **Background:** [[Lantern_Keeper|Lantern Keeper]]

### Ability Scores

| Ability | Score | Modifier |
| --- | --- | --- |
| Strength | 8 | −1 |
| Dexterity | 14 | +2 |
| Constitution | 14 | +2 |
| Intelligence | 11 | +0 |
| Wisdom | 18 | +4 |
| Charisma | 10 | +0 |

### Proficiencies

- **Saving throws:** Dexterity, Wisdom
- **Skills:** Insight, Perception (Lantern Keeper); Religion, Stealth (Lamplighter)

### Features

- [[Lantern_Keeper|Lantern Keeper]]: [[Night_Owl|Night Owl]]

### Spells

- **Cantrips:** [[Spark_Wick|Spark Wick]]
- **Prepared:** [[Soft_Light|Soft Light]]

### Equipment

- [[Lantern_Pole|Lantern Pole]], [[Leather_Coat|Leather Coat]] (worn), [[Tinderbox]]
- **Coins:** 20 GP

## Statistics

| Statistic | Value |
| --- | --- |
| Armor Class | 13 |
| Hit Point Maximum | 10 |
| Speed | 35 ft. |
MD
cat > .other-workspace/Characters/Oren/Past_Builds/Oren_01.md <<'MD'
---
player: Farid
level: 1
---

# Oren

> [!info] Past Build: level 1. The current Build is [[Oren]].

## Build

- **Species:** [[Mothfolk]]
- **Class:** [[Lamplighter]] 1
- **Background:** [[Lantern_Keeper|Lantern Keeper]]
- **Spells:** [[Moth_Dust|Moth Dust]], [[Soft_Light|Soft Light]]
MD
cat > .other-workspace/Characters/Oren/Past_Builds/Oren_02.md <<'MD'
---
player: Farid
level: 1
---

# Oren

> [!info] Past Build: level 1. The current Build is [[Oren]].

## Build

- **Species:** [[Mothfolk]]
- **Class:** [[Lamplighter]] 1
- **Background:** [[Lantern_Keeper|Lantern Keeper]]
- **Spells:** [[Spark_Wick|Spark Wick]], [[Soft_Light|Soft Light]]
MD
