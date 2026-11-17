---
type: regex
target: {source: file, path: .mapforge/parties.json}
match: contains
---
^\{"version": 1, "parties": \[\{"id": "p1", "name": "Lost Boys", "characters": \[\{"id": "c1", "name": "Ayla", "colorHex": "#D0342C", "sightSquares": 6, "noteName": "Ayla"\}, \{"id": "c2", "name": "Durga", "colorHex": "#2C6BD0", "sightSquares": 6\}\]\}\]\}\n?$
