---
type: regex
target: {source: file, path: Campagne/Cenere/Diario.md}
match: contains
---
^(?<![\s\S])# Diario\n\n- \*\*Sessione 01\*\* — 2026-09-05 — \[\[Sessione_01_La_Strada_del_Nord\]\]\. Il gruppo si è incontrato e ha messo in fuga dei banditi\.\n- \*\*Sessione 02\*\* — 2026-09-12 — \[\[Sessione_02_Il_Guado\]\]\. Il guado in piena, attraversato a fatica\.\n- \*\*Interludio La Lunga Notte\*\* — 2026-09-16 — \[\[Interludio_La_Lunga_Notte\]\]\. Ayla ha visto delle luci nella palude\.\n+- [^\n]*2026-09-19[^\n]*\[\[([^\]|]*/)?Sessione_03_Il_Corpo_di_Guardia[|\]][^\n]*\n*(?![\s\S])
