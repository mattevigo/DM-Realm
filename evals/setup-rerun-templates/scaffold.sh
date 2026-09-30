#!/bin/sh
# Starting state: an English 2024 Workspace set up by DM Realm. The DM rewrote the Session
# Template their own way and deleted the Quest Template.
set -e
. "$(dirname "$0")/../_fixtures/workspace-setup.sh"
cat > Templates/Session.md <<'MD'
## Before the game

- Reread the last recap
- One strong start, three scenes

## At the table

## After
MD
rm Templates/Quest.md
