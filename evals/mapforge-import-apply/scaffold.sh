#!/bin/sh
set -e
. "$(dirname "$0")/../_fixtures/table-record.sh"
# This case's evening also has a heal outside the fight and a Long Rest, before sessionEnded.
TR_FILE=".mapforge/sessions/$TR_LOG"
head -n 7 "$TR_FILE" > "$TR_FILE.new"
printf '%s\n' '{"at":"2026-09-19T12:45:00Z","characterID":"cd","currentHP":{"from":22,"to":30},"label":"Durga","line":"characterChanged","map":"'"$GATE"'","name":"Durga","pawnID":"D"}' >> "$TR_FILE.new"
sed -n 8p "$TR_FILE" >> "$TR_FILE.new"
printf '%s\n' '{"at":"2026-09-19T15:00:00Z","characters":[{"characterID":"cd","currentHP":{"from":30,"to":45},"name":"Durga"},{"characterID":"ca","currentHP":{"from":17,"to":24},"name":"Ayla"}],"line":"longRest","partyID":"pa","partyName":"Ashfall"}' >> "$TR_FILE.new"
sed -n '9,$p' "$TR_FILE" >> "$TR_FILE.new"
mv "$TR_FILE.new" "$TR_FILE"
