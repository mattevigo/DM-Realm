---
type: regex
target: {source: file, path: .mapforge/sessions/2026-09-19T120000Z.jsonl}
match: contains
---
^(?<![\s\S])\{"line":"sessionStarted","startedAt":"2026-09-19T12:00:00Z"\}\n[\s\S]*\{"endedAt":"2026-09-19T16:00:00Z","line":"sessionEnded"\}\n(?![\s\S])
