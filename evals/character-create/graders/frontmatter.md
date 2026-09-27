---
type: regex
target: {source: file, path: Characters/Juno/Juno.md}
match: contains
flags: m
---
^(?<![\s\S])---\n(?=(?:(?!---$)[^\n]*\n)*?player:\s*Baldu\s*$)(?=(?:(?!---$)[^\n]*\n)*?status:\s*active\s*$)(?=(?:(?!---$)[^\n]*\n)*?level:\s*1\s*$)
