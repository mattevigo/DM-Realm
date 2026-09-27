---
type: regex
target: {source: file, path: Characters/Juno/Juno.md}
match: contains
flags: m
---
^---\n(?:(?:player|status|level):[^\n]*\n){3}---$
