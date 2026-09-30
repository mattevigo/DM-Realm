#!/usr/bin/env python3
"""A note's game statistics, written once: as a Fantasy Statblocks fence or as DM Realm's
Markdown (ADR 0009, structure.md's "Stat blocks"). Both forms hold the same fields, so a
note converts between them with the same values and translations.

  statblock.py convert <note> --to fence|markdown [--labels <file>]
      Rewrite the note's statistics in the other form, in place: the ```statblock fence,
      or the Markdown that starts with its `%% statblock` comment, up to the next `## `
      heading. The frontmatter flag `statblock: inline` comes with the fence (never for a
      past Build, `bestiary: false`). A link in the Markdown becomes plain text in the
      fence, and the links are kept on one line under it, since Obsidian does not index a
      fence. Prints what it did; a note already in that form is left as it is.

  statblock.py markdown [--labels <file>]
      Print the Markdown of the fence fields read from standard input (the YAML inside a
      ```statblock fence), for a note being written in a Markdown Workspace.

--labels is a JSON object (`-` reads it from standard input) mapping the layouts' English labels (`statblocks-settings.py
labels`: Armor Class, STR, Actions…) to their translations, as the Translation Glossary
records them; a label missing from it stays English.

Exit 2: bad usage or labels. Exit 4: the note has no statistics. Exit 6: the statistics
hold a key this module cannot write as Markdown. Exit 7: they cannot be parsed. Exit 8:
they are a Character's, which keeps its stat block whatever the Workspace chose. The note
is not touched on any error.
"""
import json
import re
import sys

CHARACTER_LAYOUT = "DM Realm Character"
ABILITIES = ("STR", "DEX", "CON", "INT", "WIS", "CHA")
XP = {"0": 10, "1/8": 25, "1/4": 50, "1/2": 100, "1": 200, "2": 450, "3": 700, "4": 1100,
      "5": 1800, "6": 2300, "7": 2900, "8": 3900, "9": 5000, "10": 5900, "11": 7200,
      "12": 8400, "13": 10000, "14": 11500, "15": 13000, "16": 15000, "17": 18000,
      "18": 20000, "19": 22000, "20": 25000, "21": 33000, "22": 41000, "23": 50000,
      "24": 62000, "25": 75000, "26": 90000, "27": 105000, "28": 120000, "29": 135000,
      "30": 155000}

# The keys in the order a fence lists them. The Markdown shows every key but the hidden
# ones, which it keeps in its `%% statblock` comment.
MONSTER_KEYS = ("name", "layout", "extends", "bestiary", "size", "type", "alignment", "ac", "ac_class",
                "hp", "hit_dice", "speed", "initiative", "stats", "saves", "skillsaves",
                "damage_vulnerabilities", "damage_resistances", "damage_immunities",
                "condition_immunities", "gear", "senses", "languages", "cr", "traits", "actions",
                "bonus_actions", "reactions", "legendary_description", "legendary_actions",
                "mythic_description", "mythic_actions", "lair_actions", "regional_effects")
HIDDEN = ("name", "layout", "extends", "bestiary")

# Label lines: key, label.
MONSTER_LINES = (("ac", "Armor Class"), ("hp", "Hit Points"), ("speed", "Speed"),
                 ("initiative", "Initiative"))
MONSTER_DETAILS = (("saves", "Saving Throws"), ("skillsaves", "Skills"),
                   ("damage_vulnerabilities", "Damage Vulnerabilities"),
                   ("damage_resistances", "Damage Resistances"),
                   ("damage_immunities", "Damage Immunities"),
                   ("condition_immunities", "Condition Immunities"), ("gear", "Gear"),
                   ("senses", "Senses"), ("languages", "Languages"), ("cr", "Challenge"))
MONSTER_SECTIONS = (("traits", "Traits"), ("actions", "Actions"), ("bonus_actions", "Bonus Actions"),
                    ("reactions", "Reactions"), ("legendary_actions", "Legendary Actions"),
                    ("mythic_actions", "Mythic Actions"), ("lair_actions", "Lair Actions"),
                    ("regional_effects", "Regional Effects"))
