---
type: regex
target: {source: file, path: Templates/Session.md}
match: contains
flags: m
---
^number:[\s\S]*^\*\*Present:\*\*[\s\S]*^## Prep$[\s\S]*^## Live notes$[\s\S]*^## Recap$
