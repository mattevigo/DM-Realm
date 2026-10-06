# Shared starting state for the Table Record cases: session-played.sh's Session 03 of
# Ashfall (Sessione_03 of Cenere in Italian), played with MapForge and not consolidated,
# with the DM's own Live Notes and MapForge's files for that evening: its Session Log (a
# saving throw among its lines, and a move the Live Notes leave out), two Maps of the
# Campaign, the fog file naming a Creature's Monster and one Combat Log (an ability check
# in it). In English, MapForge also holds the Villains table's log of the same day (Maps
# of the Villains Campaign only). Logs start at
# 12:00 UTC so the local date is the 19th in any time zone from UTC-11 to UTC+11.
# Every note and log here is INVENTED test content. Set before sourcing:
#   WS_LANG   en (default) or it
#   TR_STATE  new (default): the evening's log is not in the Live Notes yet; written: it
#             already is, under its marker; running: MapForge has not closed the evening
WS_LANG=${WS_LANG:-en}
TR_STATE=${TR_STATE:-new}
if [ "$WS_LANG" = it ]; then
  TR_CAMPAIGN=Campagne/Cenere; TR_MAPS=Campagne/Cenere/Allegati
  TR_GATE="Corpo di Guardia"; TR_VAULT=Cripta; TR_MONSTER="Cultista della Cenere"
  TR_SNEAK="Il gruppo si avvicina al corpo di guardia dalla chiusa"
  TR_FLED="Il sergente è fuggito dalla chiusa"
  TR_LOOT="Stanza del tesoro: 60 mo e un calice d'argento"
  TR_NOTE="entra in ira e spacca CC1"
  SP_LIVE_NOTES="- preso il corpo di guardia
- lettera sigillata sulla scrivania, senza mittente"
else
  TR_CAMPAIGN=Campaigns/Ashfall; TR_MAPS=Campaigns/Ashfall/Attachments
  TR_GATE=Gatehouse; TR_VAULT=Vault; TR_MONSTER="Cinder Cultist"
  TR_SNEAK="The party sneaks up on the gatehouse by the sluice"
  TR_FLED="Their sergeant fled through the sluice"
  TR_LOOT="Strongroom: 60 gp and a silver chalice"
  TR_NOTE="rages and cleaves CC1"
  SP_LIVE_NOTES="- took the gatehouse
- sealed letter on the desk, no sender"
fi
TR_LOG=2026-09-19T120000Z.jsonl
if [ "$TR_STATE" = written ]; then
  SP_LIVE_NOTES="$SP_LIVE_NOTES

### MapForge, 2026-09-19 12:00

%% mapforge $TR_LOG %%

- **Map: $TR_GATE**
- $TR_SNEAK"
fi
. "$(dirname "$0")/../_fixtures/session-played.sh"

GATE="$TR_MAPS/$TR_GATE.png"; VAULT="$TR_MAPS/$TR_VAULT.png"
mkdir -p "$TR_MAPS/$TR_GATE.combat" .mapforge/sessions
printf 'PNG placeholder\n' > "$GATE"; printf 'PNG placeholder\n' > "$VAULT"
printf '{ "version": 1, "createdAt": "2026-09-01T10:12:00Z", "createdBy": "1.2.0" }\n' > .mapforge/workspace.json
cat > "$TR_MAPS/$TR_GATE.fog.json" <<JSON
{ "version": 2, "walls": [], "lights": [],
  "pawns": [ { "id": "A", "label": "Ayla", "kind": "player" },
             { "id": "D", "label": "Durga", "kind": "player" },
             { "id": "C1", "label": "CC1", "kind": "creature", "monsterName": "$TR_MONSTER" },
             { "id": "C2", "label": "CC2", "kind": "creature", "monsterName": "$TR_MONSTER" } ] }
