#!/bin/sh
# Starting state: an English Workspace with one Character, MapForge's bestiary pointed at its root.
set -e
. "$(dirname "$0")/../_fixtures/workspace-setup.sh"
mkdir -p Characters/Ayla .mapforge
printf -- '---\nstatblock: inline\n---\n# Ayla\n\n```statblock\nlayout: DM Realm Character\nname: Ayla\nac: 15\nhp: 31\n```\n\nElf ranger.\n' > Characters/Ayla/Ayla.md
printf '%s\n' '{ "version" : 1, "createdAt" : "2026-09-17T20:09:51Z", "createdBy" : "1.2.0" }' > .mapforge/workspace.json
printf '%s\n' '{"bestiaryStatBlockPath": "."}' > .mapforge/config.json
