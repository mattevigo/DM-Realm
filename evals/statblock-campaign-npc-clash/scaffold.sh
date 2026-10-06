#!/bin/sh
# The English Workspace with the Bog Goblin already imported, its stat block named "Bog Goblin".
# INVENTED content (ADR 0003).
set -e
. "$(dirname "$0")/../_fixtures/workspace-en.sh"
. "$(dirname "$0")/../_fixtures/import-cache.sh"
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
skillsaves:
  - Stealth: 6
senses: darkvision 60 ft., passive Perception 10
languages: Common, Goblin
cr: 1/2
traits:
  - name: Reed Walker
    desc: The goblin moves through reeds and mud without spending extra movement.
actions:
  - name: Reed Spear
    desc: "*Melee or Ranged Attack Roll:* +4, reach 5 ft. or range 20/60 ft. *Hit:* 6 (1d8 + 2) Piercing damage."
```
MD
