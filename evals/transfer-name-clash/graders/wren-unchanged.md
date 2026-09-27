---
type: regex
target: {source: file, path: Characters/Wren/Wren.md}
match: contains
flags: m
---
^(?<![\s\S])---\n(?:(?!---$)[^\n]*\n)*?player:\s*Carla\s*$
