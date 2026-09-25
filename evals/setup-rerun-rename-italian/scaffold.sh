#!/bin/sh
# Starting state: an Italian 2024 Workspace set up by DM Realm, with its Translation Glossary.
set -e
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
mkdir -p Riferimento Avventure Homebrew Campagne Strumenti_DM Modelli
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
MD

mkdir -p .obsidian
printf '{"useMarkdownLinks": false, "newLinkFormat": "shortest"}\n' > .obsidian/app.json
printf '{"templates": true}\n' > .obsidian/core-plugins.json
printf '{"folder": "%s"}\n' Modelli > .obsidian/templates.json
