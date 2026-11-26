#!/usr/bin/env python3
"""What MapForge reads of a DM Realm Workspace (ADR 0011): its Bestiary, its
Characters' notes and its Treasury.

  mapforge.py report <workspace>

MapForge, the DM's table tool, owns `.mapforge/`. Since MapForge 2.0 it reads every
`.md` in the Workspace outside hidden folders, once when the Workspace opens
(MapForge's ADR-0023, ADR-0024, ADR-0031); no folder is configured, and the
`bestiaryStatBlockPath` an older `.mapforge/config.json` may still hold is ignored.
A note's first closed ```statblock fence is:
  - a Character's, when it has any of `player`, `species`, `class` or `level`,
    and is not marked `bestiary: false` (a past Build);
  - kept out of the Bestiary with `bestiary: false` (a past Build, a Template),
    though a Monster may still extend it;
  - otherwise a Monster: its `name`, with what it `extends` laid underneath.
The first `name` by path wins; a later one is skipped, as is a Monster whose
`extends` names a base no note defines, or comes back to itself.
Its Treasury is every note outside hidden folders whose frontmatter says
`item: true`, a YAML boolean, never found by folder; an Item is named by its
first `# ` heading (else its file name) and a name already read is skipped; its
Portrait is a frontmatter `image:` wikilink.

report reads and never writes. It prints one JSON object:
  mapforge        false when there is no .mapforge/ (and nothing else)
  monsters        Monsters MapForge's Bestiary lists (one per name)
  characters      Characters' notes MapForge reads (one per name)
  skipped         the fences MapForge skips and lists, in path order, each
                  {file, name, reason, base?}: reason duplicate (a `name` an
                  earlier note already has), extends-missing (`base`, a name no
                  note defines; a Character is never a base), extends-loop,
                  no-name (name null), or unreadable (name null: a note that is
                  not UTF-8, or a fence MapForge's YAML reader refuses)
  parties         ok | missing (no parties.json) | invalid (not MapForge's roster)
  unlinked        each Party Character with no note linked, {party, character}
  note_missing    each linked to a note no Character's note defines (a renamed
                  `name`, a Monster's), {party, character, note}; with unlinked,
                  the Characters whose Pawns MapForge stamps with no numbers
  treasury        Items MapForge's Treasury lists (one per name)
  treasury_no_portrait  those of them without a Portrait
Exit 2: not a Workspace (no workspace-config.yml), or not `report`.
"""
import json
import os
import re
import sys

# The keys only a Character's fence has; any one will do (MapForge's ADR-0023).
CHARACTER_KEYS = ("player", "species", "class", "level")
TOP_KEY = re.compile(r"^([A-Za-z_][\w-]*)[ \t]*:(?:[ \t]+(.*)|[ \t]*)$")
LIST_ITEM = re.compile(r"^[ \t]*-[ \t]+(.*?)[ \t]*$")
# The words YAML (and so MapForge's Yams) reads as the boolean true, unquoted.
YAML_TRUE = {"true", "True", "TRUE", "yes", "Yes", "YES", "on", "On", "ON"}
YAML_FALSE = {"false", "False", "FALSE", "no", "No", "NO", "off", "Off", "OFF"}
YAML_NULL = {"null", "Null", "NULL", "~"}
# A `key: value` line, top-level, nested or a list item's; group 1 is the value.
PAIR = re.compile(r"^[ \t]*(?:-[ \t]+)?(?:\"[^\"]*\"|'[^']*'|[^\s\"'#:-][^:]*?)[ \t]*:[ \t]+(.+)$")


def fail(code, message):
    print(f"mapforge: {message}", file=sys.stderr)
    return code


def fence_text(text):
    """The lines inside the note's first ```statblock fence, or None without a closed one —
    MapForge's own rule: an unclosed fence is a note being typed, not a Monster yet. Not
    statblock.py's FENCE, which reads the fences DM Realm writes: this mirrors how MapForge finds
    one in any note, its opening and closing lines indented or not."""
    body, inside = [], False
    for line in text.replace("\r\n", "\n").split("\n"):
        trimmed = line.strip()
        if inside:
            if trimmed.startswith("```"):
                return body
            body.append(line)
        elif trimmed.startswith("```statblock"):
            inside = True
    return None


def fence_keys(lines):
    """{key: raw value} of a fence's top-level keys; a key with no value followed by a block
    list (`extends:` then `  - Scout`) gets the list of its items' raw values. Lenient, unlike
    statblock.py's parse_fence, which refuses what DM Realm does not write: MapForge reads any
    fence, and only these keys decide what it lists."""
    keys, last = {}, None
    for line in lines:
        found = TOP_KEY.match(line)
        if found:
            last = found.group(1)
            keys.setdefault(last, found.group(2))
            continue
        item = LIST_ITEM.match(line)
        if item and last and (keys[last] is None or isinstance(keys[last], list)):
            keys[last] = (keys[last] or []) + [item.group(1)]
    return keys


