---
type: regex
target: {source: file, path: workspace-config.yml}
match: not_contains
flags: m
---
^stat_blocks:
