#!/bin/sh
# Runs the Spell Index helper and its PostToolUse hook against scratch Workspaces.
# Usage: sh tests/spell-index.test.sh   (exit 0 = all pass)
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HELPER="$ROOT/skills/dmr-workspace/spell-index.py"
HOOK="$ROOT/hooks/spell-index.sh"
command -v python3 >/dev/null 2>&1 || { echo "spell-index: skipped (no python3)"; exit 0; }
TMP=$(cd "$(mktemp -d)" && pwd -P)
trap 'rm -rf "$TMP"' EXIT
FAILS=0
fail() { echo "FAIL $1"; FAILS=$((FAILS+1)); }

config() { # $1 = workspace, $2 = Reference's name, $3 = DM Tools' name
  mkdir -p "$1"
  printf 'language: x\nedition: 2024\nfolders:\n  reference: %s\n  dm_tools: %s  # the DM'"'"'s aids\n' "$2" "$3" > "$1/workspace-config.yml"
}
spell() { # $1 = path without .md, $2 = heading, $3 = its classes line ("" for none)
  mkdir -p "$(dirname "$1")"
  printf -- '---\nsource: XPHB p. 1, v1\n---\n\n# %s\n\n*Level 3 Evocation*\n' "$2" > "$1.md"
  [ -z "${3:-}" ] || printf '\n%s\n\n## Description\n\nA picture.\n' "$3" >> "$1.md"
}
hook() { # $1 = cwd, $2 = tool name, $3 = file path ("" for none)
  printf '{"hook_event_name":"PostToolUse","cwd":"%s","tool_name":"%s","tool_input":{"file_path":"%s"}}' "$1" "$2" "$3" | sh "$HOOK"
}

# An English Workspace: levels in order, Cantrips first; notes by name; a file already right is left alone.
W="$TMP/en"; config "$W" Reference DM_Tools
spell "$W/Reference/Spells/Level_3/Fireball" "Fireball"
spell "$W/Reference/Spells/Level_3/Cinder_Bloom" "Cinder Bloom"
spell "$W/Reference/Spells/Level_1/Shield" "Shield"
spell "$W/Reference/Spells/Cantrips/Fire_Bolt" "Fire Bolt"
OUT=$(python3 "$HELPER" rebuild "$W") || fail "en: exit $?"
case "$OUT" in *"Reference/Spells: written Spells.md."*) ;; *) fail "en: should say it wrote the index: $OUT";; esac
cat > "$TMP/expected" <<'MD'
# Spells

## Cantrips

- [[Fire_Bolt|Fire Bolt]]

## Level 1

- [[Shield]]

## Level 3

- [[Cinder_Bloom|Cinder Bloom]]
- [[Fireball]]
MD
diff "$TMP/expected" "$W/Reference/Spells/Spells.md" >/dev/null || { fail "en: the index is not as expected"; diff "$TMP/expected" "$W/Reference/Spells/Spells.md"; }
touch -t 200001010000 "$W/Reference/Spells/Spells.md"; BEFORE=$(ls -l "$W/Reference/Spells/Spells.md")
OUT=$(python3 "$HELPER" rebuild "$W")
case "$OUT" in *"nothing changed"*) ;; *) fail "en: a second run should change nothing: $OUT";; esac
[ "$BEFORE" = "$(ls -l "$W/Reference/Spells/Spells.md")" ] || fail "en: a file already right was rewritten"

# A name another note has is linked by its path.
spell "$W/Campaigns/Heroes/Homebrew_Spells/Level_3/Fireball" "Fireball"
python3 "$HELPER" rebuild "$W" >/dev/null
grep -q '^- \[\[Reference/Spells/Level_3/Fireball|Fireball\]\]$' "$W/Reference/Spells/Spells.md" || fail "en: a name used twice should be a path link: $(grep Fireball "$W/Reference/Spells/Spells.md")"
grep -q '^- \[\[Shield\]\]$' "$W/Reference/Spells/Spells.md" || fail "en: a unique name should stay a bare link"

