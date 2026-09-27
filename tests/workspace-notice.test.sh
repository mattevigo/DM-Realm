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
edition: 2024
folders:
  reference: Reference
  adventures: Adventures
  homebrew: Homebrew
  world: World
  characters: Characters
  campaigns: Campaigns
  dm_tools: DM_Tools
  templates: Templates
YML
OUT=$(run_hook "$WS")
expect_contains workspace "$OUT" "DM Realm Workspace"
expect_contains workspace "$OUT" "English"
for name in Reference Adventures Homebrew World Characters Campaigns DM_Tools Templates; do
  expect_contains workspace "$OUT" "$name"
done
expect_contains workspace "$OUT" "dmr-workspace"
expect_contains workspace "$OUT" "Edition: 2024"
expect_contains workspace "$OUT" "dmr-trusted-source"

# Custom names and trailing comments are read from the config, not assumed
WS2="$TMP/ws2"; mkdir -p "$WS2"
cat > "$WS2/workspace-config.yml" <<'YML'
language: Italiano   # fixed after Setup
edition: "2014"
folders:
  reference: Riferimento
  adventures: Avventure
  homebrew: Homebrew
  world: Mondo   # DM's choice
  characters: Eroi   # DM's choice
  campaigns: "Partite"   # DM's choice
  dm_tools: Strumenti_DM
  templates: Modelli
YML
OUT=$(run_hook "$WS2")
expect_contains custom "$OUT" "Italiano"
expect_contains custom "$OUT" "Partite"
expect_contains custom "$OUT" "- world: Mondo"
expect_contains custom "$OUT" "- characters: Eroi"
expect_contains custom "$OUT" "Strumenti_DM"
expect_contains custom "$OUT" "Edition: 2014"
case "$OUT" in *"fixed after Setup"*|*'"Partite"'*) echo "FAIL custom: comment or quotes leaked"; FAILS=$((FAILS+1));; esac

# Empty values followed by a comment (as in the example config) never leak the comment.
WS3="$TMP/ws3"; mkdir -p "$WS3"
cat > "$WS3/workspace-config.yml" <<'YML'
language: English
edition:   # 2014 or 2024
folders:
  reference:   # default: Reference
  adventures: Adventures
YML
OUT=$(run_hook "$WS3")
case "$OUT" in *"#"*|*"default: Reference"*) echo "FAIL empty: comment leaked into: $OUT"; FAILS=$((FAILS+1));; esac
expect_contains empty "$OUT" "Adventures"

# Fantasy Statblocks installed after Setup, never configured: its stat blocks render in the
# plugin's English Basic 5e layout, so the notice says Setup must be re-run.
PLUGIN="$WS/.obsidian/plugins/obsidian-5e-statblocks"
OUT=$(run_hook "$WS")
case "$OUT" in *"Fantasy Statblocks"*) echo "FAIL no plugin: mentions the plugin: $OUT"; FAILS=$((FAILS+1));; esac
mkdir -p "$PLUGIN"
OUT=$(run_hook "$WS")
expect_contains "plugin, no data.json" "$OUT" "Fantasy Statblocks is installed but not configured"
expect_contains "plugin, no data.json" "$OUT" "dmr-setup"
printf '{"default": "basic-5e-layout", "layouts": []}' > "$PLUGIN/data.json"
OUT=$(run_hook "$WS")
expect_contains "plugin unconfigured" "$OUT" "Fantasy Statblocks is installed but not configured"
python3 "$(dirname "$HOOK")/../skills/dmr-setup/statblocks-settings.py" merge "$WS" 2024 >/dev/null
OUT=$(run_hook "$WS")
case "$OUT" in *"not configured"*) echo "FAIL plugin configured: still says not configured"; FAILS=$((FAILS+1));; esac

# Not a Workspace: no output at all, exit 0
NO="$TMP/plain"; mkdir -p "$NO"
OUT=$(run_hook "$NO"); CODE=$?
[ -z "$OUT" ] || { echo "FAIL plain: expected no output, got: $OUT"; FAILS=$((FAILS+1)); }
[ "$CODE" -eq 0 ] || { echo "FAIL plain: exit $CODE"; FAILS=$((FAILS+1)); }

[ "$FAILS" -eq 0 ] && echo "workspace-notice: all pass" || { echo "workspace-notice: $FAILS failure(s)"; exit 1; }
