#!/usr/bin/env python3
"""Fantasy Statblocks settings for a DM Realm Workspace.

  statblocks-settings.py labels
      Print the English labels of DM Realm's layouts, one per line: the words the
      stat blocks show (Armor Class, STR, Actions…), for translation.

  statblocks-settings.py merge <workspace> <edition> [--labels <file> | --labels -]
      Merge into <workspace>/.obsidian/plugins/obsidian-5e-statblocks/data.json:
      DM Realm's three layouts (statblock-layouts/, next to this file), replacing
      any layout of the same name or id, with their labels translated; the default
      layout, the Edition's monster layout (2014 or 2024); disableSRD, autoParse,
      and paths ["/"]. Every other setting and the DM's own layouts stay as they
      are, and a file already right is not rewritten; prints what it set.
      --labels is a JSON object mapping every English label to its translation
      (`-` reads it from standard input); without it the labels stay English.
      Each layout it writes carries its revision (dmRealmRevision): a hash of the
      layout as DM Realm ships it, before translation.
      Exit 3, touching nothing, when the plugin is not installed (no plugin folder).
      Exit 2, touching nothing, when data.json or the labels are not valid JSON,
      a label has no translation, or the edition is not 2014 or 2024.
      Exit 5, touching nothing, when data.json needs a change and Obsidian is
      running: the plugin rewrites data.json from memory, so the change would be lost.

  statblocks-settings.py check <workspace>
      Whether the plugin has the layouts this DM Realm ships: exit 0 when all three
      are there at the current revision; exit 4 when one is missing or older (it
      says which); exit 3 when the plugin is not installed; exit 2 when data.json
      is not valid JSON. Writes nothing.

Layout names are stable and never translated: a fence's `layout:` names one of them.
"""
import hashlib
import json
import os
import re
import subprocess
import sys

LAYOUTS_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "statblock-layouts")
LAYOUT_FILES = ("character.json", "monster-2014.json", "monster-2024.json")
MONSTER_LAYOUT = {"2014": "dm-realm-monster-2014", "2024": "dm-realm-monster-2024"}
PLUGIN = os.path.join(".obsidian", "plugins", "obsidian-5e-statblocks")
# A label inside a callback or JavaScript block: t("Label"), replaced by its translation.
CODE_LABEL = re.compile(r'(?<![\w.$])t\("((?:[^"\\]|\\.)*)"\)')
CODE_FIELDS = ("callback", "code")


class Refused(Exception):
    pass


def layouts():
    out = []
    for name in LAYOUT_FILES:
        with open(os.path.join(LAYOUTS_DIR, name), encoding="utf-8") as f:
            out.append(json.load(f))
    return out


def revision(layout):
    """The layout as DM Realm ships it, before translation, as a short hash."""
    return hashlib.sha256(json.dumps(layout, sort_keys=True).encode("utf-8")).hexdigest()[:12]


def obsidian_running():
    # Evals only (their sandbox would see the developer's own Obsidian): 1 running, 0 not.
    if os.environ.get("EVAL_DMR_OBSIDIAN_RUNNING") in ("0", "1"):
        return os.environ["EVAL_DMR_OBSIDIAN_RUNNING"] == "1"
    for name in ("Obsidian", "obsidian"):
        try:
            if subprocess.run(["pgrep", "-x", name], stdout=subprocess.DEVNULL,
                              stderr=subprocess.DEVNULL).returncode == 0:
                return True
        except OSError:  # no pgrep: cannot tell
            return False
    return False


def installed(workspace):
    """The plugin's settings in the Workspace ({} before its first save), or None without the plugin."""
    folder = os.path.join(workspace, PLUGIN)
    if not os.path.isdir(folder):
        return None
    path = os.path.join(folder, "data.json")
    try:
        with open(path, encoding="utf-8") as f:
            current = json.load(f)
    except FileNotFoundError:
        return {}
    except ValueError as e:
        raise Refused(f"{path} is not valid JSON ({e}); nothing was changed.")
    if not isinstance(current, dict):
        raise Refused(f"{path} does not hold the plugin's settings; nothing was changed.")
    return current


NOT_INSTALLED = ("Fantasy Statblocks is not installed in this Workspace "
                 "(no .obsidian/plugins/obsidian-5e-statblocks/); nothing was changed.")


