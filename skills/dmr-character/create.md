# Create a Character

A new Character, single class, at any level: level 1's choices, then each higher level's in order, written as one note with no past Builds. The note's format, links and rules values are in [SKILL.md](SKILL.md).

1. **Name and player.** The Character's name, in the DM's words, and who plays it: "a character for Baldu" names Baldu as the player. When a Character folder of that name already exists, say so and ask for another name: a new Character never replaces or merges into one.
2. **Collect the choices**, in this order, from the Trusted Source entries of the Edition in use (a multiclass is not created: say so):
   1. The level (1 unless the DM says otherwise).
   2. Class, species (a 2014 subrace, a 2024 lineage) and background.
   3. Ability scores. The method: standard array, point buy or rolled. Point buy is checked against the Edition's point costs and budget; rolled scores are the DM's results. Then the increases the Edition gives (a 2024 background's, a 2014 species'), and the score cap.
   4. Level 1's choices: skills and other proficiencies, languages, the class's and species' feature options, the background's feat, cantrips and spells (from the class's list, up to the counts its table gives).
   5. Starting equipment, as the Edition offers it: in 2024 the class's and the background's package, or the gold each offers instead; in 2014 the class's and background's packages, or the class's starting wealth (rolled by the DM).
   6. Each higher level up to the Character's, in order: the hit points gained (the DM's roll or the fixed value; ask once for every level), then that level's choices — subclass, feat or Ability Score Improvement, new cantrips and spells, feature options.

   Ask for the open ones as SKILL.md's "Choices" says, in the mode the DM picks ([Guided or Recap](#guided-or-recap)).
3. **Link every option** as SKILL.md's "Links" says, importing each missing Reference note with `dmr-import`.
4. **Compute the numbers** in Statistics from the Build, as SKILL.md's "Numbers come from the Trusted Source" says.
5. **Write the note** in SKILL.md's format, with `status` active and `level` the Character's level, and its stat block from the numbers just computed, its `name` checked as structure.md's "Names in the bestiary" says.
6. **Report**: the note's path, its level and player, each Reference note imported, and each option the DM chose that is Off-Edition.

Done when the note holds every choice, links every option, its numbers follow from the Build and the Trusted Source rules, and no past Build was written.

## Guided or Recap

When the request leaves choices open, the DM picks how step 2 asks them:

- **Recap**: SKILL.md's "Ask once, then stop": one message with every open choice that can be asked now.
- **Guided**: one choice at a time, in step 2's order. The hit points of every higher level are one choice, asked before level 2's other choices.

A **dialog** is the `AskUserQuestion` tool: two to four options, multi-select for a "pick N" choice (skills, spells), and its answer comes back in the same turn. In a session without it (a non-interactive one, such as `claude -p`), each question meant for a dialog is a plain message instead, and ends your turn.

**The mode.** A request that names one ("guide me step by step", "list everything at once") uses it. Otherwise the mode is the first question, asked alone, with no mark: a dialog with Guided and Recap. A request that makes every choice asks nothing.

**Guided.** Ask the next open choice, alone, and check its answer as SKILL.md's "Check each answer" says before asking the one after it:

- **Up to four options**: a dialog. Asked again because the answer did not fit, its question says why.
- **More options** (a class, a species, spells from a list): a plain message with that choice and its whole list, then end your turn.
- **Off-Edition consent** is a step of its own, right after the answer that brings the Off-Edition option.
- **The backstory's choice** (SKILL.md's "Backstory and the DM's world") comes last, after every Build choice.

**Marks.** In both modes, each choice asked in a plain message starts with the mark of its status:

| Mark | Status | Followed by |
| --- | --- | --- |
| ❓ | Open | the choice and its options |
| ✅ | Answered by the DM, and the answer fits the rules | the answer, in a few words |
| 🟡 | Partly answered: one skill of two, hit points for some levels | what is still missing |
| ⚠️ | To reconsider: the answer does not fit the rules | why, in a few words |

The first message asks only the open choices, each ❓. From the DM's first reply on, a choice answered shows ✅, 🟡 or ⚠️, and in Recap the message after each reply lists every choice asked so far again, with its new mark. The marks are the same in every Workspace Language.
