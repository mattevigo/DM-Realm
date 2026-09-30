---
type: regex
target: {source: file, path: Characters/Juno/Juno.md}
match: contains
flags: m
---
^## Statistics\s*\n\s*```statblock\n(?:(?!```)[\s\S])*^```\s*(?![\s\S]*^#)
