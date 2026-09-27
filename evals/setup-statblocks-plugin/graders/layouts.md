---
type: regex
target: {source: file, path: .obsidian/plugins/obsidian-5e-statblocks/data.json}
match: contains
---
^(?=[\s\S]*"name":\s*"DM Realm Character")(?=[\s\S]*"name":\s*"DM Realm Monster 2014")(?=[\s\S]*"name":\s*"DM Realm Monster 2024")
