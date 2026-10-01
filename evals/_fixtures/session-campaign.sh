# Shared starting state for the Session cases: the English or Italian Workspace
# (workspace-en.sh / workspace-it.sh, by WS_LANG) plus one Campaign that is being played
# — "Ashfall" ("Cenere" in Italian): a README with its party, three numbered Sessions
# and a Side Session made from the Session Template, a Diary and a Party State.
# Every note here is INVENTED test content. Set before sourcing:
#   WS_LANG          en (default) or it
#   SC_SESSIONS      played (default), or none: a Campaign just started, with no
#                    Session, Diary or Party State
#   SC_CONSOLIDATED  yes (default), or no: Session 03 was played but not consolidated —
#                    it has Live Notes only, and the Diary has no entry for it
# The Italian Campaign is always played and consolidated, and runs no Adventure.
WS_LANG=${WS_LANG:-en}
SC_SESSIONS=${SC_SESSIONS:-played}
SC_CONSOLIDATED=${SC_CONSOLIDATED:-yes}
. "$(dirname "$0")/../_fixtures/workspace-$WS_LANG.sh"

if [ "$WS_LANG" = it ]; then
  mkdir -p Personaggi/Ayla Personaggi/Brom Personaggi/Durga
  printf '# Ayla\n\nElfa ranger.\n' > Personaggi/Ayla/Ayla.md
  printf '# Brom\n\nNano guerriero.\n' > Personaggi/Brom/Brom.md
  printf '# Durga\n\nOrchessa barbara.\n' > Personaggi/Durga/Durga.md
  cat >> Strumenti_DM/Glossario_Traduzioni.md <<'MD'
| Diary | Diario | fallback | |
| Party_State | Stato_del_Gruppo | fallback | |
MD
  SC=Campagne/Cenere
  SC_DIR=$SC/Sessioni
  mkdir -p $SC/PNG $SC_DIR $SC/Luoghi $SC/Missioni $SC/Fazioni $SC/Allegati
  cat > $SC/README.md <<'MD'
# Cenere

## Premessa

I cultisti della Cenere si agitano sotto una fortezza sommersa.

## Gruppo

- [[Ayla]]
- [[Brom]]
- [[Durga]]

## Livello Iniziale

3

## Stato Attuale

Il gruppo tiene il corpo di guardia della fortezza.
MD
else
  SC=Campaigns/Ashfall
  SC_DIR=$SC/Sessions
  mkdir -p $SC/NPCs $SC_DIR $SC/Places $SC/Quests $SC/Factions $SC/Attachments
  cat > $SC/README.md <<'MD'
# Ashfall

## Pitch

Cinder cultists stir beneath a drowned keep.

## Adventures Run

- [[Adventures/The_Sunken_Keep/README|The Sunken Keep]] — whole — running

## Party

- [[Ayla]]
- [[Brom]]
- [[Durga]]

## Starting Level

3

## Current State

The party holds the gatehouse of the Sunken Keep.
MD
fi
[ "$SC_SESSIONS" = none ] && return 0

# session <file name> <number or ""> <date> <heading> <present> <live notes> <recap> <loose threads>
# A Session note as made from the Session Template; a Side Session passes no number.
session() {
  if [ "$WS_LANG" = it ]; then
    K_NUMBER=numero; K_DATE=data; H_PRESENT=Presenti; H_PREP=Preparazione
    H_PARTS="Inizio forte|Scene|Segreti e indizi|PNG|Luoghi|Incontri|Tesoro"
    H_LIVE="Note dal vivo"; H_RECAP=Riepilogo; H_THREADS="Fili in sospeso"
  else
    K_NUMBER=number; K_DATE=date; H_PRESENT=Present; H_PREP=Prep
    H_PARTS="Strong start|Scenes|Secrets and clues|NPCs|Places|Encounters|Treasure"
    H_LIVE="Live notes"; H_RECAP=Recap; H_THREADS="Loose threads"
  fi
  {
    printf -- '---\n'
    [ -z "$2" ] || printf '%s: %s\n' "$K_NUMBER" "$2"
    printf '%s: %s\n---\n\n# %s\n\n**%s:** %s\n\n## %s\n\n' "$K_DATE" "$3" "$4" "$H_PRESENT" "$5" "$H_PREP"
    echo "$H_PARTS" | tr '|' '\n' | while read -r part; do printf '### %s\n\n' "$part"; done
    printf '## %s\n\n' "$H_LIVE"; [ -z "$6" ] || printf '%s\n\n' "$6"
    printf '## %s\n\n' "$H_RECAP"; [ -z "$7" ] || printf '%s\n\n' "$7"
    printf '## %s\n' "$H_THREADS"; [ -z "$8" ] || printf '\n%s\n' "$8"
  } > "$SC_DIR/$1.md"
}
PARTY='[[Ayla]], [[Brom]], [[Durga]]'

