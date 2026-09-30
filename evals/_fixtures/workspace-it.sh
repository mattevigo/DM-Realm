# Shared starting state, sourced by case scaffolds: an Italian 2024 Workspace fresh from
# Setup, with its Translation Glossary and one Campaign "Eroi". INVENTED test content.
WS_LANG=it
. "$(dirname "$0")/../_fixtures/workspace-setup.sh"
mkdir -p Campagne/Eroi/PNG Campagne/Eroi/Sessioni Campagne/Eroi/Luoghi Campagne/Eroi/Missioni Campagne/Eroi/Fazioni Campagne/Eroi/Allegati
printf '# Eroi\n\nUna campagna sul confine settentrionale.\n' > Campagne/Eroi/README.md
cat >> Strumenti_DM/Glossario_Traduzioni.md <<'MD'
| NPCs | PNG | Traduzione Ufficiale | |
| Sessions | Sessioni | fallback | |
| Places | Luoghi | fallback | |
| Quests | Missioni | fallback | |
| Factions | Fazioni | fallback | |
MD
