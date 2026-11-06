#!/bin/sh
# An English 2024 Workspace whose Homebrew_Item Template is the one Setup writes (no
# frontmatter), so the new item note's body shows it was made from it. INVENTED content.
set -e
. "$(dirname "$0")/../_fixtures/workspace-en.sh"
cat > Templates/Homebrew_Item.md <<'MD'
*Type —, rarity — (requires attunement: —)*

## Description

—

## Properties

—
MD
