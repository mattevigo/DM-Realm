---
type: regex
target: {source: file, path: Characters/Tamsin_Reed/Tamsin_Reed.md}
match: contains
flags: m
---
^(?=[\s\S]*^player:\s*Dario\s*$)(?=[\s\S]*^status:\s*active\s*$)(?=[\s\S]*^level:\s*1\s*$)(?![\s\S]*^(campaign|type|hp|ac|class):)
