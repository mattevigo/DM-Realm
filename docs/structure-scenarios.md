# Structure scenarios

Placement and linking questions that the Workspace documentation must answer in exactly one correct way. Re-run them after every change to `docs/structure.md`, `workspace-config.yml`, `CONTEXT.md` or `docs/adr/`.

## How to run

1. Start a fresh agent that has not seen this file.
2. Give it only `CONTEXT.md`, `docs/adr/`, `docs/structure.md` and `workspace-config.yml`.
3. Ask it each **Question** below, verbatim, one list at a time, and have it answer from the documentation alone, citing the section it relied on.
4. Compare each answer with **Expected**. A scenario passes only if the answer matches and the agent found no competing reading. If it fails, fix the documentation, not the scenario — unless the scenario itself contradicts the spec.

## Scopes and links

**S01.** The PCs first saw *Fireball* cast in Session 08. The DM asks the agent to add "first seen in Session 08" with a link to the Session to the *Fireball* note in Reference. What should the agent do?
Expected: Refuse to write it into the Reference note — Reference may link only to Reference. Record it in the Session 08 note instead, linking to *Fireball*.

**S02.** The DM wants the official *Alert* feat note to list which PCs have the feat. What should the agent do?
Expected: Not edit the feat note. Each PC's Character note in the Campaign links to *Alert*; "who has it" is answered by the feat note's backlinks.

**S03.** Can an Adventure's place note link to a Campaign Session? Can the Session link to the Adventure's place note?
Expected: Adventure → Session is forbidden (Adventure links only to Reference and the same Adventure). Session → Adventure place is allowed (Campaign links to anything).

**S04.** A Homebrew monster note wants to link to an official spell, and to an Adventure's NPC. Which links are allowed?
Expected: Link to the official spell (Reference) is allowed; link to the Adventure is forbidden.

