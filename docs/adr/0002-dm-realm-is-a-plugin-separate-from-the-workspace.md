# DM Realm is a Claude Code plugin, separate from the Workspace

DM Realm ships as a Claude Code plugin: its `dmr-` skills, the Workspace structure documentation they follow, and their evals. A Workspace is any folder the DM opens in Obsidian; it holds only the Workspace Config, the top-level folders with the DM's notes, and Obsidian's own settings. No DM Realm file lives in a Workspace, so DM Realm updates arrive as plugin updates and never touch or merge with the DM's notes.

## Considered Options

- **The Workspace is a clone of the DM Realm repository** (the earlier design: DM Realm's `CLAUDE.md`, `CONTEXT.md` and `docs/` at the Workspace root, next to the notes). Rejected: every DM Realm update would be a git merge into the DM's notes, and the skills could not be shared across several Workspaces.
- **Clone the repository and also install the plugin.** Rejected: two copies of the same rules that can disagree, and the merge problem remains.

## Consequences

- The structure scenarios become plugin evals (`claude plugin eval`), run in a sandbox with a fresh agent.
- Skills must work without any DM Realm file in the Workspace: everything they need travels inside the plugin.
