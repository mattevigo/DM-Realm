#!/bin/sh
# Starting state: an English 2014 Workspace fresh from Setup.
set -e
cat > workspace-config.yml <<'YML'
# DM Realm Workspace Config — written by Setup; fields in the dmr-workspace rules.
language: English
edition: 2014
folders:
  reference: Reference
  adventures: Adventures
  homebrew: Homebrew
  campaigns: Campaigns
  dm_tools: DM_Tools
  templates: Templates
YML
mkdir -p Reference Adventures Homebrew Campaigns DM_Tools Templates

# A Source Cache seeded with INVENTED entries (ADR 0003: no real Trusted Source data
# in the repository; the eval sandbox has no network). It sits in the sandbox home,
# outside the Workspace, where the case's EVAL_DMR_SOURCE_CACHE points.
CACHE="$HOME/.dm-realm/source-cache"
mkdir -p "$CACHE/v0.0.0/data"
echo v0.0.0 > "$CACHE/release"
cat > "$CACHE/v0.0.0/data/books.json" <<'JSON'
{"book": [
  {"name": "Player's Handbook (2014)", "id": "PHB", "source": "PHB", "published": "2014-08-19"},
  {"name": "Player's Handbook (2024)", "id": "XPHB", "source": "XPHB", "published": "2024-09-17"}
]}
JSON
cat > "$CACHE/v0.0.0/data/conditionsdiseases.json" <<'JSON'
{
	"condition": [
		{
			"name": "Grappled",
			"source": "PHB",
			"page": 911,
			"reprintedAs": ["Grappled|XPHB"],
			"entries": ["INVENTED TEST TEXT (2014): a grappled creature must hum a tune and cannot whistle."]
		},
		{
			"name": "Grappled",
			"source": "XPHB",
			"page": 922,
			"entries": ["INVENTED TEST TEXT (2024): while Grappled you can't whistle, and you glow faintly blue."]
		}
	]
}
JSON
