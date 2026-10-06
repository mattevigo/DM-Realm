#!/bin/sh
set -e
WS_LANG=it
. "$(dirname "$0")/../_fixtures/session-narrate.sh"
# The Chronicle's name is already recorded, so the Chapter's path is known.
printf '| Chronicle | Cronaca | fallback | |\n' >> Strumenti_DM/Glossario_Traduzioni.md