if [ "$WS_LANG" = it ]; then
  session Sessione_01_La_Strada_del_Nord 1 2026-09-05 "Sessione 1: La Strada del Nord" "$PARTY" \
    "- banditi sulla strada, messi in fuga" "Il gruppo si è incontrato sulla strada del nord e ha messo in fuga dei banditi." ""
  session Sessione_02_Il_Guado 2 2026-09-12 "Sessione 2: Il Guado" "$PARTY" \
    "- guado in piena, il traghettatore mente" "Il gruppo ha attraversato il guado in piena." ""
  session Interludio_La_Lunga_Notte "" 2026-09-16 "Interludio La Lunga Notte" "[[Ayla]]" \
    "- Ayla di guardia da sola, luci nella palude" "Ayla ha vegliato da sola e ha visto delle luci nella palude." ""
  session Sessione_03_Il_Corpo_di_Guardia 3 2026-09-19 "Sessione 3: Il Corpo di Guardia" "$PARTY" \
    "- preso il corpo di guardia, Brom ferito gravemente" "Il gruppo ha preso il corpo di guardia della fortezza." \
    "- Chi ha mandato la lettera sigillata trovata sulla scrivania?
- La chiave di ottone della cripta allagata non si trova.
- Tessa Brannock ha chiesto una scorta fino al porto."
  cat > $SC/Diario.md <<'MD'
# Diario

- **Sessione 01** — 2026-09-05 — [[Sessione_01_La_Strada_del_Nord]]. Il gruppo si è incontrato e ha messo in fuga dei banditi.
- **Sessione 02** — 2026-09-12 — [[Sessione_02_Il_Guado]]. Il guado in piena, attraversato a fatica.
- **Interludio La Lunga Notte** — 2026-09-16 — [[Interludio_La_Lunga_Notte]]. Ayla ha visto delle luci nella palude.
- **Sessione 03** — 2026-09-19 — [[Sessione_03_Il_Corpo_di_Guardia]]. Il corpo di guardia è preso.
MD
  cat > $SC/Stato_del_Gruppo.md <<'MD'
# Stato del Gruppo

## Ayla

[[Ayla]]: 24 punti ferita su 24; nessuno slot speso.

## Brom

[[Brom]]: 9 punti ferita su 31.

## Durga

[[Durga]]: 40 punti ferita su 45; 2 usi di Ira spesi.

## Tesoro del gruppo

- 120 mo
MD
  return 0
fi

session Session_01_The_Road_North 1 2026-09-05 "Session 1: The Road North" "$PARTY" \
  "- bandits on the road, driven off" "The party met on the north road and drove off bandits." ""
session Session_02_The_Ford 2 2026-09-12 "Session 2: The Ford" "$PARTY" \
  "- ford in flood, the ferryman lies" "The party crossed the flooded ford." ""
session Interlude_The_Long_Night "" 2026-09-16 "Interlude The Long Night" "[[Ayla]]" \
  "- Ayla on watch alone, lights in the marsh" "Ayla kept watch alone and saw lights in the marsh." ""
if [ "$SC_CONSOLIDATED" = no ]; then
  session Session_03 3 2026-09-19 "Session 3" "$PARTY" \
    "- took the gatehouse, Brom badly hurt
- sealed letter on the desk, no sender
- Tessa Brannock wants an escort to the harbour" "" ""
  SC_DIARY_03=
else
  session Session_03_The_Gatehouse 3 2026-09-19 "Session 3: The Gatehouse" "$PARTY" \
    "- took the gatehouse, Brom badly hurt" "The party took the gatehouse of the keep." \
    "- Who sent the sealed letter found on the desk?
- The brass key to the flooded vault is still missing.
- Tessa Brannock asked the party for an escort to the harbour."
  SC_DIARY_03='- **Session 03** — 2026-09-19 — [[Session_03_The_Gatehouse]]. The gatehouse is taken.'
fi
cat > $SC/Diary.md <<MD
# Diary

- **Session 01** — 2026-09-05 — [[Session_01_The_Road_North]]. The party met and drove off bandits.
- **Session 02** — 2026-09-12 — [[Session_02_The_Ford]]. The flooded ford, crossed the hard way.
- **Interlude The Long Night** — 2026-09-16 — [[Interlude_The_Long_Night]]. Ayla saw lights in the marsh.
${SC_DIARY_03}
MD
cat > $SC/Party_State.md <<'MD'
# Party State

## Ayla

[[Ayla]]: 24 of 24 hit points; no spell slots spent.

## Brom

[[Brom]]: 9 of 31 hit points.

## Durga

[[Durga]]: 40 of 45 hit points; 2 Rage uses spent.

## Party treasure

- 120 gp
MD