def text_of(raw):
    """A scalar's text as MapForge reads a name: quotes dropped, trimmed; None when empty, or when
    YAML reads it as null or a boolean rather than text."""
    if raw is None or isinstance(raw, list):
        return None
    text, quoted = scalar(raw)
    if not quoted and text in YAML_NULL | YAML_TRUE | YAML_FALSE:
        return None
    return text or None


def unreadable(lines):
    """True when MapForge's YAML reader would refuse the fence — as far as a hand-written note goes:
    a tab in a line's indentation, or a plain (unquoted) value holding `: ` or ending in `:`, at
    the top level or in a list item. DM Realm quotes such values itself (structure.md's "Keys and
    values"); a note the DM typed may not."""
    for line in lines:
        if "\t" in line[:len(line) - len(line.lstrip())]:
            return True
        pair = PAIR.match(line)
        if not pair:
            continue
        value = re.sub(r"(^|\s)#.*$", "", pair.group(1)).strip()
        if value and value[0] not in "\"'[{|>&*!" and (": " in value or value.endswith(":")):
            return True
    return False


def kept_out(keys):
    """`bestiary: false`, a YAML boolean: kept out of the Bestiary, though still a base."""
    if "bestiary" not in keys or isinstance(keys["bestiary"], list):
        return False
    value, quoted = scalar(keys["bestiary"] or "")
    return not quoted and value in YAML_FALSE


def is_character(keys):
    """A Character's fence: it has any key only a Character's has."""
    return any(key in keys for key in CHARACTER_KEYS)


def notes(workspace):
    """Every `.md` outside hidden folders (and not itself hidden), relative to the Workspace, in
    path order — the order in which MapForge lets the first of two same-named notes win."""
    found = []
    for dirpath, dirnames, filenames in os.walk(workspace):
        dirnames[:] = [d for d in dirnames if not d.startswith(".")]
        for filename in filenames:
            if filename.startswith(".") or not filename.lower().endswith(".md"):
                continue
            found.append(os.path.relpath(os.path.join(dirpath, filename), workspace).replace(os.sep, "/"))
    return sorted(found)


def fences(workspace):
    """(relative path, top-level keys) of every note's fence, in path order; keys None for a note
    MapForge cannot read, or a fence its YAML reader refuses."""
    found = []
    for rel in notes(workspace):
        try:
            with open(os.path.join(workspace, rel), encoding="utf-8") as f:
                lines = fence_text(f.read())
        except (UnicodeDecodeError, OSError):
            found.append((rel, None))
            continue
        if lines is not None:
            found.append((rel, None if unreadable(lines) else fence_keys(lines)))
    return found


def base_names(raw):
    """What `extends` names: `Scout`, `[Scout, "Bandit"]` or a block list of them."""
    if raw is None:
        return []
    if isinstance(raw, list):
        items = raw
    else:
        text, quoted = scalar(raw)
        if quoted or not (text.startswith("[") and text.endswith("]")):
            return [text] if text else []
        items = re.findall(r'"[^"]*"|\'[^\']*\'|[^,]+', text[1:-1])
    return [name for name in (text_of(item) for item in items) if name]


def extendable(found):
    """{name: fence} of what `extends` can name: every named fence that is not a Character's,
    the first by path winning; one kept out of the Bestiary only for a name no listed one holds."""
    by_name = {}
    candidates = [keys for _, keys in found if keys is not None and not is_character(keys)]
    for hidden in (False, True):
        for keys in candidates:
            name = text_of(keys.get("name"))
            if name and kept_out(keys) == hidden:
                by_name.setdefault(name, keys)
    return by_name


def unresolved(keys, by_name, chain):
    """None when the fence's `extends` chain resolves, else (reason, missing base or None)."""
    for parent in base_names(keys.get("extends")):
        if parent in chain:
            return "extends-loop", None
        if parent not in by_name:
            return "extends-missing", parent
        failure = unresolved(by_name[parent], by_name, chain + [parent])
        if failure:
            return failure
    return None


def notes_read(workspace):
    """(Monster names, Character note names, skipped) as MapForge reads the Workspace's fences
    (its ADR-0023, ADR-0024): a skipped fence by note and name, with its reason."""
    found = fences(workspace)
    by_name = extendable(found)
    monsters, characters, skipped = set(), set(), []
    for rel, keys in found:
        if keys is None:
            skipped.append({"file": rel, "name": None, "reason": "unreadable"})
            continue
        if kept_out(keys):
            continue
        character = is_character(keys)
        names = characters if character else monsters
        name = text_of(keys.get("name"))
        if not name:
            failure = ("no-name", None)
        elif character:
            failure = None
        else:
            failure = unresolved(keys, by_name, [name])
        if not failure and name in names:
            failure = ("duplicate", None)
        if failure:
            entry = {"file": rel, "name": name, "reason": failure[0]}
            if failure[1]:
                entry["base"] = failure[1]
            skipped.append(entry)
            continue
        names.add(name)
    return monsters, characters, skipped


