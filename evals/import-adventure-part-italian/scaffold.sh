#!/bin/sh
set -e
WS_LANG=it WS_EDITION=2024
. "$(dirname "$0")/../_fixtures/workspace-setup.sh"
. "$(dirname "$0")/../_fixtures/import-cache.sh"
# Translations an earlier Import or Research recorded (INVENTED fallbacks for invented names):
# the Adventure's title, its folders, its first two Parts, two of its names and two link targets.
# The Part's other names (the Tide Gate, the Weeping Steps, the Keeper's Key…) are not here yet.
cat >> Strumenti_DM/Glossario_Traduzioni.md <<'MD'
| source | fonte | fallback | |
| The Salt Crypt | La Cripta di Sale | fallback | |
| Parts | Parti | fallback | |
| Places | Luoghi | fallback | |
| NPCs | PNG | Traduzione Ufficiale | |
| Encounters | Incontri | Traduzione Ufficiale | |
| Items | Oggetti | Traduzione Ufficiale | |
| Monsters | Mostri | Traduzione Ufficiale | |
| Magic_Items | Oggetti_Magici | Traduzione Ufficiale | |
| Into the Brine | Nella Salamoia | fallback | |
| Chapter 1: The Drowned Stair | Capitolo 1: La Scala Sommersa | fallback | |
| Old Maren | Vecchia Maren | fallback | |
| The Rising Tide | La Marea Montante | fallback | |
| Salt Goblin Boss | Capo Goblin del Sale | fallback | |
| Brine Lantern | Lanterna Salmastra | fallback | |
MD
