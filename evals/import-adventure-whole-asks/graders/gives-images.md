---
type: regex
target: last_message
match: contains
flags: mi
---
\b(1|one)\b[^.\n]{0,30}(image|map|picture)|(image|map|picture)s?\W{0,3}\s*\b(1|one)\b
