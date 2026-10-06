---
type: regex
target: {source: file, path: workspace-config.yml}
match: contains
flags: m
---
^\s*templates:\s*"?Blueprints"?\s*(#.*)?$
