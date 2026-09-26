#!/bin/sh
# Starting state: an English 2024 Workspace, with one note imported from the 2024
# Player's Handbook, whose Workspace Config was hand-edited to 2014 after Setup.
set -e
WS_EDITION=2014
. "$(dirname "$0")/../_fixtures/workspace-setup.sh"
mkdir -p Reference/Rules
cat > Reference/Rules/Grappled.md <<'MD'
---
source: XPHB p. 364, v2.36.1
---

# Grappled

(Invented placeholder text for this test; not official content.)
MD
