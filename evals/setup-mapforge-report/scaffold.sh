#!/bin/sh
# Starting state: a folder MapForge has adopted, its bestiary pointed by the DM at Reference.
set -e
mkdir -p .mapforge
printf '%s\n' '{ "version" : 1, "createdAt" : "2026-09-17T20:09:51Z", "createdBy" : "1.2.0" }' > .mapforge/workspace.json
printf '%s\n' '{"bestiaryStatBlockPath": "Reference", "theme": "dark"}' > .mapforge/config.json
