---
type: regex
target: {source: file, path: .obsidian/core-plugins.json}
match: contains
---
^\s*\{[\s\S]*"templates":\s*true
