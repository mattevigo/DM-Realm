#!/bin/sh
# Starting state: a folder already opened in Obsidian, with no notes.
set -e
mkdir -p .obsidian
printf '{\n  "theme": "obsidian"\n}\n' > .obsidian/appearance.json
printf '{\n  "vimMode": true\n}\n' > .obsidian/app.json
printf '{\n  "graph": false\n}\n' > .obsidian/core-plugins.json
