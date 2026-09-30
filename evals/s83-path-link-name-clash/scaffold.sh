#!/bin/sh
set -e
. "$(dirname "$0")/../_fixtures/workspace-en.sh"
# A bare link to the Adventure's inn, which a second Stonehill_Inn note makes ambiguous.
printf '# Glasstaff\n\nA wizard hiding in the keep. He drinks at the [[Stonehill_Inn]].\n' > Adventures/The_Sunken_Keep/NPCs/Glasstaff.md
