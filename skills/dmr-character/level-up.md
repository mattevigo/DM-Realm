# Level up or rebuild a Character

A level-up adds a level. A rebuild changes the species, class, background or ability scores, at the same level or not. Both keep the current Build as a past Build before anything changes. The note's format, links and rules values are in [SKILL.md](SKILL.md).

1. **Read the Character note** and its Past_Builds folder. A multiclass Build (a transferred one) cannot be levelled up or rebuilt: say so and stop.
2. **Collect the choices**, from the Trusted Source entries of the Edition in use:
   - **A level-up**: for each level gained, in order, what the class table and the class's features give at that level — hit points (the DM's roll or the fixed value), subclass, feat or Ability Score Improvement, new cantrips and spells, feature options. Only the real choices are the DM's; everything else follows from the class data.
   - **A rebuild**: each changed part, as [create.md](create.md) collects it (species, class, background, ability score method and increases), and every choice that depends on it (skills, feats, spells the new class does not have).

   A choice the DM's request already makes counts. For every other one, **ask once, then stop**: one message with each open choice and its options by name, and end your turn. An Off-Edition option the DM names is asked about in the same message. Write nothing until every choice is made, and check each against the Trusted Source rules (prerequisites, counts, the score cap).
3. **Keep the past Build.** Its number is one more than the highest in Past_Builds, two digits, from 01: `Past_Builds/<Character>_<NN>.md` (the Past_Builds folder name translated as structure.md says; create it with `mkdir -p` when it is the first). Copy the whole note there (`cp`), then change only:
   - the frontmatter: keep `player` and `level`, drop `status`;
   - right under the `#` heading, a callout in the Workspace Language naming the level and linking to the current note: `> [!info] Past Build: level 3. The current Build is [[Wren]].`

   Every other line, links included, stays as it was.
4. **Update the note**: the level (frontmatter and Build) and every change the gains or the rebuild bring, each new option linked as SKILL.md's "Links" says (importing what is missing with `dmr-import`), and every number in Statistics recomputed. The Identity section stays as it is.
5. **Report**: the new level or what the rebuild changed, the past Build's path, each Reference note imported, and each Off-Edition option the DM chose.

Done when the past Build holds the whole Build as it was, with its callout and without `status`, and the note shows the new Build with its numbers recomputed.