JSON
TR_END='{"endedAt":"2026-09-19T16:00:00Z","line":"sessionEnded"}'
[ "$TR_STATE" = running ] && TR_END=
cat > ".mapforge/sessions/$TR_LOG" <<JSONL
{"line":"sessionStarted","startedAt":"2026-09-19T12:00:00Z"}
{"at":"2026-09-19T12:05:00Z","line":"comment","map":"$GATE","text":"$TR_SNEAK"}
{"at":"2026-09-19T12:06:00Z","distanceSquares":3.5,"from":{"imagePixels":{"x":10,"y":10}},"label":"Ayla","line":"pawnMoved","map":"$GATE","pawnID":"A","to":{"imagePixels":{"x":40,"y":10}}}
{"ability":"wisdom","at":"2026-09-19T12:08:00Z","d20":14,"difficultyClass":13,"label":"Ayla","line":"savingThrow","map":"$GATE","modifier":1,"pawnID":"A"}
{"at":"2026-09-19T12:10:00Z","line":"encounterStarted","logFile":"2026-09-19T121000Z.jsonl","map":"$GATE"}
{"at":"2026-09-19T12:40:00Z","line":"encounterEnded","map":"$GATE"}
{"at":"2026-09-19T12:42:00Z","line":"comment","map":"$GATE","text":"$TR_FLED"}
{"at":"2026-09-19T13:00:00Z","line":"comment","map":"$VAULT","text":"$TR_LOOT"}
$TR_END
JSONL
B='"armorClass":14,"conditions":[],"exhaustion":0,"initiativeBonus":2,"isConcentrating":false,"isInCombat":true,"temporaryHP":0'
cat > "$TR_MAPS/$TR_GATE.combat/2026-09-19T121000Z.jsonl" <<JSONL
{"combatants":[{"block":{$B,"currentHP":24,"maxHP":24},"id":"A","initiative":17,"kind":"player","name":"Ayla"},{"block":{$B,"currentHP":40,"maxHP":45},"id":"D","initiative":12,"kind":"player","name":"Durga"},{"block":{$B,"currentHP":9,"maxHP":9},"id":"C1","initiative":9,"kind":"creature","name":"CC1"},{"block":{$B,"currentHP":9,"maxHP":9},"id":"C2","initiative":5,"kind":"creature","name":"CC2"}],"line":"encounterStarted","order":["A","D","C1","C2"],"startedAt":"2026-09-19T12:10:00Z"}
{"changes":[{"combatantID":"C2","from":9,"to":4,"type":"hpChanged"}],"combatantID":"A","endedAt":"2026-09-19T12:12:00Z","line":"turn","round":1}
{"changes":[{"combatantID":"C1","from":9,"to":0,"type":"hpChanged"},{"combatantID":"C1","condition":"unconscious","type":"conditionAdded"},{"combatantID":"D","text":"$TR_NOTE","type":"noteAdded"},{"combatantID":"D","d20":12,"difficultyClass":15,"modifier":5,"name":"Durga","skill":"athletics","type":"abilityCheck"}],"combatantID":"D","endedAt":"2026-09-19T12:15:00Z","line":"turn","round":1}
{"changes":[{"combatantID":"A","from":24,"to":17,"type":"hpChanged"},{"combatantID":"A","condition":"poisoned","type":"conditionAdded"},{"combatantID":"D","from":40,"to":28,"type":"hpChanged"}],"combatantID":"C2","endedAt":"2026-09-19T12:18:00Z","line":"turn","round":1}
{"changes":[{"combatantID":"D","from":28,"to":22,"type":"hpChanged"}],"line":"correction","recordedAt":"2026-09-19T12:30:00Z","targetCombatantID":"C2","targetRound":1}
{"changes":[{"combatantID":"C2","type":"combatantRemoved"}],"combatantID":"C2","endedAt":"2026-09-19T12:20:00Z","line":"turn","round":2}
{"endedAt":"2026-09-19T12:40:00Z","line":"encounterEnded"}
JSONL
if [ "$WS_LANG" = en ]; then
  mkdir -p Campaigns/Villains/Attachments
  printf 'PNG placeholder\n' > Campaigns/Villains/Attachments/Lair.png
  cat > .mapforge/sessions/2026-09-19T110000Z.jsonl <<'JSONL'
{"line":"sessionStarted","startedAt":"2026-09-19T11:00:00Z"}
{"at":"2026-09-19T11:05:00Z","line":"comment","map":"Campaigns/Villains/Attachments/Lair.png","text":"The villains plot in the lair"}
{"endedAt":"2026-09-19T11:50:00Z","line":"sessionEnded"}
JSONL
fi
