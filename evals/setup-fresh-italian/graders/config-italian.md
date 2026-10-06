---
type: regex
target: {source: file, path: workspace-config.yml}
match: contains
flags: mi
---
^language:\s*"?(Italiano|Italian)"?\s*(#.*)?$
