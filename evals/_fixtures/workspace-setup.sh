# Shared starting state, sourced by case scaffolds and the other fixtures: a Workspace
# exactly as Setup leaves it — the Workspace Config, the eight top-level folders, empty
# but for the Templates (short stand-ins, named as Setup names them), Obsidian's
# settings and, in Italian, the Translation Glossary with one row per top-level folder
# and per term Setup translated (the Templates' names, Attachments). The one place eval
# scaffolds write the Config's folder list. Set before sourcing:
#   WS_LANG      en (default) or it — the folder names
#   WS_EDITION   2024 (default) or 2014
#   WS_LANGUAGE  the Config's language line (default English or Italiano), e.g. to
#                simulate a hand-edited Config
#   WS_STAT_BLOCKS  the Config's stat_blocks: true (default) or false, or none to leave
#                it out, as in a Workspace set up before ADR 0009
WS_LANG=${WS_LANG:-en}
WS_EDITION=${WS_EDITION:-2024}
WS_STAT_BLOCKS=${WS_STAT_BLOCKS:-true}
if [ "$WS_LANG" = it ]; then
  WS_LANGUAGE=${WS_LANGUAGE:-Italiano}
  WS_FOLDERS="Riferimento Avventure Homebrew Mondo Personaggi Campagne Strumenti_DM Modelli"
  WS_ATTACHMENTS=Allegati
  # Setup's Template set, in structure.md's order, and the Homebrew monster's among them.
  WS_TEMPLATES="Sessione PNG Luogo Fazione Missione Regola_della_Casa Incantesimo_Homebrew Oggetto_Homebrew Mostro_Homebrew"
  WS_MONSTER_TEMPLATE=Mostro_Homebrew
  WS_LABELS="Classe Armatura|Punti Ferita"
else
  WS_LANGUAGE=${WS_LANGUAGE:-English}
  WS_FOLDERS="Reference Adventures Homebrew World Characters Campaigns DM_Tools Templates"
  WS_ATTACHMENTS=Attachments
  WS_TEMPLATES="Session NPC Place Faction Quest House_Rule Homebrew_Spell Homebrew_Item Homebrew_Monster"
  WS_MONSTER_TEMPLATE=Homebrew_Monster
  WS_LABELS="Armor Class|Hit Points"
fi
# Folder name by position in WS_FOLDERS (key order of the Workspace Config).
ws_folder() { echo "$WS_FOLDERS" | cut -d' ' -f"$1"; }
cat > workspace-config.yml <<YML
# DM Realm Workspace Config — written by Setup; fields in the dmr-workspace rules.
language: $WS_LANGUAGE
edition: $WS_EDITION
$([ "$WS_STAT_BLOCKS" = none ] || echo "stat_blocks: $WS_STAT_BLOCKS")
folders:
  reference: $(ws_folder 1)
  adventures: $(ws_folder 2)
  homebrew: $(ws_folder 3)
  world: $(ws_folder 4)
  characters: $(ws_folder 5)
  campaigns: $(ws_folder 6)
  dm_tools: $(ws_folder 7)
  templates: $(ws_folder 8)
YML
mkdir -p $WS_FOLDERS .obsidian   # unquoted: one folder per word
printf '{"useMarkdownLinks": false, "newLinkFormat": "shortest", "attachmentFolderPath": "./%s"}\n' "$WS_ATTACHMENTS" > .obsidian/app.json
printf '{"templates": true}\n' > .obsidian/core-plugins.json
printf '{"folder": "%s"}\n' "$(ws_folder 8)" > .obsidian/templates.json
for t in $WS_TEMPLATES; do   # unquoted: one Template per word
  printf '## Notes\n\n—\n' > "$(ws_folder 8)/$t.md"
done
# The Homebrew monster's empty statistics, in the Workspace's form, out of the bestiary.
MONSTER="$(ws_folder 8)/$WS_MONSTER_TEMPLATE.md"
if [ "$WS_STAT_BLOCKS" = false ]; then
  printf '## Stat Block\n\n%%%% statblock\nname: "—"\nbestiary: false\n%%%%\n\n**%s** —\n**%s** —\n' \
    "${WS_LABELS%%|*}" "${WS_LABELS#*|}" > "$MONSTER"
else
  printf '## Stat Block\n\n```statblock\nname: "—"\nbestiary: false\nac: "—"\nhp: "—"\n```\n' > "$MONSTER"
fi
if [ "$WS_LANG" = it ]; then
  cat > Strumenti_DM/Glossario_Traduzioni.md <<'MD'
# Glossario delle traduzioni

| English | Traduzione | Fonte | Chiave |
| --- | --- | --- | --- |
| Reference | Riferimento | fallback | reference |
| Adventures | Avventure | Traduzione Ufficiale | adventures |
| Homebrew | Homebrew | fallback | homebrew |
| World | Mondo | fallback | world |
| Characters | Personaggi | Traduzione Ufficiale | characters |
| Campaigns | Campagne | Traduzione Ufficiale | campaigns |
| DM_Tools | Strumenti_DM | fallback | dm_tools |
| Templates | Modelli | fallback | templates |
| Session | Sessione | Traduzione Ufficiale | |
| NPC | PNG | Traduzione Ufficiale | |
| Place | Luogo | fallback | |
| Faction | Fazione | fallback | |
| Quest | Missione | fallback | |
| House_Rule | Regola_della_Casa | fallback | |
| Homebrew_Spell | Incantesimo_Homebrew | fallback | |
| Homebrew_Item | Oggetto_Homebrew | fallback | |
| Homebrew_Monster | Mostro_Homebrew | fallback | |
| Attachments | Allegati | fallback | |
MD
fi
