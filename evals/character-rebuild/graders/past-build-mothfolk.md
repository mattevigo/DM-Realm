---
type: regex
target: {source: file, path: Characters/Wren/Past_Builds/Wren_02.md}
match: contains
flags: m
---
^(?=[\s\S]*^level:\s*3\s*$)(?![\s\S]*^status:)(?=[\s\S]*\[\[([^\]|]*/)?Mothfolk[|\]])
