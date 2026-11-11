#!/bin/sh
set -e
WS_LANG=en WS_EDITION=2024
. "$(dirname "$0")/../_fixtures/workspace-setup.sh"
. "$(dirname "$0")/../_fixtures/import-cache.sh"
mkdir -p "Adventures/The_Salt_Crypt/Parts"
printf -- '---\nsource: "SACR p. 10, v3.0.0, #b00"\n---\n\n# Chapter 1: The Drowned Stair\n\nSEEDED PART NOTE\n' > "Adventures/The_Salt_Crypt/Parts/The_Drowned_Stair.md"
printf -- '---\nsource: "SACR, v3.0.0"\n---\n\n# The Salt Crypt\n\n**Book:** SACR, 2025\n**Levels:** 2–5\n\n## Parts\n\n1. Into the Brine\n2. Chapter 1: The Drowned Stair — [[Adventures/The_Salt_Crypt/Parts/The_Drowned_Stair|Chapter 1: The Drowned Stair]]\n3. Chapter 2: The Wight'"'"'s Hall\n' > "Adventures/The_Salt_Crypt/README.md"
