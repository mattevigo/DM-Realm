# Structure scenarios

Placement and linking questions that the Workspace documentation must answer in exactly one correct way. Re-run them after every change to `skills/dmr-workspace/` (the Workspace rules), `CONTEXT.md` or `docs/adr/`.

## How to run

1. Start a fresh agent that has not seen this file.
2. Give it only `CONTEXT.md`, `docs/adr/`, `skills/dmr-workspace/structure.md` and `skills/dmr-workspace/workspace-config.example.yml`.
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

**S17.** In a 2024 Workspace, where does the official Weapon Mastery property *Topple* go?
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
Expected: `workspace-config.yml` at the Workspace root: `language`, `edition`, and `folders` with one entry per top-level folder key.

**S26.** The DM sets the Campaigns folder name to `Games/Active` in the Workspace Config. What happens?
Expected: Not valid: a top-level folder name must be a single folder name directly under the Workspace root, never a path. The agent asks the DM for a single name.

**S27.** After Setup, the DM changes `language` from Italian to Spanish. What does the agent do?
Expected: Refuse to act on it: the Workspace Language is fixed after Setup. The agent keeps writing in Italian and tells the DM.

**S28.** An Italian Workspace. What language are the neutral keys (e.g. `reference.monsters`) and this documentation in, and do the keys appear in the Workspace?
Expected: English. The keys never appear in the Workspace as folder or file names; the agent uses them only to identify folders in the documentation and config.

**S29.** In an Italian Workspace, the agent creates the note for Session 3, "The Ambush". What is the file name?
Expected: The Session number pattern is kept but the words are in Italian: `Sessione_03_<translated title>.md` (e.g. `Sessione_03_L_Imboscata.md`), in the Campaign's Sessions folder under its Italian name.

## Edition

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

**S37.** After Setup, in a Workspace whose Reference holds rules notes imported from 2024 books, the DM changes `edition` in the Workspace Config from 2024 to 2014. What does the agent do?
Expected: Refuse to act on it: the Edition became fixed with the first rules material imported, and those notes' source says 2024. The agent keeps working in 2024 and tells the DM.

**S38.** What does Setup ask the DM, and does it fetch any official data?
Expected: First the Workspace Language, then (in that language) the Edition: 2014 or 2024, with 2024 recommended, no default, and a warning that it cannot change later. It writes the Workspace Config and creates the six top-level folders. It does not touch the Source Cache.

## Official data

**S39.** The DM pastes the text of a monster from their own copy of a book and asks the agent to add it to Reference. The Trusted Source does not have that monster. What does the agent do?
Expected: Refuse to add it: official material the Trusted Source does not contain cannot be in the Workspace, and the agent does not copy the pasted text anywhere. The DM may write their own version as Homebrew.

**S40.** The DM asks for a spell that is not in the Source Cache, and the Trusted Source cannot be reached. What does the agent do?
Expected: Stop, tell the DM, and write nothing — no note from memory and no other site.

**S41.** The DM asks "how does the Grappled condition work?". What does the agent do?
Expected: Answer from the Source Cache in the Workspace's Edition, naming the book and page. It creates no note unless the DM asks for one.

**S42.** Where is the Source Cache, and is it part of the Workspace?
Expected: Outside every Workspace, one per machine, shared by all the Workspaces on it. It is not in the Workspace: the Workspace Config stays the only DM Realm file there.

**S43.** The DM refreshes the Source Cache while working in Workspace A. What changes in Workspace B's notes?
Expected: Nothing. Each imported note keeps the release it records. When the DM asks, in B, to check for updates, the agent compares each note's entry in its recorded release with the cached release, lists the notes whose official content changed, and re-imports the ones the DM approves.

**S44.** The DM once added a line of their own to the Reference note *Fireball*. An update check finds an erratum to *Fireball*. What does the agent do?
Expected: Warn that the note differs from its recorded import and offer to move the DM's line where it belongs (a House Rule, Homebrew, or a Campaign note linking to *Fireball*). Then, if the DM approves, replace the official content wholesale and record the new release.

**S45.** The DM asks for a starter pack of official spells bundled with DM Realm, so a new Workspace works offline from day one. What is the answer?
Expected: DM Realm never ships Trusted Source data; it is only fetched on the DM's machine, into the Source Cache.

**S46.** A 2024 Workspace. The DM starts running *Curse of Strahd*, a 2014 Adventure. Is its content imported, and how is it marked?
Expected: Imported normally into Adventures, with no Edition callout and no consent: Adventures are not tied to an Edition. The rules material it points to follows the Edition — its creatures link to their 2024 versions, and only those without one enter Reference as Off-Edition Material.

**S47.** A 2024 Workspace. The DM wants the official Forgotten Realms lore from a 2015 book. Where does it go, and is it Off-Edition Material?
Expected: Reference › Setting › its Forgotten Realms subfolder. It is not Off-Edition Material and has no callout: Setting lore is not tied to an Edition.

**S48.** Italian Workspace. The agent believes a term's Italian name is the official one but is not sure. How is it recorded?
Expected: As a fallback in the Translation Glossary, so its first occurrence in each note shows the English original. Only a term the agent is sure the Italian books of the Edition use is an Official Translation.

**S49.** The DM asks to check for updates. The Source Cache is pinned to an older release than the latest. What does the agent do?
Expected: It does not refresh on its own. It says which release the cache is pinned to and that a newer one exists, offers to refresh first, and then compares the imported notes against the cache's release.

**S50.** Right after Setup, before anything is imported, the DM changes `edition` in the Workspace Config from 2024 to 2014. What does the agent do?
Expected: Work in 2014: the Edition is fixed only once the first rules material is imported, so until then the Workspace Config's `edition` is the Edition. Nothing needs changing.
