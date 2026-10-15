#!/bin/sh
set -e
. "$(dirname "$0")/../_fixtures/workspace-setup.sh"

# A Homebrew House Rule that changes the Grapple action, in a Workspace with no Campaign:
# it applies everywhere. INVENTED test content.
mkdir -p Homebrew/House_Rules
cat > Homebrew/House_Rules/Giant_Grapple.md <<'MD'
# Giant Grapple

At our table you can grapple a creature up to three sizes larger than you, but a Huge or Gargantuan target makes its saving throw with Advantage.
MD

# A Source Cache seeded with INVENTED entries (ADR 0003; no network in evals): a 2024
# Grapple whose size limit (two sizes larger) and page (412) are not the real ones.
CACHE="$HOME/.dm-realm/source-cache"
mkdir -p "$CACHE/v3.0.0/data"
echo v3.0.0 > "$CACHE/release"
cat > "$CACHE/v3.0.0/data/books.json" <<'JSON'
{"book": [{"name": "Player's Handbook (2024)", "id": "XPHB", "source": "XPHB", "published": "2024-09-17"}]}
JSON
cat > "$CACHE/v3.0.0/data/actions.json" <<'JSON'
{"action": [{"name": "Grapple", "source": "XPHB", "page": 412, "entries": ["You can grapple a creature no more than two sizes larger than you, within your reach. The target must succeed on a Strength or Dexterity saving throw (its choice) against DC 9 plus your Strength modifier and Proficiency Bonus, or have the Grappled condition."]}]}
JSON
cat > "$CACHE/v3.0.0/data/conditionsdiseases.json" <<'JSON'
{"condition": [{"name": "Grappled", "source": "XPHB", "page": 413, "entries": ["A Grappled creature has Speed 0 and can't benefit from any bonus to its Speed."]}]}
JSON
