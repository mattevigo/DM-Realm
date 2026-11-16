---
name: dmr-player-wiki
description: The Player Wiki of a DM Realm Workspace — write or update a copy of the parts the DM chooses (Reference, Homebrew, World, Characters, a Campaign's Chronicle) as a wiki for the players, outside the Workspace ("update the Player Wiki", "make a wiki for my players", "put the World in the wiki too"), with the DM's secrets, Sessions and Adventures left out.
argument-hint: <what to do, e.g. update the Player Wiki, or add the World to it>
allowed-tools: Read, Glob, Grep, Edit, Skill, Bash(ls:*), Bash(python3:*)
---

# The Player Wiki

Write the Workspace's Player Wiki. The rules are the `dmr-workspace` skill's structure.md, its "Player Wiki" section and the Workspace Config's `player_wiki` key:
- what can go in and what never does;
- what is removed from World and Homebrew;
- how links, stat blocks and titles change;
- the folder.

A helper next to that skill does every bit of the copying:

    python3 "<dmr-workspace base directory>/player-wiki.py" write .

`<dmr-workspace base directory>` is this skill's base directory with `dmr-player-wiki` replaced by `dmr-workspace`. This skill only records what goes in, runs the helper and reports. Never write, edit or copy a note into the wiki folder yourself. Speak to the DM in the Workspace Language.

1. **Load the rules.** Invoke `dmr-workspace` (read its structure.md in full), and find the Workspace Language in use as its "Fixed after Setup" reads it.
2. **Read the `player_wiki` key** in `workspace-config.yml`.
   - **No key yet** (the first time): propose it in one message, and end your turn.
     - The parts: every one of `reference`, `homebrew`, `world`, `characters`, and in `chronicles` every Campaign whose folder has a Chronicle.
     - `dm_only_headings`:
       - the Secrets heading, as the NPC, Place and Faction Templates in use write it;
       - "DM Notes", translated as structure.md's "Translating a term" says.
     - The folder: an absolute path outside the Workspace. Suggest one beside it: `<the Workspace folder's parent>/<the Workspace folder's name>_Player_Wiki`, its last part in the Workspace Language.
     - Say in one line that Reference holds official text, so the wiki is for the DM's players only, never a public site.

     On the DM's answer, with their changes, add the key at the end of the Config in `workspace-config.example.yml`'s format, every value filled in, and go on.
   - **The request changes what goes in** ("add the World", "leave out the Characters", "Bilanciamento is a DM heading too"): edit the key to match, and leave the rest of the Config as it is.
3. **Refuse what cannot go in.** Write nothing for it, say why, and go on with the rest. That covers an Adventure, a Session, any other Campaign note, the Voice, a Past Build, DM Tools or the Translation Glossary, and the Templates. structure.md's "Player Wiki" says why. A Campaign's NPCs, Places and other notes linked from its Chronicle stay plain text in the wiki: say so when the DM asks for them.
4. **Check the folder** before the helper runs. A path inside the Workspace, or one holding it, is refused: say why and ask for another. Do the same for a relative path.
5. **Run the helper** from the Workspace root. If it exits with an error, nothing was written:
   - **Exit 2:** the `player_wiki` key is wrong (the message names it). Fix it as the DM asked, and run again.
   - **Exit 3:** the folder is not allowed (the message says why). Ask the DM for another and end your turn.
   - **Exit 5:** the folder holds files that DM Realm did not write. Never empty it yourself: ask for an empty or new folder, and end your turn.
6. **Report** from the helper's output, in the Workspace Language:
   - the folder, and how many notes and files went in, from which parts;
   - how many links became plain text because their note is not in the wiki;
   - each World or Homebrew note and the sections removed from it. Invite the DM to name any other heading that hides a secret, or that should not have been removed, and to look over the wiki before sharing it.
   - each note the helper gives;
   - that the wiki is a copy rewritten at every update, so edits made in it are lost, and that it is written again only when the DM asks.

Done when the helper has written the wiki and the DM has the report, or the DM has the one question that stopped it and the wiki folder is as it was.
