---
type: regex
target: {source: file, path: Adventures/The_Salt_Crypt/NPCs/Glasstaff.md}
match: contains
flags: m
---
^(?<![\s\S])---\n(?:(?!---$)[^\n]*\n)*?statblock:\s*inline\s*$
