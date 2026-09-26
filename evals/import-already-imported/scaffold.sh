#!/bin/sh
set -e
WS_LANG=en WS_EDITION=2024
. "$(dirname "$0")/../_fixtures/import-workspace.sh"
. "$(dirname "$0")/../_fixtures/import-cache.sh"
mkdir -p Reference/Spells/Level_3
printf -- '---\nsource: EMBC p. 211, v3.0.0\n---\n\n# Cinder Bloom\n\n(Imported earlier.)\n' > Reference/Spells/Level_3/Cinder_Bloom.md
