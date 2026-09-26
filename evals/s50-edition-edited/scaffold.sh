#!/bin/sh
set -e
WS_LANG=en WS_EDITION=2014
. "$(dirname "$0")/../_fixtures/workspace-setup.sh"
. "$(dirname "$0")/../_fixtures/import-cache.sh"
sed 's/^edition: 2014$/edition: 2014   # changed by the DM after Setup (was 2024)/' workspace-config.yml > c.tmp && mv c.tmp workspace-config.yml
