#!/bin/sh
# An Italian 2024 Workspace whose Source Cache also holds a magic item with a description
# and its picture: the Ember Satchel (EMBC p. 282). The Glossary already names the source
# property and Magic_Items, so the note's path and keys are known. INVENTED content (ADR 0003).
set -e
. "$(dirname "$0")/../_fixtures/workspace-it.sh"
. "$(dirname "$0")/../_fixtures/import-cache.sh"
python3 - "$D" <<'PY'
import json, sys
data = sys.argv[1]
path = f"{data}/items.json"
items = json.load(open(path))
items["item"].append(
    {"name": "Ember Satchel", "source": "EMBC", "page": 282, "wondrous": True, "rarity": "uncommon",
     "hasFluff": True, "hasFluffImages": True,
     "entries": ["Coals carried in this satchel stay warm for a tenday and never burn the leather."]})
json.dump(items, open(path, "w"))
json.dump({"itemFluff": [
    {"name": "Ember Satchel", "source": "EMBC",
     "entries": ["Charcoal burners stitch these from smoked hide."],
     "images": [{"type": "image", "href": {"type": "internal", "path": "items/EMBC/Ember Satchel.webp"}}]}]},
    open(f"{data}/fluff-items.json", "w"))
PY
mkdir -p "$CACHE/v3.0.0/img/items/EMBC"
printf 'INVENTED IMAGE: items/EMBC/Ember Satchel.webp' > "$CACHE/v3.0.0/img/items/EMBC/Ember Satchel.webp"
cat >> Strumenti_DM/Glossario_Traduzioni.md <<'MD'
| source | fonte | fallback | |
| Magic_Items | Oggetti_Magici | Traduzione Ufficiale | |
MD
