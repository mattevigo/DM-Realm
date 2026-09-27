#!/bin/sh
# A Workspace set up by an older DM Realm, with Fantasy Statblocks holding DM Realm's three
# layouts by name, translated as the Glossary says, but at an older revision (their blocks
# are a stand-in marker): at a glance, the plugin looks configured.
set -e
WS_LANG=en WS_EDITION=2024
. "$(dirname "$0")/../_fixtures/workspace-setup.sh"
mkdir -p .obsidian/plugins/obsidian-5e-statblocks
printf '{\n  "obsidian-5e-statblocks": true\n}\n' > .obsidian/community-plugins.json
python3 - <<'PY'
import json
layouts = [{"id": i, "name": n, "dmRealmRevision": "000000000000",
            "blocks": [{"type": "heading", "id": "dmr-stale-marker", "properties": ["name"], "size": 1}]}
           for i, n in (("dm-realm-character", "DM Realm Character"), ("dm-realm-monster-2014", "DM Realm Monster 2014"),
                        ("dm-realm-monster-2024", "DM Realm Monster 2024"))]
json.dump({"layouts": layouts, "default": "dm-realm-monster-2024", "disableSRD": True, "autoParse": True,
           "paths": ["/"], "useDice": True}, open(".obsidian/plugins/obsidian-5e-statblocks/data.json", "w"), indent=2)
PY
