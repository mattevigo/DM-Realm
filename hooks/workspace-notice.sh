#!/bin/sh
# SessionStart hook: when the session's folder is a DM Realm Workspace (it holds
# workspace-config.yml), print a short notice that becomes context for the agent.
# Anywhere else, print nothing.

INPUT=$(cat)
CWD=$(printf '%s' "$INPUT" | sed -n 's/.*"cwd"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
[ -n "$CWD" ] || CWD=${CLAUDE_PROJECT_DIR:-$PWD}
CONFIG="$CWD/workspace-config.yml"
[ -f "$CONFIG" ] || exit 0

# Value of a "key: value" line: comment, surrounding quotes and spaces removed;
# "(not set)" when empty.
value() {
  v=$(sed -n "s/^[[:space:]]*$1:[[:space:]]*//p" "$CONFIG" | head -n 1 |
    sed 's/^#.*$//; s/[[:space:]]#.*$//; s/[[:space:]]*$//; s/^"\(.*\)"$/\1/; s/^'"'"'\(.*\)'"'"'$/\1/')
  printf '%s' "${v:-(not set)}"
}

LANGUAGE=$(value language)
EDITION=$(value edition)
STAT_BLOCKS=$(value stat_blocks)
[ "$STAT_BLOCKS" = "(not set)" ] && STAT_BLOCKS="true (not in the Config yet: a Setup re-run asks)"
FOLDERS=""
for key in reference adventures homebrew world characters campaigns dm_tools templates; do
  FOLDERS="$FOLDERS
- $key: $(value "$key")"
done

cat <<NOTICE
This folder is a DM Realm Workspace. Its Workspace Config (workspace-config.yml) records:
Workspace Language: ${LANGUAGE}
Edition: ${EDITION}
Stat blocks (stat_blocks): ${STAT_BLOCKS}
Top-level folders, by key:${FOLDERS}
(The dmr-workspace rules, "Fixed after Setup", say how to confirm the language and Edition in use.)
Before writing, moving, renaming or linking any note or folder here, load the dmr-workspace skill and follow its rules.
For official D&D material — a question about it, rules text, a stat block — load the dmr-trusted-source skill first.
For a question about using DM Realm, this Workspace or its Campaigns, use the dmr-ask skill.
NOTICE

# Fantasy Statblocks installed after Setup has none of DM Realm's layouts, and one set up by
# an older DM Realm has older ones: either way its stat blocks do not show as DM Realm's
# layouts draw them until Setup is re-run.
PLUGIN="$CWD/.obsidian/plugins/obsidian-5e-statblocks"
[ -d "$PLUGIN" ] || exit 0
HELPER="$(cd "$(dirname "$0")/.." && pwd)/skills/dmr-setup/statblocks-settings.py"
if command -v python3 >/dev/null 2>&1 && [ -f "$HELPER" ]; then
  STATE=$(python3 "$HELPER" check "$CWD" 2>/dev/null); CODE=$?
else  # without python3, only whether the layouts are there at all
  STATE="Fantasy Statblocks lacks DM Realm's layouts."; CODE=0
  for id in dm-realm-character dm-realm-monster-2014 dm-realm-monster-2024; do
    grep -q "\"$id\"" "$PLUGIN/data.json" 2>/dev/null || CODE=4
  done
fi
[ "$CODE" -eq 4 ] || exit 0
cat <<NOTICE
Fantasy Statblocks is installed but not configured for this version of DM Realm: $STATE Its stat blocks do not show as DM Realm's layouts draw them (a missing layout falls back to the plugin's own, with English labels). Tell the DM, and offer to re-run Setup (/dm-realm:dmr-setup), which installs them; Obsidian must be closed while it does.
NOTICE
