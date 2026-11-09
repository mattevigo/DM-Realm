#!/usr/bin/env python3
"""Refresh the Classes line of every spell note in Reference, then the Spell Indexes.

  spell-classes.py <workspace>

A spell's Classes line (`**Classes:** Sorcerer, Wizard`, last in the spell's own text)
names the classes whose spell list has it in the Trusted Source's class spell lists
(`data/spells/sources.json`, through the Source Cache, so DMR_SOURCE_CACHE applies) that
count in this Workspace (ADR 0016): every class of a core book (the `core` group of
`data/books.json`), and a class of any other book only when Reference holds its class note.
That note is the one named as its class folder, and it is matched by English name and
by the book its source property records. So a Setting book's own classes stay out until
the DM imports one. For every spell note, this writes the line that rule gives now:
added, changed, or removed when no class is left. A line already right is left alone,
and a class the old line gave its `(EN: …)` keeps it. Then it rebuilds the Spell Indexes.

It translates nothing itself: the label and each class are the Translation Glossary's.
The spell's book is the one its source property records; its English name is the Glossary
row whose translation is the note's heading (in an English Workspace, the heading). A note
it cannot do is left as it is and listed with the reason: no Glossary row for the spell,
or for a class (it names the class: add the row, then run this again).

Prints a JSON report: `added`, `changed` and `removed` (the notes whose line it wrote,
rewrote or took out), `classes` (every class term it wrote, with its English: check that
a fallback one shows its `(EN: …)`), `missing_rows` (the classes the Glossary has no row
for), `skipped` (note and reason) and `indexes` (what the Spell Index helper did).
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


def heading_of(text, fallback):
    """A note's `#` heading without a fallback term's `(EN: …)`, and that English original (or None)."""
    heading = next((l[2:].strip() for l in text.splitlines() if l.startswith("# ")), fallback)
    original = FALLBACK.search(heading)
    return FALLBACK.sub("", heading).strip(), (original.group(1).strip() if original else None)


def english_names(heading, original, terms, english):
    """The English names a note's heading may stand for: its fallback's English original, the
    Glossary rows that translate to it, and, in an English Workspace (no Glossary), the heading."""
    return ([original] if original else []) + english.get(heading.casefold(), []) + ([heading] if not terms else [])


def held_classes(workspace, terms, english):
    """The classes Reference holds, as case-folded (English name, book) pairs: each class folder's
    class note (the note named as its folder; the others are its subclasses), by the book its
    source property records."""
    reference = index.folder(workspace, "reference") or ""
    folders = [os.path.join(workspace, reference, n) for n in (terms.get("Classes"), "Classes") if n]
    classes = next((f for f in folders if reference and os.path.isdir(f)), None)
    held = set()
    for sub in sorted(os.listdir(classes)) if classes else []:
        path = os.path.join(classes, sub, sub + ".md")
        if not os.path.isfile(path):
            continue
        with open(path, encoding="utf-8", errors="replace") as f:
            text = f.read()
        book = book_of(text)
        if book:
            names = english_names(*heading_of(text, index.words(sub)), terms, english)
            held |= {(n.casefold(), book.casefold()) for n in names}
    return held


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


def with_classes(text, line, label, classes):
    """The note with its Classes line naming `classes` (none: without the line), and what that
    did: `added`, `changed` or `removed`. A class the old line gave its `(EN: …)` keeps it."""
    lines = text.rstrip("\n").split("\n")
    at = next((i for i in reversed(range(len(lines))) if line.fullmatch(lines[i])), None)
    if at is None:
        return with_line(text, f"**{label}:** {', '.join(classes)}"), "added"
    if not classes:
        start = at - 1 if at > 0 and not lines[at - 1].strip() else at
        return "\n".join(lines[:start] + lines[at + 1:]) + "\n", "removed"
    old = {FALLBACK.sub("", n).strip(): n.strip() for n in line.fullmatch(lines[at]).group(1).split(",")}
    lines[at] = f"**{label}:** {', '.join(old.get(c, c) for c in classes)}"
    return "\n".join(lines) + "\n", "changed"


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
    core = entry.core_books(required=True)  # never an empty set standing for "no core book"
    english = {}  # translation -> every English term it translates
    for term, translation in terms.items():
        english.setdefault(translation.casefold(), []).append(term)
    held = held_classes(workspace, terms, english)
    label = terms.get("Classes", "Classes")
    line = index.classes_line(label)

    report = {"added": [], "changed": [], "removed": [], "classes": {}, "missing_rows": [], "skipped": []}
    for level in index.level_folders(spells):
        for note in sorted(index.spell_notes(spells, level)):
            path = os.path.join(spells, level, note + ".md")
            shown = os.path.relpath(path, workspace).replace(os.sep, "/")
            with open(path, encoding="utf-8") as f:
                text = f.read()
            book = book_of(text)
            if not book:
                report["skipped"].append({"note": shown, "why": "it records no source"})
                continue
            listed = next((v for k, v in lists.items() if entry.same(k, book) and isinstance(v, dict)), {})
            heading, original = heading_of(text, index.words(note))
            names = english_names(heading, original, terms, english)
            if not names:
                report["skipped"].append({"note": shown, "why": f"no Translation Glossary row translates to '{heading}'"})
                continue
            spell_name = next((k for k in listed if any(entry.same(k, n) for n in names)), None)  # as the Trusted Source spells it
            classes = entry.spell_classes_of(book, spell_name, core, held) if spell_name else []
            missing = [c for c in classes if terms and c not in terms]
            if missing:
                report["missing_rows"] = sorted(set(report["missing_rows"]) | set(missing))
                report["skipped"].append({"note": shown, "why": "no Translation Glossary row for the class "
                                          + ", ".join(missing)})
                continue
            translated = [terms.get(c, c) for c in classes]
            if index.classes(text, line) == translated:  # already right, (EN: …) and all
                continue
            changed, what = with_classes(text, line, label, translated)
            with open(path, "w", encoding="utf-8") as f:
                f.write(changed)
            report[what].append(shown)
            if translated:
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
