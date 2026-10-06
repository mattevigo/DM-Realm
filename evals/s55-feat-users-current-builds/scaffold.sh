#!/bin/sh
set -e
. "$(dirname "$0")/../_fixtures/workspace-en.sh"
# Ayla links to the feat; Durga's past Build does too, her current Build does not.
printf '# Ayla\n\nElf ranger. Feats: [[Alert]].\n' > Characters/Ayla/Ayla.md
printf '# Brom\n\nDwarf fighter. Feats: Great Weapon Master.\n' > Characters/Brom/Brom.md
