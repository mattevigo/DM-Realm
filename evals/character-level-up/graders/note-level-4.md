---
type: regex
target: {source: file, path: Characters/Wren/Wren.md}
match: contains
flags: m
---
^(?<![\s\S])---\n(?=(?:(?!---$)[^\n]*\n)*?status:\s*active\s*$)(?=(?:(?!---$)[^\n]*\n)*?level:\s*4\s*$)
