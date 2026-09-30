#!/bin/sh
# Starting state: an English Workspace's folders and settings, with its Workspace Config gone.
set -e
. "$(dirname "$0")/../_fixtures/workspace-setup.sh"
rm workspace-config.yml
