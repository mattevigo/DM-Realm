#!/usr/bin/env python3
"""A Campaign's Party State as structure.md's "Party State" writes it (ADR 0021): known lines,
each opened by its Translation Glossary label, and the DM's own words around them, which
nothing here reads. player-wiki.py loads this module to show, on each Character Sheet, where
the Character stands in each Campaign (ADR 0022).

  party-state.py read <workspace> <Campaign folder>
      Print, as JSON, what the Character Sheets read of that Campaign's Party State, after
      the Player Wiki's DM-only filter (the Config's `player_wiki.dm_only_headings` and
      `%% … %%` comments): its updated-at line, and for each section that links to a
      Character note, that Character's known lines (label, value as the sheet shows it,
      sub-items) and the known lines it could not read; and the sections it did not read
      because they link first to a Character another section has. Exit 2: bad usage, not a
      Workspace; 4: the Campaign has no Party State.

A known line is a top-level list item `- **<label>:** <value>` (the bold is optional), its
label one of KNOWN's in the Workspace Language (the Glossary's row, else the English); its
indented sub-items belong to it. The sheet shows a value as plain text: its links as their
text, every note in parentheses dropped. A Character's section is a top-level section of the
note (the level of its first heading below the title) whose first link resolves to a
Character note, `<characters>/<Character>/<Character>.md`.
"""
import json
import os
import re
import sys

AS_OF = "As of"
# The known lines of a Character's section, in the order they are written.
KNOWN = ("Hit Points", "Temporary Hit Points", "Spell Slots Spent", "Hit Dice Spent",
         "Uses Spent", "Casts Without a Slot", "Magic Item Charges", "Conditions", "Exhaustion",
         "Heroic Inspiration", "Inspiration", "Active Effects", "Death Saving Throws",
         "Campaign Homebrew Carried")
# Known lines the sheet never shows: the whole table reads the wiki.
OFF_SHEET = ("Campaign Homebrew Carried",)

CODE_FENCE = re.compile(r"^[ \t]*(```|~~~)")
HEADING = re.compile(r"^(#{1,6})[ \t]+(.*?)[ \t#]*$")
ITEM = re.compile(r"^-[ \t]+(\*\*)?(?P<label>[^:\n]+?)(?:\*\*)?[ \t]*:(?:\*\*)?[ \t]*(?P<value>.*)$")
SUB_ITEM = re.compile(r"^(?:[ \t]{2,}|\t)[-*][ \t]+(?P<text>.*)$")
WIKILINK = re.compile(r"!?\[\[([^\]\n]*)\]\]")
MDLINK = re.compile(r"!?\[([^\]\n]*)\]\(<?([^)\s>]+)>?(?:[ \t]+\"[^\"\n]*\")?\)")
FIRST_LINK = re.compile(WIKILINK.pattern + "|" + MDLINK.pattern)
PARENS = re.compile(r"[ \t]*\([^()]*\)")
COMMENT = re.compile(r"%%.*?(?:%%|$)")


def link_text(target, alias):
    if alias.strip():
        return alias.strip()
    name = re.split(r"[#^]", target, 1)[0].strip().rsplit("/", 1)[-1]
    return (name[:-3] if name.endswith(".md") else name).replace("_", " ")


def plain(value):
    """A value as the sheet shows it: links as their text, notes in parentheses dropped,
    no emphasis."""
    text = COMMENT.sub("", value)
    text = WIKILINK.sub(lambda m: link_text(*(m.group(1).split("|", 1) + [""])[:2]), text)
    text = MDLINK.sub(lambda m: m.group(1), text)
    while PARENS.search(text):
        text = PARENS.sub("", text)
    text = text.replace("*", "")
    text = re.sub(r"[ \t]+", " ", text)
    text = re.sub(r" ([;,.:])", r"\1", text)
    return text.strip(" ;,·").strip()


def labels_for(terms):
    """{label casefolded: English} for every known line and the updated-at line, in the
    Workspace Language and in English."""
    found = {}
    for english in KNOWN + (AS_OF,):
        for word in (terms.get(english), english):
            if word:
                found.setdefault(word.strip().casefold(), english)
    return found


def outside_fences(lines):
    """[(line, in a code fence)]."""
    out, fence = [], None
    for line in lines:
        m = CODE_FENCE.match(line)
        if fence is None and m:
            fence = m.group(1)
            out.append((line, True))
        elif fence is not None:
            out.append((line, True))
            if m and m.group(1) == fence:
                fence = None
        else:
            out.append((line, False))
    return out


