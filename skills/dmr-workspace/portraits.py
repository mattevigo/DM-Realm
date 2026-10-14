#!/usr/bin/env python3
"""Give every stat block whose note embeds its own picture its Portrait.

  portraits.py <workspace>

A monster's or an NPC's statistics name its Portrait — the first picture of its
Description, the one MapForge cuts a Pawn's Face from — as `image:` with the picture's
full path from the Workspace root (structure.md's "The Portrait"). For every note with
statistics (a ```statblock fence, or Markdown from its `%% statblock` comment) that names
none, this adds the line an Import writes today: `image: "[[Riferimento/Allegati/X.webp]]"`.

The note's own picture is the first one it embeds before its statistics whose file is
named after the note, as an Import names it: `<note>.<ext>` or `<note>_01.<ext>` (png,
jpg, jpeg or webp). A picture under the statistics (an action's) is never the Portrait,
nor one named otherwise (a map, the DM's own picture): those notes are not listed. An
`image:` already there is the DM's choice and stays as it is; a Character's stat block
is left as it is. The picture is found as MapForge finds it: by its path, or a path's
end, among the Workspace's files outside hidden folders, ignoring case.

Prints a JSON report: `added` (note and the `image:` it now names) and `skipped` (note
and why: no file by that name, or several). Exit 2 when <workspace> is not a Workspace.
"""
import importlib.util
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
_spec = importlib.util.spec_from_file_location("statblock", os.path.join(HERE, "statblock.py"))
statblock = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(statblock)

CONFIG = "workspace-config.yml"
PICTURES = (".png", ".jpg", ".jpeg", ".webp")
EMBED = re.compile(r"!\[\[([^\]|#]+)(?:[|#][^\]]*)?\]\]")
COMMENT = re.compile(r"^%% statblock[ \t]*\n(.*?)^%%[ \t]*$", re.S | re.M)
KEY = re.compile(r"^([A-Za-z_]+):")


def files(workspace):
    """Every file's path from the Workspace root, outside hidden folders."""
    found = []
    for root, dirs, names in os.walk(workspace):
        dirs[:] = sorted(d for d in dirs if not d.startswith("."))
        rel = os.path.relpath(root, workspace)
        found += [n if rel == "." else f"{rel}/{n}".replace(os.sep, "/") for n in sorted(names)]
    return found


def statistics(text):
    """(start of the statistics' lines, their end) for the fence, or else the Markdown comment."""
    m = statblock.FENCE.search(text) or COMMENT.search(text)
    return (m.start(1), m.end(1)) if m else None


def own_picture(text, before, stem):
    """The note's own picture, as it embeds it, among its embeds before its statistics."""
    names = {f"{stem}{suffix}".casefold() for suffix in ("", "_01")}
    for m in EMBED.finditer(text, 0, before):
        target = m.group(1).strip()
        base, ext = os.path.splitext(target.rsplit("/", 1)[-1])
        if ext.lower() in PICTURES and base.casefold() in names:
            return target
    return None


def resolve(target, paths):
    """The paths a link names, as MapForge reads it: the whole path or its end."""
    wanted = target.casefold()
    return [p for p in paths if p.casefold() == wanted or p.casefold().endswith("/" + wanted)]


def key_of(line):
    """A stat block line's top-level key, or None."""
    m = KEY.match(line)
    return m.group(1) if m else None


def with_line(text, start, end, line):
    """The statistics with the Portrait's line in its place among their keys."""
    lines = text[start:end].split("\n")
    at = statblock.portrait_at([key_of(l) for l in lines])
    return text[:start] + "\n".join(lines[:at] + [line] + lines[at:]) + text[end:]


def main(argv):
    if len(argv) != 2:
        print(__doc__, file=sys.stderr)
        return 2
    workspace = argv[1]
    if not os.path.isfile(os.path.join(workspace, CONFIG)):
        print(f"portraits: {workspace} is not a DM Realm Workspace; nothing was changed.", file=sys.stderr)
        return 2
    paths = files(workspace)
    report = {"added": [], "skipped": []}
    for shown in (p for p in paths if p.endswith(".md")):
        path = os.path.join(workspace, shown)
        with open(path, encoding="utf-8") as f:
            text = f.read()
        span = statistics(text)
        if not span:
            continue
        keys = {key_of(l): l for l in text[span[0]:span[1]].split("\n") if key_of(l)}
        if statblock.PORTRAIT in keys or statblock.CHARACTER_LAYOUT in keys.get("layout", ""):
            continue
        target = own_picture(text, span[0], os.path.splitext(os.path.basename(shown))[0])
        if not target:
            continue
        found = resolve(target, paths)
        if len(found) != 1:
            why = f"no file is named {target}" if not found else \
                f"several files are named {target}: {', '.join(found)}"
            report["skipped"].append({"note": shown, "why": why})
            continue
        link = f"[[{found[0]}]]"
        with open(path, "w", encoding="utf-8") as f:
            f.write(with_line(text, *span, f"{statblock.PORTRAIT}: {statblock.yaml_scalar(link)}"))
        report["added"].append({"note": shown, "image": link})
    print(json.dumps(report, indent=2, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
