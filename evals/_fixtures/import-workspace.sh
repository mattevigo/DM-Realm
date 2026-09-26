# Shared starting state for Import cases, sourced by their scaffolds: a Workspace fresh
# from Setup, with nothing in Reference yet. Set before sourcing:
#   WS_LANG     en (default) or it
#   WS_EDITION  2024 (default) or 2014
# Then source import-cache.sh for the Source Cache. Every note here is INVENTED.
WS_LANG=${WS_LANG:-en}
WS_EDITION=${WS_EDITION:-2024}
mkdir -p .obsidian
printf '{"useMarkdownLinks": false, "newLinkFormat": "shortest"}\n' > .obsidian/app.json
printf '{"templates": true}\n' > .obsidian/core-plugins.json
if [ "$WS_LANG" = it ]; then
  cat > workspace-config.yml <<YML
# DM Realm Workspace Config — written by Setup; fields in the dmr-workspace rules.
language: Italiano
edition: $WS_EDITION
folders:
  reference: Riferimento
  adventures: Avventure
  homebrew: Homebrew
  characters: Personaggi
  campaigns: Campagne
  dm_tools: Strumenti_DM
  templates: Modelli
YML
  mkdir -p Riferimento Avventure Homebrew Personaggi Campagne Strumenti_DM Modelli
  cat > Strumenti_DM/Glossario_Traduzioni.md <<'MD'
# Glossario delle traduzioni

| English | Traduzione | Fonte | Chiave |
| --- | --- | --- | --- |
| Reference | Riferimento | fallback | reference |
| Adventures | Avventure | Traduzione Ufficiale | adventures |
| Homebrew | Homebrew | fallback | homebrew |
| Characters | Personaggi | Traduzione Ufficiale | characters |
| Campaigns | Campagne | Traduzione Ufficiale | campaigns |
| DM_Tools | Strumenti_DM | fallback | dm_tools |
| Templates | Modelli | fallback | templates |
MD
  printf '{"folder": "Modelli"}\n' > .obsidian/templates.json
else
  cat > workspace-config.yml <<YML
# DM Realm Workspace Config — written by Setup; fields in the dmr-workspace rules.
language: English
edition: $WS_EDITION
folders:
  reference: Reference
  adventures: Adventures
  homebrew: Homebrew
  characters: Characters
  campaigns: Campaigns
  dm_tools: DM_Tools
  templates: Templates
YML
  mkdir -p Reference Adventures Homebrew Characters Campaigns DM_Tools Templates
  printf '{"folder": "Templates"}\n' > .obsidian/templates.json
fi
