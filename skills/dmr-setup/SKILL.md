---
name: dmr-setup
description: Set up the current folder as a DM Realm Workspace.
disable-model-invocation: true
allowed-tools: Read, Glob, Write, Bash(ls:*), Bash(mkdir:*), Skill
---

# Setup

Turn the current folder into a DM Realm Workspace, in any Workspace Language, leaving everything already in it intact.

1. **Load the rules.** Invoke the `dmr-workspace` skill. Its structure.md gives the six top-level folders with their keys and default English names, the Edition question, and the Workspace Config; `workspace-config.example.yml` next to it shows the Config's format.
2. **Classify the folder**, before asking the DM anything. List it with hidden entries (`ls -A`) and look for Markdown notes anywhere below it (Glob `**/*.md`):
   - **Fresh** — empty, or holding only dot-entries such as `.obsidian/`, `.git/` or `.DS_Store`: continue with step 3.
   - **Already a Workspace** — `workspace-config.yml` at the root, next to top-level folders: this is a re-run; follow [Re-run](#re-run) instead of the steps below.
   - **Anything else** — notes or other files outside a Workspace: refuse and write nothing. When it holds Markdown notes, tell the DM it looks like an existing vault, and that migrating a vault into a Workspace is a separate skill DM Realm does not have yet.
3. **Workspace Language.** Use the language the DM's request names, in any language ("italiano", "Deutsch"…). When it names none, ask which language the Workspace will be written in — every folder, file and note, fixed for good after Setup — and end your turn. Ask in the language the DM's request is written in (English when there is no text). Take the language only from the DM's explicit words; the language the request happens to be written in is not a choice. **From here on, write to the DM in the Workspace Language.**
4. **Edition.** Use the Edition the DM's request names ("2024 rules", "5.5e" and "One D&D" mean 2024; "5e 2014" means 2014). When it names none, ask it as structure.md's "Edition" section says, in one message, and end your turn. In that question, 2024 means the 2024 Player's Handbook, Dungeon Master's Guide and Monster Manual; 2014 means the 2014 core books and the books that followed them. Take the Edition only from the DM's explicit answer.
5. **Folder names.** For each of the six top-level folders:
   - **Named by the DM** (in the request or an answer): use that name exactly, after checking it as structure.md's "Workspace Config" requires — a single folder name, not empty after the name rules, not a duplicate. An invalid name: say why, ask for another, and end your turn; the folder stays as it is.
   - **Otherwise**: its default English name, translated into the Workspace Language as structure.md's "Translating a term" says (Official Translation, else a faithful fallback), with the name rules applied. In English, the default name itself.
6. **Preview.** Show exactly what Setup will create: `workspace-config.yml` with its content — Workspace Language, Edition and every folder name; the six top-level folders, each empty; and, in a non-English Workspace, the Translation Glossary with its rows. Unless the request already settled the names ("default names", or names given), invite the DM to rename any folder.
7. **Confirmation.** Continue on an explicit go-ahead from the DM: one already in the request ("go ahead", "proceed", "procedi", "create it") counts. Otherwise ask for it and end your turn; the folder stays as it is until then.
8. **Create.**
   1. Write `workspace-config.yml` at the folder root in the example's format, every value filled in (each folder name written out).
   2. Create the six folders with `mkdir`.
   3. In a non-English Workspace, write the Translation Glossary note at the root of the DM Tools folder, its name translated from `Translation_Glossary`, in the format structure.md's "Translation Glossary" gives: one row per top-level folder (English name, name in use, source, key).

   These are the whole new Workspace; an English Workspace has no Translation Glossary.
9. **Report** what was created, in the Workspace Language.

Done when the folder holds `workspace-config.yml`, the six empty top-level folders and, in a non-English Workspace, the Translation Glossary — and nothing else of Setup's.

## Re-run

A Workspace is set up once. A re-run reports on it, and the folder stays as it is — the one exception is restoring an edited Config line, on the DM's yes. Renaming folders and repairing settings are not in this version.

1. **Find the Workspace Language and Edition in use** from the Workspace itself, as structure.md's "Fixed after Setup" says: the config's `language` and `edition` lines may have been edited since Setup.
2. **Answer the DM:**
   - When the config or the DM's request names another language or Edition than the one in use, say that changing it is not supported and the Workspace keeps the one in use. If the config was edited, offer to put that line back; change it only on the DM's yes.
   - Otherwise say the folder is already a DM Realm Workspace in that language and Edition, and Setup has nothing to create.

Done when the DM knows the Workspace's language and Edition in use and the folder is exactly as it was.
