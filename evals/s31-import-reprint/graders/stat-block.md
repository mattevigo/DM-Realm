---
type: regex
target: {source: file, path: Reference/Monsters/Bog_Goblin.md}
match: contains
flags: m
---
^(?<![\s\S])---\n(?=(?:(?!---$)[^\n]*\n)*?statblock:\s*inline\s*$)[\s\S]*^```statblock\n(?=(?:(?!```)[\s\S])*^name:\s*Bog Goblin\s*$)(?=(?:(?!```)[\s\S])*^initiative:\s*4\s*$)(?=(?:(?!```)[\s\S])*^stats:\s*\[8, 15, 14, 9, 10, 8\]\s*$)(?!(?:(?!```)[\s\S])*^layout:)
