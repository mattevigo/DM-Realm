---
type: regex
target: {source: file, path: Characters/Juno/Juno.md}
match: contains
flags: m
---
^## Statistics\s*\n\s*%% statblock\n(?=(?:(?!^## )[\s\S])*^layout: DM Realm Character$)(?=(?:(?!^## )[\s\S])*^\*\*Hit Point Maximum\*\* 10$)(?=(?:(?!^## )[\s\S])*^\*\*Armor Class\*\* 13$)(?![\s\S]*^## )