# The hook: a spell written with Write updates the index and tells the agent; a note elsewhere does not.
spell "$W/Reference/Spells/Level_9/Wish" "Wish"
OUT=$(hook "$W" Write "$W/Reference/Feats/Alert.md")
[ -z "$OUT" ] || fail "hook: a note outside Spells should do nothing: $OUT"
grep -q 'Wish' "$W/Reference/Spells/Spells.md" && fail "hook: a note outside Spells rebuilt the index"
OUT=$(hook "$W" Write "$W/Reference/Spells/Level_9/Wish.md")
case "$OUT" in *'"additionalContext"'*"updated Spells.md"*) ;; *) fail "hook: should tell the agent the index changed: $OUT";; esac
printf '%s' "$OUT" | python3 -c 'import json,sys; json.load(sys.stdin)' 2>/dev/null || fail "hook: its output is not JSON"
[ "$(tail -n 3 "$W/Reference/Spells/Spells.md" | head -n 1)" = "## Level 9" ] || fail "hook: Level 9 should come last"
OUT=$(hook "$W" Write "$W/Reference/Spells/Level_9/Wish.md")
[ -z "$OUT" ] || fail "hook: nothing to change should say nothing: $OUT"
# A relative path, as Edit may give it.
spell "$W/Reference/Spells/Level_2/Web" "Web"
hook "$W" Edit "Reference/Spells/Level_2/Web.md" >/dev/null
grep -q '^- \[\[Web\]\]$' "$W/Reference/Spells/Spells.md" || fail "hook: a relative path was not recognised"
# Bash can move or delete anything: it always rebuilds.
rm "$W/Reference/Spells/Level_1/Shield.md"
hook "$W" Bash "" >/dev/null
grep -q 'Shield' "$W/Reference/Spells/Spells.md" && fail "hook: a deleted spell is still listed after Bash"
grep -q '^## Level 1$' "$W/Reference/Spells/Spells.md" && fail "hook: a level with no note left keeps its section"

