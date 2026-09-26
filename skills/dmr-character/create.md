# Create a Character

A new Character, single class, at any level: level 1's choices, then each higher level's in order, written as one note with no past Builds. The note's format, links and rules values are in [SKILL.md](SKILL.md).

1. **Name and player.** The Character's name, in the DM's words, and who plays it. When a Character folder of that name already exists, say so and ask for another name: a new Character never replaces or merges into one.
2. **Collect the choices**, in this order, from the Trusted Source entries of the Edition in use (a multiclass is not created: say so):
   1. The level (1 unless the DM says otherwise).
   2. Class, species (a 2014 subrace, a 2024 lineage) and background.
   3. Ability scores. The method: standard array, point buy or rolled. Point buy is checked against the Edition's point costs and budget; rolled scores are the DM's results. Then the increases the Edition gives (a 2024 background's, a 2014 species'), and the score cap.
   4. Level 1's choices: skills and other proficiencies, languages, the class's and species' feature options, the background's feat, cantrips and spells (from the class's list, up to the counts its table gives).
   5. Starting equipment, as the Edition offers it: in 2024 the class's and the background's package, or the gold each offers instead; in 2014 the class's and background's packages, or the class's starting wealth (rolled by the DM).
   6. Each higher level up to the Character's, in order: the hit points gained (the DM's roll or the fixed value; ask once for every level), then that level's choices — subclass, feat or Ability Score Improvement, new cantrips and spells, feature options.

   A choice the DM's request already makes counts. For every other one, **ask once, then stop**: gather every open choice you can ask now into one message, each with its options by name from the Trusted Source, and end your turn. A choice that depends on an answer (the subclass's own options) waits for that answer. An Off-Edition option the DM names is asked about in the same message (structure.md's consent rule). Write nothing until every choice is made.
3. **Check the choices** against the Trusted Source rules: prerequisites, counts, the point-buy budget, the score cap. Tell the DM what does not fit, and ask again.
4. **Link every option** as SKILL.md's "Links" says, importing each missing Reference note with `dmr-import`.
5. **Compute the numbers** in Statistics from the Build, as SKILL.md's "Numbers come from the Trusted Source" says.
6. **Write the note** in SKILL.md's format, with `status` active and `level` the Character's level. Create its folder (`mkdir -p`) only now.
7. **Report**: the note's path, its level and player, each Reference note imported, and each option the DM chose that is Off-Edition.

Done when the note holds every choice, links every option, its numbers follow from the Build and the Trusted Source rules, and no past Build was written.
