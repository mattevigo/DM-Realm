---
type: regex
target: {source: file, path: Campaigns/Ashfall/Party_State.md}
match: contains
flags: m
---
^## Ayla$(?:(?!^## )[\s\S])*?^- \*\*Spell Slots Spent:\*\*[^\n]*\b(?:2|two)\b
