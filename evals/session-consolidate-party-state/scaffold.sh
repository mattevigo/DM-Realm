#!/bin/sh
set -e
SP_LIVE_NOTES="- Brom's player could not make it: Ayla and Durga only
- took the gatehouse from the cinder cultists; Ayla uses a charge of her Wand of Web on the sergeant, 6 of 7 left
- short rest in the guardroom: Durga spends 2 Hit Dice, ends at 45 of 45
- the DM gives Durga Heroic Inspiration for holding the stairs
- we stop with Ayla still concentrating on Hunter's Mark on the fleeing sergeant, about 50 minutes left
- Ayla ends at 24 of 24"
. "$(dirname "$0")/../_fixtures/session-played.sh"
printf '# Ayla\n\nElf ranger. Feats: Alert.\n\n## Equipment\n\n- Longbow\n- Wand of Web (7 charges, regains 1d6 + 1 at dawn)\n' > Characters/Ayla/Ayla.md
# The DM's own words around the known lines: a paragraph and a section of open questions.
awk '{print} /^- \*\*As of:\*\*/{print ""; print "Morale is low after the ford; Brom blames Durga for the ferryman."}' \
  $SC/Party_State.md > $SC/Party_State.tmp && mv $SC/Party_State.tmp $SC/Party_State.md
printf '\n## Open questions\n\n- Does the ferryman owe Brom money?\n' >> $SC/Party_State.md
