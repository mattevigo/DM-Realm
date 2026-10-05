---
type: regex
target: {source: file, path: .mapforge/config.json}
match: contains
---
^\{"bestiaryStatBlockPath": "\."\}\n?$
