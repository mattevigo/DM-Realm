#!/bin/sh
set -e
WS_LANG=en WS_EDITION=2024
. "$(dirname "$0")/../_fixtures/import-workspace.sh"
. "$(dirname "$0")/../_fixtures/import-cache.sh"
printf '{"OLDC": "bestiary-oldc.json", "EMBC": "bestiary-embc.json", "BOFI": "bestiary-bofi.json", "SACR": "bestiary-sacr.json"}\n' > "$D/bestiary/index.json"
