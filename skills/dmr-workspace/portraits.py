#!/usr/bin/env python3
"""Give every stat block, and every item note, whose note embeds its own picture its Portrait,
and every item note `item: true`.

  portraits.py <workspace>

A monster's or an NPC's statistics name its Portrait — the first picture of its
Description, the one MapForge cuts a Pawn's Face from — as `image:` with the picture's
full path from the Workspace root (structure.md's "The Portrait"). For every note with
statistics (a ```statblock fence, or Markdown from its `%% statblock` comment) that names
none, this adds the line an Import writes today: `image: "[[Riferimento/Allegati/X.webp]]"`.

An item note says so, and names its Portrait, in its frontmatter: `item: true` and
`image: "[[Riferimento/Allegati/Borsa.webp]]"`, after the keys already there (a
frontmatter block is made when the note has none). Item notes are every note in
Reference's and Homebrew's Equipment (not its Weapon_Masteries) and Magic_Items, each
Adventure's Items, and each Campaign's Homebrew_Equipment (not its Weapon_Masteries) and
Homebrew_Magic_Items, and no other: no Spells, no NPCs. The folders are named by the
Workspace Config and the Translation Glossary, as spell-index.py finds the Spells folder.
Every item note gets `item: true`, picture or not.

The note's own picture is a file named after the note, as an Import names it (png, jpg,
jpeg or webp). A stat block's is the first one it embeds before its statistics named
`<note>.<ext>` or `<note>_01.<ext>`. An item's is the first one its Description section
embeds named `<note>.<ext>` or `<note>_NN.<ext>`: an Import numbers a note's pictures in
order, so a picture in the item's own text, above its Description, can take `_01`. The
Description is the section under the heading an Import gives it — the Translation
Glossary's row for Description, else `Description` — up to the next heading of its level
or above. An item note with no Description section names no Portrait and is not listed,
as an Import of an entry with no description names none. A stat block's picture under its
statistics (an action's) is never the Portrait, nor an item's outside its Description,
nor one named otherwise (a map, the DM's own picture): those notes are not listed. An
`image:` already there is the DM's choice and stays as it is; a Character's stat block is
left as it is. The picture is found as MapForge finds it: by its path, or a path's end,
among the Workspace's files outside hidden folders, ignoring case.

Prints a JSON report. For stat blocks: `added` (note and the `image:` it now names) and
`skipped` (note and why: no file by that name, or several). For item notes, under
`items`: `added` (note, and `item: true` and/or the `image:` it now names, whichever this
run wrote) and `skipped` (note and why its Portrait was not written; it still became an
item). A second run adds nothing. Exit 2 when <workspace> is not a Workspace.
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
_spec = importlib.util.spec_from_file_location("spell_index", os.path.join(HERE, "spell-index.py"))
spell_index = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(spell_index)

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


def own_picture(text, start, end, stem, numbered=False):
    """The note's own picture, as it embeds it, among its embeds from `start` to `end`:
    `<note>` or `<note>_01`, or with `numbered` any `<note>_NN`."""
    names = {f"{stem}{suffix}".casefold() for suffix in ("", "_01")}
    number = re.compile(re.escape(stem.casefold()) + r"_\d{2,}")
    for m in EMBED.finditer(text, start, end):
        target = m.group(1).strip()
        base, ext = os.path.splitext(target.rsplit("/", 1)[-1])
        if ext.lower() in PICTURES and (base.casefold() in names
                                        or numbered and number.fullmatch(base.casefold())):
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


ITEM = "item"
FRONTMATTER = re.compile(r"\A---[ \t]*\n(.*?)^---[ \t]*$", re.S | re.M)
HEADING = re.compile(r"^(#{1,6})[ \t]+(.*?)[ \t#]*$", re.M)


def term(terms, english):
    """A term's Translation Glossary row (`Magic Items` or `Magic_Items`), or None."""
    return terms.get(english) or terms.get(english.replace(" ", "_"))


def subfolder(workspace, parent, english, terms):
    """`parent`'s subfolder named by a term (its Translation Glossary row, else the English), or None."""
    for name in (term(terms, english), english):
        if name and os.path.isdir(os.path.join(workspace, parent, spell_index.file_stem(name))):
            return f"{parent}/{spell_index.file_stem(name)}"
    return None


def subfolders(workspace, parent):
    """`parent`'s subfolders, outside hidden ones."""
    path = os.path.join(workspace, parent)
    return sorted(f"{parent}/{d}" for d in os.listdir(path)
                  if os.path.isdir(os.path.join(path, d)) and not d.startswith("."))


