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
FOLDERS=""
for key in reference adventures homebrew characters campaigns dm_tools templates; do
  FOLDERS="$FOLDERS
- $key: $(value "$key")"
done

cat <<NOTICE
This folder is a DM Realm Workspace. Its Workspace Config (workspace-config.yml) records:
Workspace Language: ${LANGUAGE}
Edition: ${EDITION}
Top-level folders, by key:${FOLDERS}
(The dmr-workspace rules, "Fixed after Setup", say how to confirm the language and Edition in use.)
Before writing, moving, renaming or linking any note or folder here, load the dmr-workspace skill and follow its rules.
For official D&D material — a rules question, rules text, a stat block — load the dmr-trusted-source skill first.
NOTICE
