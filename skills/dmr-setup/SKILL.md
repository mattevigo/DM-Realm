---
name: dmr-setup
description: Set up the current folder as a DM Realm Workspace.
disable-model-invocation: true
allowed-tools: Read, Glob, Write, Bash(ls:*), Bash(mkdir:*), Skill
---

# Setup

Turn the current folder into a DM Realm Workspace, leaving everything already in it intact. This version sets up a fresh folder in English with the default folder names.

1. **Load the rules.** Invoke the `dmr-workspace` skill. Its structure.md gives the six top-level folders, their keys and default English names, and the Workspace Config fields.
2. **Classify the folder**, before asking the DM anything. List it with hidden entries (`ls -A`) and look for Markdown notes anywhere below it (Glob `**/*.md`):
   - **Fresh** — empty, or holding only dot-entries such as `.obsidian/`, `.git/` or `.DS_Store`: continue with step 3.
   - **Already a Workspace** — `workspace-config.yml` at the root, next to top-level folders: this is a re-run; follow [Re-run](#re-run) instead of the steps below.
   - **Anything else** — notes or other files outside a Workspace: refuse and write nothing. When it holds Markdown notes, tell the DM it looks like an existing vault, and that migrating a vault into a Workspace is a separate skill DM Realm does not have yet.
3. **Workspace Language.** Use the language the DM's request names. When it names none, ask which language the Workspace will be written in — every folder, file and note, fixed for good after Setup — and end your turn. The language comes only from the DM's explicit words, never from the language their request is written in. If the chosen language is not English, tell the DM this version of Setup supports English Workspaces only, and stop.
4. **Preview.** Show exactly what Setup will create: `workspace-config.yml` with the content below, and the six top-level folders — `Reference`, `Adventures`, `Homebrew`, `Campaigns`, `DM_Tools`, `Templates` — empty.
5. **Confirmation.** Continue on an explicit go-ahead from the DM: one already in the request ("go ahead", "proceed", "create it") counts. Otherwise ask for it and end your turn; nothing is written before it.
6. **Create.** Write `workspace-config.yml` at the folder root, then create the six folders with `mkdir`. The Workspace starts with exactly these seven entries: no subfolders, no notes, and no Translation Glossary (an English Workspace has none).
7. **Report** what was created.

The Workspace Config Setup writes:

```yaml
# DM Realm Workspace Config — written by Setup; fields in the dmr-workspace rules.
language: English
folders:
  reference: Reference
  adventures: Adventures
  homebrew: Homebrew
  campaigns: Campaigns
  dm_tools: DM_Tools
  templates: Templates
```

Done when the folder holds `workspace-config.yml` and the six empty top-level folders, and nothing else of Setup's.

## Re-run

A Workspace is set up once. A re-run reports on it and writes nothing: renaming folders and repairing settings are not in this version.

1. **Find the Workspace Language in use** from the Workspace itself: the top-level folder names on disk and, in a non-English Workspace, the Translation Glossary in DM Tools. The config's `language` line may have been edited since Setup, so it does not decide.
2. **Answer the DM:**
   - When the config's `language` or the DM's request names another language, say that changing the Workspace Language is not supported and the Workspace stays in the language in use. If the config was edited, offer to put its `language` line back; change it only on the DM's yes.
   - Otherwise say the folder is already a DM Realm Workspace in that language, and Setup has nothing to create.

Done when the DM knows the Workspace's language in use and the folder is exactly as it was.
