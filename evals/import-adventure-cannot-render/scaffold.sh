#!/bin/sh
set -e
WS_LANG=en WS_EDITION=2024
. "$(dirname "$0")/../_fixtures/workspace-setup.sh"
. "$(dirname "$0")/../_fixtures/import-cache.sh"
# The Coral Door (section c01) gets an entry type the renderer does not know.
F="$HOME/.dm-realm/source-cache/v3.0.0/data/adventure/adventure-sacr.json"
sed 's/"entries": \["Only the keeper'"'"'s key opens it."\]/"entries": ["Only the keeper'"'"'s key opens it.", {"type": "puzzlebox", "id": "c02"}]/' "$F" > "$F.new" && mv "$F.new" "$F"
grep -q puzzlebox "$F"
