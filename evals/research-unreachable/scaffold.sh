#!/bin/sh
# Starting state: an English 2024 Workspace fresh from Setup.
set -e
cat > workspace-config.yml <<'YML'
# DM Realm Workspace Config — written by Setup; fields in the dmr-workspace rules.
language: English
edition: 2024
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
