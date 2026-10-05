#!/usr/bin/env python3
"""What MapForge's bestiary reads of a DM Realm Workspace (ADR 0011).

  mapforge.py report <workspace>
  mapforge.py set-bestiary <workspace> <folder>

MapForge, the DM's table tool, owns `.mapforge/`. Its bestiary is every note
with a closed ```statblock fence and a `name` under the one folder that
`.mapforge/config.json` names in `bestiaryStatBlockPath`, relative to the
Workspace root, hidden folders included; it does not honour `bestiary: false`,
and skips a `name` it has already read.

report reads and never writes. It prints one JSON object:
  mapforge        false when there is no .mapforge/ (and nothing else)
  config          ok | missing (no config.json) | invalid (not a JSON object,
                  or the key not a string) | no-key | outside (empty, absolute
                  or leaving the Workspace) | not-found (no such folder)
  path            the folder, normalised ("." is the root), when there is one
  read            Monsters MapForge lists (one per name)
  scopes          per Scope that holds bestiary statistics — reference,
                  adventures, homebrew, campaigns, characters:
                  {folder, reads: all|part|none, missed, missed_in}; missed
                  counts the monster and NPC stat blocks outside the folder
                  (never a Character's, which is not a Monster), and
                  missed_in splits them by the Scope's subfolder (an
                  Adventure, a Campaign, Monsters…; "" for a note directly in it)
  characters_read Characters' stat blocks inside the folder, read as Monsters
  kept_out_read   fences with `bestiary: false` inside the folder (a
                  Character's past Builds, the Homebrew monster Template)
Exit 2: not a Workspace (no workspace-config.yml).

set-bestiary is for when the DM asks for it, and only then. It merges
`bestiaryStatBlockPath` into .mapforge/config.json, creating the file when
absent, keeping every other key, and writes nothing else (never the Manifest:
MapForge writes it when it adopts the folder, and keeps the config).
Exit 2: the folder is empty, absolute or outside the Workspace, or
config.json is not a JSON object (nothing changed). Exit 3: no such folder.
"""
import importlib.util
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))


def module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    loaded = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(loaded)
    return loaded


folders = module("workspace_folders", os.path.join(HERE, "workspace-folders.py"))
statblock = module("statblock", os.path.join(HERE, "..", "dmr-workspace", "statblock.py"))

BESTIARY_SCOPES = ["reference", "adventures", "homebrew", "campaigns", "characters"]
CONFIG_KEY = "bestiaryStatBlockPath"
NAME = re.compile(r"^name:[ \t]*(.+?)[ \t]*$", re.M)
KEPT_OUT = re.compile(r"^bestiary:[ \t]*false[ \t]*$", re.M)


def fail(code, message):
    print(f"mapforge: {message}", file=sys.stderr)
    return code


def resolve(workspace, folder):
    """The folder relative to the Workspace root, normalised ("." for the root), or None when
    it is empty, absolute or would leave the Workspace — MapForge's own rule."""
    folder = folder.strip()
    if not folder or folder.startswith("/") or folder.startswith("~"):
        return None
    root = os.path.normpath(os.path.abspath(workspace))
    resolved = os.path.normpath(os.path.join(root, folder))
    if resolved != root and not resolved.startswith(root + os.sep):
        return None
    return os.path.relpath(resolved, root).replace(os.sep, "/")


def read_config(workspace):
    """(state, config): missing, invalid or ok. As MapForge decodes it, a key that is not a
    string makes the whole file unreadable, and a null one is no key."""
    path = os.path.join(workspace, ".mapforge", "config.json")
    if not os.path.isfile(path):
        return "missing", None
    try:
        with open(path, encoding="utf-8") as f:
            config = json.load(f)
    except (ValueError, OSError):
        return "invalid", None
    if not isinstance(config, dict) or not isinstance(config.get(CONFIG_KEY, ""), (str, type(None))):
        return "invalid", None
    return "ok", config


def note_fence(text):
    """(name, kept_out) of the note's first closed ```statblock fence, or None without one."""
    found = statblock.FENCE.search(text.replace("\r\n", "\n"))
    if not found:
        return None
    name = NAME.search(found.group(1))
    return (name.group(1).strip("\"'") if name else ""), KEPT_OUT.search(found.group(1)) is not None


