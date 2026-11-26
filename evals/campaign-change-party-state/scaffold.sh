#!/bin/sh
set -e
. "$(dirname "$0")/../_fixtures/session-campaign.sh"
printf '\n## Open questions\n\n- Does the ferryman owe Brom money?\n' >> $SC/Party_State.md
