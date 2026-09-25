#!/bin/sh
# Runs the SessionStart hook with fake session input and checks its output.
# Usage: sh tests/workspace-notice.test.sh   (exit 0 = all pass)
set -u
HOOK="$(cd "$(dirname "$0")/.." && pwd)/hooks/workspace-notice.sh"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
FAILS=0

run_hook() { # $1 = cwd
  printf '{"session_id":"t","hook_event_name":"SessionStart","source":"startup","cwd":"%s"}' "$1" | (cd "$1" && sh "$HOOK")
}
expect_contains() { # $1 = name, $2 = output, $3 = text
  case "$2" in *"$3"*) ;; *) echo "FAIL $1: missing '$3'"; FAILS=$((FAILS+1));; esac
}

# A Workspace with default English names
WS="$TMP/ws"; mkdir -p "$WS"
cat > "$WS/workspace-config.yml" <<'YML'
# DM Realm Workspace Config — written by Setup; fields in the dmr-workspace rules.
language: English
folders:
  reference: Reference
  adventures: Adventures
  homebrew: Homebrew
  campaigns: Campaigns
  dm_tools: DM_Tools
  templates: Templates
YML
OUT=$(run_hook "$WS")
expect_contains workspace "$OUT" "DM Realm Workspace"
expect_contains workspace "$OUT" "English"
for name in Reference Adventures Homebrew Campaigns DM_Tools Templates; do
  expect_contains workspace "$OUT" "$name"
done
expect_contains workspace "$OUT" "dmr-workspace"

# Custom names and trailing comments are read from the config, not assumed
WS2="$TMP/ws2"; mkdir -p "$WS2"
cat > "$WS2/workspace-config.yml" <<'YML'
language: Italiano   # fixed after Setup
folders:
  reference: Riferimento
  adventures: Avventure
  homebrew: Homebrew
  campaigns: "Partite"   # DM's choice
  dm_tools: Strumenti_DM
  templates: Modelli
YML
OUT=$(run_hook "$WS2")
expect_contains custom "$OUT" "Italiano"
expect_contains custom "$OUT" "Partite"
expect_contains custom "$OUT" "Strumenti_DM"
case "$OUT" in *"fixed after Setup"*|*'"Partite"'*) echo "FAIL custom: comment or quotes leaked"; FAILS=$((FAILS+1));; esac

# Not a Workspace: no output at all, exit 0
NO="$TMP/plain"; mkdir -p "$NO"
OUT=$(run_hook "$NO"); CODE=$?
[ -z "$OUT" ] || { echo "FAIL plain: expected no output, got: $OUT"; FAILS=$((FAILS+1)); }
[ "$CODE" -eq 0 ] || { echo "FAIL plain: exit $CODE"; FAILS=$((FAILS+1)); }

[ "$FAILS" -eq 0 ] && echo "workspace-notice: all pass" || { echo "workspace-notice: $FAILS failure(s)"; exit 1; }