**S05.** The DM adds a `Narrative` subfolder inside a Campaign, and separately wants a seventh top-level folder `Maps`. Which is allowed?
Expected: The Campaign subfolder is allowed (the DM is free inside top-level folders). A seventh top-level folder is not allowed (the six top-level folders are fixed; maps belong inside an existing one, e.g. the Campaign's Attachments).

**S06.** An NPC note in one Adventure wants to link to an NPC in a different Adventure. Allowed?
Expected: Forbidden — an Adventure links only to Reference and to the same Adventure.

**S07.** A Homebrew note wants to link to a checklist in DM Tools. Allowed?
Expected: Forbidden — only Campaign and DM Tools notes may link into DM Tools.

**S08.** During play the PCs burned down a tavern that an Adventure describes. Where is that recorded?
Expected: In the Campaign (e.g. the Session note, or the Campaign's Places), linking to the Adventure's tavern note. The Adventure note is not changed.

**S09.** The agent creates a new monster note in the Reference Monsters folder. How does it mark the note's Scope?
Expected: It doesn't: the Scope is Reference because of the top-level folder the note lives in. There is no Scope property.

## Placement

**S10.** An Adventure introduces an official monster that appears in no other book. Where does its stat block go?
Expected: Reference Monsters. The Adventure's notes (e.g. its NPCs or Encounters) link to it.

**S11.** The DM invents a spell for one Campaign only. Where does it go?
Expected: In that Campaign's `Homebrew_Spells` subfolder, in the level subfolder for its spell level (e.g. `Homebrew_Spells › Level_2`), created when this first note is written.

**S12.** The DM invents a 3rd-level spell meant for every future Campaign, and the Workspace has no Homebrew Spells folder yet. Where does it go?
Expected: Homebrew › Spells › Level_3, with the folders created now, by this first note.

**S13.** Where do these go: (a) the official lore of the Forgotten Realms; (b) a world the DM invented; (c) the fact that, in one Campaign, the PCs' actions made a Realms city fall?
Expected: (a) Reference Setting; (b) Homebrew Setting; (c) that Campaign (e.g. its Places), linking to the Reference note.

**S14.** Where does a quick-reference of the official Conditions go?
Expected: Reference Rules — not DM Tools and not House Rules.

**S15.** Where do (a) a random tavern-name table and (b) a to-do board for one Campaign go?
Expected: (a) DM Tools › Random_Tables; (b) inside that Campaign.

**S16.** A magic item invented for Campaign A (in its `Homebrew_Magic_Items`) is now also used in Campaign B. What should the agent do?
Expected: Move it to Homebrew › Magic_Items and remove everything in it that refers to Campaign A (links and mentions). Campaign A and B notes link to it there.

**S17.** Where does the official Weapon Mastery property *Topple* go?
Expected: Reference › Equipment › Weapon_Masteries.

**S18.** A DM sets up a fresh Workspace and starts one Campaign. Which folders exist before any other note is written?
Expected: The six top-level folders, and that Campaign's folder with its core: README, Characters, NPCs, Sessions, Places, Quests, Factions, Attachments. No Reference, Adventure, Homebrew, DM Tools or Templates subfolders yet.

**S19.** In an English Workspace, what is the file for Session 3, "The Ambush", and where does it go?
Expected: `Session_03_The_Ambush.md` in the Campaign's Sessions folder.

**S20.** The DM wants a house rule on flanking to apply at every table. Where does it go?
Expected: Homebrew › House_Rules. It applies to every Campaign in the Workspace.

**S21.** The DM starts running a published Adventure, *The Sunken Keep*. Where does the Adventure's content go, and where does an item unique to that Adventure go?
Expected: Adventures › The_Sunken_Keep, with README, Places, NPCs, Items and Encounters; the unique item goes in its Items (an official magic item from the DMG stays in Reference Magic_Items).

## Language and config

**S22.** The Workspace Language is Italian and the Workspace Config leaves every folder name empty. The agent writes the first official monster. What is the Monsters folder called, and what else does the agent do?
Expected: The Italian Official Translation of "Monsters" (the name the Italian books use) — not the English name and not the neutral key. Its path is the translated Reference folder › that name. The agent records the choice in the Translation Glossary in DM Tools, as an Official Translation.

**S23.** Italian Workspace. A game term has no Official Translation in Italian. How does the agent name it in a note?
Expected: It translates it as faithfully as it can (it may search the web for an existing correspondence), records it in the Translation Glossary as a fallback, and in each note shows the English original the first time the term appears, e.g. `Term (EN: Original)`.

**S24.** A later note uses a term that is already in the Translation Glossary. What does the agent do?
Expected: Use the Glossary's translation unchanged, without re-translating it. If the Glossary records it as a fallback, its first occurrence in this note also shows the English original.

**S25.** Where does the agent read the Workspace Language and the top-level folder names?
Expected: `workspace-config.yml` at the Workspace root: `language`, and `folders` with one entry per top-level folder key.

**S26.** The DM sets the Campaigns folder name to `Games/Active` in the Workspace Config. What happens?
Expected: Not valid: a top-level folder name must be a single folder name directly under the Workspace root, never a path. The agent asks the DM for a single name.

**S27.** After Setup, the DM changes `language` from Italian to Spanish. What does the agent do?
Expected: Refuse to act on it: the Workspace Language is fixed after Setup. The agent keeps writing in Italian and tells the DM.

**S28.** An Italian Workspace. What language are the neutral keys (e.g. `reference.monsters`) and this documentation in, and do the keys appear in the Workspace?
Expected: English. The keys never appear in the Workspace as folder or file names; the agent uses them only to identify folders in the documentation and config.

**S29.** In an Italian Workspace, the agent creates the note for Session 3, "The Ambush". What is the file name?
Expected: The Session number pattern is kept but the words are in Italian: `Sessione_03_<translated title>.md` (e.g. `Sessione_03_L_Imboscata.md`), in the Campaign's Sessions folder under its Italian name.
