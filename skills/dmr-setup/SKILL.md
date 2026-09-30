---
name: dmr-setup
description: Set up the current folder as a DM Realm Workspace.
disable-model-invocation: true
allowed-tools: Read, Glob, Write, Edit, Bash(ls:*), Bash(mkdir:*), Bash(cp:*), Bash(python3:*), Skill
---

# Setup

Turn the current folder into a DM Realm Workspace, in any Workspace Language, leaving everything already in it intact.

1. **Load the rules.** Invoke the `dmr-workspace` skill. Its structure.md gives the top-level folders with their keys and default English names, the Edition question, and the Workspace Config; `workspace-config.example.yml` next to it shows the Config's format.
2. **Classify the folder**, before asking the DM anything. List it with hidden entries (`ls -A`) and look for Markdown notes anywhere below it (Glob `**/*.md`):
   - **Fresh** — empty, or holding only dot-entries such as `.obsidian/`, `.git/` or `.DS_Store`: continue with step 3.
   - **Already a Workspace** — `workspace-config.yml` at the root, whatever is or is not beside it (a Config alone, with every top-level folder gone, is still a Workspace): this is a re-run; follow [Re-run](#re-run) instead of the steps below.
   - **Anything else** — no Config, and folders, notes or other files: refuse and write nothing. When it holds folders named like a Workspace's top-level folders (Reference, Campaigns… in any language), tell the DM the Workspace Config is missing: without it Setup cannot tell a Workspace, so the DM puts it back (from a backup or the folder's history) and runs Setup again. When it holds Markdown notes, tell the DM it looks like an existing vault, and that migrating a vault into a Workspace is a separate skill DM Realm does not have yet.
3. **Workspace Language.** Use the language the DM's request names, in any language ("italiano", "Deutsch"…). When it names none, ask which language the Workspace will be written in — every folder, file and note, fixed for good after Setup — and end your turn. Ask in the language the DM's request is written in (English when there is no text). Take the language only from the DM's explicit words; the language the request happens to be written in is not a choice. **From here on, write to the DM in the Workspace Language.**
4. **Edition.** Use the Edition the DM's request names ("2024 rules", "5.5e" and "One D&D" mean 2024; "5e 2014" means 2014). When it names none, ask it as structure.md's "Edition" section says, in one message, and end your turn. In that question, 2024 means the 2024 Player's Handbook, Dungeon Master's Guide and Monster Manual; 2014 means the 2014 core books and the books that followed them. Take the Edition only from the DM's explicit answer.
5. **Stat blocks.** Use the choice the DM's request makes ("with stat blocks", "Markdown only"). When it makes none, ask the [stat blocks question](#the-stat-blocks-question) in a message of its own and end your turn. Take `stat_blocks` only from the DM's explicit answer.
6. **Folder names.** For each top-level folder:
   - **Named by the DM** (in the request or an answer): use that name exactly, after checking it as structure.md's "Workspace Config" requires — a single folder name, not empty after the name rules, not a duplicate. An invalid name: say why, ask for another, and end your turn; the folder stays as it is.
   - **Otherwise**: its default English name, translated into the Workspace Language as structure.md's "Translating a term" says (Official Translation, else a faithful fallback), with the name rules applied. In English, the default name itself.
