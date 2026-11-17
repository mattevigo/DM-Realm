---
type: regex
target: last_message
match: contains
flags: i
---
MapForge[^\n]{0,200}\b(every|whole|all|entire)\b[^\n]{0,80}\b(notes?|Workspace|vault)\b
