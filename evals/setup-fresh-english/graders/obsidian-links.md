---
type: regex
target: {source: file, path: .obsidian/app.json}
match: contains
---
"useMarkdownLinks":\s*false[\s\S]*"newLinkFormat":\s*"shortest"|"newLinkFormat":\s*"shortest"[\s\S]*"useMarkdownLinks":\s*false
