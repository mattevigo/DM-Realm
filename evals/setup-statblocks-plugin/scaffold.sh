#!/bin/sh
# Starting state: a folder already opened in Obsidian with Fantasy Statblocks installed and
# configured by the DM: one layout of their own, dice rolling on, a bestiary folder.
set -e
mkdir -p .obsidian/plugins/obsidian-5e-statblocks
printf '{\n  "obsidian-5e-statblocks": true\n}\n' > .obsidian/community-plugins.json
cat > .obsidian/plugins/obsidian-5e-statblocks/data.json <<'JSON'
{
  "useDice": true,
  "paths": ["Bestiary"],
  "autoParse": false,
  "disableSRD": false,
  "default": "basic-5e-layout",
  "layouts": [{"id": "my-own-layout", "name": "My Own Layout", "blocks": []}]
}
JSON
