#!/usr/bin/env python3
"""The Spell Indexes of a DM Realm Workspace: Reference's spells, listed by level.

  spell-index.py rebuild <workspace>
      Write the Spell Indexes from the spell notes on disk, as structure.md's "Spell
      Indexes" defines them, all in Reference's Spells folder: one of every spell, named
      after that folder (Spells.md), and one per class (Spells_Wizard.md) of the spells
      whose note names the class in its Classes line. Each has a section per level folder
      (Cantrips first, then by number) linking to each note by name. A file already right
      is not rewritten; an index with no spell left is removed. Prints what it did.
      Exit 0 also when there is nothing to do (no Spells folder yet).
      Exit 2, touching nothing, when <workspace> has no workspace-config.yml.

  spell-index.py hook
      The same, as a PostToolUse hook: reads the hook's JSON on standard input, and
      rebuilds when the session's folder is a Workspace and the tool was Bash (which can
      move or delete anything) or wrote a file inside the Spells folder. Always exits 0;
      when an index changed, tells the agent so.

It names nothing itself: the Reference and DM Tools folders are the Workspace Config's,
the Spells folder and the Classes label are the Translation Glossary's rows for "Spells"
and "Classes" (in an English Workspace, those words), each level's heading is its folder's
name, and each class is named as the spell notes name it.
"""
import json
import os
import re
import sys
import unicodedata

CONFIG = "workspace-config.yml"


def folder(workspace, key):
    """A top-level folder's name, from the Workspace Config."""
    with open(os.path.join(workspace, CONFIG), encoding="utf-8") as f:
        for line in f:
            m = re.match(rf"\s+{key}:\s*(.*?)\s*(?:\s#.*)?$", line)
            if m:
                return m.group(1).strip("\"'")
    return None


def glossary(workspace):
    """The Translation Glossary's rows, English to translation ({} in an English Workspace)."""
    rows = {}
    tools = os.path.join(workspace, folder(workspace, "dm_tools") or "")
    if not os.path.isdir(tools) or os.path.realpath(tools) == os.path.realpath(workspace):
        return rows
    for name in sorted(os.listdir(tools)):  # the Glossary is a note at the root of DM Tools
        path = os.path.join(tools, name)
        if not name.endswith(".md") or not os.path.isfile(path):
            continue
        with open(path, encoding="utf-8", errors="replace") as f:
            for line in f:
                if not line.lstrip().startswith("|"):
                    continue
                cells = [c.strip() for c in line.strip().strip("|").split("|")]
                if len(cells) >= 2 and cells[0] and cells[1] and not set(cells[0]) <= set("-: "):
                    rows.setdefault(cells[0], cells[1])
    return rows


def spells_folder(workspace, terms=None):
    """Reference's Spells folder, or None when there is none yet."""
    reference = folder(workspace, "reference")
    if not reference:
        return None
    terms = glossary(workspace) if terms is None else terms
    for name in (terms.get("Spells"), "Spells"):
        path = os.path.join(workspace, reference, name or "")
        if name and os.path.isdir(path):
            return path
    return None


def level_folders(spells):
    """The level folders, Cantrips (the one without a number) first, then by number."""
    return sorted((d for d in os.listdir(spells) if os.path.isdir(os.path.join(spells, d))
                   and not d.startswith(".")), key=level_order)


def spell_notes(spells, level):
    """The spell notes of a level folder, as file names without `.md`."""
    return [n[:-3] for n in os.listdir(os.path.join(spells, level))
            if n.endswith(".md") and os.path.isfile(os.path.join(spells, level, n))]


def classes_line(label):
    """The line of a spell note naming its classes: `**Classes:** Sorcerer, Wizard`."""
    return re.compile(rf"^\*\*{re.escape(label)}:\*\*[ \t]*(.*?)[ \t]*$", re.M)


def classes(text, line):
    """The classes a spell note names, without a fallback term's `(EN: …)`."""
    found = line.findall(text)
    names = [re.sub(r"\s*\(EN:[^)]*\)", "", n).strip() for n in found[-1].split(",")] if found else []
    return [n for n in names if n]


def words(name):
    return name.replace("_", " ")


def sort_key(text):
    plain = unicodedata.normalize("NFKD", text)
    return "".join(c for c in plain if not unicodedata.combining(c)).casefold()


def level_order(name):
    number = re.search(r"\d+", name)
    return (1, int(number.group())) if number else (0, 0)


def file_stem(name):
    """A name as a file name, by structure.md's name rules."""
    kept = "".join(c for c in name if c not in '#^[]|\\/:*?"<>')
    return re.sub(r"[\s'’]+", "_", kept.strip())


