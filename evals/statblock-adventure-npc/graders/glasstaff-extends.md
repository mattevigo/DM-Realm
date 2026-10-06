---
type: regex
target: {source: file, path: Adventures/The_Salt_Crypt/NPCs/Glasstaff.md}
match: contains
flags: m
---
^```statblock\n(?=(?:(?!```)[\s\S])*^name:\s*Glasstaff\s*$)(?=(?:(?!```)[\s\S])*^extends:\s*"?Salt Wight"?\s*$)(?=(?:(?!```)[\s\S])*^hp:\s*70\s*$)
