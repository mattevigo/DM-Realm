---
type: regex
target: {source: file, path: Campaigns/Ashfall/Diary.md}
match: contains
---
^(?<![\s\S])# Diary\n\n- \*\*Session 01\*\* — 2026-09-05 — \[\[Session_01_The_Road_North\]\]\. The party met and drove off bandits\.\n- \*\*Session 02\*\* — 2026-09-12 — \[\[Session_02_The_Ford\]\]\. The flooded ford, crossed the hard way\.\n- [^\n]*2026-09-16[^\n]*\[\[([^\]|]*/)?Interlude_The_Long_Night[|\]][^\n]*\n+- \*\*Session 03\*\* — 2026-09-19 — \[\[Session_03_The_Gatehouse\]\]\. The gatehouse is taken\.\n*(?![\s\S])