def note_names(workspace):
    """How many notes in the Workspace have each file name: a name used twice is linked by its path."""
    seen = {}
    for root, dirs, files in os.walk(workspace):
        dirs[:] = [d for d in dirs if not d.startswith(".")]
        for name in files:
            if name.endswith(".md"):
                seen[name[:-3]] = seen.get(name[:-3], 0) + 1
    return seen


def indexes(workspace, spells, terms):
    """Every index's text by its file name: the one of all spells, and one per class."""
    line = classes_line(terms.get("Classes", "Classes"))
    title = words(os.path.basename(spells))
    seen = None
    every, by_class = [], {}
    for level in level_folders(spells):
        entries = []
        for note in spell_notes(spells, level):
            if seen is None:
                seen = note_names(workspace)
            path = os.path.join(spells, level, note + ".md")
            try:
                with open(path, encoding="utf-8", errors="replace") as f:
                    text = f.read()
            except OSError:
                continue
            name = next((l[2:].strip() for l in text.splitlines() if l.startswith("# ") and l[2:].strip()),
                        words(note))
            target = note
            if seen.get(note, 0) > 1:
                target = os.path.relpath(path[:-3], workspace).replace(os.sep, "/")
            link = f"- [[{target}]]" if target == name else f"- [[{target}|{name}]]"
            entries.append((sort_key(name), link, classes(text, line)))
        entries.sort()
        if entries:
            every.append((level, [link for _, link, _ in entries]))
        for _, link, names in entries:
            for name in names:
                levels = by_class.setdefault(name, [])
                if not levels or levels[-1][0] != level:
                    levels.append((level, []))
                levels[-1][1].append(link)

    def page(heading, levels):
        return f"# {heading}\n\n" + "\n\n".join(
            f"## {words(level)}\n\n" + "\n".join(links) for level, links in levels) + "\n"

    stem = os.path.basename(spells)
    pages = {stem + ".md": page(title, every)} if every else {}
    for name, levels in by_class.items():
        pages[f"{stem}_{file_stem(name)}.md"] = page(f"{title} — {name}", levels)
    return pages


def rebuild(workspace):
    """Returns what changed, as a sentence, or None when nothing did."""
    terms = glossary(workspace)
    spells = spells_folder(workspace, terms)
    if spells is None:
        return None
    pages = indexes(workspace, spells, terms)
    stem = os.path.basename(spells)
    # Every note directly in Spells named after the folder is an index: one no longer due goes.
    old = [n for n in os.listdir(spells) if os.path.isfile(os.path.join(spells, n))
           and (n == stem + ".md" or n.startswith(stem + "_") and n.endswith(".md"))]
    done = {"written": [], "updated": [], "removed": []}
    for name in sorted(set(old) - set(pages)):
        os.remove(os.path.join(spells, name))
        done["removed"].append(name)
    for name, text in sorted(pages.items()):
        path = os.path.join(spells, name)
        try:
            with open(path, encoding="utf-8") as f:
                current = f.read()
        except FileNotFoundError:
            current = None
        if text != current:
            with open(path, "w", encoding="utf-8") as f:
                f.write(text)
            done["written" if current is None else "updated"].append(name)
    if not any(done.values()):
        return None
    where = os.path.relpath(spells, workspace).replace(os.sep, "/")
    return f"Spell Indexes in {where}: " + "; ".join(
        f"{what} {', '.join(names)}" for what, names in done.items() if names) + "."


def hook():
    try:
        event = json.load(sys.stdin)
        workspace = event.get("cwd") or os.environ.get("CLAUDE_PROJECT_DIR") or os.getcwd()
        if not os.path.isfile(os.path.join(workspace, CONFIG)):
            return 0
        if event.get("tool_name") != "Bash":
            written = (event.get("tool_input") or {}).get("file_path") or ""
            spells = spells_folder(workspace)
            if not written or spells is None:
                return 0
            written = os.path.realpath(os.path.join(workspace, written))
            if not written.startswith(os.path.realpath(spells) + os.sep):
                return 0
        changed = rebuild(workspace)
        if changed:
            print(json.dumps({"hookSpecificOutput": {
                "hookEventName": "PostToolUse",
                "additionalContext": f"DM Realm: {changed} They are kept by the plugin from the "
                                     "spell notes on disk; do not edit them, and tell the DM they changed."}}))
    except Exception:  # a hook never blocks the DM's work
        pass
    return 0


def main(argv):
    if argv[1:] == ["hook"]:
        return hook()
    if len(argv) == 3 and argv[1] == "rebuild":
        if not os.path.isfile(os.path.join(argv[2], CONFIG)):
            print(f"spell-index: {argv[2]} is not a DM Realm Workspace (no {CONFIG}); nothing was changed.",
                  file=sys.stderr)
            return 2
        print(rebuild(argv[2]) or "Spell Indexes already right; nothing changed.")
        return 0
    print(__doc__, file=sys.stderr)
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv))
