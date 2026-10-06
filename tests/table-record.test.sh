#!/bin/sh
# Tests the Table Record helper: which of MapForge's Session Logs belong to a Session, and
# what one holds for its Live Notes (ADR 0012). MapForge's files are only read (ADR 0011).
# Usage: sh tests/table-record.test.sh   (exit 0 = all pass)
set -u
HELPER="$(cd "$(dirname "$0")/.." && pwd)/skills/dmr-mapforge-import/table-record.py"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
FAILS=0
fail() { echo "FAIL $1"; FAILS=$((FAILS+1)); }
# field <json> <python expression on d>: prints the value, for comparisons.
field() { printf '%s' "$1" | python3 -c "import json,sys; d=json.load(sys.stdin); print(($2))"; }
# Local times are the machine's: pin them.
TZ=Europe/Rome; export TZ

W="$TMP/ws"
mkdir -p "$W/Campaigns/Ashfall/Sessions" "$W/Campaigns/Ashfall/Attachments" "$W/Campaigns/Villains/Attachments" \
  "$W/Adventures/The_Sunken_Keep/Attachments" "$W/.mapforge/sessions"
cat > "$W/workspace-config.yml" <<'YML'
language: English
edition: 2024
folders:
  reference: Reference
  adventures: Adventures
  homebrew: Homebrew
  world: World
  characters: Characters
  campaigns: Campaigns   # the campaigns
  dm_tools: DM_Tools
  templates: Templates
YML
printf '{ "version": 1, "createdAt": "2026-09-01T10:12:00Z", "createdBy": "1.2.0" }\n' > "$W/.mapforge/workspace.json"
GATE=Campaigns/Ashfall/Attachments/Gatehouse.png
VAULT=Campaigns/Ashfall/Attachments/Vault.png
LAIR=Campaigns/Villains/Attachments/Lair.png
KEEP=Adventures/The_Sunken_Keep/Attachments/Keep.png
S=$W/.mapforge/sessions

