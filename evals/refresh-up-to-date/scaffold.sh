#!/bin/sh
# Starting state: an English 2024 Workspace, a Source Cache pinned to v3.0.0, and a local
# stand-in for the Trusted Source mirror whose latest release is v3.0.0. Every entry is
# INVENTED (ADR 0003); cache and mirror sit in the sandbox home, outside the Workspace.
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

DMR="$HOME/.dm-realm"
mkdir -p "$DMR/source-cache/v3.0.0/data" "$DMR/mirror/raw/v3.0.0/data" "$DMR/mirror/raw/v3.1.0/data"
echo v3.0.0 > "$DMR/source-cache/release"
printf '{"tag_name": "v3.0.0"}\n' > "$DMR/mirror/latest.json"
for tag in v3.0.0 v3.1.0; do
  page=368; [ "$tag" = v3.1.0 ] && page=369
  cat > "$DMR/mirror/raw/$tag/data/conditionsdiseases.json" <<JSON
{"condition": [{"name": "Grappled", "source": "XPHB", "page": $page,
  "entries": ["A Grappled creature has Speed 0 and Disadvantage on Dexterity saving throws and on Stealth checks."]}]}
JSON
  printf '{"book": [{"name": "Player'"'"'s Handbook (2024)", "id": "XPHB", "source": "XPHB", "published": "2024-09-17"}]}\n' > "$DMR/mirror/raw/$tag/data/books.json"
done
cp "$DMR/mirror/raw/v3.0.0/data/conditionsdiseases.json" "$DMR/mirror/raw/v3.0.0/data/books.json" "$DMR/source-cache/v3.0.0/data/"
