#!/bin/sh
# A Workspace set up before ADR 0009: its Config has no stat_blocks.
set -e
WS_STAT_BLOCKS=none
. "$(dirname "$0")/../_fixtures/workspace-setup.sh"