def check(workspace):
    current = installed(workspace)
    if current is None:
        print(NOT_INSTALLED, file=sys.stderr)
        return 3
    have = {l.get("name"): l for l in current.get("layouts") or [] if isinstance(l, dict)}
    missing, older = [], []
    for layout in layouts():
        mine = have.get(layout["name"])
        if mine is None:
            missing.append(layout["name"])
        elif mine.get("dmRealmRevision") != revision(layout):
            older.append(layout["name"])
    if missing:
        print(f"Fantasy Statblocks lacks DM Realm's layouts: {', '.join(missing)}.")
    if older:
        print(f"Fantasy Statblocks has an older version of DM Realm's layouts: {', '.join(older)}.")
    if missing or older:
        return 4
    print("Fantasy Statblocks has DM Realm's current layouts.")
    return 0


def blocks(items):
    for block in items:
        yield block
        yield from blocks(block.get("nested", []))


def relabel(layout, word):
    """Every label of the layout passed through word(label): displays, headings, table
    headers and the t("…") labels in its code. Returns the layout, changed in place."""
    for block in blocks(layout["blocks"]):
        for field in ("display", "heading"):
            if isinstance(block.get(field), str) and block[field].strip():
                block[field] = word(block[field])
        if "headers" in block:
            block["headers"] = [word(h) for h in block["headers"]]
        for field in CODE_FIELDS:
            if block.get(field):
                block[field] = CODE_LABEL.sub(
                    lambda m: json.dumps(word(json.loads(f'"{m.group(1)}"')), ensure_ascii=False), block[field])
    return layout


def all_labels():
    seen = []

    def record(label):
        if label not in seen:
            seen.append(label)
        return label

    for layout in layouts():
        relabel(layout, record)
    return seen


def read_labels(source):
    try:
        if source == "-":
            words = json.load(sys.stdin)
        else:
            with open(source, encoding="utf-8") as f:
                words = json.load(f)
    except (OSError, ValueError) as e:
        raise Refused(f"the labels are not a readable JSON object ({e}).")
    if not isinstance(words, dict) or not all(isinstance(v, str) and v.strip() for v in words.values()):
        raise Refused("the labels must be a JSON object of English label to translation.")
    missing = [label for label in all_labels() if label not in words]
    if missing:
        raise Refused(f"no translation for: {', '.join(missing)}.")
    return words


def merge(workspace, edition, labels_source=None):
    if edition not in MONSTER_LAYOUT:
        raise Refused(f"the edition must be 2014 or 2024, not '{edition}'.")
    current = installed(workspace)
    if current is None:
        print(NOT_INSTALLED, file=sys.stderr)
        return 3
    words = read_labels(labels_source) if labels_source else {}
    path = os.path.join(workspace, PLUGIN, "data.json")

    data = json.loads(json.dumps(current))
    ours = []
    for layout in layouts():
        stamp = revision(layout)
        ours.append(dict(relabel(layout, lambda label: words.get(label, label)), dmRealmRevision=stamp))
    names = {layout["name"] for layout in ours}

    def ours_for(layout):
        """DM Realm's layout this one is a copy of, by name — or by id, so no two share one."""
        return next((o for o in ours if layout.get("name") == o["name"] or layout.get("id") == o["id"]), None)

    existing = [l for l in data.get("layouts") or [] if isinstance(l, dict)]
    merged, placed = [], set()
    for layout in existing:
        mine = ours_for(layout)
        if mine is None:
            merged.append(layout)
        elif mine["name"] not in placed:  # replaced in place
            merged.append(mine)
            placed.add(mine["name"])
    merged.extend(o for o in ours if o["name"] not in placed)
    data.update({"layouts": merged, "default": MONSTER_LAYOUT[edition],
                 "disableSRD": True, "autoParse": True, "paths": ["/"]})

    if data == current and os.path.exists(path):
        print("Fantasy Statblocks already as DM Realm needs it; nothing changed.")
        return 0
    if obsidian_running():
        print("statblocks-settings: Obsidian is running, and Fantasy Statblocks would overwrite data.json "
              "from memory; close Obsidian and run this again. Nothing was changed.", file=sys.stderr)
        return 5
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        f.write("\n")
    print(f"Fantasy Statblocks set in {os.path.join(PLUGIN, 'data.json')}: layouts "
          f"{', '.join(sorted(names))}; default layout for {edition}; bundled SRD off; "
          f"stat blocks read from every folder.")
    return 0


def main(argv):
    try:
        if argv[1:] == ["labels"]:
            print("\n".join(all_labels()))
            return 0
        if len(argv) == 3 and argv[1] == "check":
            return check(argv[2])
        if len(argv) == 4 and argv[1] == "merge":
            return merge(argv[2], argv[3])
        if len(argv) == 6 and argv[1] == "merge" and argv[4] == "--labels":
            return merge(argv[2], argv[3], argv[5])
    except Refused as e:
        print(f"statblocks-settings: {e}", file=sys.stderr)
        return 2
    print(__doc__, file=sys.stderr)
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv))
