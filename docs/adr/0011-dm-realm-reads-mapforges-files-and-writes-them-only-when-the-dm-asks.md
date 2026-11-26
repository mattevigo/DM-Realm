# DM Realm reads MapForge's files and writes them only when the DM asks

MapForge, the DM's table tool, is supported by DM Realm and stays independent of it. MapForge owns `.mapforge/` (its Manifest `workspace.json`, `config.json`, `parties.json`, `preferences.json`, its Session Logs) and the files beside a Map (`<map>.fog.json`, `<map>.combat/`). DM Realm reads them — to tell the DM what MapForge will see of the Workspace, and to write a Session's Table Record into its Live Notes — and on its own initiative never creates, edits or deletes any of them: not at Setup, not after an Import, not when a Character changes. It writes one only when the DM's own request names that change ("remove the old bestiary folder from MapForge's config.json"). A question DM Realm raises itself, even an opt-in line in a preview, is not such a request. Nor does DM Realm shape the Workspace to fit MapForge: what MapForge cannot read of a Workspace is MapForge's to lift, in MapForge.

*Changed 2026-11-17: MapForge 2.0 lifted the limits this decision left to it (MapForge's ADR-0023 and ADR-0024). It reads every note in the Workspace, with no bestiary folder to set, and takes a Character's numbers from its note. The decision stands; the example request and the first two consequences are updated, and DM Realm's helper no longer sets `bestiaryStatBlockPath`.*

## Considered Options

- **Setup adopts the Workspace for MapForge**, writing the Manifest and `config.json`. Rejected: the Manifest is written by MapForge when it adopts a folder, and `config.json` is the DM's hand-written file, which MapForge itself never writes (MapForge ADR-0020). DM Realm would be a second author of files whose format follows MapForge's releases.
- **DM Realm keeps `parties.json` in step with the Character notes.** Rejected: MapForge writes that file itself, and two writers of one file overwrite each other.
- **Setup offers to configure MapForge, and the DM's yes counts as asking.** Rejected: every DM, with MapForge or without, would get the question, and the line between reading and writing would depend on how a preview is worded.
- **Arrange the Workspace so that one folder holds every stat block**, to suit MapForge's single bestiary folder. Rejected: it bends the Scopes ([ADR 0001](0001-scope-by-top-level-folder.md)) to one tool's current limit.

## Consequences

- MapForge reads every note in the Workspace, wherever its Scope puts it, so the Workspace needs no arranging for it. DM Realm reports what MapForge reads and what it skips, and fixes nothing in `.mapforge/`.
- A Party is chosen in MapForge, and each Character takes its numbers from its note once the DM links the two there. DM Realm reports a Party Character with no note linked, or linked to a note no longer there; the link is MapForge's to keep.
- A Session's Table Record is read into its Live Notes ([ADR 0012](0012-the-table-record-enters-a-session-as-its-live-notes.md)) and left as it is.
- An eval whose prompt does not ask for MapForge must leave `.mapforge/` unchanged.
- This is the same line as `.out-of-scope/mapforge-adventure-maps.md`, where DM Realm declined to author `<map>.fog.json`.
