---
name: dmr-workspace
description: DM Realm Workspace rules — where a note goes, what it may link to, how it is named and translated. Load before creating, moving, renaming or linking any note or folder in a DM Realm Workspace (a folder with `workspace-config.yml` at its root), and before any `dmr-` skill acts.
user-invocable: false
---

# DM Realm Workspace rules

The rules are [structure.md](structure.md), next to this file: folders and their neutral keys, Scopes and link rules, folder creation, Edition, official data, language and names, and the Workspace Config. Terms follow the glossary in [CONTEXT.md](../../CONTEXT.md).

1. **Read the Workspace Config** — `workspace-config.yml` at the Workspace root — for the Workspace Language, the Edition and the top-level folder names. (During Setup there is none yet; Setup writes it.)
2. **Read structure.md in full.** It is the single source of truth; the layout of an existing Workspace never overrides it.
3. **Apply it to every path and link you write.** Place each note in the folder structure.md gives it, name it in the Workspace Language by its name rules, and write only the links its Scope allows. When the DM asks for a forbidden link, refuse it, say why, and record the fact on the side allowed to link, pointing back.

Done when every folder, file and link you wrote is the one structure.md prescribes.
