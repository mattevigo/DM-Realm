---
type: regex
target: {source: file, path: Characters/Tamsin_Reed/Tamsin_Reed.md}
match: contains
flags: m
---
^(?<![\s\S])---\n(?=(?:(?!---$)[^\n]*\n)*?player:\s*Dario\s*$)(?=(?:(?!---$)[^\n]*\n)*?status:\s*active\s*$)(?=(?:(?!---$)[^\n]*\n)*?level:\s*1\s*$)(?!(?:(?!---$)[^\n]*\n)*?(campaign|type|hp|ac|class):)
