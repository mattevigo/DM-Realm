#!/usr/bin/env python3
"""Write a rendered Part's notes into the Workspace, for dmr-import-adventure.

  adventure-notes.py split  <render.json> <dir> --source-key <key>
  adventure-notes.py images <render.json> --attachments <folder>
  adventure-notes.py write  <render.json> --source-key <key>

Run from the Workspace root. <render.json> is what `render-adventure.py --plan` printed
for one Part: its `notes`, the Part note first. Notes are written in the order structure.md
asks — the Part's other notes first, its Part note last — and a note already written is
never touched: a note is `done` when a non-empty file is at its path (an empty one, which
Obsidian makes for a link not imported yet, counts as none, ADR 0013).

split   writes each note's English text to <dir>/<NN>.md (outside the Workspace) and
        prints JSON, one object per note in writing order: its `note` and `path` (with
        `.md`), `english` (the file just written), `frontmatter` (the block the note starts
        with: --source-key, the source property quoted, and for an item `item: true` and
        its `image:` Portrait), `images` and `done`. A translated Import gives each note's
        translator its `english`, `frontmatter` and `path`.
images  copies each image of the notes not done into --attachments (from the Workspace
        root), named as the note embeds it, and prints the files placed.
write   writes each note not done, its frontmatter then its text as rendered: an English
        Workspace's Import. Prints {"written": [...], "skipped": [...]}, paths with `.md`.

Exit 2: a bad command line, or a render file that is missing or not a render.
"""
import json
import os
import shutil
import sys


def fail(message):
    sys.stderr.write(f"adventure-notes: {message}\n")
    sys.exit(2)


def option(args, name):
    if name not in args:
        return None
    at = args.index(name)
    if at + 1 >= len(args):
        fail(f"{name} needs a value.")
    value = args[at + 1]
    del args[at:at + 2]
    return value


def load(path):
    try:
        with open(path, encoding="utf-8") as handle:
            notes = json.load(handle)["notes"]
    except (OSError, ValueError, KeyError, TypeError) as error:
        fail(f"{path} is not a render of a Part ({error}).")
    if not isinstance(notes, list) or not notes or not all(
            isinstance(n, dict) and isinstance(n.get("note"), str) and isinstance(n.get("text"), str)
            for n in notes):
        fail(f"{path} is not a render of a Part.")
    return notes[1:] + notes[:1]          # the Part note last


def done(note):
    path = note["note"] + ".md"
    return os.path.isfile(path) and os.path.getsize(path) > 0


def frontmatter(note, key):
    lines = ["---", f"{key}: {json.dumps(note.get('source_property', ''), ensure_ascii=False)}"]
    if note.get("item"):
        lines.append("item: true")
        if note.get("portrait"):
            lines.append(f"image: {json.dumps(note['portrait'], ensure_ascii=False)}")
    return "\n".join(lines + ["---", ""])


def main(argv):
    args = list(argv)
    key = option(args, "--source-key")
    attachments = option(args, "--attachments")
    if len(args) < 2 or args[0] not in ("split", "images", "write"):
        fail("usage: split <render.json> <dir> | images <render.json> | write <render.json>.")
    command, render = args[0], args[1]
    if command in ("split", "write") and not key:
        fail(f"{command} needs --source-key, the source property's key in the Workspace Language.")
    if command == "images" and (not attachments or os.path.isabs(attachments)):
        fail("images needs --attachments, the Adventure's Attachments folder from the Workspace root.")
    if command == "split" and len(args) != 3:
        fail("split needs the folder its English files go in.")
    notes = load(render)

    if command == "split":
        os.makedirs(args[2], exist_ok=True)
        out = []
        for number, note in enumerate(notes):
            english = os.path.join(args[2], f"{number:02d}.md")
            with open(english, "w", encoding="utf-8") as handle:
                handle.write(note["text"])
            out.append({"note": note["note"], "path": note["note"] + ".md", "english": english,
                        "frontmatter": frontmatter(note, key), "images": note.get("images", []),
                        "done": done(note)})
        print(json.dumps(out, indent=2, ensure_ascii=False))
    elif command == "images":
        placed = []
        for note in notes:
            if done(note):
                continue
            for image in note.get("images", []):
                os.makedirs(attachments, exist_ok=True)
                target = os.path.join(attachments, image["file"])
                shutil.copyfile(image["cached"], target)
                placed.append(target)
        print(json.dumps({"placed": placed}, indent=2, ensure_ascii=False))
    else:
        written, skipped = [], []
        for note in notes:
            path = note["note"] + ".md"
            if done(note):
                skipped.append(path)
                continue
            os.makedirs(os.path.dirname(path) or ".", exist_ok=True)
            with open(path, "w", encoding="utf-8") as handle:
                handle.write(frontmatter(note, key) + "\n" + note["text"].rstrip("\n") + "\n")
            written.append(path)
        print(json.dumps({"written": written, "skipped": skipped}, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main(sys.argv[1:])
