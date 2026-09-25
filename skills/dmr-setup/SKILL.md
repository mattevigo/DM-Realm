---
name: dmr-setup
description: Set up the current folder as a DM Realm Workspace.
disable-model-invocation: true
allowed-tools: Read, Glob, Write, Bash(ls:*), Bash(mkdir:*), Skill
---

# Setup

Turn the current folder into a DM Realm Workspace. This version handles one path: an empty folder, set up in English with the default folder names.

1. **Load the rules.** Invoke the `dmr-workspace` skill. Its structure.md gives the six top-level folders, their keys and default English names, and the Workspace Config fields.
2. **Check the folder.** List the current folder with hidden entries (`ls -A`). Continue only if it holds nothing but dot-entries such as `.obsidian/`, `.git/` or `.DS_Store`. Otherwise tell the DM this version of Setup only sets up an empty folder, and stop.
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
