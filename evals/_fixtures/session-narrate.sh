# Shared starting state for the Chronicle cases: session-campaign.sh's Campaign with
# Session 03 played by Ayla and Durga (Brom absent) and consolidated, its Live Notes
# holding numbers, a line of dialogue and one fact the party did not learn (the sergeant
# is Tessa Brannock's brother), and an NPC note for Tessa. Every note here is INVENTED
# test content. Set before sourcing:
#   WS_LANG      en (default) or it
#   SN_PREVIOUS  yes (default): the Chronicle already holds Session 02's Chapter, so the
#                Side Session between them is a gap; or no: no Chronicle (English only)
#   SN_VOICE     the Voice's instructions, one per line, or empty for no Voice (English only)
#   SN_CHAPTER   yes: Session 03 already has a Chapter, edited by the DM (English only)
WS_LANG=${WS_LANG:-en}
SN_PREVIOUS=${SN_PREVIOUS:-yes}
SN_CHAPTER=${SN_CHAPTER:-no}
SC_CONSOLIDATED=yes
. "$(dirname "$0")/../_fixtures/session-campaign.sh"

if [ "$WS_LANG" = it ]; then
  session Sessione_03_Il_Corpo_di_Guardia 3 2026-09-19 "Sessione 3: Il Corpo di Guardia" '[[Ayla]], [[Durga]]' \
    "- attraversata la diga al tramonto, cultisti della cenere sulle mura
- Durga sfonda il portone con l'ascia; Ayla abbatte il campanaro prima che dia l'allarme
- il sergente fugge dalla chiusa
- Ayla finisce a 17 punti ferita, due slot di 1° livello spesi; Durga a 22
- lettera sigillata sulla scrivania, senza mittente
- [[Tessa_Brannock]] aspetta al portone, chiede una scorta fino al porto. Durga: «Fino al porto, e non un passo oltre.»
- (non se ne accorgono) il sergente è il fratello di Tessa" \
    "Il gruppo ha attraversato la diga al tramonto e ha preso il corpo di guardia della fortezza sommersa ai cultisti della cenere; il sergente è fuggito dalla chiusa. Tessa Brannock ha chiesto una scorta fino al porto." \
    "- Chi ha mandato la lettera sigillata trovata sulla scrivania?
- Tessa Brannock ha chiesto una scorta fino al porto."
  printf '# Tessa Brannock\n\nTraghettatrice della palude, capelli rossi, risata facile.\n' > $SC/PNG/Tessa_Brannock.md
  return 0
fi

session Session_03_The_Gatehouse 3 2026-09-19 "Session 3: The Gatehouse" '[[Ayla]], [[Durga]]' \
  "- crossed the causeway at dusk, cinder cultists on the walls
- Durga broke the gate with her axe; Ayla shot the bell-ringer before he raised the alarm
- the sergeant fled through the sluice
- Ayla ends at 17 hp, two 1st-level slots spent; Durga at 22 hp
- sealed letter on the desk, no sender
- [[Tessa_Brannock]] waiting at the gate, asks for an escort to the harbour. Durga: \"To the harbour, and not a step further.\"
- (they didn't notice) the sergeant is Tessa's brother" \
  "The party crossed the causeway at dusk and took the gatehouse of the Sunken Keep from the cinder cultists; their sergeant fled through the sluice. Tessa Brannock asked for an escort to the harbour." \
  "- Who sent the sealed letter found on the desk?
- Tessa Brannock asked the party for an escort to the harbour."
printf '# Tessa Brannock\n\nA ferrywoman of the marsh, red-haired, quick to laugh.\n' > $SC/NPCs/Tessa_Brannock.md

[ "$SN_PREVIOUS" = yes ] || [ -n "$SN_VOICE" ] || [ "$SN_CHAPTER" = yes ] || return 0
mkdir -p $SC/Chronicle
if [ "$SN_PREVIOUS" = yes ]; then
  cat > $SC/Chronicle/Chapter_02_The_Ford.md <<'MD'
# Chapter 2: The Ford

[[Session_02_The_Ford|Session 2: The Ford]]

The river had swallowed the ford whole. The ferryman swore the water would drop by noon, and he was lying, and they crossed anyway, roped together, the current tearing at their boots. By nightfall the drowned keep rose out of the mist ahead of them, black against a sky the colour of ash.
MD
fi
if [ -n "$SN_VOICE" ]; then
  printf '# Voice\n\n%s\n' "$SN_VOICE" > $SC/Chronicle/Voice.md
fi
if [ "$SN_CHAPTER" = yes ]; then
  cat > $SC/Chronicle/Chapter_03_The_Gatehouse.md <<'MD'
# Chapter 3: The Gatehouse

[[Session_03_The_Gatehouse|Session 3: The Gatehouse]]

The causeway ran straight into the dusk. Durga went first, as she always did. (DM's own line, added by hand: the bell never rang that night.)
MD
fi
