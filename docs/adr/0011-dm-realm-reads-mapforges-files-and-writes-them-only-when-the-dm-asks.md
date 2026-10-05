# DM Realm reads MapForge's files and writes them only when the DM asks

MapForge, the DM's table app, is supported by DM Realm and stays independent of it. MapForge owns `.mapforge/` (its Manifest `workspace.json`, `config.json`, `parties.json`, `preferences.json`, its Session Logs) and the files beside a Map (`<map>.fog.json`, `<map>.combat/`). DM Realm reads them — to tell the DM what MapForge will see of the Workspace, and for the Table Record in Consolidation — and on its own initiative never creates, edits or deletes any of them: not at Setup, not after an Import, not when a Character changes. It writes one only when the DM's own request names that change ("point MapForge's bestiary at the Bestiary folder"). A question DM Realm raises itself, even an opt-in line in a preview, is not such a request. Nor does DM Realm shape the Workspace to fit MapForge: what MapForge cannot read of a Workspace is MapForge's to lift, in MapForge.

## Considered Options

- **Setup adopts the Workspace for MapForge**, writing the Manifest and `config.json`. Rejected: the Manifest is written by MapForge when it adopts a folder, and `config.json` is the DM's hand-written file, which MapForge itself never writes (MapForge ADR-0020). DM Realm would be a second author of files whose format follows MapForge's releases.
- **DM Realm keeps `parties.json` in step with the Character notes.** Rejected: MapForge writes that file itself, and two writers of one file overwrite each other.
- **Setup offers to configure MapForge, and the DM's yes counts as asking.** Rejected: every DM, with MapForge or without, would get the question, and the line between reading and writing would depend on how a preview is worded.
- **Arrange the Workspace so that one folder holds every stat block**, to suit MapForge's single bestiary folder. Rejected: it bends the Scopes ([ADR 0001](0001-scope-by-top-level-folder.md)) to one tool's current limit.

## Consequences

- MapForge's Bestiary holds what its `bestiaryStatBlockPath` names. Until MapForge reads more than one folder, the stat blocks in other Scopes are missing from it; DM Realm reports this, and does not fix it.
- A Party reaches MapForge by being typed in MapForge, by MapForge reading the Character notes, or by DM Realm writing `parties.json` at the DM's request.
- Consolidation reads the Table Record and leaves it as it is.
- An eval whose prompt does not ask for MapForge must leave `.mapforge/` unchanged.
- This is the same line as `.out-of-scope/mapforge-adventure-maps.md`, where DM Realm declined to author `<map>.fog.json`.