# The Ashfall evening of 19 September (20:00 in Rome): two Maps, comments, a move, a roll,
# one fight with a Correction, and a comment with no Map.
cat > "$S/2026-09-19T180000Z.jsonl" <<JSONL
{"line":"sessionStarted","startedAt":"2026-09-19T18:00:00Z"}
{"at":"2026-09-19T18:01:00Z","line":"comment","map":"$GATE","text":"The party reaches the gatehouse"}
{"at":"2026-09-19T18:02:00Z","distanceSquares":3.2,"from":{"imagePixels":{"x":1,"y":1}},"label":"Ayla","line":"pawnMoved","map":"$GATE","pawnID":"A","to":{"imagePixels":{"x":2,"y":2}}}
{"ability":"wisdom","at":"2026-09-19T18:03:00Z","d20":14,"label":"Ayla","line":"savingThrow","map":"$GATE","modifier":1,"pawnID":"A"}
{"at":"2026-09-19T18:04:00Z","d20":9,"difficultyClass":15,"label":"Jonny","line":"abilityCheck","map":"$GATE","modifier":-1,"pawnID":"B","skill":"sleightOfHand"}
{"at":"2026-09-19T18:10:00Z","line":"encounterStarted","logFile":"2026-09-19T181000Z.jsonl","map":"$GATE"}
{"at":"2026-09-19T18:40:00Z","line":"encounterEnded","map":"$GATE"}
{"at":"2026-09-19T18:45:00Z","line":"comment","text":"short break"}
{"at":"2026-09-19T19:00:00Z","line":"comment","map":"$VAULT","text":"Down into the vault"}
{"at":"2026-09-19T19:05:00Z","line":"comment","map":"$VAULT","text":"A sealed letter, no sender"}
{"at":"2026-09-19T19:30:00Z","line":"mysteryLine","map":"$VAULT"}
{"endedAt":"2026-09-19T21:00:00Z","line":"sessionEnded"}
{"at":"2026-09-19T21:0
JSONL
mkdir -p "$W/Campaigns/Ashfall/Attachments/Gatehouse.combat"
cat > "$W/Campaigns/Ashfall/Attachments/Gatehouse.fog.json" <<'JSON'
{ "version": 2, "walls": [], "lights": [],
  "pawns": [ { "id": "A", "label": "Ayla", "kind": "player", "characterID": "c1" },
             { "id": "G1", "label": "GG1", "kind": "creature", "monsterName": "Gnoll Warrior" } ] }
JSON
B='"armorClass":14,"conditions":[],"exhaustion":0,"initiativeBonus":2,"isConcentrating":false,"isInCombat":true,"temporaryHP":0'
cat > "$W/Campaigns/Ashfall/Attachments/Gatehouse.combat/2026-09-19T181000Z.jsonl" <<JSONL
{"combatants":[{"block":{$B,"currentHP":24,"maxHP":24},"id":"A","initiative":17,"kind":"player","name":"Ayla"},{"block":{$B,"currentHP":20,"maxHP":31},"id":"B","initiative":12,"kind":"player","name":"Jonny"},{"block":{$B,"currentHP":27,"maxHP":27},"id":"G1","initiative":9,"kind":"creature","name":"GG1"},{"block":{$B,"currentHP":7,"maxHP":7},"id":"G2","initiative":5,"kind":"creature","name":"GG2"}],"line":"encounterStarted","order":["A","B","G1","G2"],"startedAt":"2026-09-19T18:10:00Z"}
{"changes":[{"combatantID":"G1","from":27,"to":19,"type":"hpChanged"},{"combatantID":"A","distanceSquares":4,"from":{"imagePixels":{"x":1,"y":1}},"to":{"imagePixels":{"x":2,"y":2}},"type":"moved"}],"combatantID":"A","endedAt":"2026-09-19T18:12:00Z","line":"turn","round":1}
{"changes":[{"combatantID":"G2","from":7,"to":-2,"type":"hpChanged"},{"combatantID":"G2","condition":"unconscious","type":"conditionAdded"},{"combatantID":"B","text":"swore an oath to the river god","type":"noteAdded"},{"ability":"constitution","combatantID":"G1","d20":3,"difficultyClass":12,"modifier":2,"name":"GG1","type":"savingThrow"}],"combatantID":"B","endedAt":"2026-09-19T18:14:00Z","line":"turn","round":1}
{"changes":[{"combatantID":"A","from":24,"to":10,"type":"hpChanged"},{"combatantID":"A","condition":"poisoned","type":"conditionAdded"}],"combatantID":"G1","endedAt":"2026-09-19T18:16:00Z","line":"turn","round":1}
{"changes":[{"combatantID":"G2","type":"combatantRemoved"}],"combatantID":"G2","endedAt":"2026-09-19T18:17:00Z","line":"turn","round":1}
{"changes":[{"combatantID":"G1","from":19,"to":3,"type":"hpChanged"},{"combatantID":"A","from":0,"to":1,"type":"exhaustionChanged"}],"combatantID":"A","endedAt":"2026-09-19T18:20:00Z","line":"turn","round":2}
{"changes":[{"combatantID":"A","from":10,"to":12,"type":"hpChanged"}],"line":"correction","recordedAt":"2026-09-19T18:25:00Z","targetCombatantID":"G1","targetRound":1}
{"changes":[{"combatantID":"B","from":20,"to":15,"type":"hpChanged"},{"combatantID":"A","from":12,"to":9,"type":"tempHPChanged"},{"combatantID":"B","isConcentrating":true,"type":"concentrationChanged"},{"combatantID":"B","type":"someFutureChange"}],"combatantID":"B","endedAt":"2026-09-19T18:30:00Z","line":"turn","round":2}
{"endedAt":"2026-09-19T18:40:00Z","line":"encounterEnded"}
JSONL

# Same evening, the Villains table, every Map under the Villains Campaign.
cat > "$S/2026-09-19T090000Z.jsonl" <<JSONL
{"line":"sessionStarted","startedAt":"2026-09-19T09:00:00Z"}
{"at":"2026-09-19T09:05:00Z","line":"comment","map":"$LAIR","text":"The villains plot"}
{"endedAt":"2026-09-19T11:00:00Z","line":"sessionEnded"}
JSONL
# Same day, an Adventure's Map only: no Campaign's, so it may be Ashfall's.
cat > "$S/2026-09-19T130000Z.jsonl" <<JSONL
{"line":"sessionStarted","startedAt":"2026-09-19T13:00:00Z"}
{"at":"2026-09-19T13:05:00Z","line":"comment","map":"$KEEP","text":"The keep from outside"}
{"at":"2026-09-19T13:06:00Z","line":"encounterStarted","logFile":"2026-09-19T130600Z.jsonl","map":"$KEEP"}
{"endedAt":"2026-09-19T15:00:00Z","line":"sessionEnded"}
JSONL
# 22:30Z on the 18th is 00:30 on the 19th in Rome: the 19th's, by local time.
cat > "$S/2026-09-18T223000Z.jsonl" <<JSONL
{"line":"sessionStarted","startedAt":"2026-09-18T22:30:00Z"}
{"at":"2026-09-18T22:35:00Z","line":"comment","text":"late one-shot, no map"}
JSONL
# Another evening, written already into Session 02's Live Notes.
cat > "$S/2026-09-12T180000Z.jsonl" <<JSONL
{"line":"sessionStarted","startedAt":"2026-09-12T18:00:00Z"}
{"at":"2026-09-12T18:05:00Z","line":"comment","map":"$GATE","text":"The ford"}
{"endedAt":"2026-09-12T21:00:00Z","line":"sessionEnded"}
JSONL
printf -- '---\nnumber: 2\ndate: 2026-09-12\n---\n\n# Session 2\n\n## Live notes\n\n- ford\n\n### MapForge, 2026-09-12 20:00\n\n%%%% mapforge 2026-09-12T180000Z.jsonl %%%%\n\n- The ford\n\n## Recap\n' > "$W/Campaigns/Ashfall/Sessions/Session_02.md"
printf '{"anything": 1}\n' > "$S/notes.json"

snapshot() { (cd "$W" && find .mapforge Campaigns -type f \( -path '.mapforge/*' -o -path '*.combat/*' -o -name '*.fog.json' \) -exec cksum {} + | sort); }
BEFORE=$(snapshot)

# find with a date: that local day's logs, in start order, each with whose it is.
OUT=$(python3 "$HELPER" find "$W" Campaigns/Ashfall 2026-09-19) || fail "find: exit $?"
[ "$(field "$OUT" "[l['file'] for l in d]")" = "['2026-09-18T223000Z.jsonl', '2026-09-19T090000Z.jsonl', '2026-09-19T130000Z.jsonl', '2026-09-19T180000Z.jsonl']" ] || fail "find: the 19th's logs in order: $OUT"
[ "$(field "$OUT" "[l['belongs'] for l in d]")" = "['none', 'other', 'none', 'this']" ] || fail "find: whose: $OUT"
[ "$(field "$OUT" "d[3]['date'] + ' ' + d[3]['time']")" = "2026-09-19 20:00" ] || fail "find: local date and time: $OUT"
[ "$(field "$OUT" "d[0]['date'] + ' ' + d[0]['time']")" = "2026-09-19 00:30" ] || fail "find: after midnight is the next day: $OUT"
[ "$(field "$OUT" "[l['running'] for l in d]")" = "[True, False, False, False]" ] || fail "find: running: $OUT"
[ "$(field "$OUT" "d[3]['maps']")" = "['$GATE', '$VAULT']" ] || fail "find: maps: $OUT"
[ "$(field "$OUT" "d[1]['campaigns']")" = "['Campaigns/Villains']" ] || fail "find: other Campaign named: $OUT"
[ "$(field "$OUT" "[l['written_in'] for l in d]")" = "[[], [], [], []]" ] || fail "find: none written: $OUT"

# find without a date: every log; a written one names the note that holds it.
OUT=$(python3 "$HELPER" find "$W" Campaigns/Ashfall/) || fail "find all: exit $?"
[ "$(field "$OUT" "len(d)")" = "5" ] || fail "find all: five logs: $OUT"
[ "$(field "$OUT" "d[0]['file'] + ' ' + str(d[0]['written_in'])")" = "2026-09-12T180000Z.jsonl ['Campaigns/Ashfall/Sessions/Session_02.md']" ] || fail "find all: written: $OUT"

# For the Villains Campaign, Ashfall's evening is another Campaign's.
OUT=$(python3 "$HELPER" find "$W" Campaigns/Villains 2026-09-19) || fail "find villains: exit $?"
[ "$(field "$OUT" "[l['belongs'] for l in d]")" = "['none', 'this', 'none', 'other']" ] || fail "find villains: $OUT"

# read: the evening in order — Map changes, comments word for word, the fight as it ended.
OUT=$(python3 "$HELPER" read "$W" 2026-09-19T180000Z.jsonl) || fail "read: exit $?"
[ "$(field "$OUT" "d['running']")" = "False" ] || fail "read: ended: $OUT"
[ "$(field "$OUT" "[e['kind'] for e in d['events']]")" = "['map', 'comment', 'roll', 'roll', 'fight', 'comment', 'map', 'comment', 'comment']" ] || fail "read: events: $OUT"
# Rolls as MapForge records them, with their total; never resolved. Names as the rules write them.
[ "$(field "$OUT" "d['events'][2]")" = "{'kind': 'roll', 'time': '20:03', 'name': 'Ayla', 'roll': 'save', 'ability': 'Wisdom', 'skill': None, 'd20': 14, 'modifier': 1, 'total': 15, 'dc': None}" ] || fail "read: saving throw: $OUT"
[ "$(field "$OUT" "d['events'][3]")" = "{'kind': 'roll', 'time': '20:04', 'name': 'Jonny', 'roll': 'check', 'ability': None, 'skill': 'Sleight of Hand', 'd20': 9, 'modifier': -1, 'total': 8, 'dc': 15}" ] || fail "read: ability check: $OUT"
[ "$(field "$OUT" "d['events'][0]['map'] + '|' + d['events'][0]['name'] + '|' + d['events'][0]['time']")" = "$GATE|Gatehouse|20:01" ] || fail "read: first Map: $OUT"
[ "$(field "$OUT" "d['events'][1]['text']")" = "The party reaches the gatehouse" ] || fail "read: comment verbatim: $OUT"
[ "$(field "$OUT" "d['events'][5]['text']")" = "short break" ] || fail "read: comment with no Map, no Map change: $OUT"
[ "$(field "$OUT" "d['events'][6]['name']")" = "Vault" ] || fail "read: Map change: $OUT"

F="d['events'][4]"
[ "$(field "$OUT" "$F['time'] + '-' + $F['end_time']")" = "20:10-20:40" ] || fail "fight: times: $OUT"
[ "$(field "$OUT" "$F['found'] and $F['ended']")" = "True" ] || fail "fight: found and ended: $OUT"
[ "$(field "$OUT" "$F['log']")" = "Campaigns/Ashfall/Attachments/Gatehouse.combat/2026-09-19T181000Z.jsonl" ] || fail "fight: log path: $OUT"
[ "$(field "$OUT" "$F['rounds']")" = "2" ] || fail "fight: rounds: $OUT"
[ "$(field "$OUT" "[c['name'] for c in $F['combatants']]")" = "['Ayla', 'Jonny', 'GG1', 'GG2']" ] || fail "fight: combatants in Order: $OUT"
C="$F['combatants']"
# Ayla: hit to 10 in round 1, corrected to 12 there; 1 exhaustion, 9 temporary, poisoned.
[ "$(field "$OUT" "$C[0]")" = "{'name': 'Ayla', 'kind': 'player', 'monster': None, 'hp': 12, 'max_hp': 24, 'temp_hp': 9, 'conditions': ['poisoned'], 'exhaustion': 1, 'concentrating': False, 'dropped': False, 'benched': False}" ] || fail "fight: Ayla: $OUT"
[ "$(field "$OUT" "$C[1]['hp'], $C[1]['max_hp'], $C[1]['concentrating']")" = "(15, 31, True)" ] || fail "fight: Jonny: $OUT"
[ "$(field "$OUT" "$C[2]['monster'], $C[2]['hp'], $C[2]['dropped']")" = "('Gnoll Warrior', 3, False)" ] || fail "fight: GG1 with its Monster: $OUT"
[ "$(field "$OUT" "$C[3]['hp'], $C[3]['dropped'], $C[3]['benched'], $C[3]['conditions'], $C[3]['monster']")" = "(-2, True, True, ['unconscious'], None)" ] || fail "fight: GG2 below 0 is down, and benched: $OUT"
[ "$(field "$OUT" "$F['notes']")" = "[{'name': 'Jonny', 'text': 'swore an oath to the river god'}]" ] || fail "fight: notes: $OUT"
[ "$(field "$OUT" "$F['rolls']")" = "[{'round': 1, 'name': 'GG1', 'roll': 'save', 'ability': 'Constitution', 'skill': None, 'd20': 3, 'modifier': 2, 'total': 5, 'dc': 12}]" ] || fail "fight: rolls: $OUT"

[ "$(snapshot)" = "$BEFORE" ] || fail "MapForge's files changed"

# A later Turn's number beats an earlier Correction, as MapForge folds it.
cat > "$W/Campaigns/Ashfall/Attachments/Gatehouse.combat/2026-09-19T190000Z.jsonl" <<JSONL
{"combatants":[{"block":{$B,"currentHP":24,"maxHP":24},"id":"A","initiative":17,"kind":"player","name":"Ayla"}],"line":"encounterStarted","order":["A"],"startedAt":"2026-09-19T19:00:00Z"}
{"changes":[{"combatantID":"A","from":24,"to":0,"type":"hpChanged"}],"combatantID":"A","endedAt":"2026-09-19T19:01:00Z","line":"turn","round":1}
{"changes":[{"combatantID":"A","from":0,"to":5,"type":"hpChanged"}],"combatantID":"A","endedAt":"2026-09-19T19:02:00Z","line":"turn","round":2}
{"changes":[{"combatantID":"A","from":0,"to":3,"type":"hpChanged"}],"line":"correction","recordedAt":"2026-09-19T19:03:00Z","targetCombatantID":"A","targetRound":1}
{"changes":[{"combatantID":"A","type":"hpChanged"}],"combatantID":"A","endedAt":"2026-09-19T19:04:00Z","line":"turn","round":3}
JSONL
cat > "$S/2026-09-26T180000Z.jsonl" <<JSONL
{"line":"sessionStarted","startedAt":"2026-09-26T18:00:00Z"}
{"at":"2026-09-26T19:00:00Z","line":"encounterStarted","logFile":"2026-09-19T190000Z.jsonl","map":"$GATE"}
JSONL
BEFORE=$(snapshot)
OUT=$(python3 "$HELPER" read "$W" 2026-09-26T180000Z.jsonl) || fail "read running: exit $?"
[ "$(field "$OUT" "d['running']")" = "True" ] || fail "running: no sessionEnded: $OUT"
F="d['events'][1]"
[ "$(field "$OUT" "$F['ended'], $F['end_time'], $F['rounds']")" = "(False, None, 3)" ] || fail "running fight: $OUT"
# 0 in round 1, corrected there to 3 (so never down), 5 in round 2, then untyped.
[ "$(field "$OUT" "$F['combatants'][0]['hp'], $F['combatants'][0]['dropped']")" = "(None, False)" ] || fail "later Turn wins, untyped hp: $OUT"

# A fight whose Combat Log is not there (an Adventure's Map): reported, not invented.
OUT=$(python3 "$HELPER" read "$W" 2026-09-19T130000Z.jsonl) || fail "read missing: exit $?"
[ "$(field "$OUT" "d['events'][2]['found'], d['events'][2]['combatants']")" = "(False, [])" ] || fail "missing Combat Log: $OUT"

# Fractional seconds; a fight line with no Map of its own (it is on the current one); a drop
# healed within the same Turn; a Combatant who starts at 0 has not dropped; one who joins.
cat > "$S/2026-10-03T120000Z.jsonl" <<JSONL
{"line":"sessionStarted","startedAt":"2026-10-03T12:00:00.250Z"}
{"at":"2026-10-03T12:01:00.5Z","line":"comment","map":"$GATE","text":"Back at the gatehouse"}
{"at":"2026-10-03T12:10:00Z","line":"encounterStarted","logFile":"2026-10-03T121000Z.jsonl"}
{"at":"2026-10-03T12:20:00Z","line":"encounterEnded"}
{"endedAt":"2026-10-03T13:00:00Z","line":"sessionEnded"}
JSONL
cat > "$W/Campaigns/Ashfall/Attachments/Gatehouse.combat/2026-10-03T121000Z.jsonl" <<JSONL
{"combatants":[{"block":{$B,"currentHP":24,"maxHP":24},"id":"A","initiative":17,"kind":"player","name":"Ayla"},{"block":{$B,"currentHP":0,"maxHP":20},"id":"K","initiative":3,"kind":"player","name":"Kip"}],"line":"encounterStarted","order":["A","K"],"startedAt":"2026-10-03T12:10:00Z"}
{"changes":[{"combatantID":"A","from":24,"to":0,"type":"hpChanged"},{"combatantID":"A","from":0,"to":5,"type":"hpChanged"}],"combatantID":"A","endedAt":"2026-10-03T12:11:00Z","line":"turn","round":1}
{"changes":[],"combatantID":"K","endedAt":"2026-10-03T12:12:00Z","line":"turn","round":1}
{"changes":[{"block":{$B,"currentHP":7,"maxHP":7},"combatantID":"G3","initiative":4,"kind":"creature","name":"GG3","type":"combatantJoined"},{"combatantID":"G3","from":7,"to":3,"type":"hpChanged"}],"combatantID":"A","endedAt":"2026-10-03T12:13:00Z","line":"turn","round":2}
{"endedAt":"2026-10-03T12:20:00Z","line":"encounterEnded"}
JSONL
# A marker in Obsidian's own folders, or not in the documented form, does not count.
mkdir -p "$W/.trash" "$W/.obsidian"
printf '%%%% mapforge 2026-10-03T120000Z.jsonl %%%%\n' > "$W/.trash/Old_Session.md"
printf '%%%% mapforge 2026-10-03T120000Z.jsonl %%%%\n' > "$W/.obsidian/note.md"
printf '%%%% MapForge: 2026-10-03T120000Z.jsonl %%%%\n' > "$W/Campaigns/Ashfall/Sessions/Draft.md"
BEFORE=$(snapshot)
OUT=$(python3 "$HELPER" find "$W" Campaigns/Ashfall 2026-10-03) || fail "fractional: exit $?"
[ "$(field "$OUT" "[(l['file'], l['time'], l['written_in']) for l in d]")" = "[('2026-10-03T120000Z.jsonl', '14:00', [])]" ] || fail "fractional seconds, markers: $OUT"
OUT=$(python3 "$HELPER" read "$W" 2026-10-03T120000Z.jsonl) || fail "read fractional: exit $?"
F="d['events'][2]"
[ "$(field "$OUT" "d['events'][1]['time'], $F['kind'], $F['found'], $F['log']")" = "('14:01', 'fight', True, 'Campaigns/Ashfall/Attachments/Gatehouse.combat/2026-10-03T121000Z.jsonl')" ] || fail "fight on the current Map: $OUT"
[ "$(field "$OUT" "[(c['name'], c['hp'], c['dropped']) for c in $F['combatants']]")" = "[('Ayla', 5, True), ('Kip', 0, False), ('GG3', 3, False)]" ] || fail "drops and a join: $OUT"
[ "$(snapshot)" = "$BEFORE" ] || fail "MapForge's files changed"

# Refusals: not a Workspace, no such log, a log name that leaves the folder, no such Campaign.
python3 "$HELPER" find "$TMP/nowhere" Campaigns/Ashfall >/dev/null 2>&1; [ $? -eq 2 ] || fail "no workspace: expected exit 2"
python3 "$HELPER" read "$W" 2026-01-01T000000Z.jsonl >/dev/null 2>&1; [ $? -eq 3 ] || fail "no log: expected exit 3"
python3 "$HELPER" read "$W" ../workspace.json >/dev/null 2>&1; [ $? -eq 2 ] || fail "log outside: expected exit 2"
python3 "$HELPER" find "$W" Campaigns/Nowhere >/dev/null 2>&1; [ $? -eq 3 ] || fail "no campaign: expected exit 3"
python3 "$HELPER" find "$W" Campaigns/Ashfall 19-09-2026 >/dev/null 2>&1; [ $? -eq 2 ] || fail "bad date: expected exit 2"

# No .mapforge/sessions: no logs.
mkdir -p "$TMP/plain/Campaigns/Ashfall"; cp "$W/workspace-config.yml" "$TMP/plain/"
OUT=$(python3 "$HELPER" find "$TMP/plain" Campaigns/Ashfall) || fail "no mapforge: exit $?"
[ "$OUT" = "[]" ] || fail "no mapforge: $OUT"

# MapForge's files were only read.
[ "$(snapshot)" = "$BEFORE" ] || fail "MapForge's files changed"

[ "$FAILS" -eq 0 ] && echo "table-record: all pass" || { echo "table-record: $FAILS failed"; exit 1; }
