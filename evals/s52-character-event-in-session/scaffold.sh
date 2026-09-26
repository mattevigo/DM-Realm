#!/bin/sh
set -e
. "$(dirname "$0")/../_fixtures/workspace-en.sh"
mkdir -p Homebrew/Magic_Items
printf '# Belt of the Ox\n\nA wide leather belt; its wearer counts as one size larger when carrying.\n' > Homebrew/Magic_Items/Belt_of_the_Ox.md
printf '# Session 21: The Vault\n\nThe party opened the old vault.\n' > Campaigns/Heroes/Sessions/Session_21_The_Vault.md
