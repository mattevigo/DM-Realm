---
type: regex
target: {source: file, path: .obsidian/plugins/obsidian-5e-statblocks/data.json}
match: not_contains
---
"(display|heading)":\s*"(Armor Class|Hit Points|Actions|Saving Throws|Senses|Languages)"
