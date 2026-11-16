# Structure scenarios

Placement, linking and official-data questions that the Workspace rules must answer in exactly one correct way.

**Most scenarios are now plugin evals** (`evals/`, tag `scenario` and the Setup/research cases): run `claude plugin eval` as CLAUDE.md says after every change to `skills/dmr-workspace/`, `CONTEXT.md` or `docs/adr/`. The table maps each scenario to its eval. The scenarios listed in full below have no eval yet, or only a partial one — most wait for the update-check spec, or have no observable behaviour — and are still checked by hand with a fresh agent.

| Scenario | Eval case |
| --- | --- |
| S01 | s01-reference-refuses-session-link |
| S02 | s02-feat-users-from-backlinks |
| S03 | s03-adventure-to-session-link |
| S04 | s04-homebrew-links |
| S05 | s05a-campaign-subfolder, s05b-no-ninth-top-level-folder |
| S06 | s06-adventure-to-adventure |
| S07 | s07-homebrew-to-dm-tools |
| S08 | s08-table-events-in-campaign |
| S09 | s09-no-scope-property |
| S10 | s10-adventure-monster (the stat block in Reference Monsters), import-adventure-part (an NPC with a heading of its own links to its Adventure's own monster, as a path link, before that monster is imported) |
| S11 | s11-campaign-homebrew-spell |
| S12 | workspace-plain-request |
| S13 | s13b-invented-world, s13c-campaign-changes-setting (part a, official Setting lore, waits for the Setting lore spec) |
| S14 | s14-conditions |
| S15 | s15a-random-table, s15b-campaign-todo (a Campaign-level note with no DM subfolder goes at the Campaign root) |
| S16 | s16-promotion |
| S17 | s17-weapon-mastery |
| S18 | s18-campaign-start |
| S19 | s19-session-file-name |
| S20 | s20-house-rule |
| S21 | import-adventure-item (an item the Adventure introduces, imported alone, goes to its Items with a README of the Adventure's title, book, levels and Parts), import-adventure-part (a Part: its Part note, a note per Place, NPC, Encounter and Item heading, the README's Parts linked, a core magic item linked in Reference Magic_Items) |
| S22 | s24-italian-glossary-reuse (its first Homebrew monster creates the translated folder and its Glossary row; no import needed) |
| S23 | import-italian-fallback (an invented term surely has no Official Translation) |
| S24 | s24-italian-glossary-reuse |
| S25 | workspace-plain-request, tests/workspace-notice.test.sh |
| S26 | setup-invalid-name |
| S27 | setup-rerun-language-change |
| S28 | setup-fresh-italian (config-italian-names: no neutral key is used as a folder name) |
| S29 | s29-italian-session-name |
| S30 | s30-import-spell |
| S31 | s31-import-reprint (the 2024 reprint is imported, not the 2014 entry), import-adventure-part (the Adventure's notes link a 2014 monster to its 2024 reprint in Reference Monsters, before it is imported) |
| S32 | s32-off-edition-monster (partial: an Encounter linking to an unreprinted 2014 monster has no eval yet) |
| S33 | s33-off-edition-option-asks |
| S34 | s32-off-edition-monster |
| S35 | s35-italian-2014-races |
| S36 | s36-weapon-mastery-2014 (consent given in the request; asking for it is s33-off-edition-option-asks) |
| S37 | setup-rerun-edition-change |
| S38 | setup-asks-edition, setup-fresh-english |
| S39 | s39-pasted-text |
| S40 | research-unreachable |
| S41 | research-2024-grappled, research-2014-grappled |
| S42 | research-2024-grappled, research-2014-grappled (cached-outside-workspace) |
| S43 | refresh-to-latest |
| S45 | — (a policy: DM Realm ships no Trusted Source data; tests/source-cache.test.sh and every eval use invented entries) |
| S48 | import-italian-fallback |
| S49 | research-no-refresh (partly: the update check itself waits for its spec) |
| S50 | s50-edition-edited |
| S51 | s51-character-refuses-session-link |
| S52 | s52-character-event-in-session |
| S53 | s53a-character-campaign-item-asks, s53b-character-campaign-item-promoted |
| S54 | s54-campaign-readme-party |
| S55 | s55-feat-users-current-builds |
| S56 | s56a-campaign-npc-to-world-asks, s56b-campaign-npc-to-world-promoted |
| S57 | s57-homebrew-refuses-world-link |
| S58 | s58-world-refuses-session-link |
| S59 | s59-invented-villain-split |
| S60 | s60-realms-town-in-world |
| S61 | s61-character-backstory-world-place |
| S62 | character-create (a new Character: its folder and note, `player`, links to Reference, a missing note imported) |
| S63 | character-create-level-3, character-create-asks-choices (a Character created above level 1: one note, no past Builds, each level's choices asked) |
| S64 | character-level-up (the current Build kept as the next past Build, `_02` after `_01`) |
| S65 | character-rebuild (a rebuild at the same level keeps a past Build, the first one: `_01`) |
| S66 | character-update-attune (attuning recomputes the numbers, no past Build); a Campaign-only item gained is S53 |
| S67 | character-retired |
| S68 | character-backstory-campaign-place-asks, character-backstory-generic, character-backstory-promoted (a backstory naming a Campaign-only place: asked, kept generic, or promoted to World) |
| S69 | transfer-old-vault (story dropped and listed, no official text, options linked) |
| S70 | transfer-2014-asks, transfer-2014-replaced (Transfer 2014 → 2024: reprints, consent, a refused option replaced) |
| S71 | transfer-italian (Transfer English → Italian, through the Translation Glossary) |
| S72 | transfer-preview (nothing written before the go-ahead, the source unchanged) |
| S73 | transfer-name-clash |
| S74 | transfer-past-builds (past Builds as history: plain-text options, no links) |
| S75 | s31-import-reprint, s32-off-edition-monster, statblock-import-italian (an imported monster's stat block: English keys, values in the Workspace Language, the default layout or the Off-Edition one) |
| S76 | statblock-adventure-npc (an Adventure NPC the book changes extends its Reference monster with the change alone; one it does not change only links to it) |
| S77 | statblock-campaign-npc-clash (a stat block name already in the bestiary: nothing written, another name asked) |
| S78 | character-create, character-level-up, transfer-past-builds (a Character's stat block agrees with its Build and is written again; a past Build leaves the bestiary) |
| S79 | setup-statblocks-plugin, setup-statblocks-italian, setup-fresh-english (Setup merges the layouts when Fantasy Statblocks is installed, labels translated; without it, writes nothing for it and mentions it) |
| S80 | statblock-plugin-unconfigured, tests/workspace-notice.test.sh (Fantasy Statblocks installed after Setup: the session notice says it lacks DM Realm's layouts, and the agent tells the DM to re-run Setup) |
| S81 | setup-rerun-statblocks-outdated, setup-rerun-statblocks-obsidian-open, tests/statblocks-settings.test.sh (DM Realm's layouts at an older revision: a re-run updates them, and with Obsidian open writes nothing and asks the DM to close it) |
| S82 | s82-refused-link-named-session (a refused link's fact goes, without asking, in the Session note the request names) |
| S83 | s83-path-link-name-clash (a second note with an existing name: path links, and the older note's bare links rewritten first) |
| S84 | s84-chained-promotion (Promotion moves the Campaign-only homebrew the note links to; a request to use it elsewhere is the go-ahead) |
| S85 | s85-campaign-house-rule |
| S86 | s86-italian-english-session-title (S29's other half: a title given in English stays English) |
| S87 | s87-research-records-nothing (a rules answer in the Workspace Language writes no note and no Glossary row) |
| S89 | setup-fresh-english, setup-fresh-italian, setup-rerun-templates, tests/setup-templates.test.sh (the first Setup writes the nine Templates, translated and with no links; a re-run keeps an edited one byte for byte and only offers a missing one) |
| S90 | setup-fresh-english, setup-fresh-italian, setup-rerun-drifted, tests/obsidian-settings.test.sh (Obsidian puts pasted files in an Attachments subfolder, its name translated; a re-run restores a drifted location) |
| S91 | setup-rerun-config-only, setup-refuses-no-config (the Config alone makes a Workspace: with every folder gone Setup re-runs and asks; folders without it are refused, naming the missing Config) |
| S92 | tests/workspace-folders.test.sh (renaming Homebrew renames every Campaign's `Homebrew_<Type>` folders and the links into them) |
| S93 | s93-session-dm-name (a Session note the DM names their own way keeps that name) |
| S94 | s94-side-session (a Side Session has no number and does not shift the run; an untitled Session is `Session_<NN>.md`) |
| S95 | s95-spent-resources-party-state (a Character's spent hit points and spell slots go in the Campaign's Party State; the Character note is unchanged) |
| S96 | setup-fresh-english, tests/setup-templates.test.sh (the Session Template has the `number` and `date` properties, the Present line and a Live notes section between Prep and Recap) |
| S97 | session-narrate-apply, session-narrate-italian (a consolidated Session's Chapter goes in its Campaign's Chronicle, named after the Session note and linking to it, and the Session note does not link back) |
| S98 | tests/player-wiki.test.sh, player-wiki-update (the Player Wiki holds only the parts chosen, never an Adventure, a Session, another Campaign note, the Voice or a Past Build; a link to a note left out is plain text; World and Homebrew lose their DM-only sections; the Workspace is unchanged) |
| S100 | setup-asks-quartz, setup-quartz-old-node, player-wiki-site-old-node, tests/player-wiki-site.test.sh (Setup asks whether the Player Wiki is also a website and checks Node, installing nothing; without Node 22 the Markdown wiki is written and the site is not; the site is built with the pinned Quartz, its configuration DM Realm's, and a failed build leaves the previous site) |
| S99 | player-wiki-refuse-adventure, player-wiki-inside-workspace, tests/player-wiki.test.sh (an Adventure asked for the Player Wiki is refused, saying why; a folder inside the Workspace, or one DM Realm did not write, is refused and nothing is deleted) |
| S101 | s101-designed-adventure-links-world (a designed Adventure's note links to the DM's World; the World note does not name it) |
| S102 | s102-designed-adventure-refuses-campaign-link (a designed Adventure's note never links to a Campaign; the Campaign's note links to it instead) |
| S103 | s103-campaign-plot-stays (the DM's own dungeon in place of an Adventure's chapter is the Campaign's, and nothing is written in Adventures) |
| S105 | s105-designed-adventure-monster (a monster a designed Adventure introduces is a Homebrew monster that never names it; its encounter is the Adventure's) |
| S106 | s106-promotion-to-adventure (a Campaign place promoted to a new designed Adventure: a README with no source property, the note in its Places, stripped of the Campaign) |

## How to run the manual scenarios

1. Start a fresh agent that has not seen this file.
2. Give it only `CONTEXT.md`, `docs/adr/`, `skills/dmr-workspace/structure.md` and `skills/dmr-workspace/workspace-config.example.yml`.
3. Ask it each **Question** below, verbatim, and have it answer from the documentation alone, citing the section it relied on.
4. Compare each answer with **Expected**. A scenario passes only if the answer matches and the agent found no competing reading. If it fails, fix the documentation, not the scenario — unless the scenario itself contradicts the spec.

## Scenarios without an eval yet

**S13.** Where do these go: (a) the official lore of the Forgotten Realms; (b) a world the DM invented; (c) the fact that, in one Campaign, the PCs' actions made a Realms city fall?
Expected: (a) Reference Setting; (b) World, in a folder named after the world; (c) that Campaign (e.g. its Places), linking to the Reference note.

**S88.** Glasstaff, an NPC, appears in two published Adventures, *The Sunken Keep* and *The Salt Crypt*, and the DM runs both. Where do his notes go?
Expected: One note in each Adventure's NPCs, each as its own book describes him. Neither links to the other, and there is no shared note.

**S104.** A Workspace holds the official *Sunken Keep*, imported, and *The Drowned Bell*, an Adventure the DM designs. The DM asks for an update check. What does it compare?
Expected: Only the notes with a source property — the official Adventure's, and Reference's. *The Drowned Bell*'s notes have none, so the check never lists, compares or re-imports them, and it does not warn that they were edited.

**S107.** The DM designed an Adventure and named it *The Sunken Keep*, then asks to import chapter 1 of the official *Sunken Keep*. What happens?
Expected: The Import writes nothing: the folder its title gives holds a designed Adventure (its README has no source property). It says so and asks the DM to rename one of the two; a rename moves the folder and rewrites the links into it, and the Import can then go on.

**S108.** The Heroes Campaign ran *The Drowned Bell*, and in its Session 6 the NPC Old Marrow died. The DM asks for an Idea for the Adventure's next Part. What limits it?
Expected: The official rules and Homebrew's House Rules, *The Drowned Bell*'s own notes, their secrets included, and the lore of the world its README names (Orsenna's World notes): Old Marrow may appear alive, since no Campaign's notes are a limit or a source. Its README's Pitch, Level Range and Tone are soft limits, which the Idea may depart from, saying where and how.

## Official data

**S32.** A 2024 Workspace runs a 2014 Adventure. One of its encounters uses a 2014 monster that no 2024 book reprints. What does the agent do?
Expected: Import it into Reference Monsters as Off-Edition Material, with a callout at the top naming its Edition (2014) — on its own when the DM asks for it, or with the Part's other missing monsters on the DM's one yes to their count when the Part is imported; no consent of its own, since it is not a player option. The Encounter links to it either way.

**S44.** The DM once added a line of their own to the Reference note *Fireball*. An update check finds an erratum to *Fireball*. What does the agent do?
Expected: Warn that the note differs from its recorded import and offer to move the DM's line where it belongs (a House Rule, Homebrew, or a Campaign note linking to *Fireball*). Then, if the DM approves, replace the official content wholesale and record the new release.

**S46.** A 2024 Workspace. The DM starts running *Curse of Strahd*, a 2014 Adventure. Is its content imported, and how is it marked?
Expected: Imported normally into Adventures, a Part at a time, with no Edition callout and no consent: Adventures are not tied to an Edition. The rules material it points to follows the Edition — its creatures link to their 2024 versions, and only those without one enter Reference as Off-Edition Material.

**S47.** A 2024 Workspace. The DM wants the official Forgotten Realms lore from a 2015 book. Where does it go, and is it Off-Edition Material?
Expected: Reference › Setting › its Forgotten Realms subfolder. It is not Off-Edition Material and has no callout: Setting lore is not tied to an Edition.

