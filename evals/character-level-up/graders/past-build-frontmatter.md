---
type: regex
target: {source: file, path: Characters/Wren/Past_Builds/Wren_02.md}
match: contains
flags: m
---
^(?<![\s\S])---\n(?=(?:(?!---$)[^\n]*\n)*?player:\s*Carla\s*$)(?=(?:(?!---$)[^\n]*\n)*?level:\s*3\s*$)(?!(?:(?!---$)[^\n]*\n)*?status:)
