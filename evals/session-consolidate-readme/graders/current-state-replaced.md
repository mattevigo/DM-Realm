---
type: regex
target: {source: file, path: Campaigns/Ashfall/README.md}
match: contains
flags: m
---
^## Current State\n\n(?!The party holds the gatehouse of the Sunken Keep\.\n)(?:(?!^## )[\s\S])*?(?i:inn|spy|keep)
