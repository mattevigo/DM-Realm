---
type: regex
target: {source: file, path: Characters/Oren/Oren.md}
match: contains
flags: m
---
^statblock:\s*inline\s*$[\s\S]*^```statblock\n(?=(?:(?!```)[\s\S])*^layout:\s*DM Realm Character\s*$)(?=(?:(?!```)[\s\S])*^name:\s*Oren\s*$)
