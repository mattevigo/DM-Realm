#!/bin/sh
set -e
. "$(dirname "$0")/../_fixtures/session-campaign.sh"
printf '# Ayla\n\nElf ranger. Feats: Alert.\n\n## Equipment\n\n- Longbow\n- 1 Potion of Healing\n' > Characters/Ayla/Ayla.md
cat > $SC/Party_State.md <<'MD'
# Party State

Written after the gatehouse. Morale is low; Brom blames Durga.

## Ayla

[[Ayla]]: 17 of 24 hit points; two 1st-level spell slots spent. Carries 2 Potions of Healing.

## Brom

[[Brom]]: 9 of 31 hit points. Attuned to a Cloak of Protection.

## Durga

[[Durga]]: 40 of 45 hit points; 2 Rage uses spent. Poisoned until she finishes a Long Rest.

## Party treasure

- 120 gp

## Open questions

- Who keeps the silver chalice?
MD
