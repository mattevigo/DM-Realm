#!/bin/sh
# Starting state: an English Workspace with one Character, a MapForge Party of two (Ayla linked to her
# note, Durga linked to none), and the bestiary folder MapForge 1.x read left in its config.json.
set -e
. "$(dirname "$0")/../_fixtures/workspace-setup.sh"
mkdir -p Characters/Ayla .mapforge
printf -- '---\nstatblock: inline\n---\n# Ayla\n\n```statblock\nlayout: DM Realm Character\nname: Ayla\nsize: Medium\nspecies: Elf\nclass: Ranger\nlevel: 3\nplayer: Baldu\nac: 15\nhp: 31\ninitiative: 3\n```\n\nElf ranger.\n' > Characters/Ayla/Ayla.md
printf '%s\n' '{ "version" : 1, "createdAt" : "2026-09-17T20:09:51Z", "createdBy" : "1.2.0" }' > .mapforge/workspace.json
printf '%s\n' '{"bestiaryStatBlockPath": "."}' > .mapforge/config.json
printf '%s\n' '{"version": 1, "parties": [{"id": "p1", "name": "Lost Boys", "characters": [{"id": "c1", "name": "Ayla", "colorHex": "#D0342C", "sightSquares": 6, "noteName": "Ayla"}, {"id": "c2", "name": "Durga", "colorHex": "#2C6BD0", "sightSquares": 6}]}]}' > .mapforge/parties.json
