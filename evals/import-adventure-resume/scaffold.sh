#!/bin/sh
set -e
WS_LANG=en WS_EDITION=2024
. "$(dirname "$0")/../_fixtures/workspace-setup.sh"
. "$(dirname "$0")/../_fixtures/import-cache.sh"
mkdir -p "Adventures/The_Salt_Crypt/Places" "Adventures/The_Salt_Crypt/NPCs"
printf -- '---\nsource: "SACR p. 11, v3.0.0, #b02"\n---\n\n# D1. Tide Gate\n\nSEEDED GATE\n' > "Adventures/The_Salt_Crypt/Places/Tide_Gate.md"
printf -- '---\nsource: "SACR p. 12, v3.0.0, #b04"\n---\n\n# Old Maren\n\nSEEDED MAREN\n' > "Adventures/The_Salt_Crypt/NPCs/Maren.md"
printf -- '---\nsource: "SACR, v3.0.0"\n---\n\n# The Salt Crypt\n\n**Book:** SACR, 2025\n**Levels:** 2–5\n\n## Parts\n\n1. Into the Brine\n2. Chapter 1: The Drowned Stair\n3. Chapter 2: The Wight'"'"'s Hall\n' > "Adventures/The_Salt_Crypt/README.md"
