#!/bin/sh
# Party State on the Character Sheets (ADR 0021, ADR 0022): the Player Wiki helper and the
# party-state.py reader against a scratch Workspace with invented notes.
# Usage: sh tests/party-state.test.sh   (exit 0 = all pass)
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WIKI="$ROOT/skills/dmr-workspace/player-wiki.py"
READER="$ROOT/skills/dmr-workspace/party-state.py"
command -v python3 >/dev/null 2>&1 || { echo "party-state: skipped (no python3)"; exit 0; }
TMP=$(cd "$(mktemp -d)" && pwd -P)
trap 'rm -rf "$TMP"' EXIT
FAILS=0
fail() { echo "FAIL $1"; FAILS=$((FAILS+1)); }
has() { grep -qF -- "$2" "$1" 2>/dev/null || fail "$3: $(basename "$1") lacks: $2"; }
lacks() { ! grep -qF -- "$2" "$1" 2>/dev/null || fail "$3: $(basename "$1") still has: $2"; }
note() { mkdir -p "$(dirname "$1")"; cat > "$1"; }
character() {  # name, hp
  note "$W/Personaggi/$1/$1.md" <<MD
---
statblock: inline
---

# $1

\`\`\`statblock
layout: DM Realm Character
name: $1
class: Guerriero
level: 5
ac: 16
hp: $2
stats: [16, 12, 14, 8, 10, 10]
\`\`\`

## Build

Un guerriero.
MD
}

W="$TMP/Tavolo"; OUT="$TMP/Wiki"
mkdir -p "$W"
cat > "$W/workspace-config.yml" <<YML
language: Italiano
edition: 2024
stat_blocks: true
folders:
  reference: Riferimento
  adventures: Avventure
  homebrew: Homebrew
  world: Mondo
  characters: Personaggi
  campaigns: Campagne
  dm_tools: Strumenti_del_DM
  templates: Modelli

player_wiki:
  output: $OUT
  include: [characters]
  chronicles: []
  dm_only_headings: [Segreti, Note del DM]
YML
note "$W/Strumenti_del_DM/Glossario_delle_Traduzioni.md" <<'MD'
# Glossario delle Traduzioni

| Inglese | Traduzione | Fonte | Chiave |
| --- | --- | --- | --- |
| Character Sheet | Scheda del Personaggio | ripiego | |
| Party_State | Stato_del_Gruppo | ripiego | |
| Party State | Stato del Gruppo | ripiego | |
| README | README | ripiego | |
| As of | Aggiornato a | ripiego | |
| Hit Points | Punti Ferita | Traduzione Ufficiale | |
| Temporary Hit Points | Punti Ferita Temporanei | Traduzione Ufficiale | |
| Spell Slots Spent | Slot Incantesimo Spesi | ripiego | |
| Hit Dice Spent | Dadi Vita Spesi | ripiego | |
| Uses Spent | Usi Spesi | ripiego | |
| Magic Item Charges | Cariche degli Oggetti Magici | ripiego | |
| Conditions | Condizioni | Traduzione Ufficiale | |
| Exhaustion | Indebolimento | Traduzione Ufficiale | |
| Heroic Inspiration | Ispirazione Eroica | ripiego | |
| Active Effects | Effetti Attivi | ripiego | |
| Campaign Homebrew Carried | Homebrew di Campagna che Porta | ripiego | |
MD
character Durga 57
character Brom 44
character Wren 30
note "$W/Campagne/Eroi/README.md" <<'MD'
# Eroi delle Terre di Confine

## Stato Attuale

Il gruppo è nella forgia.
MD
note "$W/Campagne/Eroi/Sessioni/Sessione_30_La_Forgia.md" <<'MD'
# Sessione 30: La Forgia
MD
note "$W/Campagne/Eroi/Stato_del_Gruppo.md" <<'MD'
# Stato del Gruppo

- **Aggiornato a:** [[Sessione_30_La_Forgia|Sessione 30]]

Parole del DM: il gruppo esce dalla forgia con il drago al seguito. **Punti Ferita:** 99 su 99 non è una riga nota.

## Durga Pietraferma

[[Durga|Durga Pietraferma]]

- **Punti Ferita:** 53 su 57 (il drago, S30; più la sua [[Parola_Guaritrice|Parola Guaritrice]])
- **Punti Ferita Temporanei:** nessuno
- **Slot Incantesimo Spesi:** livello 1: 1 su 4 ([[Comando]], S28); livello 3: 2 su 3 (S30)
- **Dadi Vita Spesi:**
- **Cariche degli Oggetti Magici:**
  - [[Bacchetta_dei_Dardi|Bacchetta dei Dardi Incantati]]: da 0 a 3 su 7 (il tiro dell'alba non è nelle note)
  - [[Pietre_Parlanti|Pietra Parlante]]: disponibile
- **Ispirazione Eroica:** disponibile
- **Effetti Attivi:** Resistenza al fuoco, 1 ora (Pozione di Resistenza, S29) %% fino alla S31 %%
- **Homebrew di Campagna che Porta:** [[Martelletto_delle_Sfere|Martelletto delle Sfere]] (non l'ha detto ai compagni)
- **Seguito:** uno scarabeo di fuoco gigante
- Riga del DM senza etichetta.

### Note del DM

- **Condizioni:** maledetta dal drago, e non lo sa

## Brom il Rosso

- **Punti Ferita:** 12 su 44

## Gastonius

[[Gastonius]] è morto nella sessione 06.

## Tesoro del gruppo

[[Durga]] custodisce la cassapanca.

- **Punti Ferita:** 1 su 1
- 95 mo non spartite.

## Da chiarire

- Le antenne del rugginofago: a Durga o a Krathos?

## Segreti

[[Durga]] è la figlia del drago.
MD
note "$W/Campagne/Bassifondi/README.md" <<'MD'
# I Bassifondi di Porto Grigio
MD
note "$W/Campagne/Bassifondi/Stato_del_Gruppo.md" <<'MD'
# Stato del Gruppo

- **Aggiornato a:** Sessione 02, poi modificato dal DM

## Durga

[[Personaggi/Durga/Durga.md|Durga]]

- **Punti Ferita:** 57 su 57
- **Indebolimento:** 1
- **Condizioni:** (nessuna, dopo il Riposo Lungo)
MD
note "$W/Personaggi/Gastonius/Gastonius.md" <<'MD'
# Gastonius

Nessun blocco statistiche: è morto.
MD
(cd "$W" && find . -type f -exec cksum {} + | sort) > "$TMP/before"
REPORT=$(python3 "$WIKI" write "$W") || fail "write: exit $?"
(cd "$W" && find . -type f -exec cksum {} + | sort) > "$TMP/after"
cmp -s "$TMP/before" "$TMP/after" || fail "the Workspace changed"

# Durga's sheet: a block per Campaign, named by its README's title, in title order; each with
# its updated-at line and that Character's known values, as plain text without their notes.
D="$OUT/Personaggi/Durga/Durga_Scheda_del_Personaggio.html"
[ -f "$D" ] || fail "Durga has no sheet"
[ "$(grep -o 'class="card state"' "$D" | wc -l | tr -d ' ')" = 2 ] || fail "Durga's sheet should have two Party State blocks"
has "$D" '<h2>Eroi delle Terre di Confine</h2>' "a block is named by its README's title"
has "$D" '<h2>I Bassifondi di Porto Grigio</h2>' "the second Campaign's block"
first=$(grep -o '<h2>Eroi delle Terre di Confine</h2>\|<h2>I Bassifondi di Porto Grigio</h2>' "$D" | head -1)
[ "$first" = '<h2>Eroi delle Terre di Confine</h2>' ] || fail "the blocks are not in title order: $first"
has "$D" '<p class="eyebrow">Stato del Gruppo</p>' "the block's eyebrow"
has "$D" '<p class="state-as-of">Aggiornato a: Sessione 30</p>' "the updated-at line, its link as text"
has "$D" '<p class="state-as-of">Aggiornato a: Sessione 02, poi modificato dal DM</p>' "a DM's change since"
has "$D" '<dt>Punti Ferita</dt><dd><p>53 su 57</p></dd>' "hit points without the note in parentheses"
has "$D" '<dt>Punti Ferita</dt><dd><p>57 su 57</p></dd>' "the other Campaign's hit points"
has "$D" '<dt>Slot Incantesimo Spesi</dt><dd><p>livello 1: 1 su 4; livello 3: 2 su 3</p></dd>' "every note in parentheses dropped"
has "$D" '<li>Bacchetta dei Dardi Incantati: da 0 a 3 su 7</li><li>Pietra Parlante: disponibile</li>' "sub-items, links as their text"
has "$D" '<dt>Ispirazione Eroica</dt><dd><p>disponibile</p></dd>' "Inspiration"
has "$D" '<dt>Effetti Attivi</dt><dd><p>Resistenza al fuoco, 1 ora</p></dd>' "a %% comment dropped"
has "$D" '<dt>Indebolimento</dt><dd><p>1</p></dd>' "exhaustion"
has "$D" '<dt>Punti Ferita Temporanei</dt><dd><p>nessuno</p></dd>' "a value of none is still a value"
# Never on a sheet: the DM's own words, the notes, the DM-only sections, the Party treasure,
# Campaign homebrew carried, another section's lines.
for s in 'Parole del DM' '99 su 99' 'il drago, S30' 'Parola Guaritrice' "il tiro dell" 'fino alla S31' \
         'Martelletto' 'Homebrew di Campagna' 'scarabeo' 'Seguito' 'Riga del DM' 'maledetta' 'figlia del drago' \
         '95 mo' '1 su 1' 'antenne' 'Dadi Vita Spesi' '12 su 44'; do
  lacks "$D" "$s" "Durga's sheet"
done
# A section matched only by its heading's text is not read; a Character in no Party State, or
# whose section has no known lines, gets the sheet a Workspace without Party State gives.
B="$OUT/Personaggi/Brom/Brom_Scheda_del_Personaggio.html"
lacks "$B" 'class="card state"' "a section that does not link to Brom"
lacks "$OUT/Personaggi/Wren/Wren_Scheda_del_Personaggio.html" 'class="card state"' "Wren is in no Party State"
NOPS="$TMP/Senza_Stato"; cp -R "$W" "$NOPS"; rm -rf "$NOPS/Campagne"
sed "s|$OUT|$TMP/Wiki2|" "$W/workspace-config.yml" > "$NOPS/workspace-config.yml"
python3 "$WIKI" write "$NOPS" >/dev/null || fail "write without Party State: exit $?"
for c in Wren Brom; do
  cmp -s "$OUT/Personaggi/$c/${c}_Scheda_del_Personaggio.html" "$TMP/Wiki2/Personaggi/$c/${c}_Scheda_del_Personaggio.html" \
    || fail "$c's sheet differs from the one a Workspace without Party State gives"
done
# Party State and the rest of the Campaign never go into the wiki as notes.
[ -e "$OUT/Campagne" ] && fail "a Campaign note went into the wiki: $(cd "$OUT" && find Campagne -type f)"
grep -rq 'Stato del Gruppo\|Tesoro del gruppo' "$OUT" --include='*.md' && fail "Party State text went into a wiki note"

# The report: which Campaigns' state is on each sheet, and each known line that could not be read.
case "$REPORT" in *"Party State on the Character Sheets:"*"- Durga: Eroi delle Terre di Confine, I Bassifondi di Porto Grigio"*) ;;
  *) fail "the report does not list the Campaigns on Durga's sheet: $REPORT";; esac
case "$REPORT" in *"Campagne/Eroi/Stato_del_Gruppo.md: Durga: Dadi Vita Spesi (no value)"*) ;;
  *) fail "the report does not name the unreadable line: $REPORT";; esac
case "$REPORT" in *"Condizioni (no value)"*) ;;
  *) fail "a value that is only a note is unreadable: $REPORT";; esac

# A known line written twice in a section: the first is read, the second reported.
note "$W/Campagne/Bassifondi/Stato_del_Gruppo.md" <<'MD'
# Stato del Gruppo

## Durga

[[Durga]]

- Punti Ferita: 40 su 57
- **Punti Ferita**: 41 su 57
MD
REPORT=$(python3 "$WIKI" write "$W") || fail "write again: exit $?"
has "$D" '<dt>Punti Ferita</dt><dd><p>40 su 57</p></dd>' "a known line without bold, colon outside the bold"
lacks "$D" '41 su 57' "a known line written twice"
case "$REPORT" in *"Punti Ferita (written twice)"*) ;; *) fail "a known line written twice is not reported: $REPORT";; esac
lacks "$D" 'state-as-of">Aggiornato a: Sessione 02' "a Party State with no updated-at line"

# Without Characters in the wiki, no Party State is read at all.
sed 's/include: \[characters\]/include: []/' "$W/workspace-config.yml" > "$TMP/c.yml" && mv "$TMP/c.yml" "$W/workspace-config.yml"
REPORT=$(python3 "$WIKI" write "$W") || fail "write without characters: exit $?"
case "$REPORT" in *"Party State"*) fail "a wiki without Characters reports Party State: $REPORT";; esac

# The reader on its own: JSON of what a script reads, for a skill to check a Party State.
JSON=$(python3 "$READER" read "$W" Eroi) || fail "reader: exit $?"
case "$JSON" in *'"as_of": "Sessione 30"'*'"Personaggi/Durga/Durga.md"'*'"key": "Campaign Homebrew Carried"'*) ;;
  *) fail "the reader's JSON: $JSON";; esac
case "$JSON" in *'Brom'*|*'95 mo'*|*'maledetta'*|*'fino alla'*) fail "the reader read what is not a Character's known line: $JSON";; esac
case "$JSON" in *'Tesoro del gruppo: a second section for the same Character, not read'*) ;;
  *) fail "a second section that links first to the same Character is not reported: $JSON";; esac
python3 "$READER" read "$W" Nessuna >/dev/null 2>&1; [ $? -eq 4 ] || fail "a Campaign with no Party State should exit 4"

[ "$FAILS" -eq 0 ] && echo "party-state: all pass" || { echo "party-state: $FAILS failed"; exit 1; }
