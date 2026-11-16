#!/bin/sh
# Runs the Player Wiki helper against scratch Workspaces with invented notes.
# Usage: sh tests/player-wiki.test.sh   (exit 0 = all pass)
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HELPER="$ROOT/skills/dmr-workspace/player-wiki.py"
command -v python3 >/dev/null 2>&1 || { echo "player-wiki: skipped (no python3)"; exit 0; }
TMP=$(cd "$(mktemp -d)" && pwd -P)
trap 'rm -rf "$TMP"' EXIT
FAILS=0
fail() { echo "FAIL $1"; FAILS=$((FAILS+1)); }
has() { grep -qF -- "$2" "$1" 2>/dev/null || fail "$3: $(basename "$1") lacks: $2"; }
lacks() { ! grep -qF -- "$2" "$1" 2>/dev/null || fail "$3: $(basename "$1") still has: $2"; }
note() { mkdir -p "$(dirname "$1")"; cat > "$1"; }

# An Italian Workspace: the folders are the Config's, the deeper names the Glossary's.
W="$TMP/Il_Mio_Workspace"; OUT="$TMP/Wiki"
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
  include: [reference, homebrew, world, characters]
  chronicles: [Eroi]
  dm_only_headings: [Segreti, Note del DM]
YML
note "$W/Strumenti_del_DM/Glossario_delle_Traduzioni.md" <<'MD'
# Glossario delle Traduzioni

| Inglese | Traduzione | Fonte | Chiave |
| --- | --- | --- | --- |
| Spells | Incantesimi | Traduzione Ufficiale | |
| Chronicle | Cronaca | ripiego | |
| Voice | Voce | ripiego | |
| Past_Builds | Build_Passate | ripiego | |
| House_Rules | Regole_della_Casa | ripiego | |
| Armor Class | Classe Armatura | Traduzione Ufficiale | |
| Hit Points | Punti Ferita | Traduzione Ufficiale | |
| STR | FOR | Traduzione Ufficiale | |
| Actions | Azioni | Traduzione Ufficiale | |
| Character Sheet | Scheda del Personaggio | ripiego | |
| Level | Livello | Traduzione Ufficiale | |
| Player | Giocatore | ripiego | |
| Hit Point Maximum | Punti Ferita Massimi | Traduzione Ufficiale | |
| SAVE | TS | ripiego | |
| Skills | Abilità | Traduzione Ufficiale | |
| Spellcasting | Incantesimi | Traduzione Ufficiale | |
| Features and Traits | Privilegi e Tratti | ripiego | |
MD
note "$W/Riferimento/Incantesimi/Livello_3/Palla_di_Fuoco.md" <<'MD'
---
source: XPHB p. 241, v1
---

# Palla di Fuoco

*Invocazione di 3° livello*

Un lampo esplode. Vedi [[Accecato]] e [[Avventure/La_Torre/Capitolo_1|la torre]].

## Segreti

Una sezione con questo titolo in Reference resta.

%% un commento di Reference resta %%
MD
note "$W/Riferimento/Incantesimi/Incantesimi.md" <<'MD'
# Incantesimi

## Livello 3

- [[Palla_di_Fuoco|Palla di Fuoco]]
MD
note "$W/Riferimento/Regole/Condizioni/Accecato.md" <<'MD'
# Accecato

Non vedi.
MD
note "$W/Riferimento/Mostri/Goblin_Pallido.md" <<'MD'
---
statblock: inline
---

# Goblin Pallido

![[Riferimento/Allegati/Goblin_Pallido.webp]]

Un goblin inventato.

```statblock
name: Goblin Pallido
image: "[[Riferimento/Allegati/Goblin_Pallido.webp]]"
size: Piccolo
type: Umanoide
alignment: Neutrale
ac: 13
hp: 9
hit_dice: 2d6 + 2
speed: 9 metri
stats: [8, 14, 12, 10, 8, 8]
cr: "1/4"
actions:
  - name: Pugnale
    desc: "Attacco con arma da mischia: +4 al tiro per colpire."
```
MD
mkdir -p "$W/Riferimento/Allegati"
printf 'webp' > "$W/Riferimento/Allegati/Goblin_Pallido.webp"
printf 'unused' > "$W/Riferimento/Allegati/Non_Usata.webp"
note "$W/Homebrew/Regole_della_Casa/Pozioni_Bonus.md" <<'MD'
# Pozioni Bonus

