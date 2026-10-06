---
type: regex
target: {source: file, path: workspace-config.yml}
match: contains
flags: m
---
^stat_blocks: true
