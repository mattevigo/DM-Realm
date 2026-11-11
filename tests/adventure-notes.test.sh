#!/bin/sh
# Tests dmr-import-adventure's note writer on a rendered Part with INVENTED text and
# invented image bytes (no Trusted Source data, ADR 0003). No network, no Source Cache.
# Usage: sh tests/adventure-notes.test.sh   (exit 0 = all pass)
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HELPER="$ROOT/skills/dmr-import-adventure/adventure-notes.py"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
FAILS=0
fail() { echo "FAIL $1"; FAILS=$((FAILS+1)); }
has() { case "$2" in *"$3"*) ;; *) fail "$1: expected '$3' in:
$2";; esac; }
hasnt() { case "$2" in *"$3"*) fail "$1: did not expect '$3' in:
$2";; esac; }

WS="$TMP/ws"; mkdir -p "$WS" "$TMP/img"
printf 'IMG gate' > "$TMP/img/gate.webp"
A=Adventures/The_Brine_Well
# A render as render-adventure.py --plan prints it: the Part note first.
cat > "$TMP/render.json" <<JSON
{"notes": [
 {"note": "$A/Parts/Chapter_1_The_Well", "section": "w00", "source_property": "BRW p. 3, v9.9.9, #w00",
  "text": "# Chapter 1: The Well\n\nThe well is deep.\n\n[[$A/Places/W1_The_Gate|W1. The Gate]]\n", "images": [], "item": false},
 {"note": "$A/Places/W1_The_Gate", "section": "w01", "source_property": "BRW p. 4, v9.9.9, #w01",
  "text": "# W1. The Gate\n\nA rusted gate.\n\n![[W1_The_Gate.webp]]\n",
  "images": [{"image": "adventure/BRW/gate.webp", "cached": "$TMP/img/gate.webp", "file": "W1_The_Gate.webp"}], "item": false},
 {"note": "$A/Items/The_Well_Key", "section": "w02", "source_property": "BRW p. 4, v9.9.9, #w02",
  "text": "# The Well Key\n\nIt drips.\n", "images": [], "item": true, "portrait": null},
 {"note": "$A/Items/Bucket_of_Stars", "section": "w03", "source_property": "BRW p. 5, v9.9.9, #w03",
  "text": "# Bucket of Stars\n\nIt glows.\n", "images": [], "item": true, "portrait": "[[$A/Attachments/Bucket_of_Stars.webp]]"}
]}
JSON
run() { (cd "$WS" && python3 "$HELPER" "$@") 2>"$TMP/err"; }

# --- split: one English file per note, the Part note last, with its frontmatter ----------
OUT=$(run split "$TMP/render.json" "$TMP/en" --source-key fonte) || fail "split: exit $?: $(cat "$TMP/err")"
FIRST=$(printf '%s' "$OUT" | python3 -c 'import json,sys; print(json.load(sys.stdin)[0]["note"])')
LAST=$(printf '%s' "$OUT" | python3 -c 'import json,sys; print(json.load(sys.stdin)[-1]["note"])')
[ "$FIRST" = "$A/Places/W1_The_Gate" ] || fail "split: expected the Gate first, got $FIRST"
[ "$LAST" = "$A/Parts/Chapter_1_The_Well" ] || fail "split: expected the Part note last, got $LAST"
EN=$(printf '%s' "$OUT" | python3 -c 'import json,sys; print(json.load(sys.stdin)[0]["english"])')
has "split text" "$(cat "$EN")" "A rusted gate."
# The source property is quoted: its ' #' would start a YAML comment.
has "split frontmatter" "$OUT" '---\nfonte: \"BRW p. 4, v9.9.9, #w01\"\n---'
has "split item" "$OUT" '---\nfonte: \"BRW p. 4, v9.9.9, #w02\"\nitem: true\n---'
has "split portrait" "$OUT" "item: true\\nimage: \\\"[[$A/Attachments/Bucket_of_Stars.webp]]\\\"\\n---"
has "split path" "$OUT" "\"path\": \"$A/Places/W1_The_Gate.md\""
has "split not done" "$OUT" '"done": false'
[ -z "$(find "$WS" -type f)" ] || fail "split: wrote into the Workspace"

# --- images: each note's images in the Attachments folder -------------------------------
run images "$TMP/render.json" --attachments "$A/Attachments" >/dev/null || fail "images: exit $?: $(cat "$TMP/err")"
[ "$(cat "$WS/$A/Attachments/W1_The_Gate.webp" 2>/dev/null)" = "IMG gate" ] || fail "images: the Gate's map not placed"

# --- write: every note, frontmatter and text, the Part note last ------------------------
OUT=$(run write "$TMP/render.json" --source-key source) || fail "write: exit $?: $(cat "$TMP/err")"
GATE=$(cat "$WS/$A/Places/W1_The_Gate.md" 2>/dev/null)
[ "$GATE" = "---
source: \"BRW p. 4, v9.9.9, #w01\"
---

# W1. The Gate

A rusted gate.

![[W1_The_Gate.webp]]" ] || fail "write: the Gate's note is:
$GATE"
has "write item" "$(cat "$WS/$A/Items/The_Well_Key.md")" 'source: "BRW p. 4, v9.9.9, #w02"
item: true
---'
has "write portrait" "$(cat "$WS/$A/Items/Bucket_of_Stars.md")" "item: true
image: \"[[$A/Attachments/Bucket_of_Stars.webp]]\""
LAST=$(printf '%s' "$OUT" | python3 -c 'import json,sys; print(json.load(sys.stdin)["written"][-1])')
[ "$LAST" = "$A/Parts/Chapter_1_The_Well.md" ] || fail "write: expected the Part note written last, got $LAST"

# --- a resumed Import: a written note is kept, an empty one is written over -------------
printf 'KEPT\n' > "$WS/$A/Places/W1_The_Gate.md"
: > "$WS/$A/Items/The_Well_Key.md"
rm "$WS/$A/Parts/Chapter_1_The_Well.md"
OUT=$(run split "$TMP/render.json" "$TMP/en2" --source-key source) || fail "resume split: exit $?"
DONE=$(printf '%s' "$OUT" | python3 -c 'import json,sys; print(" ".join(n["note"] for n in json.load(sys.stdin) if n["done"]))')
[ "$DONE" = "$A/Places/W1_The_Gate $A/Items/Bucket_of_Stars" ] || fail "resume split: done should be the Gate and the Bucket, got '$DONE'"
OUT=$(run write "$TMP/render.json" --source-key source) || fail "resume: exit $?: $(cat "$TMP/err")"
[ "$(cat "$WS/$A/Places/W1_The_Gate.md")" = KEPT ] || fail "resume: a written note was rewritten"
has "resume empty" "$(cat "$WS/$A/Items/The_Well_Key.md")" "It drips."
has "resume report" "$OUT" "\"skipped\": [
    \"$A/Places/W1_The_Gate.md\""
hasnt "resume report" "$OUT" "\"$A/Places/W1_The_Gate.md\",
    \"$A/Items/The_Well_Key.md\""

# --- refusals ---------------------------------------------------------------------------
OUT=$(run write "$TMP/missing.json" --source-key source); [ $? -eq 2 ] || fail "missing render: expected exit 2"
OUT=$(run write "$TMP/render.json"); [ $? -eq 2 ] || fail "no --source-key: expected exit 2"
OUT=$(run images "$TMP/render.json"); [ $? -eq 2 ] || fail "images, no --attachments: expected exit 2"

[ "$FAILS" -eq 0 ] && echo "adventure-notes: all pass" || { echo "adventure-notes: $FAILS failed"; exit 1; }