## Regola

Bere una pozione è un'azione bonus.

## Note del DM

Il DM la toglie se diventa troppo forte.

### Dettaglio

Anche questo è del DM.

## Perché

Velocizza.
MD
note "$W/Mondo/Aerth/Aerth.md" <<'MD'
# Aerth

Un mondo. %% il segreto del DM %% Bello.

Vedi [[Porto_Grigio|il porto]] e la [[Campagne/Eroi/Luoghi/Rocca|Rocca]].
MD
note "$W/Mondo/Aerth/Luoghi/Porto_Grigio.md" <<'MD'
# Porto Grigio

## Descrizione

Nebbioso.

## Segreti

Il porto nasconde un culto.

## Agganci

Una nave sparisce.

```text
## Segreti
dentro un blocco di codice non è un titolo
```
MD
note "$W/Mondo/Valdor/Luoghi/Guado.md" <<'MD'
# Guado
MD
note "$W/Personaggi/Durga/Durga.md" <<'MD'
---
giocatore: Baldu
statblock: inline
---

# Durga

```statblock
layout: DM Realm Character
name: Durga
image: "[[Personaggi/Durga/Allegati/Durga_Ritratto.webp]]"
size: Media
species: Umana
class: Chierica (Dominio dell'Inganno)
level: 6
player: Baldu
ac: 16
hp: 57
hit_dice: 6d8
initiative: -1
speed: 9 metri
stats: [11, 8, 18, 12, 17, 12]
saves:
  - Forza: 0
  - Destrezza: -1
  - Costituzione: 4
  - Intelligenza: 1
  - Saggezza ●: 6
  - Carisma ●: 4
skillsaves:
  - Intuizione: 6
senses: Percezione Passiva 13
languages: Comune, Nanico
actions:
  - name: Mazza
    desc: "+3 al tiro per colpire, 1d6 danni <Contundenti> & altro"
spells:
  - "Saggezza, CD del tiro salvezza degli incantesimi 14, +6 al tiro per colpire con incantesimi"
  - 1° livello: 4 slot
  - 3° livello: 3 slot
traits:
  - name: Benedizione dell'Ingannatore
    desc: Dà vantaggio a Furtività a un alleato.
```

## Identità

Viene da [[Porto_Grigio]] e combatte come [[Goblin_Pallido|un goblin]].

## Build

Lancia [[Palla_di_Fuoco]].
MD
note "$W/Personaggi/Durga/Build_Passate/Durga_01.md" <<'MD'
---
statblock: inline
---

# Durga (livello 1)

```statblock
layout: DM Realm Character
name: Durga (livello 1)
level: 1
```
MD
mkdir -p "$W/Personaggi/Durga/Allegati"; printf 'webp' > "$W/Personaggi/Durga/Allegati/Durga_Ritratto.webp"
note "$W/Personaggi/Brom/Brom.md" <<'MD'
---
giocatore: Ayla
stato: ritirato
statblock: inline
---

# Brom

```statblock
layout: DM Realm Character
name: Brom
class: Guerriero
level: 3
ac: 18
hp: 31
stats: [16, 12, 14, 8, 10, 10]
saves:
  - Forza ●: 5
  - Destrezza: 1
  - Costituzione ●: 4
  - Intelligenza: -1
  - Saggezza: 0
  - Carisma: 0
```

## Identità

Un guerriero.
MD
note "$W/Personaggi/Brom/Diario_di_Brom.md" <<'MD'
# Diario di Brom

Non è la nota del Personaggio.
MD
note "$W/Personaggi/Senza/Senza.md" <<'MD'
# Senza

Nessun blocco statistiche.
MD
note "$W/Personaggi/Rotto/Rotto.md" <<'MD'
# Rotto

```statblock
layout: DM Realm Character
name: "Rotto
```
MD
note "$W/Campagne/Eroi/Cronaca/Capitolo_01_La_Rocca.md" <<'MD'
---
sessione: "[[Sessione_01_La_Rocca]]"
luogo: "[[Campagne/Eroi/Luoghi/Rocca|la Rocca]]"
eroe: "[[Durga]]"
---

# Capitolo 1: La Rocca

*[[Sessione_01_La_Rocca|Sessione 1]]*

