#!/bin/sh
# Starting state: an English 2024 Workspace fresh from Setup.
set -e
. "$(dirname "$0")/../_fixtures/workspace-setup.sh"

# A Source Cache seeded with INVENTED entries (ADR 0003: no real Trusted Source data
# in the repository; the eval sandbox has no network). It sits in the sandbox home,
# outside the Workspace, where the case's EVAL_DMR_SOURCE_CACHE points.
CACHE="$HOME/.dm-realm/source-cache"
mkdir -p "$CACHE/v3.0.0/data"
echo v3.0.0 > "$CACHE/release"
cat > "$CACHE/v3.0.0/data/books.json" <<'JSON'
{"book": [
  {"name": "Player's Handbook (2014)", "id": "PHB", "source": "PHB", "published": "2014-08-19"},
  {"name": "Player's Handbook (2024)", "id": "XPHB", "source": "XPHB", "published": "2024-09-17"}
]}
JSON
cat > "$CACHE/v3.0.0/data/conditionsdiseases.json" <<'JSON'
{
	"condition": [
		{
			"name": "Grappled",
			"source": "PHB",
			"page": 291,
			"reprintedAs": ["Grappled|XPHB"],
			"entries": ["While grappled, a creature has a speed of 0 and disadvantage on Dexterity saving throws until the grapple ends."]
		},
		{
			"name": "Grappled",
			"source": "XPHB",
			"page": 368,
			"entries": ["A Grappled creature has Speed 0 and Disadvantage on Dexterity saving throws and on Stealth checks."]
		}
	]
}
JSON
