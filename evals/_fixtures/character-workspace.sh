# Shared starting state for Character cases: the English 2024 Workspace (workspace-en.sh),
# the Character Source Cache (character-cache.sh), and the Reference notes a Lamplighter
# Character links to, as if already imported (INVENTED placeholders, ADR 0003). Left out,
# for cases to import: the Lantern Keeper background (written by character-wren.sh), the
# Wickwright feat, the Path of the Moth subclass, the Emberkin species and every magic item.
. "$(dirname "$0")/../_fixtures/workspace-en.sh"
. "$(dirname "$0")/../_fixtures/character-cache.sh"

# reference_stub <path> <source property without the release> <title>
reference_stub() {
  mkdir -p "$(dirname "$1")"
  printf -- '---\nsource: %s, v3.0.0\n---\n\n# %s\n\n(Placeholder for the imported official text.)\n' "$2" "$3" > "$1"
}
reference_stub Reference/Classes/Lamplighter/Lamplighter.md "EMBC p. 100" "Lamplighter"
reference_stub Reference/Classes/Lamplighter/Path_of_the_Wick.md "EMBC p. 105" "Path of the Wick"
reference_stub Reference/Species/Mothfolk/Mothfolk.md "EMBC p. 80" "Mothfolk"
reference_stub Reference/Feats/Night_Owl.md "EMBC p. 201" "Night Owl"
reference_stub Reference/Spells/Cantrips/Spark_Wick.md "EMBC p. 215" "Spark Wick"
reference_stub Reference/Spells/Cantrips/Moth_Dust.md "EMBC p. 216" "Moth Dust"
reference_stub Reference/Spells/Level_1/Glimmerlance.md "EMBC p. 212" "Glimmerlance"
reference_stub Reference/Spells/Level_1/Soft_Light.md "EMBC p. 217" "Soft Light"
reference_stub Reference/Spells/Level_2/Whisper_Veil.md "EMBC p. 214" "Whisper Veil"
reference_stub Reference/Equipment/Lantern_Pole.md "EMBC p. 150" "Lantern Pole"
reference_stub Reference/Equipment/Leather_Coat.md "EMBC p. 152" "Leather Coat"
reference_stub Reference/Equipment/Tinderbox.md "EMBC p. 160" "Tinderbox"
. "$(dirname "$0")/../_fixtures/spell-index.sh"