Gli eroi incontrano [[Kalista]] alla [[Campagne/Eroi/Luoghi/Rocca|Rocca]], e Durga ([[Durga]]) la saluta.

![[Mappa_della_Rocca.png]]

Un [link Markdown](../Sessioni/Sessione_01_La_Rocca.md) e uno [esterno](https://example.com).

Codice: `[[Kalista]]` resta.
MD
note "$W/Campagne/Eroi/Cronaca/Voce.md" <<'MD'
Racconta in prima persona.
MD
note "$W/Campagne/Eroi/Sessioni/Sessione_01_La_Rocca.md" <<'MD'
# Sessione 01

## Preparazione

Il tradimento di Kalista.
MD
note "$W/Campagne/Eroi/PNG/Kalista.md" <<'MD'
# Kalista
MD
note "$W/Campagne/Eroi/Luoghi/Rocca.md" <<'MD'
# Rocca
MD
mkdir -p "$W/Campagne/Eroi/Allegati"; printf 'png' > "$W/Campagne/Eroi/Allegati/Mappa_della_Rocca.png"
note "$W/Avventure/La_Torre/Capitolo_1.md" <<'MD'
# Capitolo 1
MD
note "$W/Modelli/PNG.md" <<'MD'
## Segreti
MD
(cd "$W" && find . -type f -exec cksum {} + | sort) > "$TMP/before"

OUT_TEXT=$(python3 "$HELPER" write "$W") || fail "write: exit $?"
(cd "$W" && find . -type f -exec cksum {} + | sort) > "$TMP/after"
cmp -s "$TMP/before" "$TMP/after" || fail "the Workspace changed"

# Only the parts chosen go in; never an Adventure, a Session, another Campaign note, DM Tools,
# Templates, the Voice or a Past Build.
for f in Riferimento/Incantesimi/Livello_3/Palla_di_Fuoco.md Riferimento/Mostri/Goblin_Pallido.md \
         Homebrew/Regole_della_Casa/Pozioni_Bonus.md Mondo/Aerth/Luoghi/Porto_Grigio.md \
         Personaggi/Durga/Durga.md Campagne/Eroi/Cronaca/Capitolo_01_La_Rocca.md index.md .dm-realm-player-wiki; do
  [ -f "$OUT/$f" ] || fail "missing from the wiki: $f"
done
for f in Avventure Campagne/Eroi/Sessioni Campagne/Eroi/PNG Campagne/Eroi/Luoghi Strumenti_del_DM Modelli \
         Campagne/Eroi/Cronaca/Voce.md Personaggi/Durga/Build_Passate workspace-config.yml; do
  [ -e "$OUT/$f" ] && fail "should not be in the wiki: $f"
done

# Links: to a note in the wiki kept, to one left out made plain text (alias, else name), embeds of
# files copied; links in inline code and to the web untouched.
C="$OUT/Campagne/Eroi/Cronaca/Capitolo_01_La_Rocca.md"
has "$C" '*Sessione 1*' "plain alias"
has "$C" 'incontrano Kalista alla Rocca' "plain name and path link"
has "$C" '([[Durga]])' "a link into the wiki is kept"
has "$C" '![[Mappa_della_Rocca.png]]' "an embedded file is kept"
[ -f "$OUT/Campagne/Eroi/Allegati/Mappa_della_Rocca.png" ] || fail "the Chronicle's map was not copied"
has "$C" 'Un link Markdown e uno [esterno](https://example.com).' "markdown links"
has "$C" '`[[Kalista]]` resta' "inline code is left alone"
has "$C" 'sessione: "Sessione 01 La Rocca"' "a frontmatter link left out"
has "$C" 'luogo: "la Rocca"' "a frontmatter alias left out"
has "$C" 'eroe: "[[Durga]]"' "a frontmatter link kept"
has "$C" 'title: "Capitolo 1: La Rocca"' "title beside other frontmatter"
has "$OUT/Riferimento/Incantesimi/Livello_3/Palla_di_Fuoco.md" 'Vedi [[Accecato]] e la torre.' "Reference links"
has "$OUT/Mondo/Aerth/Aerth.md" 'Vedi [[Porto_Grigio|il porto]] e la Rocca.' "World links"
[ -e "$OUT/Riferimento/Allegati/Non_Usata.webp" ] && fail "a file no note embeds was copied"

# The title moves into the frontmatter; Reference keeps its secrets and comments.
P="$OUT/Riferimento/Incantesimi/Livello_3/Palla_di_Fuoco.md"
has "$P" 'title: "Palla di Fuoco"' "title"
has "$P" 'source: XPHB p. 241, v1' "frontmatter kept"
lacks "$P" '# Palla di Fuoco' "title heading"
has "$P" '## Segreti' "Reference keeps its sections"
has "$P" '%% un commento di Reference resta %%' "Reference keeps its comments"
head -1 "$OUT/Riferimento/Regole/Condizioni/Accecato.md" | grep -qx -- '---' || fail "a note without frontmatter gets one for its title"

# World and Homebrew lose the DM-only sections (to the next heading of the same level) and %% comments.
H="$OUT/Homebrew/Regole_della_Casa/Pozioni_Bonus.md"
lacks "$H" 'Note del DM' "Homebrew DM notes"; lacks "$H" 'Anche questo' "Homebrew DM notes' subsection"
has "$H" '## Perché' "the next section stays"; has "$H" "Bere una pozione" "the rule stays"
G="$OUT/Mondo/Aerth/Luoghi/Porto_Grigio.md"
lacks "$G" 'culto' "World secrets"; has "$G" '## Agganci' "World next section"
has "$G" 'dentro un blocco di codice' "a heading inside code is not a section"
has "$OUT/Mondo/Aerth/Aerth.md" 'Un mondo.  Bello.' "World comment"
lacks "$OUT/Mondo/Aerth/Aerth.md" 'segreto' "World comment"

# A monster's stat block becomes Markdown with the Glossary's labels, its Portrait copied; a
# Character's fence is dropped and its flag with it.
M="$OUT/Riferimento/Mostri/Goblin_Pallido.md"
lacks "$M" '```statblock' "monster fence"; lacks "$M" 'statblock: inline' "monster flag"
has "$M" '**Classe Armatura** 13' "translated label"; has "$M" '| FOR |' "translated ability"
has "$M" '### Azioni' "translated section"
[ -f "$OUT/Riferimento/Allegati/Goblin_Pallido.webp" ] || fail "the monster's picture was not copied"
D="$OUT/Personaggi/Durga/Durga.md"
lacks "$D" '```statblock' "Character fence"; lacks "$D" 'statblock: inline' "Character flag"
has "$D" 'giocatore: Baldu' "Character frontmatter"; has "$D" '## Identità' "Character body"
has "$D" 'Viene da [[Porto_Grigio]] e combatte come [[Goblin_Pallido|un goblin]].' "Character links"

# A Character Sheet beside each Character note, rendered from its fence, and one link to it as the
# first line of the note's body; the rest of the note as it was.
SH="$OUT/Personaggi/Durga/Durga_Scheda_del_Personaggio.html"
[ -f "$SH" ] || fail "Durga's Character Sheet was not written"
[ -f "$OUT/Personaggi/Scheda_del_Personaggio.css" ] || fail "the sheets' stylesheet was not written"
awk 'BEGIN{n=0} /^---$/{n++; next} n>=2' "$D" > "$TMP/durga_body"
[ "$(sed -n 2p "$TMP/durga_body")" = "[Scheda del Personaggio](Durga_Scheda_del_Personaggio.html)" ] \
  || fail "the link to the sheet is not the body's first line: $(head -3 "$TMP/durga_body")"
sed '1,3d' "$TMP/durga_body" > "$TMP/durga_rest"
printf '## Identità\n\nViene da [[Porto_Grigio]] e combatte come [[Goblin_Pallido|un goblin]].\n\n## Build\n\nLancia [[Palla_di_Fuoco]].\n' > "$TMP/durga_expected"
cmp -s "$TMP/durga_rest" "$TMP/durga_expected" || fail "the rest of Durga's note changed: $(cat "$TMP/durga_rest")"
grep -c 'Scheda_del_Personaggio' "$D" | grep -qx 1 || fail "the sheet is linked more than once"
for s in '<title>Durga — Scheda del Personaggio</title>' '<h1>Durga</h1>' 'Media, Umana, Chierica (Dominio dell&#x27;Inganno)' \
         '<span class="chip-label">Livello</span> 6' '<span class="chip-label">Giocatore</span> Baldu' \
         '<span class="stat-label">Classe Armatura</span><span class="stat-value">16</span>' \
         '<span class="stat-label">Punti Ferita Massimi</span><span class="stat-value">57</span>' \
         '<span class="stat-value">6d8</span>' '<span class="stat-value">−1</span>' '<span class="stat-value">9 metri</span>' \
         '<span class="stat-label">Proficiency Bonus</span><span class="stat-value">+3</span>' \
         '<span class="ability-abbr">FOR</span><span class="ability-name">Forza</span><span class="ability-mod">+0</span><span class="ability-score">11</span>' \
         '<span class="ability-mod">+4</span><span class="ability-score">18</span>' \
         '<span class="dot on" aria-hidden="true"></span>TS <strong>+6</strong>' '<span class="dot" aria-hidden="true"></span>TS <strong>−1</strong>' \
         '<span class="row-name">Intuizione</span><span class="row-value">+6</span>' 'Percezione Passiva 13' 'Comune, Nanico' \
         '+3 al tiro per colpire, 1d6 danni &lt;Contundenti&gt; &amp; altro' \
         '<p class="spell-line">Saggezza, CD del tiro salvezza degli incantesimi 14, +6 al tiro per colpire con incantesimi</p>' \
         '<li>1° livello: 4 slot</li>' '<li>3° livello: 3 slot</li>' '<h2>Privilegi e Tratti</h2>' 'Benedizione dell&#x27;Ingannatore' \
         '<img class="portrait" src="Allegati/Durga_Ritratto.webp"' '<a href="Durga.md">← Durga</a>' \
         '<link rel="stylesheet" href="../Scheda_del_Personaggio.css">' '<meta name="viewport" content="width=device-width'; do
  has "$SH" "$s" "Durga's sheet"
done
lacks "$SH" 'Tiri Salvezza' "a 2024 sheet's saves are in its abilities, not a list"
[ -f "$OUT/Personaggi/Durga/Allegati/Durga_Ritratto.webp" ] || fail "the Portrait on the sheet was not copied"
for f in "$OUT"/Personaggi/*/*.html "$OUT/Personaggi/Scheda_del_Personaggio.css"; do
  grep -qi '<script' "$f" && fail "a sheet has a script: $f"
  grep -qiE '(src|href)="(https?:)?//|url\((https?:)?//|@import' "$f" && fail "a sheet loads something from outside: $f"
done
B="$OUT/Personaggi/Brom/Brom_Scheda_del_Personaggio.html"
[ -f "$B" ] || fail "a retired Character gets a sheet too"
lacks "$B" '<h2>Incantesimi</h2>' "a non-caster's sheet has no spellcasting"
lacks "$B" '<img' "a Character with no Portrait"
[ -e "$OUT/Personaggi/Brom/Diario_di_Brom_Scheda_del_Personaggio.html" ] && fail "a note that is not the Character's got a sheet"
lacks "$OUT/Personaggi/Brom/Diario_di_Brom.md" 'Scheda' "a note that is not the Character's"
ls "$OUT/Personaggi/Durga/Build_Passate" >/dev/null 2>&1 && fail "a Past Build went in"
for c in Senza Rotto; do
  [ -e "$OUT/Personaggi/$c/${c}_Scheda_del_Personaggio.html" ] && fail "$c has no readable stat block, yet got a sheet"
  lacks "$OUT/Personaggi/$c/$c.md" 'Scheda_del_Personaggio' "$c's note"
done

# The home page links each part's front doors.
I="$OUT/index.md"
has "$I" 'title: "Il Mio Workspace"' "home title"
has "$I" '- [[Incantesimi]]' "spell index"; has "$I" '- [[Pozioni_Bonus|Pozioni Bonus]]' "house rule"
has "$I" '- [[Aerth]]' "world"; has "$I" '- [[Durga]]' "character"
lacks "$I" '[[Porto_Grigio' "a world with an overview lists only it"
has "$I" '- [[Guado]]' "a world with no overview lists its notes"
lacks "$I" 'Durga_01' "a Past Build on the home page"
W2="$TMP/Solo_Luoghi"; mkdir -p "$W2"
printf 'language: x\nfolders:\n  world: World\nplayer_wiki:\n  output: %s\n  include: [world]\n' "$TMP/w2_wiki" > "$W2/workspace-config.yml"
note "$W2/World/Valdor/Places/Ford.md" <<'MD'
# Ford
MD
python3 "$HELPER" write "$W2" >/dev/null || fail "world only: exit $?"
has "$TMP/w2_wiki/index.md" '- [[Ford]]' "a World with no overview lists its notes"
has "$I" '### Eroi — Cronaca' "chronicle heading"; has "$I" '- [[Capitolo_01_La_Rocca|Capitolo 01 La Rocca]]' "chapter"

# The report says what went out and what was removed.
case "$OUT_TEXT" in *"Player Wiki written to $OUT"*) ;; *) fail "report: $OUT_TEXT";; esac
case "$OUT_TEXT" in *"Homebrew/Regole_della_Casa/Pozioni_Bonus.md: Note del DM"*) ;; *) fail "report removed: $OUT_TEXT";; esac
case "$OUT_TEXT" in *"Mondo/Aerth/Luoghi/Porto_Grigio.md: Segreti"*) ;; *) fail "report World: $OUT_TEXT";; esac
case "$OUT_TEXT" in *"Mondo/Aerth/Aerth.md: 1 %% comment"*) ;; *) fail "report comment: $OUT_TEXT";; esac
case "$OUT_TEXT" in *"Character Sheets written: 2, with Scheda_del_Personaggio.css"*) ;; *) fail "report sheets: $OUT_TEXT";; esac
case "$OUT_TEXT" in *"Personaggi/Senza/Senza.md: it has no stat block"*) ;; *) fail "report no fence: $OUT_TEXT";; esac
case "$OUT_TEXT" in *"Personaggi/Rotto/Rotto.md: its stat block cannot be read"*) ;; *) fail "report bad fence: $OUT_TEXT";; esac
case "$OUT_TEXT" in *"not in the Translation Glossary, written in English: "*"Proficiency Bonus"*) ;; *) fail "report labels: $OUT_TEXT";; esac
case "$OUT_TEXT" in *"English: "*"Classe Armatura"*|*"English: "*"Character Sheet"*) fail "report lists a label the Glossary has: $OUT_TEXT";; esac

# Rewritten from scratch: a note gone from the Workspace leaves the wiki; dot-entries stay.
mkdir -p "$OUT/.git"; printf 'x' > "$OUT/.git/HEAD"
rm "$W/Riferimento/Regole/Condizioni/Accecato.md"
python3 "$HELPER" write "$W" >/dev/null || fail "second write: exit $?"
[ -e "$OUT/Riferimento/Regole/Condizioni/Accecato.md" ] && fail "a removed note stayed in the wiki"
[ -f "$OUT/.git/HEAD" ] || fail "a dot-entry of the output was deleted"
has "$P" 'Vedi Accecato e la torre.' "a link to a removed note becomes plain text"

# Refusals, touching nothing.
set_output() { sed -i.bak "s|^  output: .*|  output: $1|" "$W/workspace-config.yml" && rm -f "$W/workspace-config.yml.bak"; }
mkdir -p "$TMP/Altro"; printf 'mine' > "$TMP/Altro/Note_mie.md"
set_output "$TMP/Altro"
python3 "$HELPER" write "$W" >/dev/null 2>"$TMP/err"; [ $? -eq 5 ] || fail "a folder without the marker should exit 5"
[ -f "$TMP/Altro/Note_mie.md" ] || fail "a folder without the marker was emptied"
set_output "$W/Wiki"
python3 "$HELPER" write "$W" >/dev/null 2>"$TMP/err"; [ $? -eq 3 ] || fail "an output inside the Workspace should exit 3"
grep -q "inside the Workspace" "$TMP/err" || fail "inside: $(cat "$TMP/err")"
set_output "$TMP"
python3 "$HELPER" write "$W" >/dev/null 2>&1; [ $? -eq 3 ] || fail "an output holding the Workspace should exit 3"
set_output "relativo/Wiki"
python3 "$HELPER" write "$W" >/dev/null 2>&1; [ $? -eq 3 ] || fail "a relative output should exit 3"
set_output "$OUT"
sed -i.bak 's|^  include: .*|  include: [reference, adventures]|' "$W/workspace-config.yml" && rm -f "$W/workspace-config.yml.bak"
python3 "$HELPER" write "$W" >/dev/null 2>"$TMP/err"; [ $? -eq 2 ] || fail "an Adventure in include should exit 2"
grep -q "cannot include adventures" "$TMP/err" || fail "adventures: $(cat "$TMP/err")"

# Block lists in the Config; an English Workspace with no Glossary uses the English names.
E="$TMP/en"; EOUT="$TMP/en_wiki"
mkdir -p "$E"
cat > "$E/workspace-config.yml" <<YML
language: English
folders:
  reference: Reference
  campaigns: Campaigns
player_wiki:
  output: "$EOUT"   # outside the Workspace
  include:
    - reference
  chronicles:
    - Heroes
    - Missing
YML
note "$E/Campaigns/Heroes/Chronicle/Chapter_01.md" <<'MD'
# Chapter 1
MD
mkdir -p "$E/Characters/Wren"; printf -- '---\nstatblock: inline\n---\n\n# Wren\n\n```statblock\nlayout: DM Realm Character\nname: Wren\n```\n' > "$E/Characters/Wren/Wren.md"
note "$E/Campaigns/Heroes/Chronicle/Voice.md" <<'MD'
Tell it plainly.
MD
OUT_TEXT=$(python3 "$HELPER" write "$E") || fail "en: exit $?"
[ -f "$EOUT/Campaigns/Heroes/Chronicle/Chapter_01.md" ] || fail "en: the chapter is missing"
[ -e "$EOUT/Campaigns/Heroes/Chronicle/Voice.md" ] && fail "en: the Voice went out"
case "$OUT_TEXT" in *"Missing has no Chronicle folder"*) ;; *) fail "en: a missing Campaign should be noted: $OUT_TEXT";; esac
case "$OUT_TEXT" in *"no Reference folder"*) ;; *) fail "en: a missing part should be noted: $OUT_TEXT";; esac
find "$EOUT" -name '*.html' -o -name '*.css' | grep -q . && fail "en: sheets written without characters in include"

# A 2014 Workspace in English: the saving throws are a list of their own, the names English.
F="$TMP/f14"; FOUT="$TMP/f14_wiki"; mkdir -p "$F/Characters/Wren"
printf 'language: English\nedition: 2014\nfolders:\n  characters: Characters\nplayer_wiki:\n  output: %s\n  include: [characters]\n' "$FOUT" > "$F/workspace-config.yml"
note "$F/Characters/Wren/Wren.md" <<'MD'
# Wren

```statblock
layout: DM Realm Character
name: Wren
level: 1
stats: [10, 16, 12, 10, 14, 8]
saves:
  - Strength: 0
  - Dexterity ●: 5
  - Constitution: 1
  - Intelligence ●: 2
  - Wisdom: 2
  - Charisma: -1
```
MD
OUT_TEXT=$(python3 "$HELPER" write "$F") || fail "2014: exit $?"
S14="$FOUT/Characters/Wren/Wren_Character_Sheet.html"
[ -f "$S14" ] && [ -f "$FOUT/Characters/Character_Sheet.css" ] || fail "2014: no sheet or stylesheet"
has "$S14" '<h2>Saving Throws</h2>' "2014 saves list"; lacks "$S14" 'ability-save' "2014 abilities"
has "$S14" '<span class="row-name">Dexterity</span><span class="row-value">+5</span>' "2014 save row"
has "$S14" 'class="edition-2014"' "2014 edition"; has "$S14" '<span class="stat-value">+2</span>' "level 1 proficiency bonus"
has "$FOUT/Characters/Wren/Wren.md" '[Character Sheet](Wren_Character_Sheet.html)' "English link"
case "$OUT_TEXT" in *"written in English"*) fail "2014: an English Workspace reports no missing label: $OUT_TEXT";; esac

# No player_wiki key, no Workspace.
printf 'language: English\n' > "$TMP/bare.yml"; mkdir -p "$TMP/bare"; mv "$TMP/bare.yml" "$TMP/bare/workspace-config.yml"
python3 "$HELPER" write "$TMP/bare" >/dev/null 2>&1; [ $? -eq 2 ] || fail "no player_wiki key should exit 2"
python3 "$HELPER" write "$TMP/nowhere" >/dev/null 2>&1; [ $? -eq 2 ] || fail "no Workspace should exit 2"

[ "$FAILS" -eq 0 ] && echo "player-wiki: all pass" || { echo "player-wiki: $FAILS failed"; exit 1; }
