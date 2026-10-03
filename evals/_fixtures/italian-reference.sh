# The Reference notes a Lamplighter Character links to, in the Italian Workspace
# (workspace-it.sh), as if already imported and translated, with their Translation Glossary
# rows (INVENTED placeholders, ADR 0003). The Lantern Keeper background is left out, for
# cases to import.
reference_stub_it() { # <path> <source property without the release> <title>
  mkdir -p "$(dirname "$1")"
  printf -- '---\nfonte: %s, v3.0.0\n---\n\n# %s\n\n(Segnaposto per il testo ufficiale importato.)\n' "$2" "$3" > "$1"
}
reference_stub_it Riferimento/Classi/Accendilampade/Accendilampade.md "EMBC p. 100" "Accendilampade"
reference_stub_it Riferimento/Specie/Popolo_Falena/Popolo_Falena.md "EMBC p. 80" "Popolo Falena"
reference_stub_it Riferimento/Talenti/Gufo_Notturno.md "EMBC p. 201" "Gufo Notturno"
reference_stub_it Riferimento/Incantesimi/Trucchetti/Stoppino_Scintillante.md "EMBC p. 215" "Stoppino Scintillante"
reference_stub_it Riferimento/Incantesimi/Livello_1/Luce_Soffusa.md "EMBC p. 217" "Luce Soffusa"
reference_stub_it Riferimento/Equipaggiamento/Asta_da_Lanterna.md "EMBC p. 150" "Asta da Lanterna"
reference_stub_it Riferimento/Equipaggiamento/Giubba_di_Cuoio.md "EMBC p. 152" "Giubba di Cuoio"
reference_stub_it Riferimento/Equipaggiamento/Acciarino.md "EMBC p. 160" "Acciarino"
cat >> Strumenti_DM/Glossario_Traduzioni.md <<'MD'
| source | fonte | fallback | |
| Classes | Classi | Traduzione Ufficiale | |
| Species | Specie | Traduzione Ufficiale | |
| Backgrounds | Background | Traduzione Ufficiale | |
| Feats | Talenti | Traduzione Ufficiale | |
| Spells | Incantesimi | Traduzione Ufficiale | |
| Cantrips | Trucchetti | Traduzione Ufficiale | |
| Level_1 | Livello_1 | Traduzione Ufficiale | |
| Equipment | Equipaggiamento | Traduzione Ufficiale | |
| Lamplighter | Accendilampade | fallback | |
| Mothfolk | Popolo Falena | fallback | |
| Night Owl | Gufo Notturno | fallback | |
| Spark Wick | Stoppino Scintillante | fallback | |
| Soft Light | Luce Soffusa | fallback | |
| Lantern Pole | Asta da Lanterna | fallback | |
| Leather Coat | Giubba di Cuoio | fallback | |
| Tinderbox | Acciarino | Traduzione Ufficiale | |
MD
. "$(dirname "$0")/../_fixtures/spell-index.sh"
