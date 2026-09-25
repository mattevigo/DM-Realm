#!/bin/sh
# Starting state: an English 2024 Workspace set up by DM Realm, with one Campaign and a
# DM Tools note that links into it by path; Obsidian settings as Setup left them.
set -e
cat > workspace-config.yml <<'YML'
# DM Realm Workspace Config — written by Setup; fields in the dmr-workspace rules.
language: English
edition: 2024
folders:
  reference: Reference
  adventures: Adventures
  homebrew: Homebrew
  campaigns: Campaigns
  dm_tools: DM_Tools
  templates: Templates
YML
mkdir -p Reference Adventures Homebrew Campaigns/Heroes/Sessions DM_Tools/Checklists Templates .obsidian
printf '# Session 1\n\nThe party meets in Phandalin.\n' > Campaigns/Heroes/Sessions/Session_01.md
printf '# Prep\n\nLast time: [[Campaigns/Heroes/Sessions/Session_01|Session 1]].\nRecap: [Session 1](Campaigns/Heroes/Sessions/Session_01.md)\n' > DM_Tools/Checklists/Prep.md
printf '{"useMarkdownLinks": false, "newLinkFormat": "shortest"}\n' > .obsidian/app.json
printf '{"templates": true}\n' > .obsidian/core-plugins.json
printf '{"folder": "Templates"}\n' > .obsidian/templates.json
rm -rf Homebrew   # the DM deleted it
