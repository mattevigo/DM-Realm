#!/bin/sh
set -e
. "$(dirname "$0")/../_fixtures/workspace-en.sh"
# The ring now depends on a spell that is Campaign-only homebrew too.
mkdir -p Campaigns/Heroes/Homebrew_Spells/Level_1
printf '# Cinder Bolt\n\n1st-level evocation, made for the Heroes campaign. A mote of ember hits one creature within 60 feet: 2d8 fire damage.\n' > Campaigns/Heroes/Homebrew_Spells/Level_1/Cinder_Bolt.md
printf '# Emberglass Ring\n\nFound by [[Ayla]] during the Heroes campaign. Stores one casting of [[Cinder_Bolt]].\n' > Campaigns/Heroes/Homebrew_Magic_Items/Emberglass_Ring.md
