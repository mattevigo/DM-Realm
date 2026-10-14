#!/bin/sh
# Tests the Portrait helper (skills/dmr-workspace/portraits.py): every stat block whose
# note embeds its own picture names it as its Portrait (`image:`), by its full path, and
# one that already names one is left as it is. Every note and picture here is INVENTED.
# Usage: sh tests/portraits.test.sh   (exit 0 = all pass)
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HELPER="$ROOT/skills/dmr-workspace/portraits.py"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
FAILS=0
fail() { echo "FAIL $1"; FAILS=$((FAILS+1)); }
has() { case "$2" in *"$3"*) ;; *) fail "$1: expected '$3' in:
$2";; esac; }
hasnt() { case "$2" in *"$3"*) fail "$1: did not expect '$3' in:
$2";; esac; }
W="$TMP/ws"
note() { mkdir -p "$(dirname "$W/$1")"; cat > "$W/$1"; }
picture() { mkdir -p "$(dirname "$W/$1")"; printf 'INVENTED PICTURE' > "$W/$1"; }
field() { printf '%s' "$OUT" | python3 -c "import json, sys; r = json.load(sys.stdin); print($1)"; }

printf 'language: Italiano\nedition: 2024\nstat_blocks: true\n' > "$W.config"
mkdir -p "$W" && mv "$W.config" "$W/workspace-config.yml"

# An imported monster: two pictures, the first the Portrait; and one under the fence.
note Riferimento/Mostri/Drago_Lanterna.md <<'MD'
---
statblock: inline
---

# Drago Lanterna

## Descrizione

![[Drago_Lanterna_01.webp]]

![[Drago_Lanterna_02.webp]]

I draghi lanterna custodiscono i lampionai.

## Blocco Statistiche

```statblock
name: Drago Lanterna
layout: DM Realm Monster 2014
size: Piccola
ac: 13
hp: 9
```

![[Drago_Lanterna_03.webp]]
MD
picture Riferimento/Allegati/Drago_Lanterna_01.webp
picture Riferimento/Allegati/Drago_Lanterna_02.webp
picture Riferimento/Allegati/Drago_Lanterna_03.webp
picture .mapforge/faces/Drago_Lanterna_01.webp   # a hidden folder's file never makes a name ambiguous
# One whose only picture is in an action, under the fence: no Portrait.
note Riferimento/Mostri/Falena_di_Vetro.md <<'MD'
# Falena di Vetro

## Blocco Statistiche

```statblock
name: Falena di Vetro
size: Minuscola
```

![[Falena_di_Vetro.webp]]
MD
picture Riferimento/Allegati/Falena_di_Vetro.webp
# One that names its Portrait already, another picture: the DM's choice stays.
note Riferimento/Mostri/Segugio_di_Penne.md <<'MD'
# Segugio di Penne

## Descrizione

![[Segugio_di_Penne.webp]]

## Blocco Statistiche

```statblock
name: Segugio di Penne
image: [[Altro_Segugio.png]]
size: Media
```
MD
cp "$W/Riferimento/Mostri/Segugio_di_Penne.md" "$TMP/segugio-original.md"
picture Riferimento/Allegati/Segugio_di_Penne.webp
# A Campaign NPC that extends a monster, with no picture of its own: it inherits.
note Campagne/Eroi/PNG/Vinx.md <<'MD'
# Vinx

![[Mappa_della_Torre.webp]]

```statblock
name: Vinx
extends: Drago Lanterna
hp: 20
```
MD
picture Campagne/Eroi/Allegati/Mappa_della_Torre.webp
# A Homebrew monster in Markdown: the Portrait goes in its `%% statblock` comment.
note Homebrew/Mostri/Lucciola_Ardente.md <<'MD'
# Lucciola Ardente

## Descrizione

![[Lucciola_Ardente.webp|La lucciola]]

## Statistiche

%% statblock
name: Lucciola Ardente
%%

