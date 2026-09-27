---
name: dmr-setup
description: Set up the current folder as a DM Realm Workspace.
disable-model-invocation: true
allowed-tools: Read, Glob, Write, Edit, Bash(ls:*), Bash(mkdir:*), Bash(python3:*), Skill
---

# Setup

Turn the current folder into a DM Realm Workspace, in any Workspace Language, leaving everything already in it intact.

1. **Load the rules.** Invoke the `dmr-workspace` skill. Its structure.md gives the top-level folders with their keys and default English names, the Edition question, and the Workspace Config; `workspace-config.example.yml` next to it shows the Config's format.
2. **Classify the folder**, before asking the DM anything. List it with hidden entries (`ls -A`) and look for Markdown notes anywhere below it (Glob `**/*.md`):
   - **Fresh** — empty, or holding only dot-entries such as `.obsidian/`, `.git/` or `.DS_Store`: continue with step 3.
   - **Already a Workspace** — `workspace-config.yml` at the root, next to top-level folders: this is a re-run; follow [Re-run](#re-run) instead of the steps below.
   - **Anything else** — notes or other files outside a Workspace: refuse and write nothing. When it holds Markdown notes, tell the DM it looks like an existing vault, and that migrating a vault into a Workspace is a separate skill DM Realm does not have yet.
3. **Workspace Language.** Use the language the DM's request names, in any language ("italiano", "Deutsch"…). When it names none, ask which language the Workspace will be written in — every folder, file and note, fixed for good after Setup — and end your turn. Ask in the language the DM's request is written in (English when there is no text). Take the language only from the DM's explicit words; the language the request happens to be written in is not a choice. **From here on, write to the DM in the Workspace Language.**
4. **Edition.** Use the Edition the DM's request names ("2024 rules", "5.5e" and "One D&D" mean 2024; "5e 2014" means 2014). When it names none, ask it as structure.md's "Edition" section says, in one message, and end your turn. In that question, 2024 means the 2024 Player's Handbook, Dungeon Master's Guide and Monster Manual; 2014 means the 2014 core books and the books that followed them. Take the Edition only from the DM's explicit answer.
5. **Folder names.** For each top-level folder:
   - **Named by the DM** (in the request or an answer): use that name exactly, after checking it as structure.md's "Workspace Config" requires — a single folder name, not empty after the name rules, not a duplicate. An invalid name: say why, ask for another, and end your turn; the folder stays as it is.
   - **Otherwise**: its default English name, translated into the Workspace Language as structure.md's "Translating a term" says (Official Translation, else a faithful fallback), with the name rules applied. In English, the default name itself.
6. **Preview.** Show exactly what Setup will create: `workspace-config.yml` with its content — Workspace Language, Edition and every folder name; every top-level folder, each empty; in a non-English Workspace, the Translation Glossary with its rows; the Obsidian settings Setup merges (below); and, when Fantasy Statblocks is installed, what [Fantasy Statblocks](#fantasy-statblocks) sets, with the request to close Obsidian first. Unless the request already settled the names ("default names", or names given), invite the DM to rename any folder.
7. **Confirmation.** Continue on an explicit go-ahead from the DM: one already in the request ("go ahead", "proceed", "procedi", "create it") counts. Otherwise ask for it and end your turn; the folder stays as it is until then.
8. **Create.**
   1. Write `workspace-config.yml` at the folder root in the example's format, every value filled in (each folder name written out).
   2. Create the top-level folders with `mkdir`.
   3. In a non-English Workspace, write the Translation Glossary note at the root of the DM Tools folder, its name translated from `Translation_Glossary`, in the format structure.md's "Translation Glossary" gives: one row per top-level folder (English name, name in use, source, key).
   4. Merge the Obsidian settings with the helper next to this file, passing the Templates folder's name in use:

      ```sh
      python3 "<this skill's base directory>/obsidian-settings.py" merge . "<Templates folder name>"
      ```

      It sets wikilinks with shortest-path links, turns the Templates core plugin on and points it at the Templates folder, and leaves every other Obsidian setting as the DM had it. On exit 2 (a settings file that is not valid JSON) it changed nothing: name the file for the DM and go on. Without `python3`, make the same three changes by hand with Read and Write — `app.json`: `useMarkdownLinks: false`, `newLinkFormat: "shortest"`; `core-plugins.json`, always a JSON object: `templates: true`; `templates.json`: `folder` — keeping every other key.

   5. Set up [Fantasy Statblocks](#fantasy-statblocks).

   These are the whole new Workspace; an English Workspace has no Translation Glossary.
9. **Check Obsidian** with `python3 "<this skill's base directory>/obsidian-settings.py" version`: it prints the version found, the version found and that it is older than the one DM Realm was built for, or that none was found. This never stops Setup.
10. **Report**, in the Workspace Language: what was created; the Obsidian version found (with a warning to update when it is older), or that Obsidian was not found and can be installed later; Fantasy Statblocks, as its section says; and the one step left to the DM — open this folder in Obsidian with **Open folder as vault**.

Done when the folder holds `workspace-config.yml`, the empty top-level folders and, in a non-English Workspace, the Translation Glossary, and Fantasy Statblocks, when installed, has DM Realm's layouts — and nothing else of Setup's.

## Re-run

A Workspace is set up once. A re-run keeps its Workspace Language and Edition, renames top-level folders when the DM asks, restores the Obsidian settings DM Realm needs, and asks before recreating a missing folder. Speak the Workspace Language in use.

1. **Find the Workspace Language and Edition in use** from the Workspace itself, as structure.md's "Fixed after Setup" says: the config's `language` and `edition` lines may have been edited since Setup. When the config or the DM's request names another language or Edition than the one in use, say that changing it is not supported and the Workspace keeps the one in use; if the config was edited, offer to put that line back, and change it only on the DM's yes.
2. **Compare the top-level folders** on disk with the Workspace Config:
   - **Renamed** — the DM asks to rename a folder, or the Config names a folder that is not on disk while an unlisted folder is (the DM edited the Config): that is a rename to the new name.
   - **Missing** — a folder the Config names is on disk under no name: tell the DM and ask whether to recreate it; create it (`mkdir`) only on their yes.
3. **Rename**, one folder at a time. Preview it — the folder, its new name, and that every link into it will be rewritten — and continue only on an explicit go-ahead (one already in the request counts). Then run the helper next to this file:

   ```sh
   python3 "<this skill's base directory>/workspace-folders.py" rename . <key> "<new name>"            # add --from "<name on disk>" when the Config already has the new name
   ```

   It checks the name as structure.md requires (exit 2: say why and ask for another), moves the folder, rewrites every link whose path starts with the old name, updates the Workspace Config and, for the Templates folder, Obsidian's template folder. In a non-English Workspace, then update that folder's row in the Translation Glossary: the name in use, with the source *DM's choice* in the Workspace Language.
4. **Repair Obsidian settings**: run `python3 "<this skill's base directory>/obsidian-settings.py" merge . "<Templates folder name in use>"`. It restores only DM Realm's keys that drifted and rewrites nothing that is right. Then set up [Fantasy Statblocks](#fantasy-statblocks) the same way, with the layout labels the Translation Glossary already holds.
5. **Report** what changed — renamed folders and rewritten notes, restored settings, Fantasy Statblocks, recreated folders — or that the Workspace was already in order.

Done when every change the DM confirmed is made, the Obsidian settings (Fantasy Statblocks' included, when installed) are as DM Realm needs them, and nothing else in the Workspace changed.

## Fantasy Statblocks

The Obsidian plugin that renders the Workspace's stat blocks (structure.md's "Stat blocks"). Setup configures it only where the DM installed it.

- **Not installed** — no `.obsidian/plugins/obsidian-5e-statblocks/` folder: write nothing for it. In the report, say what it adds — monsters, NPCs and Characters rendered as stat blocks, a bestiary MapForge also reads — and how to get it: in Obsidian, Settings › Community plugins › Browse, "Fantasy Statblocks"; then re-run Setup to configure it.
- **Installed** — merge DM Realm's layouts and settings with the helper next to this file, passing the Edition in use:

  ```sh
  python3 "<this skill's base directory>/statblocks-settings.py" merge . <Edition>
  ```

  It installs the three layouts (Character, Monster 2014, Monster 2024) by name, makes the Edition's monster layout the default, turns off the plugin's bundled SRD, and makes it read stat blocks from every folder; every other setting and the DM's own layouts stay. **In a non-English Workspace**, translate the layouts' labels first: `statblocks-settings.py labels` prints them, one per line; translate each as structure.md's "Translating a term" says, reusing the Translation Glossary's rows and adding the new ones to it, then pass them all as one JSON object on standard input:

  ```sh
  python3 "<this skill's base directory>/statblocks-settings.py" merge . <Edition> --labels - <<'JSON'
  {"Armor Class": "<translation>", "STR": "<translation>", …}
  JSON
  ```

  Exit 2 changed nothing: `data.json` is not valid JSON (name the file for the DM and go on), or a label is missing (the message names it: add it and run again). The plugin rewrites `data.json` while Obsidian is open, so the preview asks the DM to close Obsidian first, and the report says to reload the plugin (or restart Obsidian) if it was open. Without `python3`, leave `data.json` as it is and tell the DM that Fantasy Statblocks was not configured.
