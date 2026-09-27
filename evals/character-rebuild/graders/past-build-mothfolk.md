---
type: regex
target: {source: file, path: Characters/Wren/Past_Builds/Wren_01.md}
match: contains
flags: m
---
^(?<![\s\S])---\n(?=(?:(?!---$)[^\n]*\n)*?level:\s*3\s*$)(?!(?:(?!---$)[^\n]*\n)*?status:)(?=[\s\S]*\[\[([^\]|]*/)?Mothfolk[|\]])
