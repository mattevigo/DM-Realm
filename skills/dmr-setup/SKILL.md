---
name: dmr-setup
description: Set up the current folder as a DM Realm Workspace.
disable-model-invocation: true
allowed-tools: Read, Glob, Write, Bash(ls:*), Bash(mkdir:*), Skill
---

# Setup

Turn the current folder into a DM Realm Workspace, leaving everything already in it intact. This version sets up a fresh folder in English with the default folder names.

1. **Load the rules.** Invoke the `dmr-workspace` skill. Its structure.md gives the six top-level folders with their keys and default English names, the Edition question, and the Workspace Config; `workspace-config.example.yml` next to it shows the Config's format.
2. **Classify the folder**, before asking the DM anything. List it with hidden entries (`ls -A`) and look for Markdown notes anywhere below it (Glob `**/*.md`):
   - **Fresh** — empty, or holding only dot-entries such as `.obsidian/`, `.git/` or `.DS_Store`: continue with step 3.
   - **Already a Workspace** — `workspace-config.yml` at the root, next to top-level folders: this is a re-run; follow [Re-run](#re-run) instead of the steps below.
   - **Anything else** — notes or other files outside a Workspace: refuse and write nothing. When it holds Markdown notes, tell the DM it looks like an existing vault, and that migrating a vault into a Workspace is a separate skill DM Realm does not have yet.
3. **Workspace Language.** Use the language the DM's request names. When it names none, ask which language the Workspace will be written in — every folder, file and note, fixed for good after Setup — and end your turn. Take it only from the DM's explicit words; the language the request happens to be written in is not a choice. If the chosen language is not English, tell the DM this version of Setup supports English Workspaces only, and stop.
4. **Edition.** Use the Edition the DM's request names ("2024 rules", "5.5e" and "One D&D" mean 2024; "5e 2014" means 2014). When it names none, ask it as structure.md's "Edition" section says, in one message, and end your turn. In that question, 2024 means the 2024 Player's Handbook, Dungeon Master's Guide and Monster Manual; 2014 means the 2014 core books and the books that followed them. Take the Edition only from the DM's explicit answer.
5. **Preview.** Show exactly what Setup will create: `workspace-config.yml` with its content — Workspace Language and Edition included — and the six top-level folders with their default English names, each empty.
6. **Confirmation.** Continue on an explicit go-ahead from the DM: one already in the request ("go ahead", "proceed", "create it") counts. Otherwise ask for it and end your turn; the folder stays as it is until then.
7. **Create.** Write `workspace-config.yml` at the folder root in the example's format, every value filled in (each folder name written out), then create the six folders with `mkdir`. These seven entries are the whole new Workspace; an English Workspace has no Translation Glossary.
8. **Report** what was created.

Done when the folder holds `workspace-config.yml` and the six empty top-level folders, and nothing else of Setup's.

## Re-run

A Workspace is set up once. A re-run reports on it, and the folder stays as it is — the one exception is restoring an edited Config line, on the DM's yes. Renaming folders and repairing settings are not in this version.

1. **Find the Workspace Language and Edition in use** from the Workspace itself, as structure.md's "Fixed after Setup" says: the config's `language` and `edition` lines may have been edited since Setup.
2. **Answer the DM:**
   - When the config or the DM's request names another language or Edition than the one in use, say that changing it is not supported and the Workspace keeps the one in use. If the config was edited, offer to put that line back; change it only on the DM's yes.
   - Otherwise say the folder is already a DM Realm Workspace in that language and Edition, and Setup has nothing to create.

Done when the DM knows the Workspace's language and Edition in use and the folder is exactly as it was.
