#!/bin/sh
set -e
. "$(dirname "$0")/../_fixtures/workspace-it.sh"
# A fallback term already chosen for this Workspace, which notes must reuse unchanged.
printf '| Hit Points | Punti Vitali | fallback | |\n' >> Strumenti_DM/Glossario_Traduzioni.md
