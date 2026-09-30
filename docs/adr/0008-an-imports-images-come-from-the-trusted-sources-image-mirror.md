# An Import's images come from the Trusted Source's image mirror

An Import brings in every image the entry shows (a monster's picture, an Adventure's maps), fetched from 5etools' image mirror (`5etools-mirror-3/5etools-img`) at the same release as the data, and embeds each one in the note where the Trusted Source places it. The image mirror is tagged in step with the source mirror, and each entry names its images by path, so an image is as repeatable and checkable as the text: the Trusted Source becomes the data and its images at one release, and the Source Cache holds both. An image lives in the Workspace, in the Attachments folder of the Scope whose note embeds it (Reference › Attachments, or the Adventure's own), named after its note, and a re-import replaces it with the note. This amends [ADR 0003](0003-official-material-comes-only-from-5etools.md).

## Considered Options

- **No images** (the earlier rule). Rejected: an Adventure's maps are what a DM most needs from it, and leaving them out is not faithful to the entry.
- **Embed the mirror's URL instead of a file.** Rejected: it breaks offline, and it reaches the Trusted Source outside the Source Cache.
- **An image only when the DM asks.** Rejected: the files are small, and a faithful Import brings the whole entry.

## Consequences

- **Fetched one at a time**, like the data: the image mirror is several gigabytes, so it is never cloned.
- **Never shipped**: images, like the text, are fetched only on the DM's machine, never bundled with DM Realm or its evals.
