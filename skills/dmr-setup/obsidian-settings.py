#!/usr/bin/env python3
"""Obsidian settings for a DM Realm Workspace.

  obsidian-settings.py merge <workspace> <templates-folder>
      Merge DM Realm's keys into <workspace>/.obsidian/ and leave every other
      setting as it is: wikilinks with the shortest-path format (app.json), the
      Templates core plugin on (core-plugins.json, always the object form) and the
      template folder (templates.json). Writes no other file.
      Exit 2, touching nothing, when an existing file is not valid JSON.

  obsidian-settings.py version
      Print "found X.Y.Z", "found X.Y.Z, older than 1.13.7" or "not found".
      The installed version is the higher of the installer version and the newest
      downloaded app package (obsidian-X.Y.Z.asar) in Obsidian's config folder.
      Never launches Obsidian; always exits 0.

Keys and detection: docs/research/obsidian-vault-setup.md (Obsidian 1.13.7).
DMR_OBSIDIAN_PLIST / DMR_OBSIDIAN_CONFIG override the install locations (tests).
"""
import json
import os
import plistlib
import re
import sys

BUILT_FOR = (1, 13, 7)

# Core plugins Obsidian turns on by default. In the legacy array form every unlisted
# plugin is off, so converting it to the object form sets these to false unless listed.
DEFAULT_ON = [
    "backlink", "bases", "bookmarks", "canvas", "command-palette", "daily-notes",
    "editor-status", "file-explorer", "file-recovery", "global-search", "graph",
    "note-composer", "outgoing-link", "outline", "page-preview", "properties",
    "switcher", "sync", "tag-pane", "templates", "word-count",
]


def load(path, default):
    if not os.path.exists(path):
        return default
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def merge(workspace, templates_folder):
    config = os.path.join(workspace, ".obsidian")
    paths = {name: os.path.join(config, name) for name in ("app.json", "core-plugins.json", "templates.json")}
    try:
        app = load(paths["app.json"], {})
        core = load(paths["core-plugins.json"], {})
        templates = load(paths["templates.json"], {})
    except ValueError as e:
        print(f"obsidian-settings: an Obsidian settings file is not valid JSON ({e}); nothing was changed.", file=sys.stderr)
        return 2

    app.update({"useMarkdownLinks": False, "newLinkFormat": "shortest"})
    if isinstance(core, list):
        listed = set(core)
        core = {plugin: True for plugin in core}
        core.update({plugin: False for plugin in DEFAULT_ON if plugin not in listed})
    core["templates"] = True
    templates["folder"] = templates_folder

    os.makedirs(config, exist_ok=True)
    for name, data in (("app.json", app), ("core-plugins.json", core), ("templates.json", templates)):
        with open(paths[name], "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2)
            f.write("\n")
    print("Obsidian settings merged: wikilinks, shortest-path links, Templates plugin on, "
          f"template folder '{templates_folder}'.")
    return 0


def parse(version):
    return tuple(int(part) for part in version.split("."))


def installer_version():
    home = os.path.expanduser("~")
    candidates = [os.environ["DMR_OBSIDIAN_PLIST"]] if "DMR_OBSIDIAN_PLIST" in os.environ else [
        "/Applications/Obsidian.app/Contents/Info.plist",
        os.path.join(home, "Applications/Obsidian.app/Contents/Info.plist"),
    ]
    for plist in candidates:
        try:
            with open(plist, "rb") as f:
                return parse(plistlib.load(f)["CFBundleShortVersionString"])
        except (OSError, KeyError, ValueError, plistlib.InvalidFileException):
            continue
    return None


def config_dirs():
    if "DMR_OBSIDIAN_CONFIG" in os.environ:
        return [os.environ["DMR_OBSIDIAN_CONFIG"]]
    home = os.path.expanduser("~")
    return [
        os.path.join(home, "Library/Application Support/obsidian"),  # macOS
        os.path.join(os.environ.get("XDG_CONFIG_HOME", os.path.join(home, ".config")), "obsidian"),  # Linux
        os.path.join(os.environ.get("APPDATA", ""), "obsidian") if os.environ.get("APPDATA") else "",  # Windows
    ]


def package_versions():
    for directory in config_dirs():
        try:
            names = os.listdir(directory)
        except OSError:
            continue
        for name in names:
            match = re.fullmatch(r"obsidian-(\d+\.\d+\.\d+)\.asar", name)
            if match:
                yield parse(match.group(1))


def version():
    found = [v for v in [installer_version(), *package_versions()] if v]
    if not found:
        print("not found")
        return 0
    best = max(found)
    text = ".".join(map(str, best))
    print(f"found {text}" if best >= BUILT_FOR else f"found {text}, older than {'.'.join(map(str, BUILT_FOR))}")
    return 0


def main(argv):
    if len(argv) == 4 and argv[1] == "merge":
        return merge(argv[2], argv[3])
    if len(argv) == 2 and argv[1] == "version":
        return version()
    print(__doc__, file=sys.stderr)
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv))
