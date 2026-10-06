# Preparing an Adventure's maps for MapForge

DM Realm does not prepare an imported Adventure's maps for MapForge: it does not set their grid, trace their walls or place their lights, and it writes nothing beside a map image.

## Why this is out of scope

An Import already puts every map an Adventure shows into the Workspace, in the Adventure's Attachments folder ([ADR 0008](../docs/adr/0008-an-imports-images-come-from-the-trusted-sources-image-mirror.md)), and MapForge opens any image file wherever it sits. So the map reaches the table with no help from DM Realm.

What is left is the work MapForge does on a map: Grid Fit, the Wall Editor, Lights and Pawns. Their result is MapForge's own file beside the image (`<map>.fog.json`), authored in its Live View. DM Realm writing that file would be a second author of a file MapForge owns, with a format DM Realm would have to follow release by release, to save the DM a few minutes of fitting a grid they want to check by eye anyway.

The integration DM Realm does take on is in the Workspace and the Session: MapForge reading the Workspace's stat blocks and party, and a Session's Live Notes taking in MapForge's Table Record.

## Prior requests

- [#22 MapForge Integration](https://trello.com/c/EBKJEvs9/22-mapforge-integration) — direction 4 of its triage, "imported Adventure maps go straight into MapForge, with the grid already set"
