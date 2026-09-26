# Shared starting state, sourced by case scaffolds: an Italian 2024 Workspace fresh from
# Setup, with its Translation Glossary and one Campaign "Eroi". INVENTED test content.
cat > workspace-config.yml <<'YML'
# DM Realm Workspace Config — written by Setup; fields in the dmr-workspace rules.
language: Italiano
edition: 2024
folders:
  reference: Riferimento
  adventures: Avventure
  homebrew: Homebrew
  campaigns: Campagne
  dm_tools: Strumenti_DM
  templates: Modelli
YML
mkdir -p Riferimento Avventure Homebrew Strumenti_DM Modelli .obsidian
mkdir -p Campagne/Eroi/Personaggi Campagne/Eroi/PNG Campagne/Eroi/Sessioni Campagne/Eroi/Luoghi Campagne/Eroi/Missioni Campagne/Eroi/Fazioni Campagne/Eroi/Allegati
printf '# Eroi\n\nUna campagna sul confine settentrionale.\n' > Campagne/Eroi/README.md
cat > Strumenti_DM/Glossario_Traduzioni.md <<'MD'
# Glossario delle traduzioni

| English | Traduzione | Fonte | Chiave |
| --- | --- | --- | --- |
| Reference | Riferimento | fallback | reference |
| Adventures | Avventure | Traduzione Ufficiale | adventures |
| Homebrew | Homebrew | fallback | homebrew |
| Campaigns | Campagne | Traduzione Ufficiale | campaigns |
| DM_Tools | Strumenti_DM | fallback | dm_tools |
| Templates | Modelli | fallback | templates |
| Characters | Personaggi | Traduzione Ufficiale | campaigns.<campaign>.characters |
| NPCs | PNG | Traduzione Ufficiale | campaigns.<campaign>.npcs |
| Sessions | Sessioni | fallback | campaigns.<campaign>.sessions |
| Places | Luoghi | fallback | campaigns.<campaign>.places |
| Quests | Missioni | fallback | campaigns.<campaign>.quests |
| Factions | Fazioni | fallback | campaigns.<campaign>.factions |
| Attachments | Allegati | fallback | campaigns.<campaign>.attachments |
MD
printf '{"useMarkdownLinks": false, "newLinkFormat": "shortest"}\n' > .obsidian/app.json
printf '{"templates": true}\n' > .obsidian/core-plugins.json
printf '{"folder": "Modelli"}\n' > .obsidian/templates.json
