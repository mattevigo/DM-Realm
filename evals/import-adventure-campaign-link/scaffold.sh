#!/bin/sh
set -e
WS_LANG=en WS_EDITION=2024
. "$(dirname "$0")/../_fixtures/workspace-setup.sh"
. "$(dirname "$0")/../_fixtures/import-cache.sh"
mkdir -p Campaigns/The_Long_Road
cat > Campaigns/The_Long_Road/README.md <<'MD'
# The Long Road

## Pitch

The heroes walk the coast road from Saltmere to the capital.

## Adventures Run

- Salt Crypt — chapters 1–2 — running

## Current State

The party has just reached Saltmere.
MD