DESCRIPTIONS = {"legendary_actions": "legendary_description", "mythic_actions": "mythic_description"}
BONUS_LISTS = ("saves", "skillsaves")
TEXT_LISTS = ("spells",)  # lists of plain lines, as Fantasy Statblocks writes spellcasting

LINK = re.compile(r"\[\[([^\]|]+)(?:\|([^\]]+))?\]\]")
LINKS_LINE = re.compile(r"\[\[[^\]]+\]\](?:, \[\[[^\]]+\]\])*")
FENCE = re.compile(r"^```statblock[ \t]*\n(.*?)^```[ \t]*$", re.S | re.M)
YAML_AMBIGUOUS = re.compile(r"(?i)(true|false|yes|no|on|off|null|~|0x[\da-f_]+|0o?[0-7_]+|[-+]?(\d[\d_]*)?(\.\d*)?([e][-+]?\d+)?)")
INTEGER = re.compile(r"[-+]?\d+")


class Failure(Exception):
    def __init__(self, code, message):
        super().__init__(message)
        self.code = code


def refuse_character(fields):
    if dict(fields).get("layout") == CHARACTER_LAYOUT:
        raise Failure(8, "the statistics are a Character's, which keeps its stat block whatever the Workspace chose.")


def ordered(fields):
    keys = MONSTER_KEYS
    unknown = [k for k, _ in fields if k not in keys]
    if unknown:
        raise Failure(6, f"the stat block has keys DM Realm does not write: {', '.join(unknown)}.")
    values = dict(fields)
    return [(k, values[k]) for k in keys if k in values]


# --- The fence: a small YAML subset, the one DM Realm writes ----------------------------

def yaml_scalar(value):
    """A YAML scalar: numbers as they are, strings plain when that is unambiguous, else quoted."""
    if isinstance(value, bool) or not isinstance(value, (int, str)):
        raise Failure(7, f"a stat block value is not text or a number: {value!r}")
    if isinstance(value, int):
        return str(value)
    # structure.md's rule: quoted when it starts with anything but a letter or digit,
    # holds ': ' or ' #', or reads as a number or true/false.
    plain = value[:1].isalnum() and value == value.strip() and "\n" not in value \
        and ": " not in value and " #" not in value and not value.endswith(":") \
        and not YAML_AMBIGUOUS.fullmatch(value)
    return value if plain else json.dumps(value, ensure_ascii=False)


def fence_body(fields):
    """The YAML inside a ```statblock fence, one key per line in the fields' order."""
    lines = []
    for key, value in fields:
        if value in (None, "", []):
            continue
        if key == "stats":
            lines.append(f"stats: [{', '.join(yaml_scalar(v) for v in value)}]")
        elif isinstance(value, list):
            lines.append(f"{key}:")
            for item in value:
                if key in TEXT_LISTS:
                    lines.append(f"  - {item}")
                    continue
                pairs = list(item.items())
                if key in BONUS_LISTS:
                    (name, v), = pairs
                    lines.append(f"  - {yaml_scalar(name)}: {yaml_scalar(v)}")
                else:
                    lines.append(f"  - {pairs[0][0]}: {yaml_scalar(pairs[0][1])}")
                    lines.extend(f"    {k}: {yaml_scalar(v)}" for k, v in pairs[1:])
        elif key == "bestiary":
            lines.append(f"bestiary: {'true' if value else 'false'}")
        else:
            lines.append(f"{key}: {yaml_scalar(value)}")
    return "\n".join(lines)


def fence(fields):
    return "```statblock\n" + fence_body(fields) + "\n```"


def parse_scalar(text):
    text = text.strip()
    if text.startswith('"'):
        try:
            return json.loads(text)
        except ValueError:
            raise Failure(7, f"a quoted stat block value is malformed: {text[:60]}")
    if INTEGER.fullmatch(text):
        return int(text)
    return text


