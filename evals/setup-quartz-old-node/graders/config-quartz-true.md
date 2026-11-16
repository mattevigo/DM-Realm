---
type: regex
target: {source: file, path: workspace-config.yml}
match: contains
flags: m
---
^quartz:\s*true\s*(#.*)?$
