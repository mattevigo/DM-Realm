---
type: regex
target: last_message
match: contains
flags: is
---
treasury[\s\S]{0,200}\b(4|four)\b|\b(4|four)\b[\s\S]{0,200}treasury
