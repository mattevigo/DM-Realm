#!/bin/sh
set -e
SC_SESSIONS=none
. "$(dirname "$0")/../_fixtures/session-campaign.sh"
sed "s/ — whole — running$/ — whole — planned/" $SC/README.md > $SC/README.tmp && mv $SC/README.tmp $SC/README.md
