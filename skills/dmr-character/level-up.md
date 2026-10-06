# Level up or rebuild a Character

A level-up adds a level. A rebuild changes the species, class, background or ability scores, at the same level or not. Both keep the current Build as a past Build before anything changes. The note's format, links and rules values are in [SKILL.md](SKILL.md).

1. **Read the Character note** and its Past_Builds folder. A multiclass Build (a transferred one) cannot be levelled up or rebuilt: say so and stop.
2. **Collect the choices**, from the Trusted Source entries of the Edition in use:
   - **A level-up**: for each level gained, in order, what the class table and the class's features give at that level — hit points (the DM's roll or the fixed value), subclass, feat or Ability Score Improvement, new cantrips and spells, feature options. Only the real choices are the DM's; everything else follows from the class data.
   - **A rebuild**: each changed part, as [create.md](create.md) collects it (species, class, background, ability score method and increases), and every choice that depends on it (skills, feats, spells the new class does not have).

   Ask for the open ones as SKILL.md's "Choices" says.
3. **Keep the past Build**, at the next past Build path structure.md's Characters section gives. Copy the whole note there (`cp`), then change only:
   - the frontmatter: keep `player` and `level`, drop `status` and `statblock`;
   - the stat block fence: add `bestiary: false` after its `name`, so the past Build stays a snapshot and out of the bestiary;
   - right under the `#` heading, a callout in the Workspace Language naming the level and linking to the current note: `> [!info] Past Build: level 3. The current Build is [[Wren]].`

   Every other line, links included, stays as it was.
4. **Update the note**: the level (frontmatter and Build) and every change the gains or the rebuild bring, each new option linked as SKILL.md's "Links" says (importing what is missing with `dmr-import`), every number in Statistics recomputed, and the stat block written again from them. The Identity section stays as it is.
5. **Report**: the new level or what the rebuild changed, the past Build's path, each Reference note imported, and each Off-Edition option the DM chose.

Done when the past Build holds the whole Build as it was, with its callout, without `status` or `statblock`, and with `bestiary: false` in its fence; and the note shows the new Build with its numbers and stat block recomputed.
