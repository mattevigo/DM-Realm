#!/bin/sh
# Starting state: an English 2024 Workspace, with one note imported from the 2024
# Player's Handbook, whose Workspace Config was hand-edited to 2014 after Setup.
set -e
cat > workspace-config.yml <<'YML'
# DM Realm Workspace Config — written by Setup; fields in the dmr-workspace rules.
language: English
edition: 2014
folders:
  reference: Reference
  adventures: Adventures
  homebrew: Homebrew
  characters: Characters
  campaigns: Campaigns
  dm_tools: DM_Tools
  templates: Templates
YML
mkdir -p Reference/Rules Adventures Homebrew Characters Campaigns DM_Tools Templates
cat > Reference/Rules/Grappled.md <<'MD'
---
source: XPHB p. 364, v2.36.1
---

# Grappled

(Invented placeholder text for this test; not official content.)
MD

mkdir -p .obsidian
printf '{"useMarkdownLinks": false, "newLinkFormat": "shortest"}\n' > .obsidian/app.json
printf '{"templates": true}\n' > .obsidian/core-plugins.json
printf '{"folder": "%s"}\n' Templates > .obsidian/templates.json