def frontmatter(text):
    """({key: raw value} of the note's top-level frontmatter keys, the lines after it), or None
    without one: the lines between an opening `---` and the next `---`."""
    lines = text.replace("\r\n", "\n").split("\n")
    if lines[0].strip() != "---":
        return None
    fields = {}
    for end, line in enumerate(lines[1:], 1):
        if line.strip() == "---":
            return fields, lines[end + 1:]
        found = TOP_KEY.match(line)
        if found:
            fields.setdefault(found.group(1), found.group(2))
    return None


def scalar(raw):
    """A plain or quoted YAML scalar as (text, quoted), its trailing comment dropped."""
    raw = raw.strip()
    if raw[:1] in ("'", '"') and raw.endswith(raw[0]) and len(raw) > 1:
        return raw[1:-1], True
    return re.sub(r"(^|\s)#.*$", "", raw).strip(), False


def has_portrait(raw):
    """True when `image:` names a picture as MapForge reads it: a wikilink, quoted or not, with a
    target before any `|` or `#`."""
    text, _ = scalar(raw or "")
    link = text[1:] if text.startswith("!") else text
    if not (link.startswith("[[") and link.endswith("]]")):
        return False
    return bool(re.split(r"[|#]", link[2:-2])[0].strip())


def item_name(body, rel):
    for line in body:
        line = line.strip()
        if line.startswith("# ") and line[2:].strip():
            return line[2:].strip()
    return os.path.splitext(os.path.basename(rel))[0].replace("_", " ")


def treasury(workspace):
    """(items, without a Portrait) MapForge's Treasury reads (its ADR-0031): every note outside
    hidden folders whose frontmatter says `item: true`, a YAML boolean, wherever it is, one per
    name (its first `# ` heading, else its file name), the first by path."""
    found = []
    for dirpath, dirnames, filenames in os.walk(workspace):
        dirnames[:] = [d for d in dirnames if not d.startswith(".")]
        for filename in filenames:
            if not filename.lower().endswith(".md"):
                continue
            path = os.path.join(dirpath, filename)
            try:
                with open(path, encoding="utf-8") as f:
                    text = f.read()
            except (UnicodeDecodeError, OSError):
                continue
            split = frontmatter(text)
            if not split or "item" not in split[0]:
                continue
            value, quoted = scalar(split[0]["item"] or "")
            if quoted or value not in YAML_TRUE:
                continue
            rel = os.path.relpath(path, workspace).replace(os.sep, "/")
            found.append((rel, item_name(split[1], rel), split[0].get("image")))
    names, without = set(), 0
    for _, name, image in sorted(found):
        if name in names:
            continue
        names.add(name)
        without += not has_portrait(image)
    return len(names), without


def party_links(workspace, characters):
    """(state, unlinked, note_missing) of the roster in `.mapforge/parties.json`, read and never
    written: each Party Character with no `noteName`, and each whose `noteName` no Character's
    note defines. Either stamps its Pawns with no numbers (MapForge's ADR-0024)."""
    path = os.path.join(workspace, ".mapforge", "parties.json")
    if not os.path.isfile(path):
        return "missing", [], []
    try:
        with open(path, encoding="utf-8") as f:
            roster = json.load(f)
        parties = roster["parties"]
        unlinked, note_missing = [], []
        for party in parties:
            for character in party["characters"]:
                where = {"party": party["name"], "character": character["name"]}
                note = character.get("noteName")
                if note is None:
                    unlinked.append(where)
                elif note not in characters:
                    note_missing.append({**where, "note": note})
    except (ValueError, OSError, KeyError, TypeError, AttributeError):
        return "invalid", [], []
    return "ok", unlinked, note_missing


def report(workspace):
    if not os.path.isdir(os.path.join(workspace, ".mapforge")):
        return {"mapforge": False}
    out = {"mapforge": True}
    monsters, characters, skipped = notes_read(workspace)
    out.update(monsters=len(monsters), characters=len(characters), skipped=skipped)
    out["parties"], out["unlinked"], out["note_missing"] = party_links(workspace, characters)
    out["treasury"], out["treasury_no_portrait"] = treasury(workspace)
    return out


def main(argv):
    if len(argv) != 3 or argv[1] != "report":
        print(__doc__, file=sys.stderr)
        return 2
    workspace = argv[2]
    if not os.path.isfile(os.path.join(workspace, "workspace-config.yml")):
        return fail(2, f"{workspace} is not a Workspace (no workspace-config.yml)")
    print(json.dumps(report(workspace), ensure_ascii=False))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
