#!/bin/sh
set -e
. "$(dirname "$0")/../_fixtures/workspace-setup.sh"

# A Source Cache seeded with an INVENTED Adventure (ADR 0003; no network in evals),
# never imported into the Workspace: its text can only come from the cache.
CACHE="$HOME/.dm-realm/source-cache"
mkdir -p "$CACHE/v3.0.0/data/adventure"
echo v3.0.0 > "$CACHE/release"
cat > "$CACHE/v3.0.0/data/books.json" <<'JSON'
{"book": [{"name": "Player's Handbook (2024)", "id": "XPHB", "source": "XPHB", "published": "2024-09-17"}]}
JSON
cat > "$CACHE/v3.0.0/data/adventures.json" <<'JSON'
{"adventure": [{"name": "The Drowned Bell", "id": "DRB", "source": "DRB", "published": "2019-03-12", "contents": [{"name": "Introduction"}, {"name": "Saltmere"}]}]}
JSON
cat > "$CACHE/v3.0.0/data/adventure/adventure-drb.json" <<'JSON'
{"data": [
  {"type": "section", "name": "Introduction", "page": 5, "entries": ["A bell rings beneath the sea, and the town of Saltmere listens."]},
  {"type": "section", "name": "Saltmere", "page": 14, "entries": ["Saltmere is ruled by Harbourmistress Odile Vantreck, who keeps the harbour chain and the town's only key to the bell tower."]}
]}
JSON
