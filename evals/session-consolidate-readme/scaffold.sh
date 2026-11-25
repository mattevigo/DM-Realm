#!/bin/sh
set -e
SP_LIVE_NOTES='- the party rode into Stonehill Inn, where Glasstaff'"'"'s spy was waiting
- Brom'"'"'s player is moving away: Brom stays at the inn for good and leaves the party
- Ayla ends at 17 hp
- the spy fled toward the keep; the party means to follow at dawn'
. "$(dirname "$0")/../_fixtures/session-played.sh"
sed "s/ — whole — running$/ — whole — planned/" $SC/README.md > $SC/README.tmp && mv $SC/README.tmp $SC/README.md