def split_pair(line):
    """`key: value` at the first ': ' outside quotes, or (line, None) when it has none."""
    if line.startswith('"'):
        end = json_end(line)
        rest = line[end:]
        if rest.startswith(":"):
            return json.loads(line[:end]), rest[1:].strip()
        return line, None
    if ": " in line or line.endswith(":"):
        key, _, value = line.partition(":")
        return key.strip(), value.strip()
    return line, None


def json_end(text):
    escaped = False
    for i, c in enumerate(text[1:], 1):
        if escaped:
            escaped = False
        elif c == "\\":
            escaped = True
        elif c == '"':
            return i + 1
    raise Failure(7, f"an unclosed quote in the stat block: {text[:60]}")


def parse_fence(body):
    """The fields of a fence's YAML, in their order."""
    fields, key, items = [], None, None
    for raw in body.splitlines():
        if not raw.strip():
            continue
        if raw.startswith("    ") and items:
            k, v = split_pair(raw.strip())
            if v is None:
                raise Failure(7, f"unexpected line in the stat block: {raw.strip()[:60]}")
            items[-1][k] = parse_scalar(v)
        elif raw.startswith("  - ") and key:
            text = raw[4:]
            if key in TEXT_LISTS:
                items.append(text)
                continue
            k, v = split_pair(text)
            if v is None:
                raise Failure(7, f"unexpected list item in the stat block: {text[:60]}")
            items.append({k: parse_scalar(v)})
        elif not raw.startswith(" "):
            k, v = split_pair(raw)
            if v is None:
                raise Failure(7, f"unexpected line in the stat block: {raw[:60]}")
            if v == "":
                key, items = k, []
                fields.append((k, items))
            elif k == "stats":
                fields.append((k, [parse_scalar(x) for x in v.strip("[]").split(",")]))
                key = None
            elif k == "bestiary":
                fields.append((k, v.lower() not in ("false", "no")))
                key = None
            else:
                fields.append((k, parse_scalar(v)))
                key = None
        else:
            raise Failure(7, f"unexpected indentation in the stat block: {raw[:60]}")
    for k, v in fields:
        if isinstance(v, list) and k not in ("stats",) + BONUS_LISTS + TEXT_LISTS \
                and any(set(item) - {"name", "desc"} for item in v):
            raise Failure(6, f"the stat block's '{k}' holds keys DM Realm does not write.")
    return fields


# --- The Markdown ------------------------------------------------------------------------

def signed(n):
    return f"{n:+d}" if isinstance(n, int) else str(n)


def modifier(score):
    return (score - 10) // 2 if isinstance(score, int) else None


def kind_line(values):
    what = " ".join(str(values[k]) for k in ("size", "type") if values.get(k))
    return ", ".join(x for x in (what, str(values.get("alignment") or "")) if x)


