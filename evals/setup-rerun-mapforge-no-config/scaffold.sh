#!/bin/sh
# Starting state: an English Workspace that MapForge has adopted, with no config.json.
set -e
. "$(dirname "$0")/../_fixtures/workspace-setup.sh"
mkdir -p .mapforge
printf '%s\n' '{ "version" : 1, "createdAt" : "2026-09-17T20:09:51Z", "createdBy" : "1.2.0" }' > .mapforge/workspace.json
