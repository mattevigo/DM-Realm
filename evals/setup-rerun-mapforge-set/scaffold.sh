#!/bin/sh
# Starting state: an English Workspace that MapForge has adopted, with a config.json of the DM's.
set -e
. "$(dirname "$0")/../_fixtures/workspace-setup.sh"
mkdir -p Homebrew/Monsters .mapforge
printf -- '---\nstatblock: inline\n---\n# Ash Wraith\n\n```statblock\nname: Ash Wraith\nac: 13\nhp: 27\n```\n' > Homebrew/Monsters/Ash_Wraith.md
printf '%s\n' '{ "version" : 1, "createdAt" : "2026-09-17T20:09:51Z", "createdBy" : "1.2.0" }' > .mapforge/workspace.json
printf '%s\n' '{"theme": "dark"}' > .mapforge/config.json
