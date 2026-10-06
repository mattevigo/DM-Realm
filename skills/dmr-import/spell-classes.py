#!/usr/bin/env python3
"""Give the spell notes imported before DM Realm wrote it their Classes line.

  spell-classes.py <workspace>

For every spell note in Reference's Spells folder that has no Classes line, finds the
spell in the Trusted Source's class spell lists (`data/spells/sources.json`, through the
Source Cache, so DMR_SOURCE_CACHE applies) and adds the line an Import writes today —
`**Classes:** Sorcerer, Wizard`, last in the spell's own text — with the label and each
class as the Translation Glossary translates them. Then it rebuilds the Spell Indexes.

It translates nothing itself. The spell's book is the one its source property records;
its English name is the Glossary row whose translation is the note's heading (in an
English Workspace, the heading). A note it cannot do is left as it is and listed with
the reason — no Glossary row for the spell, or for a class (it names the class: add the
row, then run this again). A spell on no class's list needs no line and is not listed.

Prints a JSON report: `added` (notes changed), `classes` (every class term it wrote, with
its English: check that a fallback one shows its `(EN: …)`), `missing_rows` (the classes
the Glossary has no row for), `skipped` (note and reason) and `indexes` (what the Spell
Index helper did).
Exit 2 when <workspace> is not a Workspace or has no Spells folder; the Source Cache's
exits (3 unreachable and not cached, 4 no such file) when the class lists cannot be read.
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


entry = module("render_entry", os.path.join(HERE, "render-entry.py"))
index = module("spell_index", os.path.join(HERE, "..", "dmr-workspace", "spell-index.py"))

# A source property's value: book code, page and release (`XPHB p. 239, v2.36.1`).
SOURCE = re.compile(r"^[^\s:#][^:\n]*:\s*[\"']?([A-Za-z0-9][\w-]*)(?: p\. ?\d+)?, v[\w.]+[\"']?\s*$", re.M)
FALLBACK = re.compile(r"\s*\(EN:\s*([^)]*)\)")


def book_of(text):
    if not text.startswith("---"):
        return None
    found = SOURCE.search(text.split("\n---", 1)[0])
    return found.group(1) if found else None


def with_line(text, line):
    """The note with the line last in the spell's own text: before its first `##` section, or at the end."""
    lines = text.rstrip("\n").split("\n")
    at = next((i for i, l in enumerate(lines) if l.startswith("## ")), len(lines))
    while at > 0 and not lines[at - 1].strip():
        at -= 1
    tail = lines[at:]
    while tail and not tail[0].strip():
        tail = tail[1:]
    return "\n".join(lines[:at] + ["", line] + ([""] + tail if tail else [])) + "\n"


def main(argv):
    if len(argv) != 2:
        print(__doc__, file=sys.stderr)
        return 2
    workspace = argv[1]
    if not os.path.isfile(os.path.join(workspace, index.CONFIG)):
        print(f"spell-classes: {workspace} is not a DM Realm Workspace; nothing was changed.", file=sys.stderr)
        return 2
    terms = index.glossary(workspace)
    spells = index.spells_folder(workspace, terms)
    if spells is None:
        print("spell-classes: the Workspace has no Spells folder in Reference; nothing was changed.", file=sys.stderr)
        return 2
    lists = entry.load("data/spells/sources.json")
    english = {}  # translation -> every English term it translates
    for term, translation in terms.items():
        english.setdefault(translation.casefold(), []).append(term)
    label = terms.get("Classes", "Classes")
    line = index.classes_line(label)

    report = {"added": [], "classes": {}, "missing_rows": [], "skipped": []}
    for level in index.level_folders(spells):
        for note in sorted(index.spell_notes(spells, level)):
            path = os.path.join(spells, level, note + ".md")
            shown = os.path.relpath(path, workspace).replace(os.sep, "/")
            with open(path, encoding="utf-8") as f:
                text = f.read()
            if line.search(text):
                continue
            book = book_of(text)
            if not book:
                report["skipped"].append({"note": shown, "why": "it records no source"})
                continue
            listed = next((v for k, v in lists.items() if entry.same(k, book) and isinstance(v, dict)), {})
            heading = next((l[2:].strip() for l in text.splitlines() if l.startswith("# ")), index.words(note))
            original = FALLBACK.search(heading)
            heading = FALLBACK.sub("", heading).strip()
            names = ([original.group(1).strip()] if original else []) + english.get(heading.casefold(), [])
            if not terms:  # an English Workspace: the heading is the name
                names.append(heading)
            if not names:
                report["skipped"].append({"note": shown, "why": f"no Translation Glossary row translates to '{heading}'"})
                continue
            found = next((v for k, v in listed.items() if any(entry.same(k, n) for n in names)), None)
            classes = sorted({c["name"] for c in (found or {}).get("class") or []
                              if isinstance(c, dict) and c.get("name")})
            if not classes:  # on no class's list: nothing to add
                continue
            missing = [c for c in classes if terms and c not in terms]
            if missing:
                report["missing_rows"] = sorted(set(report["missing_rows"]) | set(missing))
                report["skipped"].append({"note": shown, "why": "no Translation Glossary row for the class "
                                          + ", ".join(missing)})
                continue
            translated = [terms.get(c, c) for c in classes]
            with open(path, "w", encoding="utf-8") as f:
                f.write(with_line(text, f"**{label}:** {', '.join(translated)}"))
            report["added"].append(shown)
            report["classes"].update(zip(translated, classes))
    report["indexes"] = index.rebuild(workspace) or "Spell Indexes already right; nothing changed."
    print(json.dumps(report, indent=2, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main(sys.argv))
    except entry.Failure as e:
        print(f"spell-classes: {e}", file=sys.stderr)
        sys.exit(e.code)