def item_folders(workspace):
    """The folders of item notes, from the Workspace root: (folder, its Weapon_Masteries folder or None).

    Reference's and Homebrew's Equipment and Magic_Items, each Adventure's Items, and each
    Campaign's Homebrew_Equipment and Homebrew_Magic_Items; never a Weapon_Masteries folder.
    """
    terms = spell_index.glossary(workspace)
    top = {key: spell_index.folder(workspace, key) for key in ("reference", "homebrew", "adventures", "campaigns")}
    found = []

    def add(folder):
        if folder:
            found.append((folder, subfolder(workspace, folder, "Weapon Masteries", terms)))

    for key in ("reference", "homebrew"):
        if top[key] and os.path.isdir(os.path.join(workspace, top[key])):
            add(subfolder(workspace, top[key], "Equipment", terms))
            add(subfolder(workspace, top[key], "Magic Items", terms))
    if top["adventures"] and os.path.isdir(os.path.join(workspace, top["adventures"])):
        for adventure in subfolders(workspace, top["adventures"]):
            add(subfolder(workspace, adventure, "Items", terms))
    if top["campaigns"] and top["homebrew"] and os.path.isdir(os.path.join(workspace, top["campaigns"])):
        prefixed = {f"{top['homebrew']}_{spell_index.file_stem(name)}"
                    for t in ("Equipment", "Magic Items") for name in (term(terms, t) or t, t)}
        for campaign in subfolders(workspace, top["campaigns"]):
            for path in subfolders(workspace, campaign):
                if path.rsplit("/", 1)[-1] in prefixed:
                    add(path)
    return found


def item_notes(workspace):
    """Every item note's path from the Workspace root."""
    for folder, masteries in item_folders(workspace):
        for root, dirs, names in os.walk(os.path.join(workspace, folder)):
            rel = os.path.relpath(root, workspace).replace(os.sep, "/")
            dirs[:] = sorted(d for d in dirs if not d.startswith(".") and f"{rel}/{d}" != masteries)
            yield from (f"{rel}/{n}" for n in sorted(names) if n.endswith(".md"))


def with_frontmatter(text, lines):
    """The note with these lines at the end of its frontmatter, made when it has none."""
    m = FRONTMATTER.match(text)
    if not m:
        return "---\n" + "".join(l + "\n" for l in lines) + "---\n" + ("" if text.startswith("\n") else "\n") + text
    return text[:m.end(1)] + "".join(l + "\n" for l in lines) + text[m.end(1):]


def description(text, terms):
    """(start, end) of the note's Description section — its heading named as an Import names
    it, the Translation Glossary's row or else the English — up to the next heading of its
    level or above; None when it has none."""
    names = {n.casefold() for n in (term(terms, "Description"), "Description") if n}
    front = FRONTMATTER.match(text)
    headings = list(HEADING.finditer(text, front.end() if front else 0))
    for i, m in enumerate(headings):
        if m.group(2).casefold() in names:
            level = len(m.group(1))
            end = next((h.start() for h in headings[i + 1:] if len(h.group(1)) <= level), len(text))
            return m.end(), end
    return None


def portrait(text, span, shown, paths, numbered=False):
    """(the Portrait's link, None) for a note's own picture embedded in `span`;
    (None, why) when no file or several have its name; (None, None) when it has none."""
    target = own_picture(text, *span, os.path.splitext(os.path.basename(shown))[0], numbered)
    if not target:
        return None, None
    found = resolve(target, paths)
    if len(found) == 1:
        return f"[[{found[0]}]]", None
    return None, (f"no file is named {target}" if not found else
                  f"several files are named {target}: {', '.join(found)}")


def stat_blocks(workspace, paths):
    """Give every stat block whose note embeds its own picture its Portrait; their report."""
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
        link, why = portrait(text, (0, span[0]), shown, paths)
        if why:
            report["skipped"].append({"note": shown, "why": why})
        if not link:
            continue
        with open(path, "w", encoding="utf-8") as f:
            f.write(with_line(text, *span, f"{statblock.PORTRAIT}: {statblock.yaml_scalar(link)}"))
        report["added"].append({"note": shown, "image": link})
    return report


def items(workspace, paths):
    """Give every item note `item: true`, and its Portrait when its Description embeds its own
    picture; their report."""
    report = {"added": [], "skipped": []}
    terms = spell_index.glossary(workspace)
    for shown in item_notes(workspace):
        path = os.path.join(workspace, shown)
        with open(path, encoding="utf-8") as f:
            text = f.read()
        m = FRONTMATTER.match(text)
        keys = {key_of(l) for l in m.group(1).split("\n")} if m else set()
        added = {}
        if ITEM not in keys:
            added[ITEM] = True
        span = description(text, terms)
        if statblock.PORTRAIT not in keys and span:  # no Description, no Portrait
            link, why = portrait(text, span, shown, paths, numbered=True)
            if why:
                report["skipped"].append({"note": shown, "why": why})
            if link:
                added[statblock.PORTRAIT] = link
        if not added:
            continue
        lines = [f"{ITEM}: true"] if ITEM in added else []
        if statblock.PORTRAIT in added:
            lines.append(f"{statblock.PORTRAIT}: {statblock.yaml_scalar(added[statblock.PORTRAIT])}")
        with open(path, "w", encoding="utf-8") as f:
            f.write(with_frontmatter(text, lines))
        report["added"].append({"note": shown, **added})
    return report


def main(argv):
    if len(argv) != 2:
        print(__doc__, file=sys.stderr)
        return 2
    workspace = argv[1]
    if not os.path.isfile(os.path.join(workspace, CONFIG)):
        print(f"portraits: {workspace} is not a DM Realm Workspace; nothing was changed.", file=sys.stderr)
        return 2
    paths = files(workspace)
    report = stat_blocks(workspace, paths)
    report["items"] = items(workspace, paths)
    print(json.dumps(report, indent=2, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
