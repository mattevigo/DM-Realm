#!/bin/sh
# PostToolUse hook (Write, Edit, Bash): in a DM Realm Workspace, keep the Spell Index —
# Reference's spells listed by level — in step with the spell notes on disk. The helper
# next to the dmr-workspace rules does the work and decides whether there is any.
# Without python3 it does nothing; it never fails the tool call.
HELPER="$(cd "$(dirname "$0")/.." && pwd)/skills/dmr-workspace/spell-index.py"
command -v python3 >/dev/null 2>&1 && [ -f "$HELPER" ] || exit 0
python3 "$HELPER" hook
exit 0
