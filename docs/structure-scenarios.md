# Structure scenarios

Placement, linking and official-data questions that the Workspace rules must answer in exactly one correct way.

**Most scenarios are now plugin evals** (`evals/`, tag `scenario` and the Setup/research cases): run `claude plugin eval` as CLAUDE.md says after every change to `skills/dmr-workspace/`, `CONTEXT.md` or `docs/adr/`. The table maps each scenario to its eval. The scenarios listed in full below have no eval yet — almost all need the future import skill, or have no observable behaviour — and are still checked by hand with a fresh agent.

| Scenario | Eval case |
| --- | --- |
| S01 | s01-reference-refuses-session-link |
| S02 | s02-feat-users-from-backlinks |
| S03 | s03-adventure-to-session-link |
| S04 | s04-homebrew-links |
| S05 | s05a-campaign-subfolder, s05b-no-seventh-top-level-folder |
| S06 | s06-adventure-to-adventure |
| S07 | s07-homebrew-to-dm-tools |
| S08 | s08-table-events-in-campaign |
| S09 | s09-no-scope-property |
| S11 | s11-campaign-homebrew-spell |
| S12 | workspace-plain-request |
| S13 | s13b-invented-world, s13c-campaign-changes-setting (part a, official Setting lore, waits for the import skill) |
| S15 | s15a-random-table, s15b-campaign-todo |
| S16 | s16-promotion |
| S18 | s18-campaign-start |
| S19 | s19-session-file-name |
| S20 | s20-house-rule |
| S22 | s24-italian-glossary-reuse (its first Homebrew monster creates the translated folder and its Glossary row; no import needed) |
| S24 | s24-italian-glossary-reuse |
| S25 | workspace-plain-request, tests/workspace-notice.test.sh |
| S26 | setup-invalid-name |
| S27 | setup-rerun-language-change |
| S28 | setup-fresh-italian (config-italian-names: no neutral key is used as a folder name) |
| S29 | s29-italian-session-name |
| S37 | setup-rerun-edition-change |
| S38 | setup-asks-edition, setup-fresh-english |
| S40 | research-unreachable |
| S41 | research-2024-grappled, research-2014-grappled |
| S42 | research-2024-grappled, research-2014-grappled (cached-outside-workspace) |
| S43 | refresh-to-latest |
| S45 | — (a policy: DM Realm ships no Trusted Source data; tests/source-cache.test.sh and every eval use invented entries) |
| S49 | research-no-refresh (partly: the update check itself waits for the import skill) |

S23 has no reliable eval: whether a term has an Official Translation depends on the model's knowledge, so a case could not tell a right answer from a wrong one.

## How to run the manual scenarios

1. Start a fresh agent that has not seen this file.
2. Give it only `CONTEXT.md`, `docs/adr/`, `skills/dmr-workspace/structure.md` and `skills/dmr-workspace/workspace-config.example.yml`.
3. Ask it each **Question** below, verbatim, and have it answer from the documentation alone, citing the section it relied on.
4. Compare each answer with **Expected**. A scenario passes only if the answer matches and the agent found no competing reading. If it fails, fix the documentation, not the scenario — unless the scenario itself contradicts the spec.

## Scenarios without an eval yet

**S10.** An Adventure introduces an official monster that appears in no other book. Where does its stat block go?
Expected: Reference Monsters. The Adventure's notes (e.g. its NPCs or Encounters) link to it.

**S13.** Where do these go: (a) the official lore of the Forgotten Realms; (b) a world the DM invented; (c) the fact that, in one Campaign, the PCs' actions made a Realms city fall?
Expected: (a) Reference Setting; (b) Homebrew Setting; (c) that Campaign (e.g. its Places), linking to the Reference note.

**S14.** Where does a quick-reference of the official Conditions go?
Expected: Reference Rules — not DM Tools and not House Rules.

**S17.** In a 2024 Workspace, where does the official Weapon Mastery property *Topple* go?
Expected: Reference › Equipment › Weapon_Masteries.

**S21.** The DM starts running a published Adventure, *The Sunken Keep*. Where does the Adventure's content go, and where does an item unique to that Adventure go?
Expected: Adventures › The_Sunken_Keep, with README, Places, NPCs, Items and Encounters; the unique item goes in its Items (an official magic item from the DMG stays in Reference Magic_Items).

## Language and config

**S23.** Italian Workspace. A game term has no Official Translation in Italian. How does the agent name it in a note?
Expected: It translates it as faithfully as it can (it may search the web for an existing correspondence), records it in the Translation Glossary as a fallback, and in each note shows the English original the first time the term appears, e.g. `Term (EN: Original)`.

