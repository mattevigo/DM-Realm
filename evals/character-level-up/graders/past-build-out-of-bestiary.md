---
type: regex
target: {source: file, path: Characters/Wren/Past_Builds/Wren_02.md}
match: contains
flags: m
---
^(?<![\s\S])(?![\s\S]*^statblock:)[\s\S]*^```statblock\n(?=(?:(?!```)[\s\S])*^bestiary:\s*false\s*$)(?=(?:(?!```)[\s\S])*^hp:\s*24\s*$)
