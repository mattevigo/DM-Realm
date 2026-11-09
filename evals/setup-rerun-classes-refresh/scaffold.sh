#!/bin/sh
# An English 2024 Workspace whose spells were imported before DM Realm wrote their Classes
# line as ADR 0016 has it: Cinder Bloom has no line, and Whisper Veil's names the Tidecaller,
# the Atlas of the Drowned Coast's own class (import-cache.sh), which Reference does not hold.
# INVENTED content throughout (ADR 0003).
set -e
. "$(dirname "$0")/../_fixtures/workspace-en.sh"
. "$(dirname "$0")/../_fixtures/import-cache.sh"
cat > Reference/Spells/Level_3/Cinder_Bloom.md <<'MD'
---
source: EMBC p. 211, v3.0.0
---

# Cinder Bloom

*Level 3 Evocation*

Ash blooms into fire around a point you choose within range.
MD
mkdir -p Reference/Spells/Level_2
cat > Reference/Spells/Level_2/Whisper_Veil.md <<'MD'
---
source: EMBC p. 214, v3.0.0
---

# Whisper Veil

*Level 2 Illusion*

Choose one creature you can see within range. It gains a Hushmark for the duration.

**Classes:** Lamplighter, Tidecaller
MD
. "$(dirname "$0")/../_fixtures/spell-index.sh"
