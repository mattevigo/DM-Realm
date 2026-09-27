---
type: regex
target: {source: file, path: Characters/Wren/Wren.md}
match: contains
flags: m
---
^(?<![\s\S])---\n(?=(?:(?!---$)[^\n]*\n)*?status:\s*retired\s*$)(?=(?:(?!---$)[^\n]*\n)*?level:\s*3\s*$)(?=(?:(?!---$)[^\n]*\n)*?player:\s*Carla\s*$)
