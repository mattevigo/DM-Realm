#!/bin/sh
# Starting state: the Workspace Config and Obsidian's settings of an English 2024 Workspace,
# with every top-level folder gone.
set -e
. "$(dirname "$0")/../_fixtures/workspace-setup.sh"
rm -rf $WS_FOLDERS   # unquoted: one folder per word
