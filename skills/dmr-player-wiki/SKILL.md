---
name: dmr-player-wiki
description: The Player Wiki of a DM Realm Workspace — write or update a copy of the parts the DM chooses (Reference, Homebrew, World, Characters, a Campaign's Chronicle) as a wiki for the players, outside the Workspace, with a Character Sheet page for each Character, and, when Setup chose it, build it as a website with Quartz ("update the Player Wiki", "make a wiki for my players", "put the World in the wiki too", "rebuild the players' site", "give my players their character sheets"), with the DM's secrets, Sessions and Adventures left out.
argument-hint: <what to do, e.g. update the Player Wiki, or add the World to it>
allowed-tools: Read, Glob, Grep, Edit, Skill, Bash(ls:*), Bash(python3:*), Bash(DMR_QUARTZ=*)
---

# The Player Wiki

Write the Workspace's Player Wiki. The rules are the `dmr-workspace` skill's structure.md, its "Player Wiki" section and the Workspace Config's `player_wiki` key:
- what can go in and what never does;
- what is removed from World and Homebrew;
- how links, stat blocks and titles change;
- the Character Sheets;
- the folder.

A helper next to that skill does every bit of the copying:

    python3 "<dmr-workspace base directory>/player-wiki.py" write .

With `quartz: true` in the Workspace Config, a second helper then builds it as a website ("The Player Wiki site" in structure.md):

    DMR_QUARTZ="${CLAUDE_PLUGIN_DATA}/quartz" python3 "<dmr-workspace base directory>/player-wiki-site.py" build . --locale <code>

`<dmr-workspace base directory>` is this skill's base directory with `dmr-player-wiki` replaced by `dmr-workspace`. This skill only records what goes in, runs the helpers and reports. Never write, edit or copy a note into the wiki folder yourself, never touch the site folder, and never run Quartz, npm or Node yourself. Speak to the DM in the Workspace Language.

1. **Load the rules.** Invoke `dmr-workspace` (read its structure.md in full), and find the Workspace Language in use as its "Fixed after Setup" reads it.
2. **Read the `player_wiki` key** in `workspace-config.yml`.
   - **No key yet** (the first time): propose it in one message, and end your turn.
     - The parts: every one of `reference`, `homebrew`, `world`, `characters`, and in `chronicles` every Campaign whose folder has a Chronicle.
     - `dm_only_headings`:
       - the Secrets heading, as the NPC, Place and Faction Templates in use write it;
       - "DM Notes", translated as structure.md's "Translating a term" says.
     - The folder: an absolute path outside the Workspace. Suggest one beside it: `<the Workspace folder's parent>/<the Workspace folder's name>_Player_Wiki`, its last part in the Workspace Language.
     - With `quartz: true`, the site folder `site` too: an absolute path outside the Workspace, suggested as the Markdown folder's path followed by `_Site`.
     - Say in one line that Reference holds official text, so where the wiki goes and who reads it is the DM's responsibility; the advice is a site only the players can open.

     On the DM's answer, with their changes, add the key at the end of the Config in `workspace-config.example.yml`'s format, every value filled in, and go on.
   - **`quartz: true` and no `site` in the key** (the DM chose the website after the key was written): propose the site folder as above, in one message, and end your turn; on the DM's answer add it to the key.
   - **The request changes what goes in** ("add the World", "leave out the Characters", "Bilanciamento is a DM heading too"): edit the key to match, and leave the rest of the Config as it is.
3. **Refuse what cannot go in.** Write nothing for it, say why, and go on with the rest. That covers an Adventure, a Session, any other Campaign note, the Voice, a Past Build, DM Tools or the Translation Glossary, and the Templates. structure.md's "Player Wiki" says why. A Campaign's NPCs, Places and other notes linked from its Chronicle stay plain text in the wiki: say so when the DM asks for them.
4. **Check the folder** before the helper runs. A path inside the Workspace, or one holding it, is refused: say why and ask for another. Do the same for a relative path.
5. **Run the helper** from the Workspace root. If it exits with an error, nothing was written:
   - **Exit 2:** the `player_wiki` key is wrong (the message names it). Fix it as the DM asked, and run again.
   - **Exit 3:** the folder is not allowed (the message says why). Ask the DM for another and end your turn.
   - **Exit 5:** the folder holds files that DM Realm did not write. Never empty it yourself: ask for an empty or new folder, and end your turn.
6. **Build the site**, only with `quartz: true` and once the Markdown wiki is written. `<code>` is the Workspace Language's locale as `xx-YY` (`it-IT` for Italiano, `en-US` for English, `de-DE` for Deutsch); the helper falls back to `en-US` when Quartz has none. When `${CLAUDE_PLUGIN_DATA}/quartz` holds no installed Quartz yet (`ls` it first), say in one line before running it that this first build downloads Quartz and its packages from GitHub and npm, once for every Workspace. If it exits with an error, the previous site is as it was and the Markdown wiki stays written:
   - **Exit 7:** no Node 22 or later. Pass on the helper's install steps, and say that the next update builds the site.
   - **Exit 8:** Quartz could not be downloaded or installed (the message says why, often no network). Say so; the next update tries again.
   - **Exit 9:** the build failed. Give the DM the error the helper printed.
   - **Exit 3 or 5:** the site folder is not allowed, or holds files DM Realm did not write. Ask for another, as for the Markdown folder, and end your turn.
   - **Exit 6:** the pinned Quartz is not as DM Realm expects, which is DM Realm's fault. Say so, and that the Markdown wiki is fine.
   - **The command is refused** by a permission check (a denial, not an exit code): do not retry it and do not work around it. Give the DM the exact command to run in their own terminal, from the Workspace folder, with `${CLAUDE_PLUGIN_DATA}` written out as its path. Also give the permission rule that would let DM Realm run it, `Bash(DMR_QUARTZ=*)`, to add in Claude Code's settings if they wish.
7. **Report** from the helpers' output, in the Workspace Language:
   - the folder, and how many notes and files went in, from which parts;
   - how many links became plain text because their note is not in the wiki;
   - each World or Homebrew note and the sections removed from it. Invite the DM to name any other heading that hides a secret, or that should not have been removed, and to look over the wiki before sharing it.
   - the Character Sheets written; each Character the helper left without one, and why (a missing or unreadable stat block: `dmr-character` writes it again); and the sheet labels the Translation Glossary lacks, which stay in English until it has them;
   - each note the helper gives;
   - that the wiki is a copy rewritten at every update, so edits made in it are lost, and that it is written again only when the DM asks.
   - with `quartz: true`:
     - the site folder and its pages, the Character Sheets among them;
     - the preview command the helper prints, and that it works with `python3` alone;
     - that the folder can be uploaded to any static host;
     - in one line, that the Reference holds official text, so publishing the site, and to whom, is the DM's responsibility;
     - or, when the site was not built, why, and what to do.

Done when the helper has written the wiki (and, with `quartz: true`, built the site or said why not) and the DM has the report, or the DM has the one question that stopped it and the wiki and site folders are as they were.
