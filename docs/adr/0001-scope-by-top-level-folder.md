# A note's Scope is its top-level folder

A note's Scope (Reference, Adventure, Homebrew, Campaign) is decided solely by the top-level folder it lives in, and links may only point from a Scope to the Scopes it is allowed to depend on: Reference links only within Reference; Adventure to Reference and within the same Adventure; Homebrew to Reference and Homebrew; Campaign and DM Tools to anything. This keeps official material free of any one table's story, so it can be reused by every Campaign and re-imported without losing anything.

The top-level folders are therefore fixed (the DM may rename them in the Workspace Config but not add or remove them), while everything inside them is up to the DM.

## Considered Options

- **A `context-scope` frontmatter property on every note.** Rejected: it duplicates what the folder already says, can drift from the note's location, and needs a fourth pseudo-value for DM Tools. The folder is the single source of truth.
- **Homebrew folders anywhere, taking the Scope of their parent.** Rejected: it mixed invented material into Reference. Reusable homebrew now has its own top-level Homebrew folder; homebrew made for one Campaign lives inside that Campaign.
