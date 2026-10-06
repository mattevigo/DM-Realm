#!/bin/sh
set -e
SN_PREVIOUS=no
. "$(dirname "$0")/../_fixtures/session-narrate.sh"
mkdir -p $SC/Chronicle
cat > $SC/Chronicle/Chapter_03_The_Gatehouse.md <<'MD'
# Chapter 3: The Gatehouse

[[Session_03_The_Gatehouse|Session 3: The Gatehouse]]

The causeway ran straight into the dusk. When the gate gave way the sergeant did not stay to fight: he dropped into the sluice and was gone, a silver key glinting at his belt as the black water closed over him.
MD
