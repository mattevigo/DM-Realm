#!/bin/sh
# An English 2024 Workspace MapForge has adopted, with item notes imported before DM Realm
# wrote the item keys: the Lamp of Echoes embeds its own picture, the Longsword has none,
# the Glow Pouch embeds a picture no file is named after, and the Campaign's Emberglass
# Ring (workspace-en.sh) is Campaign homebrew. The Snare Weapon Mastery is no item.
# INVENTED content throughout (ADR 0003).
set -e
. "$(dirname "$0")/../_fixtures/workspace-en.sh"
mkdir -p Reference/Magic_Items Reference/Equipment/Weapon_Masteries Reference/Attachments .mapforge
printf 'INVENTED IMAGE: Lamp of Echoes' > Reference/Attachments/Lamp_of_Echoes.webp
cat > Reference/Magic_Items/Lamp_of_Echoes.md <<'MD'
---
source: EMBC p. 280, v3.0.0
---

# Lamp of Echoes

*Wondrous item, rare (requires attunement)*

While you hold this lamp, you can hear anything spoken within 10 feet of its light.

## Description

![[Lamp_of_Echoes.webp]]

Lamplighters hang them in the doorways of houses in mourning.
MD
cat > Reference/Magic_Items/Glow_Pouch.md <<'MD'
---
source: EMBC p. 281, v3.0.0
---

# Glow Pouch

*Wondrous item, common*

It glows when shaken.

## Description

![[Glow_Pouch.webp]]

Mushroom farmers sew them.
MD
cat > Reference/Equipment/Longsword.md <<'MD'
---
source: EMBC p. 149, v3.0.0
---

# Longsword

*Martial weapon, melee weapon*

Damage 1d8 Slashing; Versatile (1d10). Mastery: Snare.
MD
cat > Reference/Equipment/Weapon_Masteries/Snare.md <<'MD'
---
source: EMBC p. 216, v3.0.0
---

# Snare

If you hit a creature with this weapon, you can reduce its Speed by 15 feet until the start of your next turn.
MD
printf '%s\n' '{ "version" : 1, "createdAt" : "2026-09-17T20:09:51Z", "createdBy" : "1.2.0" }' > .mapforge/workspace.json
printf '%s\n' '{"bestiaryStatBlockPath": "Reference"}' > .mapforge/config.json