def line_value(key, values, label):
    v = values[key]
    if key == "ac" and values.get("ac_class"):
        return f"{v} ({values['ac_class']})"
    if key == "hp" and values.get("hit_dice"):
        return f"{v} ({values['hit_dice']})"
    if key == "initiative":
        return f"{signed(v)} ({10 + v})" if isinstance(v, int) else signed(v)
    if key == "cr":
        v = str(v)
        if v in XP:
            n = eval_cr(v)
            pb = 2 if n < 1 else 2 + int((n - 1) // 4)
            return f"{v} ({label('XP')} {XP[v]:,}; {label('PB')} +{pb})"
        return v
    if key in BONUS_LISTS:
        return ", ".join(f"{name} {signed(b)}" for item in v for name, b in item.items())
    return str(v)


def eval_cr(cr):
    num, _, den = cr.partition("/")
    return int(num) / int(den) if den else float(num)


def item_markdown(item):
    if isinstance(item, str):
        return f"- {item}"
    name, desc = item.get("name", ""), str(item.get("desc", ""))
    paragraphs = desc.split("\n\n") if desc else []
    if not name:
        return "\n\n".join(paragraphs)
    first = f"- ***{name}.***" + (f" {paragraphs[0]}" if paragraphs else "")
    rest = ["  " + p.replace("\n", "\n  ") for p in paragraphs[1:]]
    return "\n\n".join([first] + rest)


def markdown(fields, labels=None):
    """DM Realm's Markdown for a note's statistics, from its fence fields."""
    label = lambda english: (labels or {}).get(english, english)
    refuse_character(fields)
    fields = ordered(fields)
    values = {k: v for k, v in fields if v not in (None, "", [])}
    lines, details, sections = MONSTER_LINES, MONSTER_DETAILS, MONSTER_SECTIONS
    hidden = [f"{k}: {'false' if v is False else 'true' if v is True else yaml_scalar(v)}"
              for k, v in fields if k in HIDDEN and k in values]
    blocks = ["\n".join(["%% statblock"] + hidden + ["%%"])]
    kind_text = kind_line(values)
    if kind_text:
        blocks.append(f"*{kind_text}*")
    core = [f"**{label(l)}** {line_value(k, values, label)}" for k, l in lines if k in values]
    if core:
        blocks.append("\n".join(core))
    if "stats" in values:
        scores = values["stats"]
        blocks.append("\n".join([
            "| " + " | ".join(label(a) for a in ABILITIES) + " |", "|" + " --- |" * 6,
            "| " + " | ".join(f"{s} ({signed(modifier(s))})" for s in scores) + " |"]))
    rest = [f"**{label(l)}** {line_value(k, values, label)}" for k, l in details if k in values]
    if rest:
        blocks.append("\n".join(rest))
    for key, title in sections:
        description = values.get(DESCRIPTIONS.get(key, ""))
        if key not in values and not description:
            continue
        blocks.append(f"### {label(title)}")
        if description:
            blocks.append(str(description))
        items = [item_markdown(item) for item in values.get(key, [])]
        # A list is one block, its items on consecutive lines; a header item is a paragraph.
        listed = [i for i in items if i.startswith("- ")]
        blocks.extend(i for i in items if not i.startswith("- "))
        if listed:
            blocks.append("\n".join(listed))
    return "\n\n".join(b for b in blocks if b)


def parse_markdown(text, labels=None):
    """The fence fields of DM Realm's Markdown statistics (from `%% statblock` on)."""
    back = {}
    for english in {l for group in (MONSTER_LINES, MONSTER_DETAILS, MONSTER_SECTIONS) for _, l in group}:
        back[(labels or {}).get(english, english)] = english
    lines = text.split("\n")
    if not lines or lines[0].strip() != "%% statblock":
        raise Failure(7, "the Markdown statistics do not start with their '%% statblock' comment.")
    hidden, i = [], 1
    while i < len(lines) and lines[i].strip() != "%%":
        k, v = split_pair(lines[i].strip())
        if v is None:
            raise Failure(7, f"unexpected line in the '%% statblock' comment: {lines[i][:60]}")
        hidden.append((k, (v.lower() not in ("false", "no")) if k == "bestiary" else parse_scalar(v)))
        i += 1
    refuse_character(hidden)
    by_label = {l: k for k, l in MONSTER_LINES + MONSTER_DETAILS}
    by_title = {l: k for k, l in MONSTER_SECTIONS}
    values, section, paragraphs = {}, None, split_paragraphs(lines[i + 1:])
    for para in paragraphs:
        first = para.split("\n", 1)[0]
        if first.startswith("### "):
            english = back.get(first[4:].strip(), first[4:].strip())
            if english not in by_title:
                raise Failure(7, f"unknown statistics section '{first[4:].strip()}'.")
            section = by_title[english]
            values.setdefault(section, [])
        elif section:
            if para.startswith("- "):
                values[section].append(parse_item(para))
            elif LINKS_LINE.fullmatch(para):
                continue
            elif section in DESCRIPTIONS and not values[section]:
                values[DESCRIPTIONS[section]] = para
            elif values[section] and isinstance(values[section][-1], dict) and values[section][-1].get("name"):
                raise Failure(7, f"a paragraph outside any item in '{first[:60]}'.")
            else:
                values[section].append({"name": "", "desc": para})
        elif first.startswith("|"):
            values["stats"] = [parse_scalar(c.split("(")[0]) for c in para.split("\n")[2].strip("|").split("|")]
        elif first.startswith("**"):
            for line in para.split("\n"):
                m = re.fullmatch(r"\*\*(.+?)\*\* (.*)", line)
                if not m:
                    raise Failure(7, f"unexpected statistics line: {line[:60]}")
                english = back.get(m.group(1), m.group(1))
                if english not in by_label:
                    raise Failure(7, f"unknown statistics label '{m.group(1)}'.")
                read_line(by_label[english], m.group(2), values)
        elif first.startswith("*"):
            read_kind(para.strip("*"), values)
        elif LINKS_LINE.fullmatch(para):
            continue
        else:
            raise Failure(7, f"unexpected paragraph in the statistics: {first[:60]}")
    return ordered(hidden + [(k, v) for k, v in values.items() if k not in dict(hidden)])


def split_paragraphs(lines):
    """Paragraphs, a list item's indented paragraphs joined to it."""
    paragraphs, current, blank = [], [], False
    for line in lines:
        if not line.strip():
            blank = True
            continue
        if current and not line.startswith("- ") \
                and (not blank or (line.startswith("  ") and current[0].startswith("- "))):
            current.append(("\n" if blank else "") + line)
        else:
            if current:
                paragraphs.append("\n".join(current))
            current = [line]
        blank = False
    if current:
        paragraphs.append("\n".join(current))
    return paragraphs


def parse_item(para):
    body = para[2:]
    m = re.match(r"\*\*\*(.+?)\.\*\*\*(?: (.*))?", body, re.S)
    if not m:
        raise Failure(7, f"a list item without its ***Name.***: {body[:60]}")
    item = {"name": m.group(1)}
    desc = m.group(2) or ""
    if desc:
        item["desc"] = re.sub(r"\n\n  ", "\n\n", desc).replace("\n  ", "\n")
    return item


def top_level_commas(text):
    """The positions of ", " outside parentheses."""
    depth, found = 0, []
    for i, c in enumerate(text):
        depth += (c == "(") - (c == ")")
        if depth == 0 and text.startswith(", ", i):
            found.append(i)
    return found


def read_kind(text, values):
    commas = top_level_commas(text)
    # "size type, alignment"
    at = commas[-1] if commas else len(text)
    head, tail = text[:at], text[at + 2:]
    words = head.split(" ")
    # The size is its first word, or "X or Y": the short lowercase word between two sizes.
    size_words = 3 if len(words) >= 4 and words[1].islower() and len(words[1]) <= 4 \
        and words[2][:1].isupper() == words[0][:1].isupper() else 1
    values["size"] = " ".join(words[:size_words])
    rest = " ".join(words[size_words:])
    values["type"], values["alignment"] = rest, tail
    for k in [k for k, v in values.items() if v == ""]:
        del values[k]


def read_line(key, text, values):
    if key == "ac":
        m = re.fullmatch(r"(\d+) \((.*)\)", text)
        values["ac"], extra = (int(m.group(1)), m.group(2)) if m else (parse_scalar(text), "")
        if extra:
            values["ac_class"] = extra
    elif key == "hp":
        m = re.fullmatch(r"(\d+) \((.*)\)", text)
        values["hp"] = int(m.group(1)) if m else parse_scalar(text)
        if m:
            values["hit_dice"] = m.group(2)
    elif key == "initiative":
        values["initiative"] = parse_scalar(text.split(" (")[0])
    elif key == "cr":
        values["cr"] = str(text.split(" (")[0])
    elif key in BONUS_LISTS:
        items = []
        for part in text.split(", "):
            name, _, b = part.rpartition(" ")
            items.append({name: parse_scalar(b)})
        values[key] = items
    else:
        values[key] = int(text) if key == "hp" and INTEGER.fullmatch(text) else text


# --- Notes -------------------------------------------------------------------------------

def unlink(value, found):
    """A value with its links as plain text, collecting each link once."""
    def plain(m):
        if m.group(0) not in found:
            found.append(m.group(0))
        return m.group(2) or m.group(1).rsplit("/", 1)[-1]
    if isinstance(value, str):
        return LINK.sub(plain, value)
    if isinstance(value, list):
        return [unlink(v, found) for v in value]
    if isinstance(value, dict):
        return {k: unlink(v, found) for k, v in value.items()}
    return value


def set_flag(note, on):
    """The note with its `statblock: inline` frontmatter flag added or removed."""
    m = re.match(r"---\n(.*?\n)?---\n", note, re.S)
    lines = (m.group(1) or "").splitlines() if m else []
    lines = [l for l in lines if not re.fullmatch(r"statblock:\s*inline\s*", l)]
    if on:
        lines.append("statblock: inline")
    body = note[m.end():] if m else note
    if not lines:
        return body.lstrip("\n") if m else note
    return "---\n" + "\n".join(lines) + "\n---\n" + ("" if m else "\n") + body


def convert(note, to, labels=None):
    """(the converted note, what was done)."""
    fence_match = FENCE.search(note)
    comment = re.search(r"^%% statblock[ \t]*$", note, re.M)
    if not fence_match and not comment:
        raise Failure(4, "the note has no statistics: no ```statblock fence and no '%% statblock' Markdown.")
    if to == "fence" and fence_match or to == "markdown" and not fence_match:
        return note, f"already {'a stat block' if to == 'fence' else 'Markdown'}"
    if to == "markdown":
        fields = parse_fence(fence_match.group(1))
        text = markdown(fields, labels)
        note = note[:fence_match.start()] + text + note[fence_match.end():]
        return set_flag(note, False), "converted to Markdown"
    end = re.compile(r"^## ", re.M).search(note, comment.end())
    stop = end.start() if end else len(note)
    section = note[comment.start():stop].rstrip("\n")
    fields = parse_markdown(section, labels)
    found = []
    for para in split_paragraphs(section.split("\n")):
        if LINKS_LINE.fullmatch(para):
            found.extend(m.group(0) for m in LINK.finditer(para) if m.group(0) not in found)
    fields = [(k, unlink(v, found)) for k, v in fields]
    text = fence(fields) + ("\n\n" + ", ".join(found) if found else "")
    note = note[:comment.start()] + text + ("\n\n" if end else "\n") + note[stop:].lstrip("\n")
    return set_flag(note, dict(fields).get("bestiary", True) is not False), "converted to a stat block"


def read_labels(path):
    try:
        if path == "-":
            labels = json.load(sys.stdin)
        else:
            with open(path, encoding="utf-8") as f:
                labels = json.load(f)
    except (OSError, ValueError) as e:
        raise Failure(2, f"the labels are not a readable JSON object ({e}).")
    if not isinstance(labels, dict) or not all(isinstance(v, str) for v in labels.values()):
        raise Failure(2, "the labels must be a JSON object of English label to translation.")
    return labels


def main(argv):
    usage = "usage: statblock.py convert <note> --to fence|markdown [--labels <file>] | markdown [--labels <file>]"
    labels = None
    if "--labels" in argv:
        i = argv.index("--labels")
        if i + 1 >= len(argv):
            raise Failure(2, usage)
        labels = read_labels(argv[i + 1])
        argv = argv[:i] + argv[i + 2:]
    if argv == ["markdown"]:
        return markdown(parse_fence(sys.stdin.read()), labels) + "\n"
    if len(argv) == 4 and argv[0] == "convert" and argv[2] == "--to" and argv[3] in ("fence", "markdown"):
        path = argv[1]
        try:
            with open(path, encoding="utf-8") as f:
                note = f.read()
        except OSError as e:
            raise Failure(2, f"cannot read {path}: {e}")
        converted, done = convert(note, argv[3], labels)
        if converted != note:
            with open(path, "w", encoding="utf-8") as f:
                f.write(converted)
        return f"{path}: {done}.\n"
    raise Failure(2, usage)


if __name__ == "__main__":
    try:
        sys.stdout.write(main(sys.argv[1:]))
    except Failure as e:
        print(f"statblock: {e}", file=sys.stderr)
        sys.exit(e.code)
