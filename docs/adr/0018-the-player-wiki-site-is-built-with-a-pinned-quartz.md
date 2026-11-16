# The Player Wiki site is built with a pinned Quartz, and published by the DM

When the DM chooses it at Setup (`quartz: true`), DM Realm builds the Player Wiki as a static website with Quartz. The release DM Realm uses is pinned, kept once per machine in the plugin's data like the Source Cache, and downloaded at the first build. DM Realm writes Quartz's configuration at every build. It stops at the folder of HTML: where the site goes, who can read it and how is the DM's choice and responsibility.

## Why

- **The DM gets something they can upload.** Without a built site, a DM who has never heard of Quartz cannot use the Markdown wiki: they would have to install and configure Quartz themselves.
- **A pinned release does not break under the DM.** Quartz changes fast: v5 moved its configuration from TypeScript to YAML. With a pinned release, an update of Quartz cannot break a wiki that built yesterday.
- **DM Realm owns the configuration** because each of its settings protects the players or the DM:
  - no analytics, and no fonts or formulas from a CDN, so no reader is tracked;
  - only the files the notes use go out;
  - no social images, no CNAME.
- **Hosting stays the DM's.** Hosts, access control and domains vary too much, and each needs the DM's own accounts. Publishing the Reference's official text is also a decision only the DM can take and answer for.

## Considered Options

- **A Quartz project the DM builds.** Rejected: the DM would still have to install Node, run the build and keep the configuration right.
- **Only a documented configuration.** Rejected for the same reason.
- **Quartz in the Workspace, or copied per Workspace.** Rejected:
  - a Workspace holds only notes and the Workspace Config (ADR 0002);
  - a copy per Workspace would mean one `node_modules` each.
- **The latest Quartz at every build.** Rejected: a release could change the configuration or the output under the DM.
- **Hosting and access control** (Cloudflare Pages or Workers with Access, GitHub Pages, Quartz's EncryptedPages). Left to the DM.
- **An SRD-only mode for a public site.** Dropped with them.

## Consequences

- **Node 22 or later becomes a requirement**, and only for the DM who wants the site. Setup checks for it and says how to install it. An update without Node still writes the Markdown wiki.
- **The first build needs the network** (GitHub and npm). Later builds do not.
- **Quartz's configuration is rewritten at every build**, so a DM's own edits to it are lost. Themes are not a DM Realm setting.
- **Moving to a new Quartz release is a DM Realm release.** It has to pass `tests/player-wiki-site.test.sh`, whose real build runs when Quartz is installed. If the pinned release's default configuration lacks a line DM Realm sets, the build stops (exit 6) and changes nothing.
- **A failed build leaves the previous site as it was.** The site is built in a temporary folder beside it.
- **The helper runs npm and Node inside one `python3` call.** The skill needs one permission rule, not three. A permission classifier that refuses the call leaves the DM with the command to run by hand.
