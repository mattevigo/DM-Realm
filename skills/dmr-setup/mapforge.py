#!/usr/bin/env python3
"""What MapForge's Bestiary reads of a DM Realm Workspace (ADR 0011).

  mapforge.py report <workspace>
  mapforge.py set-bestiary <workspace> <folder>

MapForge, the DM's table app, owns `.mapforge/`. Its Bestiary is every note with
a ```statblock fence and a `name` under the one folder `.mapforge/config.json`
names in `bestiaryStatBlockPath`, relative to the Workspace root; it does not
honour `bestiary: false`, and skips a `name` it has already read.

report reads and never writes. It prints one JSON object:
  mapforge        false when there is no .mapforge/ (and nothing else)
  config          ok | missing (no config.json) | invalid (not a JSON object)
                  | no-key | outside (empty, absolute or leaving the Workspace)
                  | not-found (no such folder)
  path            the folder, normalised ("." is the root), when there is a key
  read            Monsters MapForge lists (one per name, in path order)
  scopes          per Scope that holds bestiary statistics — reference,
                  adventures, homebrew, campaigns, characters:
                  {folder, reads: all|part|none, missed}; missed counts the
                  monster and NPC stat blocks outside the folder (never a
                  Character's, which is not a Monster)
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
import json
import os
import re
import sys

KEYS = ["reference", "adventures", "homebrew", "world", "characters", "campaigns", "dm_tools", "templates"]
DEFAULTS = {"reference": "Reference", "adventures": "Adventures", "homebrew": "Homebrew", "world": "World",
            "characters": "Characters", "campaigns": "Campaigns", "dm_tools": "DM_Tools", "templates": "Templates"}
BESTIARY_SCOPES = ["reference", "adventures", "homebrew", "campaigns", "characters"]
KEY = "bestiaryStatBlockPath"


def fail(code, message):
    print(f"mapforge: {message}", file=sys.stderr)
    return code


def config_names(workspace):
    with open(os.path.join(workspace, "workspace-config.yml"), encoding="utf-8") as f:
        text = f.read()
    names = {}
    for key in KEYS:
        m = re.search(rf"^[ \t]*{key}:[ \t]*(.*)$", text, re.M)
        value = re.sub(r"(^|\s)#.*$", "", m.group(1)).strip().strip("\"'") if m else ""
        names[key] = value or DEFAULTS[key]
    return names


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
    """(state, config): missing, invalid or ok."""
    path = os.path.join(workspace, ".mapforge", "config.json")
    if not os.path.isfile(path):
        return "missing", None
    try:
        with open(path, encoding="utf-8") as f:
            config = json.load(f)
    except (ValueError, OSError):
        return "invalid", None
    return ("ok", config) if isinstance(config, dict) else ("invalid", None)


def first_fence(text):
    """(name, kept_out) of the note's first ```statblock fence, or None without one."""
    lines = text.replace("\r\n", "\n").split("\n")
    body, inside = [], False
    for line in lines:
        if not inside and line.strip().startswith("```statblock"):
            inside = True
        elif inside and line.strip().startswith("```"):
            break
        elif inside:
            body.append(line)
    if not inside:
        return None
    fence = "\n".join(body)
    m = re.search(r"^name:[ \t]*(.+?)[ \t]*$", fence, re.M)
    name = m.group(1).strip("\"'") if m else ""
    kept_out = re.search(r"^bestiary:[ \t]*false[ \t]*$", fence, re.M) is not None
    return name, kept_out


def fences(workspace):
    """Every note with a named fence, as (relative path, name, kept_out), in path order."""
    found = []
    for dirpath, dirnames, filenames in os.walk(workspace):
        dirnames[:] = [d for d in dirnames if not d.startswith(".")]
        for filename in filenames:
            if not filename.lower().endswith(".md"):
                continue
            path = os.path.join(dirpath, filename)
            try:
                with open(path, encoding="utf-8") as f:
                    fence = first_fence(f.read())
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
    if KEY not in config:
        out["config"] = "no-key"
        return out
    folder = resolve(workspace, str(config[KEY]))
    if folder is None:
        out["config"] = "outside"
        return out
    out["path"] = folder
    if not os.path.isdir(os.path.join(workspace, folder)):
        out["config"] = "not-found"
        return out

    names = config_names(workspace)
    scope_of = {names[key]: key for key in BESTIARY_SCOPES}
    scopes = {}
    for key in BESTIARY_SCOPES:
        top = names[key]
        reads = "all" if inside(top, folder) else "part" if folder.startswith(top + "/") else "none"
        scopes[key] = {"folder": top, "reads": reads, "missed": 0}

    read, characters_read, kept_out_read = set(), 0, 0
    for rel, name, kept_out in fences(workspace):
        key = scope_of.get(rel.split("/", 1)[0])
        if inside(rel, folder):
            read.add(name)
            if kept_out:
                kept_out_read += 1
            elif key == "characters":
                characters_read += 1
        elif key and key != "characters" and not kept_out:
            scopes[key]["missed"] += 1
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
        return fail(2, ".mapforge/config.json is not a JSON object; nothing changed")
    config = config or {}
    config[KEY] = rel
    support = os.path.join(workspace, ".mapforge")
    os.makedirs(support, exist_ok=True)
    path = os.path.join(support, "config.json")
    with open(path + ".tmp", "w", encoding="utf-8") as f:
        f.write(json.dumps(config, indent=4, ensure_ascii=False) + "\n")
    os.replace(path + ".tmp", path)
    print(f"mapforge: {KEY} set to '{rel}' in .mapforge/config.json")
    return 0


def main(argv):
    if len(argv) == 3 and argv[1] == "report":
        workspace = argv[2]
        if not os.path.isfile(os.path.join(workspace, "workspace-config.yml")):
            return fail(2, f"{workspace} is not a Workspace (no workspace-config.yml)")
        print(json.dumps(report(workspace), ensure_ascii=False))
        return 0
    if len(argv) == 4 and argv[1] == "set-bestiary":
        if not os.path.isfile(os.path.join(argv[2], "workspace-config.yml")):
            return fail(2, f"{argv[2]} is not a Workspace (no workspace-config.yml)")
        return set_bestiary(argv[2], argv[3])
    print(__doc__, file=sys.stderr)
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv))
