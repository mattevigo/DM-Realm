---
type: regex
target: {source: file, path: workspace-config.yml}
match: contains
flags: m
---
^language:\s*English\s*$