def fences(workspace):
    """Every note with a named fence, as (relative path, name, kept_out), in path order —
    hidden folders included, as MapForge reads them."""
    found = []
    for dirpath, _, filenames in os.walk(workspace):
        for filename in filenames:
            if not filename.lower().endswith(".md"):
                continue
            path = os.path.join(dirpath, filename)
            try:
                with open(path, encoding="utf-8") as f:
                    fence = note_fence(f.read())
            except (UnicodeDecodeError, OSError):
                continue
            if fence and fence[0]:
                found.append((os.path.relpath(path, workspace).replace(os.sep, "/"), *fence))
    return sorted(found)


def inside(rel, folder):
    return folder == "." or rel == folder or rel.startswith(folder + "/")


def report(workspace):
    if not os.path.isdir(os.path.join(workspace, ".mapforge")):
        return {"mapforge": False}
    out = {"mapforge": True}
    state, config = read_config(workspace)
    out["config"] = state
    if state != "ok":
        return out
    if config.get(CONFIG_KEY) is None:
        out["config"] = "no-key"
        return out
    folder = resolve(workspace, config[CONFIG_KEY])
    if folder is None:
        out["config"] = "outside"
        return out
    out["path"] = folder
    if not os.path.isdir(os.path.join(workspace, folder)):
        out["config"] = "not-found"
        return out

    with open(os.path.join(workspace, "workspace-config.yml"), encoding="utf-8") as f:
        names = folders.config_names(f.read())
    scope_of, scopes = {}, {}
    for key in BESTIARY_SCOPES:
        top = names[key]
        if not top:
            continue
        scope_of[top] = key
        reads = "all" if inside(top, folder) else "part" if folder.startswith(top + "/") else "none"
        scopes[key] = {"folder": top, "reads": reads, "missed": 0, "missed_in": {}}

    read, characters_read, kept_out_read = set(), 0, 0
    for rel, name, kept_out in fences(workspace):
        parts = rel.split("/")
        key = scope_of.get(parts[0])
        if inside(rel, folder):
            read.add(name)
            if kept_out:
                kept_out_read += 1
            elif key == "characters":
                characters_read += 1
        elif key and key != "characters" and not kept_out:
            scope = scopes[key]
            scope["missed"] += 1
            sub = parts[1] if len(parts) > 2 else ""
            scope["missed_in"][sub] = scope["missed_in"].get(sub, 0) + 1
    out.update(read=len(read), scopes=scopes, characters_read=characters_read, kept_out_read=kept_out_read)
    return out


def set_bestiary(workspace, folder):
    rel = resolve(workspace, folder)
    if rel is None:
        return fail(2, f"'{folder}' must be a folder inside the Workspace, relative to its root")
    if not os.path.isdir(os.path.join(workspace, rel)):
        return fail(3, f"no folder '{rel}' in the Workspace")
    state, config = read_config(workspace)
    if state == "invalid":
        return fail(2, ".mapforge/config.json is not a JSON object MapForge can read; nothing changed")
    config = config or {}
    config[CONFIG_KEY] = rel
    support = os.path.join(workspace, ".mapforge")
    os.makedirs(support, exist_ok=True)
    path = os.path.join(support, "config.json")
    with open(path + ".tmp", "w", encoding="utf-8") as f:
        f.write(json.dumps(config, indent=4, ensure_ascii=False) + "\n")
    os.replace(path + ".tmp", path)
    print(f"mapforge: {CONFIG_KEY} set to '{rel}' in .mapforge/config.json")
    return 0


def main(argv):
    if len(argv) not in (3, 4) or argv[1:2] not in (["report"], ["set-bestiary"]) or (argv[1] == "report") != (len(argv) == 3):
        print(__doc__, file=sys.stderr)
        return 2
    workspace = argv[2]
    if not os.path.isfile(os.path.join(workspace, "workspace-config.yml")):
        return fail(2, f"{workspace} is not a Workspace (no workspace-config.yml)")
    if argv[1] == "report":
        print(json.dumps(report(workspace), ensure_ascii=False))
        return 0
    return set_bestiary(workspace, argv[3])


if __name__ == "__main__":
    sys.exit(main(sys.argv))
