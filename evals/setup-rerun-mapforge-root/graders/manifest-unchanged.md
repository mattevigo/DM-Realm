---
type: regex
target: {source: file, path: .mapforge/workspace.json}
match: contains
---
^\{ "version" : 1, "createdAt" : "2026-09-17T20:09:51Z", "createdBy" : "1\.2\.0" \}\n?$
