#!/bin/sh
# An English 2024 Workspace with the Salt Wight imported (its stat block included) and two
# NPC notes of The Salt Crypt, as imported, whose text says which statistics they use.
# INVENTED content throughout (ADR 0003).
set -e
WS_LANG=en WS_EDITION=2024
. "$(dirname "$0")/../_fixtures/workspace-setup.sh"
. "$(dirname "$0")/../_fixtures/import-cache.sh"
mkdir -p Reference/Monsters Adventures/The_Salt_Crypt/NPCs
cat > Reference/Monsters/Salt_Wight.md <<'MD'
---
source: SACR p. 88, v3.0.0
statblock: inline
---

# Salt Wight

## Stat Block

```statblock
name: Salt Wight
size: Medium
type: undead
alignment: lawful evil
ac: 15
hp: 52
hit_dice: 8d8 + 16
speed: 30 ft.
initiative: 1
stats: [15, 12, 14, 10, 13, 11]
damage_immunities: Poison
senses: darkvision 60 ft., passive Perception 11
languages: Common
cr: "3"
actions:
  - name: Brine Touch
    desc: "*Melee Attack Roll:* +4, reach 5 ft. *Hit:* 9 (2d6 + 2) Necrotic damage, and the target's lips crust with salt."
```
MD
printf '# The Salt Crypt\n\nA published adventure (test stub): a crypt under the salt flats.\n' > Adventures/The_Salt_Crypt/README.md
printf '# Glasstaff\n\nThe crypt'"'"'s keeper, a wizard who drowned in brine and rose again. Glasstaff uses the Salt Wight statistics, except that he has 70 hit points.\n' > Adventures/The_Salt_Crypt/NPCs/Glasstaff.md
printf '# Mother Brine\n\nAn old wight who guards the lower vault. Mother Brine uses the Salt Wight statistics.\n' > Adventures/The_Salt_Crypt/NPCs/Mother_Brine.md