# The last spell gone: the index goes too.
rm -r "$W/Reference/Spells"/*/
OUT=$(python3 "$HELPER" rebuild "$W")
[ ! -e "$W/Reference/Spells/Spells.md" ] || fail "empty: the index should be removed: $OUT"

# One index per class the spell notes name, by level; a class no note names any more loses its index.
W="$TMP/classes"; config "$W" Reference DM_Tools
spell "$W/Reference/Spells/Level_3/Fireball" "Fireball" "**Classes:** Sorcerer, Wizard"
spell "$W/Reference/Spells/Level_1/Shield" "Shield" "**Classes:** Wizard"
spell "$W/Reference/Spells/Cantrips/Fire_Bolt" "Fire Bolt" "**Classes:** Sorcerer, Blood Hunter"
spell "$W/Reference/Spells/Level_1/Bless" "Bless"
OUT=$(python3 "$HELPER" rebuild "$W")
case "$OUT" in *"written Spells.md, Spells_Blood_Hunter.md, Spells_Sorcerer.md, Spells_Wizard.md."*) ;; *) fail "classes: should name every index written: $OUT";; esac
cat > "$TMP/expected" <<'MD'
# Spells — Wizard

## Level 1

- [[Shield]]

## Level 3

- [[Fireball]]
MD
diff "$TMP/expected" "$W/Reference/Spells/Spells_Wizard.md" >/dev/null || { fail "classes: the Wizard's index is not as expected"; diff "$TMP/expected" "$W/Reference/Spells/Spells_Wizard.md"; }
[ "$(grep -c '^- ' "$W/Reference/Spells/Spells_Sorcerer.md")" = 2 ] || fail "classes: the Sorcerer has two spells"
[ "$(head -n 1 "$W/Reference/Spells/Spells_Blood_Hunter.md")" = "# Spells — Blood Hunter" ] || fail "classes: a class of two words"
grep -q 'Bless' "$W/Reference/Spells/Spells.md" || fail "classes: a spell on no list is still in the index of all"
grep -rq 'Bless' "$W/Reference/Spells"/Spells_*.md && fail "classes: a spell on no list is in a class's index"
spell "$W/Reference/Spells/Cantrips/Fire_Bolt" "Fire Bolt" "**Classes:** Sorcerer"
OUT=$(hook "$W" Write "$W/Reference/Spells/Cantrips/Fire_Bolt.md")
case "$OUT" in *"removed Spells_Blood_Hunter.md"*) ;; *) fail "classes: an index no longer due should go: $OUT";; esac
[ ! -e "$W/Reference/Spells/Spells_Blood_Hunter.md" ] || fail "classes: the stale index is still there"

# An Italian Workspace: the Spells folder is the Translation Glossary's, the headings the folders' names.
W="$TMP/it"; config "$W" Riferimento Strumenti_DM
mkdir -p "$W/Strumenti_DM"
cat > "$W/Strumenti_DM/Glossario_delle_Traduzioni.md" <<'MD'
| Inglese | Traduzione | Fonte | Chiave (solo cartelle di primo livello) |
| --- | --- | --- | --- |
| Reference | Riferimento | ripiego | reference |
| Spells | Incantesimi | Traduzione Ufficiale | |
| Cantrips | Trucchetti | Traduzione Ufficiale | |
| Classes | Classi | Traduzione Ufficiale | |
MD
spell "$W/Riferimento/Incantesimi/Livello_10_test/Zeta" "Zeta"
spell "$W/Riferimento/Incantesimi/Livello_2/Ragnatela" "Ragnatela" "**Classi:** Mago, Lampionaio (EN: Lamplighter)"
spell "$W/Riferimento/Incantesimi/Trucchetti/Elementalismo" "Elementalismo"
spell "$W/Riferimento/Incantesimi/Trucchetti/Dardo_di_Fuoco" "Dardo di Fuoco"
spell "$W/Riferimento/Incantesimi/Trucchetti/Èlan" "Èlan"
python3 "$HELPER" rebuild "$W" >/dev/null || fail "it: exit $?"
I="$W/Riferimento/Incantesimi/Incantesimi.md"
[ "$(grep '^#' "$I" | tr '\n' '|')" = "# Incantesimi|## Trucchetti|## Livello 2|## Livello 10 test|" ] || fail "it: headings: $(grep '^#' "$I" | tr '\n' '|')"
[ "$(grep '^- ' "$I" | head -n 3 | tr '\n' '|')" = "- [[Dardo_di_Fuoco|Dardo di Fuoco]]|- [[Èlan]]|- [[Elementalismo]]|" ] || fail "it: an accented name should sort with its letter: $(grep '^- ' "$I" | head -n 3 | tr '\n' '|')"
[ "$(ls "$W/Riferimento/Incantesimi" | grep '\.md$' | tr '\n' '|')" = "Incantesimi.md|Incantesimi_Lampionaio.md|Incantesimi_Mago.md|" ] || fail "it: the class indexes: $(ls "$W/Riferimento/Incantesimi" | tr '\n' '|')"
[ "$(head -n 1 "$W/Riferimento/Incantesimi/Incantesimi_Lampionaio.md")" = "# Incantesimi — Lampionaio" ] || fail "it: a fallback class is named without its English original"

# No Spells folder yet, a folder that is no Workspace, and a session outside any Workspace.
W="$TMP/fresh"; config "$W" Reference DM_Tools; mkdir -p "$W/Reference"
python3 "$HELPER" rebuild "$W" >/dev/null || fail "fresh: exit $?"
[ -z "$(find "$W/Reference" -type f)" ] || fail "fresh: something was written with no spell"
mkdir -p "$TMP/plain/Reference/Spells/Level_1"; spell "$TMP/plain/Reference/Spells/Level_1/Shield" "Shield"
python3 "$HELPER" rebuild "$TMP/plain" >/dev/null 2>&1; [ $? -eq 2 ] || fail "plain: a folder with no Config should exit 2"
OUT=$(hook "$TMP/plain" Bash ""); CODE=$?
[ $CODE -eq 0 ] && [ -z "$OUT" ] && [ ! -e "$TMP/plain/Reference/Spells/Spells.md" ] || fail "plain: the hook should do nothing outside a Workspace"
OUT=$(printf 'not json' | sh "$HOOK"); [ $? -eq 0 ] && [ -z "$OUT" ] || fail "hook: bad input should be ignored quietly"

# --- The Classes line for notes imported without it (dmr-import's spell-classes.py) ---
# A Source Cache seeded with INVENTED class spell lists, never online (ADR 0003).
CLASSES="$ROOT/skills/dmr-import/spell-classes.py"
export DMR_SOURCE_CACHE="$TMP/cache" DMR_SOURCE_API="http://127.0.0.1:9/latest" DMR_SOURCE_RAW="http://127.0.0.1:9/raw"
unset EVAL_DMR_SOURCE_CACHE EVAL_DMR_SOURCE_API EVAL_DMR_SOURCE_RAW
mkdir -p "$DMR_SOURCE_CACHE/v9.9.9/data/spells"; echo v9.9.9 > "$DMR_SOURCE_CACHE/release"
cat > "$DMR_SOURCE_CACHE/v9.9.9/data/spells/sources.json" <<'JSON'
{"CNR": {"Cinder Bloom": {"class": [{"name": "Warden", "source": "CNR"}, {"name": "Ashcaller", "source": "CNR"}]},
         "Quiet Glow": {"class": [{"name": "Lamplighter", "source": "CNR"}]},
         "Warding Hush": {"class": [{"name": "Warden", "source": "CNR"}]}}}
JSON
old_spell() { # $1 = path without .md, $2 = heading, $3 = source key, $4 = text after the heading
  mkdir -p "$(dirname "$1")"
  printf -- '---\n%s: CNR p. 88, v9.9.9\n---\n\n# %s\n\n%s\n' "$3" "$2" "$4" > "$1.md"
}
W="$TMP/old"; config "$W" Riferimento Strumenti_DM
mkdir -p "$W/Strumenti_DM"
cat > "$W/Strumenti_DM/Glossario_delle_Traduzioni.md" <<'MD'
| Inglese | Traduzione | Fonte | Chiave (solo cartelle di primo livello) |
| --- | --- | --- | --- |
| Spells | Incantesimi | Traduzione Ufficiale | |
| Classes | Classi | Traduzione Ufficiale | |
| Cinder Bloom | Fioritura di Cenere | ripiego | |
| Quiet Glow | Bagliore Quieto | ripiego | |
| Warding Hush | Silenzio Protettivo | ripiego | |
| Still Air | Aria Ferma | ripiego | |
| Warden | Custode | ripiego | |
| Ashcaller | Evocacenere | ripiego | |
MD
S="$W/Riferimento/Incantesimi"
old_spell "$S/Livello_3/Fioritura_di_Cenere" "Fioritura di Cenere" fonte "Testo.

## Descrizione

Un'immagine."
old_spell "$S/Livello_1/Silenzio_Protettivo" "Silenzio Protettivo" fonte "Testo."
old_spell "$S/Trucchetti/Bagliore_Quieto" "Bagliore Quieto" fonte "Testo."
old_spell "$S/Trucchetti/Aria_Ferma" "Aria Ferma" fonte "Su nessuna lista."
old_spell "$S/Trucchetti/Senza_Riga" "Senza Riga" fonte "Non nel Glossario."
OUT=$(python3 "$CLASSES" "$W" 2>"$TMP/err") || fail "backfill: exit $?: $(cat "$TMP/err")"
field() { printf '%s' "$OUT" | python3 -c "import json,sys; r=json.load(sys.stdin); print($1)"; }
[ "$(field 'r["added"]')" = "['Riferimento/Incantesimi/Livello_1/Silenzio_Protettivo.md', 'Riferimento/Incantesimi/Livello_3/Fioritura_di_Cenere.md']" ] || fail "backfill: added: $(field 'r["added"]')"
[ "$(field 'r["missing_rows"]')" = "['Lamplighter']" ] || fail "backfill: a class with no Glossary row should be named: $(field 'r["missing_rows"]')"
[ "$(field 'sorted(x["note"].split("/")[-1] for x in r["skipped"])')" = "['Bagliore_Quieto.md', 'Senza_Riga.md']" ] || fail "backfill: skipped: $(field 'r["skipped"]')"
[ "$(field 'r["classes"]')" = "{'Custode': 'Warden', 'Evocacenere': 'Ashcaller'}" ] || fail "backfill: classes: $(field 'r["classes"]')"
[ "$(tail -n 1 "$S/Livello_1/Silenzio_Protettivo.md")" = "**Classi:** Custode" ] || fail "backfill: the line should end a note with no section"
printf -- '---\nfonte: CNR p. 88, v9.9.9\n---\n\n# Fioritura di Cenere\n\nTesto.\n\n**Classi:** Evocacenere, Custode\n\n## Descrizione\n\nUn'"'"'immagine.\n' > "$TMP/expected"
diff "$TMP/expected" "$S/Livello_3/Fioritura_di_Cenere.md" >/dev/null || { fail "backfill: the line should stand before the Description"; diff "$TMP/expected" "$S/Livello_3/Fioritura_di_Cenere.md"; }
grep -q 'Classi' "$S/Trucchetti/Aria_Ferma.md" "$S/Trucchetti/Bagliore_Quieto.md" && fail "backfill: a note it cannot do was changed"
[ -f "$S/Incantesimi_Custode.md" ] && [ -f "$S/Incantesimi_Evocacenere.md" ] || fail "backfill: the class indexes were not built: $(ls "$S")"
# The missing row added: a second run does only what was left.
printf '| Lamplighter | Lampionaio | ripiego | |\n' >> "$W/Strumenti_DM/Glossario_delle_Traduzioni.md"
OUT=$(python3 "$CLASSES" "$W" 2>"$TMP/err") || fail "backfill again: exit $?"
[ "$(field 'r["added"]')" = "['Riferimento/Incantesimi/Trucchetti/Bagliore_Quieto.md']" ] || fail "backfill again: added: $(field 'r["added"]')"
[ -f "$S/Incantesimi_Lampionaio.md" ] || fail "backfill again: the new class has no index"
# An English Workspace needs no Glossary; the class lists not cached and unreachable is exit 3.
W="$TMP/olden"; config "$W" Reference DM_Tools
old_spell "$W/Reference/Spells/Level_3/Cinder_Bloom" "Cinder Bloom" source "Text."
OUT=$(python3 "$CLASSES" "$W" 2>"$TMP/err") || fail "backfill en: exit $?"
[ "$(tail -n 1 "$W/Reference/Spells/Level_3/Cinder_Bloom.md")" = "**Classes:** Ashcaller, Warden" ] || fail "backfill en: $(tail -n 1 "$W/Reference/Spells/Level_3/Cinder_Bloom.md")"
rm "$DMR_SOURCE_CACHE/v9.9.9/data/spells/sources.json"
python3 "$CLASSES" "$W" >/dev/null 2>&1; [ $? -eq 3 ] || fail "backfill: class lists not cached and unreachable should exit 3"

[ "$FAILS" -eq 0 ] && echo "spell-index: all pass"
exit "$FAILS"
