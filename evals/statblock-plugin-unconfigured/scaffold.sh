#!/bin/sh
# An Italian Workspace set up before the DM installed Fantasy Statblocks: the plugin keeps
# its own settings, with none of DM Realm's layouts.
set -e
WS_LANG=it WS_EDITION=2024
. "$(dirname "$0")/../_fixtures/workspace-setup.sh"
. "$(dirname "$0")/../_fixtures/import-cache.sh"
mkdir -p .obsidian/plugins/obsidian-5e-statblocks
printf '{\n  "obsidian-5e-statblocks": true\n}\n' > .obsidian/community-plugins.json
printf '{\n  "default": "basic-5e-layout",\n  "layouts": [],\n  "useDice": true\n}\n' > .obsidian/plugins/obsidian-5e-statblocks/data.json
