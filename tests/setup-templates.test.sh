#!/bin/sh
# Tests the basic Template set Setup writes (skills/dmr-setup/templates/): one file per
# row of structure.md's Templates table, no links and no heading in any, and the
# Homebrew monster's empty statistics converting to Markdown and back unchanged.
# Usage: sh tests/setup-templates.test.sh   (exit 0 = all pass)
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SET="$ROOT/skills/dmr-setup/templates"
STATBLOCK="$ROOT/skills/dmr-workspace/statblock.py"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
FAILS=0
fail() { echo "FAIL $1"; FAILS=$((FAILS+1)); }

# The set is exactly the Templates table's rows: "| `templates.<x>` | <Name> (a note) |".
WANT=$(sed -n 's/^| `templates\.[a-z_]*` *| \([A-Za-z_]*\) (a note).*/\1.md/p' "$ROOT/skills/dmr-workspace/structure.md" | sort | tr '\n' ' ')
HAVE=$(ls "$SET" | sort | tr '\n' ' ')
[ -n "$WANT" ] || fail "set: no Template rows found in structure.md"
[ "$WANT" = "$HAVE" ] || fail "set: structure.md lists '$WANT', the skill ships '$HAVE'"

for t in "$SET"/*.md; do
  name=$(basename "$t")
  # A Template links to nothing: no wikilink, embed or Markdown link.
  grep -qE '\[\[|\]\(' "$t" && fail "$name: holds a link"
  # No heading of its own and no Obsidian variable: a note made from it starts with its own.
  grep -qE '^# |\{\{' "$t" && fail "$name: has a '# ' heading or a {{variable}}"
  [ -s "$t" ] || fail "$name: empty"
done

# The monster's statistics stay out of the bestiary and survive a change of form.
M="$SET/Homebrew_Monster.md"
grep -q '^bestiary: false$' "$M" || fail "monster: the fence needs bestiary: false"
head -1 "$M" | grep -q '^---' && fail "monster: no statblock frontmatter flag on a Template"
cp "$M" "$TMP/m.md"
python3 "$STATBLOCK" convert "$TMP/m.md" --to markdown >/dev/null || fail "monster: to Markdown exit $?"
grep -q '^```statblock' "$TMP/m.md" && fail "monster: still a fence after converting to Markdown"
grep -qF '**Armor Class** —' "$TMP/m.md" || fail "monster: Markdown lost its labels: $(cat "$TMP/m.md")"
python3 "$STATBLOCK" convert "$TMP/m.md" --to fence >/dev/null || fail "monster: back to a fence exit $?"
cmp -s "$M" "$TMP/m.md" || fail "monster: not the same after a round trip: $(diff "$M" "$TMP/m.md")"

[ "$FAILS" -eq 0 ] && echo "setup-templates: all pass" || { echo "setup-templates: $FAILS failure(s)"; exit 1; }
