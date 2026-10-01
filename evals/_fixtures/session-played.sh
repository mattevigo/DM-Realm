# Shared starting state for the Consolidation cases: session-campaign.sh's Campaign with
# one Session played and not consolidated — Live Notes only, no Recap, no Loose threads,
# no Diary entry — and a Campaign note that links to it. Every note here is INVENTED test
# content. Set before sourcing:
#   WS_LANG        en (default) or it
#   SP_SESSION     numbered (default): Session 03, in the untitled Session_03.md
#                  (Sessione_03.md in Italian); or side: the Side Session
#                  Interlude_The_Long_Night, played between Sessions 02 and 03, both
#                  consolidated (English only)
#   SP_LIVE_NOTES  its Live Notes (default below), or none for an empty section
#   SP_WREN        yes: Wren (character-wren.sh, with the Character Source Cache) joins
#                  the party and plays the Session with Ayla (English only)
WS_LANG=${WS_LANG:-en}
SP_SESSION=${SP_SESSION:-numbered}
SP_WREN=${SP_WREN:-no}
SC_CONSOLIDATED=yes
[ "$WS_LANG" = it ] || [ "$SP_SESSION" = side ] || SC_CONSOLIDATED=no
. "$(dirname "$0")/../_fixtures/session-campaign.sh"

if [ "$SP_SESSION" = side ]; then
  SP_DEFAULT="- Ayla on watch alone, lights in the marsh
- she waded out after them and came back at dawn with 11 hp"
elif [ "$WS_LANG" = it ]; then
  SP_DEFAULT="- preso il corpo di guardia ai cultisti della cenere, il sergente è fuggito dalla chiusa
- Durga finisce a 22 punti ferita, Ayla e Brom illesi
- lettera sigillata sulla scrivania, senza mittente
- nella stanza del tesoro 60 mo, messe nella cassa comune"
else
  SP_DEFAULT="- Brom's player could not make it: Ayla and Durga only
- took the gatehouse from the cinder cultists, their sergeant fled through the sluice
- Ayla spent two 1st-level spell slots and ends at 17 hp; Durga ends at 22 hp
- strongroom: 60 gp and a silver chalice, into the party fund
- sealed letter on the desk, no sender
- milestone: everyone gains a level"
fi
SP_LIVE_NOTES=${SP_LIVE_NOTES:-$SP_DEFAULT}
[ "$SP_LIVE_NOTES" = none ] && SP_LIVE_NOTES=

if [ "$SP_SESSION" = side ]; then
  session Interlude_The_Long_Night "" 2026-09-16 "Interlude The Long Night" "[[Ayla]]" "$SP_LIVE_NOTES" "" ""
  grep -v Interlude_The_Long_Night $SC/Diary.md > $SC/Diary.tmp && mv $SC/Diary.tmp $SC/Diary.md
elif [ "$WS_LANG" = it ]; then
  rm $SC_DIR/Sessione_03_Il_Corpo_di_Guardia.md
  session Sessione_03 3 2026-09-19 "Sessione 3" "$PARTY" "$SP_LIVE_NOTES" "" ""
  grep -v Sessione_03 $SC/Diario.md > $SC/Diario.tmp && mv $SC/Diario.tmp $SC/Diario.md
  printf '# Corpo di Guardia\n\nIl corpo di guardia della fortezza sommersa, preso nella [[Sessione_03]].\n' > $SC/Luoghi/Corpo_di_Guardia.md
else
  if [ "$SP_WREN" = yes ]; then
    . "$(dirname "$0")/../_fixtures/character-workspace.sh"
    . "$(dirname "$0")/../_fixtures/character-wren.sh"
    PARTY='[[Ayla]], [[Wren]]'
    sed 's/^- \[\[Durga\]\]$/&\
- [[Wren]]/' $SC/README.md > $SC/README.tmp && mv $SC/README.tmp $SC/README.md
    sed 's/^## Party treasure$/## Wren\
\
[[Wren]]: 24 of 24 hit points; no spell slots spent.\
\
&/' $SC/Party_State.md > $SC/Party_State.tmp && mv $SC/Party_State.tmp $SC/Party_State.md
  fi
  session Session_03 3 2026-09-19 "Session 3" "$PARTY" "$SP_LIVE_NOTES" "" ""
  printf '# Gatehouse\n\nThe gatehouse of the Sunken Keep, taken in [[Session_03]].\n' > $SC/Places/Gatehouse.md
fi
