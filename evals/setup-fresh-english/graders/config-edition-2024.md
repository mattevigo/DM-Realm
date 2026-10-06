---
type: regex
target: {source: file, path: workspace-config.yml}
match: contains
flags: m
---
^edition:\s*"?2024"?\s*(#.*)?$
