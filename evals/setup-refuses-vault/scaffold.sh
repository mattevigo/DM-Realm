#!/bin/sh
# Starting state: an existing Obsidian vault with notes, not a Workspace.
set -e
mkdir -p .obsidian 01_Campagne/Eroi/PNG 02_Mondo
echo '{}' > .obsidian/app.json
printf '# Ivlis\n\nPNG della campagna.\n' > 01_Campagne/Eroi/PNG/Ivlis.md
printf '# Sessione 1\n\nRiepilogo.\n' > 01_Campagne/Eroi/Sessione_01.md
printf '# Geografia\n' > 02_Mondo/Geografia.md
