#!/bin/sh
set -e
. "$(dirname "$0")/../_fixtures/character-workspace.sh"
. "$(dirname "$0")/../_fixtures/character-wren.sh"
mkdir -p Campaigns/Heroes/Places
printf '# The Gull'"'"'s Rest\n\nAn inn on the Orsenna coast, where the party first met Mira Vell in Session 3.\n' > Campaigns/Heroes/Places/Gulls_Rest.md
