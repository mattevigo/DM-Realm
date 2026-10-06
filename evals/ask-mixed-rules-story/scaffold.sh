#!/bin/sh
set -e
. "$(dirname "$0")/../_fixtures/session-campaign.sh"
session Session_04_The_Flooded_Vault 4 2026-09-26 "Session 4: The Flooded Vault" "$PARTY" \
  "- into the flooded vault under the gatehouse
- Grull the ogre (Large) guarding the brass key; Durga and Brom drove him back
- Grull fled into the drowned tunnels, wounded, the key still with him" \
  "The party fought Grull the ogre in the flooded vault; he fled into the drowned tunnels with the brass key." \
  "- Grull escaped with the brass key."
echo '- **Session 04** — 2026-09-26 — [[Session_04_The_Flooded_Vault]]. Grull the ogre escapes with the key.' >> $SC/Diary.md

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
cat > "$CACHE/v3.0.0/data/variantrules.json" <<'JSON'
{"variantrule": [{"name": "Unarmed Strike", "source": "XPHB", "page": 412, "entries": ["Grapple: see the Grapple action (Player's Handbook, p. 412)."]}]}
JSON
cat > "$CACHE/v3.0.0/data/conditionsdiseases.json" <<'JSON'
{"condition": [{"name": "Grappled", "source": "XPHB", "page": 413, "entries": ["A Grappled creature has Speed 0 and can't benefit from any bonus to its Speed."]}]}
JSON
