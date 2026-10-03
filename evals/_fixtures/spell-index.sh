# Sourced last by a fixture or scaffold that seeds spell notes in Reference: writes the
# Spell Index for them with DM Realm's own helper, so the starting Workspace is as DM Realm
# leaves it and the first tool call of the run has no index to create.
python3 "$(dirname "$0")/../../skills/dmr-workspace/spell-index.py" rebuild . >/dev/null
