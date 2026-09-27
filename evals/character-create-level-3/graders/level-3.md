---
type: regex
target: {source: file, path: Characters/Ossian/Ossian.md}
match: contains
flags: m
---
^(?<![\s\S])---\n(?=(?:(?!---$)[^\n]*\n)*?player:\s*Carla\s*$)(?=(?:(?!---$)[^\n]*\n)*?level:\s*3\s*$)
