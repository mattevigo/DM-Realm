---
type: regex
target: trace
match: contains
---
"file_path":\s*"[^"]*Riferimento/Mostri/[^"]*",\s*"content":\s*"(?=(?:[^"\\]|\\.)*\\nstatblock: inline\\n)(?=(?:[^"\\]|\\.)*```statblock\\nname: [^\\]+\\n)(?=(?:[^"\\]|\\.)*\\nsize: Piccol[oa]\\n)(?=(?:[^"\\]|\\.)*\\ninitiative: 4\\n)(?=(?:[^"\\]|\\.)*\\nstats: \[8, 15, 14, 9, 10, 8\]\\n)(?=(?:[^"\\]|\\.)*\\nactions:\\n)(?!(?:[^"\\]|\\.)*\\nlayout:)