7. **Preview.** Show exactly what Setup will create: `workspace-config.yml` with its content — Workspace Language, Edition, `stat_blocks` with one line on what it means (monsters and NPCs as the plugin's stat blocks, or as Markdown that needs no plugin but that MapForge cannot read; Characters keep their stat block either way) and every folder name; every top-level folder, empty but for Templates; the [Templates](#the-templates) it writes, each by its file name; in a non-English Workspace, the Translation Glossary with its rows; the Obsidian settings Setup merges (below), the attachment location with its Attachments name included; and, when Fantasy Statblocks is installed, what [Fantasy Statblocks](#fantasy-statblocks) sets. Unless the request already settled the names ("default names", or names given), invite the DM to rename any folder.
8. **Confirmation.** Continue on an explicit go-ahead from the DM: one already in the request ("go ahead", "proceed", "procedi", "create it") counts. Otherwise ask for it and end your turn; the folder stays as it is until then.
9. **Create.**
   1. Write `workspace-config.yml` at the folder root in the example's format, every value filled in (each folder name written out).
   2. Create the top-level folders with `mkdir`.
   3. In a non-English Workspace, write the Translation Glossary note at the root of the DM Tools folder, its name translated from `Translation_Glossary`, in the format structure.md's "Translation Glossary" gives: one row per top-level folder (English name, name in use, source, key), and a row for each term the next steps translate (the Templates' names, Attachments).
   4. Write [the Templates](#the-templates) into the Templates folder.
   5. Merge the Obsidian settings with the helper next to this file, passing the Templates folder's name in use and Attachments in the Workspace Language (translated as structure.md's "Translating a term" says; in English, `Attachments`):

      ```sh
      python3 "<this skill's base directory>/obsidian-settings.py" merge . "<Templates folder name>" "<Attachments>"
      ```

      It sets wikilinks with shortest-path links, puts the files the DM pastes into a note in an Attachments subfolder beside it, turns the Templates core plugin on and points it at the Templates folder, and leaves every other Obsidian setting as the DM had it. On exit 2 (a settings file that is not valid JSON) it changed nothing: name the file for the DM and go on. Without `python3`, make the same changes by hand with Read and Write — `app.json`: `useMarkdownLinks: false`, `newLinkFormat: "shortest"`, `attachmentFolderPath: "./<Attachments>"`; `core-plugins.json`, always a JSON object: `templates: true`; `templates.json`: `folder` — keeping every other key.

   6. Set up [Fantasy Statblocks](#fantasy-statblocks).

   These are the whole new Workspace; an English Workspace has no Translation Glossary.
10. **Check Obsidian** with `python3 "<this skill's base directory>/obsidian-settings.py" version`: it prints the version found, the version found and that it is older than the one DM Realm was built for, or that none was found. This never stops Setup.
11. **Report**, in the Workspace Language: what was created, the Templates by name; with `stat_blocks: false`, that MapForge cannot place creatures without stat blocks; the Obsidian version found (with a warning to update when it is older), or that Obsidian was not found and can be installed later; Fantasy Statblocks, as its section says; and the one step left to the DM — open this folder in Obsidian with **Open folder as vault**.

Done when the folder holds `workspace-config.yml`, the top-level folders, empty but for every Template of the set, and, in a non-English Workspace, the Translation Glossary, and Fantasy Statblocks, when installed, has DM Realm's layouts — and nothing else of Setup's.

## Re-run

A Workspace is set up once. A re-run keeps its Workspace Language and Edition, renames top-level folders when the DM asks, converts the notes' statistics when `stat_blocks` changes, restores the Obsidian settings DM Realm needs, and asks before recreating a missing folder or adding a missing Template. Speak the Workspace Language in use.

1. **Find the Workspace Language and Edition in use** from the Workspace itself, as structure.md's "Fixed after Setup" says: the config's `language` and `edition` lines may have been edited since Setup. When the config or the DM's request names another language or Edition than the one in use, say that changing it is not supported and the Workspace keeps the one in use; if the config was edited, offer to put that line back, and change it only on the DM's yes.
2. **Compare the top-level folders** on disk with the Workspace Config:
   - **Renamed** — the DM asks to rename a folder, or the Config names a folder that is not on disk while an unlisted folder is (the DM edited the Config): that is a rename to the new name.
   - **Missing** — a folder the Config names is on disk under no name (with a Config alone, all eight): tell the DM and ask whether to recreate it; create it (`mkdir`) only on their yes.
3. **Templates.** A Template of [the set](#the-templates) is missing when the Templates folder has no file by its name in use — the Translation Glossary's row for it, or in English the file's own name. List every missing one (all of them, in a Workspace set up before Setup wrote them, or with the Templates folder missing) and ask whether to add them, in the same message as any missing folder; add them only on the DM's yes, as a first Setup writes them. A Template that is there is the DM's, whatever it holds: leave it byte for byte as it is.
4. **Rename**, one folder at a time. Preview it — the folder, its new name, and that every link into it will be rewritten; for Homebrew, also every Campaign's folders with its prefix (`Homebrew_Spells` → `Brew_Spells`) — and continue only on an explicit go-ahead (one already in the request counts). Then run the helper next to this file:

   ```sh
   python3 "<this skill's base directory>/workspace-folders.py" rename . <key> "<new name>"            # add --from "<name on disk>" when the Config already has the new name
   ```

   It checks the name as structure.md requires (exit 2: say why and ask for another), moves the folder, rewrites every link whose path starts with the old name, updates the Workspace Config and, for the Templates folder, Obsidian's template folder; for Homebrew it also renames each Campaign's prefixed folders and rewrites the links into them. In a non-English Workspace, then update that folder's row in the Translation Glossary: the name in use, with the source *DM's choice* in the Workspace Language.
5. **Stat blocks.** A Config without `stat_blocks` (a Workspace set up before it existed) counts as `true`. Unless the request makes the choice, ask the [stat blocks question](#the-stat-blocks-question) in a message of its own, before any other change, and end your turn; on the DM's answer, write it into the Config and convert if it is `false`. Convert, too, when the DM asks to change it, or when the Config's value is not the form the notes are in (a ```` ```statblock ```` fence, or Markdown starting with a `%% statblock` comment — the DM edited the Config). The notes to convert are every monster and NPC note with statistics, the Homebrew monster Template included; a Character's note and its past Builds are never converted:
   1. **Preview** every note to convert and the form it moves to; continue only on an explicit go-ahead (one already in the request counts).
   2. **Convert** each note with the helper next to the `dmr-workspace` skill's structure.md, passing the layouts' labels as Fantasy Statblocks gets them (below) — in English, none:

      ```sh
      python3 "<dmr-workspace base directory>/statblock.py" convert "<note>" --to <fence|markdown> --labels - <<'JSON'
      {"Armor Class": "<translation>", "STR": "<translation>", …}
      JSON
      ```

      It rewrites the note in place with the same values and translations, and moves the `statblock` frontmatter flag. Exit 6 or 7 leaves that note as it was: name it in the report and go on. Exit 8 means it is a Character's: it stays as it is, and needs no mention.
   3. **Write the value** into the Config once every note is converted.
6. **Repair Obsidian settings**: run `python3 "<this skill's base directory>/obsidian-settings.py" merge . "<Templates folder name in use>" "<Attachments>"`, Attachments as the Translation Glossary's row gives it (in English, `Attachments`; with no row yet, translated and added as a first Setup does). It restores only DM Realm's keys that drifted and rewrites nothing that is right. Then set up [Fantasy Statblocks](#fantasy-statblocks): run its helper even when the plugin looks configured, with the layout labels the Translation Glossary already holds.
7. **Report** what changed — renamed folders and rewritten notes, converted statistics (and any note left as it was), restored settings, Fantasy Statblocks, recreated folders, added Templates — or that the Workspace was already in order.

Done when every change the DM confirmed is made, every Template that was there is as it was, the Obsidian settings (Fantasy Statblocks' included, when installed) are as DM Realm needs them, and nothing else in the Workspace changed.

## The Templates

The basic set structure.md's "Templates" lists, in the form it gives a Template: one English note per Template in `templates/` next to this file, named by its default English name.

- **In English**, copy every file into the Templates folder as it is (`cp`).
- **In another language**, Read each and Write it into the Templates folder, translated as structure.md's "Translating a term" says: its file name (a term, with the name rules applied) and every heading and word, faithfully and with the same structure. The `—` marks, the `- [ ]` task and the Homebrew monster's fence (English keys, `—` values) stay as they are.
- **With `stat_blocks: false`**, then convert the Homebrew monster Template to Markdown with the helper next to the `dmr-workspace` skill's structure.md, passing the layouts' labels translated as [Fantasy Statblocks](#fantasy-statblocks) gets them (in English, no `--labels`):

  ```sh
  python3 "<dmr-workspace base directory>/statblock.py" convert "<Templates folder>/<Homebrew monster Template>.md" --to markdown --labels - <<'JSON'
  {"Armor Class": "<translation>", "STR": "<translation>", …}
  JSON
  ```

## The stat blocks question

How the Workspace writes monsters' and NPCs' statistics, asked in the Workspace Language:

- **Stat blocks** (`stat_blocks: true`): Fantasy Statblocks renders them, and MapForge reads them from its bestiary.
- **Markdown** (`stat_blocks: false`): readable with no plugin, but MapForge cannot place those creatures.

Recommend stat blocks when Fantasy Statblocks is installed (`.obsidian/plugins/obsidian-5e-statblocks/` exists) and Markdown when it is not, and say that Characters keep their stat block either way.

## Fantasy Statblocks

The Obsidian plugin that renders the Workspace's stat blocks (structure.md's "Stat blocks"). Setup configures it only where the DM installed it.

- **Not installed** — no `.obsidian/plugins/obsidian-5e-statblocks/` folder: write nothing for it. With `stat_blocks: true`, the fences show as YAML code blocks until it is installed. In the report, say what it adds — monsters, NPCs and Characters rendered as stat blocks, a bestiary MapForge also reads — and how to get it: in Obsidian, Settings › Community plugins › Browse, "Fantasy Statblocks"; then re-run Setup to configure it.
- **Installed** — merge DM Realm's layouts and settings with the helper next to this file, passing the Edition in use. Always run it, on a first Setup and on every re-run: it alone knows whether the layouts are current, since a layout with the right name and translated labels can still be an older version of DM Realm's (`statblocks-settings.py check .` tells, writing nothing). Never conclude from reading `data.json` that there is nothing to do.

  ```sh
  python3 "<this skill's base directory>/statblocks-settings.py" merge . <Edition>
  ```

  It installs the three layouts (Character, Monster 2014, Monster 2024) by name, makes the Edition's monster layout the default, turns off the plugin's bundled SRD, and makes it read stat blocks from every folder; every other setting and the DM's own layouts stay. **In a non-English Workspace**, translate the layouts' labels first: `statblocks-settings.py labels` prints them, one per line; translate each as structure.md's "Translating a term" says, reusing the Translation Glossary's rows and adding the new ones to it, then pass them all as one JSON object on standard input:

  ```sh
  python3 "<this skill's base directory>/statblocks-settings.py" merge . <Edition> --labels - <<'JSON'
  {"Armor Class": "<translation>", "STR": "<translation>", …}
  JSON
  ```

  Exit 2 changed nothing: `data.json` is not valid JSON (name the file for the DM and go on), or a label is missing (the message names it: add it and run again). **Exit 5** changed nothing either: `data.json` needs a change but Obsidian is running, and the plugin would overwrite the file from memory. Ask the DM to close Obsidian and end your turn; on their go-ahead, run the helper again. Without `python3`, leave `data.json` as it is and tell the DM that Fantasy Statblocks was not configured.
