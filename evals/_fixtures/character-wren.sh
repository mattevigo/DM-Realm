# Wren, a level 3 Character in the dmr-character note format, with one past Build (level 2)
# and the Lantern Keeper background note she links to. Sourced after character-workspace.sh.
# Her numbers follow character-cache.sh's invented rules (standard array 16, 14, 13, 11, 10, 8;
# fixed hit points 5 per level on a d8), so a recomputed number can be checked exactly.
reference_stub Reference/Backgrounds/Lantern_Keeper.md "EMBC p. 60" "Lantern Keeper"
mkdir -p Characters/Wren/Past_Builds
cat > Characters/Wren/Wren.md <<'MD'
---
player: Carla
status: active
level: 3
---

# Wren

## Identity

**Backstory.** Wren trimmed the lamps of a harbour town until the night a stranger's lantern would not go out. She followed it inland.

**Appearance.** Small and grey-winged, with soot on her fingers.

**Personality.** Patient and curious, and afraid of the dark she keeps from others.

## Build

- **Species:** [[Mothfolk]]
- **Class:** [[Lamplighter]] 3, [[Path_of_the_Wick|Path of the Wick]]
- **Background:** [[Lantern_Keeper|Lantern Keeper]]

### Ability Scores

Method: standard array.

| Ability | Base | Increases | Score | Modifier |
| --- | --- | --- | --- | --- |
| Strength | 8 | — | 8 | −1 |
| Dexterity | 14 | — | 14 | +2 |
| Constitution | 13 | +1 (Lantern Keeper) | 14 | +2 |
| Intelligence | 11 | — | 11 | +0 |
| Wisdom | 16 | +2 (Lantern Keeper) | 18 | +4 |
| Charisma | 10 | — | 10 | +0 |

### Hit Points

Level 1: 8 (the Hit Die's maximum). Levels 2–3: 5 each (fixed value).

### Proficiencies

- **Saving throws:** Dexterity, Wisdom
- **Skills:** Insight, Perception (Lantern Keeper); Religion, Stealth (Lamplighter)
- **Armor:** light. **Weapons:** simple.

### Features

- [[Lamplighter]]: Kindle, Spellcasting (level 1); Lamplighter Path (2); Path Feature (3)
- [[Path_of_the_Wick|Path of the Wick]]: Path of the Wick (2); Wick Burst (3)
- [[Mothfolk]]: Dustwings
- [[Lantern_Keeper|Lantern Keeper]]: [[Night_Owl|Night Owl]]

### Spells

- **Cantrips:** [[Spark_Wick|Spark Wick]]
- **Prepared:** [[Glimmerlance]], [[Soft_Light|Soft Light]], [[Whisper_Veil|Whisper Veil]]

### Equipment

- [[Lantern_Pole|Lantern Pole]]
- [[Leather_Coat|Leather Coat]] (worn)
- [[Tinderbox]]
- **Coins:** 20 GP
- **Attuned:** none

## Statistics

| Statistic | Value |
| --- | --- |
| Armor Class | 13 (Leather Coat 11 + Dexterity) |
| Hit Point Maximum | 24 |
| Hit Dice | 3d8 |
| Initiative | +2 |
| Speed | 30 ft., fly 30 ft. |
| Proficiency Bonus | +2 |
| Passive Perception | 16 |

- **Saving Throws:** Strength −1, Dexterity +4, Constitution +2, Intelligence +0, Wisdom +6, Charisma +0
- **Skills:** Insight +6, Perception +6, Religion +2, Stealth +4; every other skill its ability modifier
- **Attacks:** Lantern Pole +4 to hit, 1d6 + 2 bludgeoning
- **Spellcasting:** Wisdom, spell save DC 14, spell attack +6; spell slots: 1st 4, 2nd 2
MD
cat > Characters/Wren/Past_Builds/Wren_01.md <<'MD'
---
player: Carla
level: 2
---

# Wren

> [!info] Past Build: level 2. The current Build is [[Wren]].

## Identity

**Backstory.** Wren trimmed the lamps of a harbour town until the night a stranger's lantern would not go out. She followed it inland.

## Build

- **Species:** [[Mothfolk]]
- **Class:** [[Lamplighter]] 2, [[Path_of_the_Wick|Path of the Wick]]
- **Background:** [[Lantern_Keeper|Lantern Keeper]]

## Statistics

| Statistic | Value |
| --- | --- |
| Armor Class | 13 (Leather Coat 11 + Dexterity) |
| Hit Point Maximum | 17 |
| Hit Dice | 2d8 |

- **Spellcasting:** Wisdom, spell save DC 14, spell attack +6; spell slots: 1st 3
MD
