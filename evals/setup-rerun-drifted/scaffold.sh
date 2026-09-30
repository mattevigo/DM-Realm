#!/bin/sh
# Starting state: an English 2024 Workspace set up by DM Realm, with one Campaign and a
# DM Tools note that links into it by path; Obsidian settings as Setup left them.
set -e
. "$(dirname "$0")/../_fixtures/workspace-setup.sh"
mkdir -p Campaigns/Heroes/Sessions DM_Tools/Checklists
printf '# Session 1\n\nThe party meets in Phandalin.\n' > Campaigns/Heroes/Sessions/Session_01.md
printf '# Prep\n\nLast time: [[Campaigns/Heroes/Sessions/Session_01|Session 1]].\nRecap: [Session 1](Campaigns/Heroes/Sessions/Session_01.md)\n' > DM_Tools/Checklists/Prep.md
# Drift: the DM switched to Markdown links, put attachments back in the vault folder and turned the
# Templates plugin off; vim mode and graph are the DM's own.
printf '{"useMarkdownLinks": true, "newLinkFormat": "shortest", "attachmentFolderPath": "/", "vimMode": true}\n' > .obsidian/app.json
printf '{"templates": false, "graph": false}\n' > .obsidian/core-plugins.json
