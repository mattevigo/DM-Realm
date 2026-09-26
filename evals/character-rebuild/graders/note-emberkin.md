---
type: regex
target: {source: file, path: Characters/Wren/Wren.md}
match: contains
flags: m
---
^(?=[\s\S]*^level:\s*3\s*$)(?=[\s\S]*\[\[([^\]|]*/)?Emberkin[|\]])(?![\s\S]*\[\[([^\]|]*/)?Mothfolk[|\]])
