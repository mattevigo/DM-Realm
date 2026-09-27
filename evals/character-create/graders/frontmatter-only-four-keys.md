---
type: regex
target: {source: file, path: Characters/Juno/Juno.md}
match: contains
flags: m
---
^---\n(?=(?:[^\n]*\n){0,3}statblock:\s*inline\s*\n)(?:(?:player|status|level|statblock):[^\n]*\n){4}---$
