#!/bin/sh
# A stat block Workspace with an imported monster and a Character, both as fences; only the monster converts.
set -e
. "$(dirname "$0")/../_fixtures/character-workspace.sh"
. "$(dirname "$0")/../_fixtures/character-wren.sh"
mkdir -p Reference/Monsters
cat > Reference/Monsters/Bog_Goblin.md <<'MD'
---
source: EMBC p. 150, v3.0.0
statblock: inline
---

# Bog Goblin

## Stat Block

```statblock
name: Bog Goblin
size: Small
type: fey (goblinoid)
alignment: neutral
ac: 14
hp: 11
hit_dice: 2d6 + 4
speed: 30 ft., swim 30 ft.
initiative: 4
stats: [8, 15, 14, 9, 10, 8]
senses: darkvision 60 ft., passive Perception 10
languages: Common, Goblin
cr: 1/2
actions:
  - name: Reed Spear
    desc: "*Melee or Ranged Attack Roll:* +4, reach 5 ft. or range 20/60 ft. *Hit:* 6 (1d8 + 2) Piercing damage."
```
MD
