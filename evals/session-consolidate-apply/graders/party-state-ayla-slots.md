---
type: regex
target: {source: file, path: Campaigns/Ashfall/Party_State.md}
match: contains
flags: mi
---
^## Ayla$(?:(?!^## )[\s\S])*?(?:\b(?:two|2)\b[^\n]*slot|slot[^\n]*\b(?:two|2)\b)
