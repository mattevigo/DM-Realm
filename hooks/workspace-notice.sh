#!/bin/sh
# SessionStart hook: when the session's folder is a DM Realm Workspace (it holds
# workspace-config.yml), print a short notice that becomes context for the agent.
# Anywhere else, print nothing.

INPUT=$(cat)
CWD=$(printf '%s' "$INPUT" | sed -n 's/.*"cwd"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
[ -n "$CWD" ] || CWD=${CLAUDE_PROJECT_DIR:-$PWD}
CONFIG="$CWD/workspace-config.yml"
[ -f "$CONFIG" ] || exit 0

# Value of a "key: value" line: comment, surrounding quotes and spaces removed.
value() {
  sed -n "s/^[[:space:]]*$1:[[:space:]]*//p" "$CONFIG" | head -n 1 |
    sed 's/[[:space:]]#.*$//; s/[[:space:]]*$//; s/^"\(.*\)"$/\1/; s/^'"'"'\(.*\)'"'"'$/\1/'
}

LANGUAGE=$(value language)
EDITION=$(value edition)
FOLDERS=""
for key in reference adventures homebrew campaigns dm_tools templates; do
  FOLDERS="$FOLDERS
- $key: $(value "$key")"
done

cat <<NOTICE
This folder is a DM Realm Workspace (its Workspace Config is workspace-config.yml).
Workspace Language: ${LANGUAGE}
Edition: ${EDITION}
Top-level folders, by key:${FOLDERS}
Before writing, moving, renaming or linking any note or folder here, load the dmr-workspace skill and follow its rules.
Official D&D material (rules questions, rules text, stat blocks) comes only from the Trusted Source: load the dmr-trusted-source skill before answering or writing any.
NOTICE
