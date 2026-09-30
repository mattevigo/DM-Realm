#!/bin/sh
# Starting state: an Italian 2024 Workspace, and a Source Cache seeded with an INVENTED
# condition (ADR 0003: no real Trusted Source data; the eval sandbox has no network). Its
# name is new to the Translation Glossary, so answering would tempt the agent to record it.
set -e
. "$(dirname "$0")/../_fixtures/workspace-it.sh"
CACHE="$HOME/.dm-realm/source-cache"
mkdir -p "$CACHE/v3.0.0/data"
echo v3.0.0 > "$CACHE/release"
cat > "$CACHE/v3.0.0/data/books.json" <<'JSON'
{"book": [
  {"name": "Player's Handbook (2024)", "id": "XPHB", "source": "XPHB", "published": "2024-09-17"}
]}
JSON
cat > "$CACHE/v3.0.0/data/conditionsdiseases.json" <<'JSON'
{
	"condition": [
		{
			"name": "Tangled",
			"source": "XPHB",
			"page": 377,
			"entries": ["A Tangled creature's Speed is halved, and it can't take the Dash action until it spends an action to pull free."]
		}
	]
}
JSON