*Minuscola bestia, neutrale*
MD
picture Homebrew/Allegati/Lucciola_Ardente.webp
# A picture name used twice, and one that is nowhere: skipped, with the reason.
note Riferimento/Mostri/Goblin.md <<'MD'
# Goblin

![[Goblin.webp]]

```statblock
name: Goblin
```
MD
picture Riferimento/Allegati/Goblin.webp
picture Avventure/Le_Cucce/Allegati/Goblin.webp
note Riferimento/Mostri/Ombra.md <<'MD'
# Ombra

![[Ombra.webp]]

```statblock
name: Ombra
```
MD
# A Character: its Portrait is not this helper's.
note Personaggi/Ayla/Ayla.md <<'MD'
---
statblock: inline
---

# Ayla

![[Ayla.webp]]

```statblock
name: Ayla
layout: DM Realm Character
```
MD
picture Personaggi/Ayla/Allegati/Ayla.webp
cp "$W/Personaggi/Ayla/Ayla.md" "$TMP/ayla-original.md"

OUT=$(python3 "$HELPER" "$W" 2>"$TMP/err") || fail "portraits: exit $?: $(cat "$TMP/err")"
[ "$(field 'sorted(a["note"] for a in r["added"])')" = "['Homebrew/Mostri/Lucciola_Ardente.md', 'Riferimento/Mostri/Drago_Lanterna.md']" ] \
  || fail "portraits: added: $OUT"
[ "$(field 'sorted(s["note"] for s in r["skipped"])')" = "['Riferimento/Mostri/Goblin.md', 'Riferimento/Mostri/Ombra.md']" ] \
  || fail "portraits: skipped: $OUT"
has "portraits: ambiguous" "$(field '[s["why"] for s in r["skipped"] if s["note"].endswith("Goblin.md")][0]')" "Riferimento/Allegati/Goblin.webp"
has "portraits: missing" "$(field '[s["why"] for s in r["skipped"] if s["note"].endswith("Ombra.md")][0]')" "Ombra.webp"
has "portraits: fence" "$(cat "$W/Riferimento/Mostri/Drago_Lanterna.md")" '```statblock
name: Drago Lanterna
layout: DM Realm Monster 2014
image: "[[Riferimento/Allegati/Drago_Lanterna_01.webp]]"
size: Piccola'
has "portraits: embed kept" "$(cat "$W/Riferimento/Mostri/Drago_Lanterna.md")" "## Descrizione

![[Drago_Lanterna_01.webp]]"
has "portraits: markdown" "$(cat "$W/Homebrew/Mostri/Lucciola_Ardente.md")" '%% statblock
name: Lucciola Ardente
image: "[[Homebrew/Allegati/Lucciola_Ardente.webp]]"
%%'
hasnt "portraits: action picture" "$(cat "$W/Riferimento/Mostri/Falena_di_Vetro.md")" "image:"
hasnt "portraits: extends" "$(cat "$W/Campagne/Eroi/PNG/Vinx.md")" "image:"
cmp -s "$W/Riferimento/Mostri/Segugio_di_Penne.md" "$TMP/segugio-original.md" || fail "portraits: the DM's image: was changed"
cmp -s "$W/Personaggi/Ayla/Ayla.md" "$TMP/ayla-original.md" || fail "portraits: a Character was changed"

# Again: nothing left to add.
OUT=$(python3 "$HELPER" "$W" 2>"$TMP/err") || fail "portraits again: exit $?: $(cat "$TMP/err")"
[ "$(field 'r["added"]')" = "[]" ] || fail "portraits again: added: $OUT"

# Not a Workspace: exit 2, nothing changed.
mkdir -p "$TMP/plain"
python3 "$HELPER" "$TMP/plain" >/dev/null 2>&1; [ $? -eq 2 ] || fail "not a Workspace: expected exit 2"

[ "$FAILS" -eq 0 ] && echo "portraits: all pass" || { echo "portraits: $FAILS failure(s)"; exit 1; }
