#!/bin/sh
# Starting state: a folder already opened in Obsidian, with Fantasy Statblocks installed
# but never configured (no data.json yet).
set -e
mkdir -p .obsidian/plugins/obsidian-5e-statblocks
printf '{\n  "obsidian-5e-statblocks": true\n}\n' > .obsidian/community-plugins.json