def known_lines(lines, labels):
    """([{key, label, value, items}], [unreadable label]) of a run of lines."""
    found, unreadable, current = [], [], None
    for line, fenced in outside_fences(lines):
        if fenced:
            current = None
            continue
        m = ITEM.match(line)
        if m:
            key = labels.get(m.group("label").strip().casefold())
            current = None
            if key:
                current = {"key": key, "label": m.group("label").strip(), "raw": m.group("value"),
                           "value": plain(m.group("value")), "items": []}
                found.append(current)
            continue
        sub = SUB_ITEM.match(line)
        if sub and current is not None:
            text = plain(sub.group("text"))
            if text:
                current["items"].append(text)
            continue
        if line.strip() and not line.startswith((" ", "\t")):
            current = None
    kept, seen = [], set()
    for line in found:
        if line["key"] in seen:
            unreadable.append(f"{line['label']} (written twice)")
        elif not line["value"] and not line["items"]:
            unreadable.append(f"{line['label']} (no value)")
            seen.add(line["key"])
        else:
            kept.append(line)
            seen.add(line["key"])
    for line in kept:
        del line["raw"]
    return kept, unreadable


def sections(body):
    """(the lines before the first section, [(heading, [lines])]) at the note's top section
    level: the level of its first heading below the title."""
    lines = body.splitlines()
    marked = outside_fences(lines)
    levels = [len(h.group(1)) for line, fenced in marked if not fenced
              for h in [HEADING.match(line)] if h and len(h.group(1)) > 1]
    if not levels:
        return lines, []
    level = levels[0]
    preamble, out, current = [], [], None
    for line, fenced in marked:
        h = None if fenced else HEADING.match(line)
        if h and len(h.group(1)) <= level and len(h.group(1)) > 1:
            current = (h.group(2).strip(), [])
            out.append(current)
            if len(h.group(1)) < level:  # a shallower heading closes the sections
                current = None
            continue
        if h and len(h.group(1)) == 1 and current is None:
            continue
        (current[1] if current else preamble).append(line)
    return preamble, [s for s in out if s is not None]


def first_link(heading, lines):
    for text in [heading] + lines:
        m = FIRST_LINK.search(text)
        if m:
            if m.group(1) is not None:
                return re.split(r"[#^|]", m.group(1), 1)[0].strip()
            return re.split(r"#", m.group(3), 1)[0].strip()
    return None


def read(body, terms, character_of):
    """What a script reads of a Party State's body (its DM-only parts already removed):
    {as_of, characters: {note path: {lines, unreadable}}, unreadable: [...]}.
    character_of(link target) is the Character note it resolves to, or None."""
    labels = labels_for(terms)
    preamble, found = sections(body)
    as_of = None
    top, _ = known_lines(preamble, labels)
    for line in top:
        if line["key"] == AS_OF:
            as_of = line["value"]
    result = {"as_of": as_of, "characters": {}, "unreadable": []}
    for heading, lines in found:
        target = first_link(heading, lines)
        note = character_of(target) if target else None
        if not note:
            continue
        if note in result["characters"]:
            result["unreadable"].append(f"{heading}: a second section for the same Character, not read")
            continue
        kept, unreadable = known_lines(lines, labels)
        kept = [l for l in kept if l["key"] != AS_OF]
        result["characters"][note] = {"lines": kept, "unreadable": unreadable}
    return result


def on_sheet(lines):
    return [l for l in lines if l["key"] not in OFF_SHEET]


# --- The command line ------------------------------------------------------------------

def main(argv):
    if len(argv) != 4 or argv[1] != "read":
        print(__doc__, file=sys.stderr)
        return 2
    workspace, campaign = argv[2], argv[3]
    here = os.path.dirname(os.path.abspath(__file__))
    sys.path.insert(0, here)
    import importlib.util
    spec = importlib.util.spec_from_file_location("player_wiki", os.path.join(here, "player-wiki.py"))
    wiki = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(wiki)
    if not os.path.isfile(os.path.join(workspace, wiki.CONFIG)):
        print(f"party-state: {workspace} is not a DM Realm Workspace.", file=sys.stderr)
        return 2
    terms = wiki.spell_index.glossary(workspace)
    path = wiki.party_state_path(workspace, campaign, terms)
    if not path:
        print(f"party-state: {campaign} has no Party State.", file=sys.stderr)
        return 4
    files = wiki.Files(workspace)
    characters = wiki.spell_index.folder(workspace, "characters")
    with open(os.path.join(workspace, path), encoding="utf-8") as f:
        _, body = wiki.split_frontmatter(f.read())
    try:
        dm_only = wiki.player_wiki(workspace)["dm_only_headings"]
    except wiki.Failure:
        dm_only = []
    body, _ = wiki.strip_dm_only(body, dm_only)
    print(json.dumps(read(body, terms, wiki.character_resolver(files, characters)),
                     ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
