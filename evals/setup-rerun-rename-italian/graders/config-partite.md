---
type: regex
target: {source: file, path: workspace-config.yml}
match: contains
flags: m
---
^\s*campaigns:\s*"?Partite"?\s*(#.*)?$
