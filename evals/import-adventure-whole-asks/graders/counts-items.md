---
type: regex
target: last_message
match: contains
flags: mi
---
\b(2|two)\b[^.\n]{0,40}item|item[^.\n]{0,40}\b(2|two)\b