**S30.** A 2024 Workspace. The DM asks for the *Fireball* note; the Trusted Source has it in both the 2014 and the 2024 Player's Handbook. Which one is imported, and what does the note record?
Expected: The 2024 (XPHB) version, into Reference › Spells › Level_3. Its frontmatter records the source: book code, page and release (e.g. `XPHB p. 239, v2.36.1`).

**S31.** A 2024 Workspace runs a 2014 Adventure. One of its encounters uses the 2014 *Goblin*, which the 2024 Monster Manual reprints. What does the Encounter note link to?
Expected: The 2024 Goblin in Reference Monsters. The 2014 Goblin is not imported: the Edition has a version, so there is no gap.

**S32.** Same Workspace and Adventure. Another encounter uses a 2014 monster that no 2024 book reprints. What does the agent do?
Expected: Import it into Reference Monsters as Off-Edition Material, without asking (it is not a player option), with a callout at the top naming its Edition (2014). The Encounter links to it.

**S33.** A 2024 Workspace. The DM asks to import *Silvery Barbs*, a spell from a 2021 book that no 2024 book reprints. What does the agent do?
Expected: The book is 2014 by the Trusted Source's dating, so the spell is Off-Edition Material and a player option: even though the DM named it, the agent says it is Off-Edition (2014) and asks the DM's consent first. If the DM agrees, it goes in Reference › Spells › Level_1, marked with the Edition callout.

**S34.** A 2024 Workspace. The DM needs a monster printed only in *Mordenkainen Presents: Monsters of the Multiverse*. Is it Reference, and is anything special done?
Expected: It is 2014 material (the book predates the 2024 Player's Handbook), so it enters Reference Monsters as Off-Edition Material filling a gap, marked, without asking. If the 2024 Monster Manual reprints it, the 2024 version is used instead.

**S35.** An Italian 2014 Workspace, folder names empty in the Workspace Config. The agent writes the first official species note. What is its folder called?
Expected: The Italian Official Translation of "Races" as the 2014 Italian books name it — not of "Species". Its path is the translated Reference folder › that name, and the choice is recorded in the Translation Glossary.

**S36.** A 2014 Workspace. The DM asks for the Weapon Mastery property *Topple*. What does the agent do?
Expected: 2014 has no Weapon Masteries, so *Topple* is Off-Edition Material and a player option: ask the DM's consent. If agreed, create Reference › Equipment › Weapon_Masteries with it, marked with the Edition callout (2024).

**S39.** The DM pastes the text of a monster from their own copy of a book and asks the agent to add it to Reference. The Trusted Source does not have that monster. What does the agent do?
Expected: Refuse to add it: official material the Trusted Source does not contain cannot be in the Workspace, and the agent does not copy the pasted text anywhere. The DM may write their own version as Homebrew.

**S44.** The DM once added a line of their own to the Reference note *Fireball*. An update check finds an erratum to *Fireball*. What does the agent do?
Expected: Warn that the note differs from its recorded import and offer to move the DM's line where it belongs (a House Rule, Homebrew, or a Campaign note linking to *Fireball*). Then, if the DM approves, replace the official content wholesale and record the new release.

**S46.** A 2024 Workspace. The DM starts running *Curse of Strahd*, a 2014 Adventure. Is its content imported, and how is it marked?
Expected: Imported normally into Adventures, with no Edition callout and no consent: Adventures are not tied to an Edition. The rules material it points to follows the Edition — its creatures link to their 2024 versions, and only those without one enter Reference as Off-Edition Material.

**S47.** A 2024 Workspace. The DM wants the official Forgotten Realms lore from a 2015 book. Where does it go, and is it Off-Edition Material?
Expected: Reference › Setting › its Forgotten Realms subfolder. It is not Off-Edition Material and has no callout: Setting lore is not tied to an Edition.

**S48.** Italian Workspace. The agent believes a term's Italian name is the official one but is not sure. How is it recorded?
Expected: As a fallback in the Translation Glossary, so its first occurrence in each note shows the English original. Only a term the agent is sure the Italian books of the Edition use is an Official Translation.

**S50.** Right after Setup, before anything is imported, the DM changes `edition` in the Workspace Config from 2024 to 2014. What does the agent do?
Expected: Work in 2014: the Edition is fixed only once the first rules material is imported, so until then the Workspace Config's `edition` is the Edition. Nothing needs changing.
