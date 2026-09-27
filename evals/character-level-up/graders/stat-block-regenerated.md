---
type: regex
target: {source: file, path: Characters/Wren/Wren.md}
match: contains
flags: m
---
^```statblock\n(?=(?:(?!```)[\s\S])*^level:\s*4\s*$)(?=(?:(?!```)[\s\S])*^hp:\s*31\s*$)(?!(?:(?!```)[\s\S])*^bestiary:)
