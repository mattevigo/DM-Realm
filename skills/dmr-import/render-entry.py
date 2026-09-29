#!/usr/bin/env python3
"""Render one Trusted Source entry as English Markdown, for an Import.

  render-entry.py <data file> <name> <source> [--key <key>] [--class-source <source>]
                  [--edition 2014|2024] [--meta]

<data file> is a Source Cache path (`data/spells/spells-xphb.json`); the file, and
any file a copied entry comes from, is fetched through the Source Cache helper
(`dmr-trusted-source/source-cache.sh`), so DMR_SOURCE_CACHE applies as it does there.
<name> and <source> are the entry's English name and book code. --key picks the
kind when the file holds several (`subclass`, `itemMastery`…); --class-source picks
a subclass under one version of its class (`XPHB`), or a subrace under one race.

Prints the entry's Markdown: `# <name>`, then its text, deterministically, with
5etools tags as plain text; the entry's description (its 5etools fluff, from the
`fluff-*` file beside its data, images left out) is a `## Description` section, before
a monster's stat lines and at the end of any other entry. A monster also gets its stat block, a Fantasy Statblocks
fence (```statblock) with the plugin's English keys, under the heading; --edition is the
Workspace's Edition, and a monster of the other one names its own Edition's layout
(without --edition, no layout is named). --meta prints JSON facts about the entry instead: its
key, source property (`XPHB p. 12, v2.36.1`), Edition by its book's date, reprints,
and what placing its note needs (spell level, class, race, option kind…).

Exit 2: bad usage. Exit 3 and 4: passed through from the Source Cache helper
(the Trusted Source is unreachable; no such file). Exit 5: no such entry.
Exit 6: a copied entry uses a `_copy` modifier this helper does not support, or the
description holds a field it does not know.
Exit 7: a malformed entry, or one that cannot be rendered. Exit 8: several entries match.
Nothing is printed on stdout on any error.
"""
import json
import os
import re
import subprocess
import sys

SOURCE_CACHE_HELPER = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "..", "dmr-trusted-source", "source-cache.sh")
# The 2024 Player's Handbook: a book published before it is 2014, the rest 2024.
EDITION_2024_BOOK = "XPHB"
EDITION_2024_FALLBACK_DATE = "2024-09-17"


class Failure(Exception):
    def __init__(self, code, message):
        super().__init__(message)
        self.code = code


# --- Source Cache ------------------------------------------------------------------

def source_cache(*args):
    run = subprocess.run(["sh", SOURCE_CACHE_HELPER] + list(args),
                         stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
    if run.returncode != 0:
        raise Failure(run.returncode, run.stderr.strip() or "the Source Cache helper failed.")
    return run.stdout.strip()


_files = {}


def load(path):
    if path not in _files:
        local = source_cache("file", path)
        try:
            with open(local, encoding="utf-8") as f:
                _files[path] = json.load(f)
        except ValueError as e:
            raise Failure(7, f"{path} is not valid JSON: {e}")
    return _files[path]


def load_optional(path):
    try:
        return load(path)
    except Failure as e:
        if e.code == 4:
            return {}
        raise


# --- Finding the entry ---------------------------------------------------------------

def same(a, b):
    return str(a or "").lower() == str(b or "").lower()


# Keys whose entries are parts of another entry, never imported on their own.
PARTS = ("classFeature", "subclassFeature")


def find(path, name, source, key=None, class_source=None):
    data = load(path)
    if not isinstance(data, dict):
        raise Failure(7, f"{path} does not hold Trusted Source entries.")
    matches = []
    for k, entries in data.items():
        if key and k != key or not isinstance(entries, list) or k.startswith("_") or k in PARTS:
            continue
        for entry in entries:
            if not isinstance(entry, dict):
                continue
            if k == "magicvariant":
                entry = generic_variant(entry)
            parent = entry.get("classSource", entry.get("raceSource"))
            if same(entry.get("name"), name) and same(entry.get("source"), source) \
                    and (not class_source or parent is None or same(parent, class_source)):
                matches.append((k, entry))
    if not matches:
        raise Failure(5, f"no entry named '{name}' from {source} in {path}.")
    if len(matches) > 1:
        listed = "; ".join(f"{k} {e.get('name')} ({e.get('source')}"
                           + (f", under {e['classSource']}" if e.get("classSource") else "") + ")"
                           for k, e in matches)
        raise Failure(8, f"several entries match '{name}' from {source}: {listed}. "
                         f"Pass --key or --class-source.")
    key, entry = matches[0]
    return key, resolve(key, entry, path)


# --- Copies: _copy, _mod and _templates (ADR 0007) -------------------------------------

# Fields a copy takes from the entry it copies only when its _preserve names them.
PRESERVED_ONLY = {"page", "otherSources", "additionalSources", "srd", "srd52", "basicRules",
                  "basicRules2024", "reprintedAs", "hasFluff", "hasFluffImages", "hasToken",
                  "tokenUrl", "altArt", "soundClip", "legendaryGroup", "environment", "variant"}
# The fields a "*" modifier applies to.
TEXT_FIELDS = ("action", "bonus", "reaction", "trait", "legendary", "mythic", "variant",
               "spellcasting", "actionHeader", "bonusHeader", "reactionHeader",
               "legendaryHeader", "mythicHeader")
REGEX_FLAGS = {"i": re.I, "m": re.M, "s": re.S}


def unsupported(what):
    raise Failure(6, f"unsupported _copy modifier {what}: this helper cannot render the entry.")


def copied_entry(key, copy, path):
    """The entry a _copy names, from the same file or, through the folder's index, another."""
    fields = {k: v for k, v in copy.items() if not k.startswith("_")}

    def look(data):
        for e in data.get(key, []):
            if isinstance(e, dict) and all(same(e.get(k), v) for k, v in fields.items()):
                return e
        return None

    found = look(load(path))
    if found is not None:
        return found, path
    folder, base = os.path.split(path)
    index_name = "fluff-index.json" if base.startswith("fluff-") else "index.json"
    index = load_optional(f"{folder}/{index_name}") if folder != "data" else {}
    wanted = (copy.get("source"), copy.get("className"))  # bestiary/spells by book, class by class
    for src, name in index.items():
        if any(same(src, w) for w in wanted if w):
            other = f"{folder}/{name}"
            found = look(load(other))
            if found is not None:
                add_features(load(other))  # a copied subclass keeps its features there
                return found, other
    raise Failure(7, f"'{copy.get('name')}' ({copy.get('source')}), which this entry copies, "
                     f"is not in the Trusted Source.")


def resolve(key, entry, path, seen=()):
    if "_copy" not in entry:
        return entry
    copy = entry["_copy"]
    if (copy.get("name"), copy.get("source")) in seen:
        raise Failure(7, f"'{entry.get('name')}' copies itself.")
    base, base_path = copied_entry(key, copy, path)
    base = resolve(key, base, base_path, seen + ((copy.get("name"), copy.get("source")),))
    preserve = copy.get("_preserve") or {}
    result = {k: copy_of(v) for k, v in base.items()
              if k not in PRESERVED_ONLY or preserve.get("*") or preserve.get(k)}
    for k, v in entry.items():
        if k == "_copy":
            continue
        if v is None:
            result.pop(k, None)
        else:
            result[k] = copy_of(v)
    for ref in copy.get("_templates") or []:
        apply_template(key, result, ref)
    apply_mods(result, copy.get("_mod") or {})
    return result


def copy_of(value):
    return json.loads(json.dumps(value))


def apply_template(key, entry, ref):
    if key != "monster":
        unsupported(f"_templates on a {key}")
    for t in load("data/bestiary/template.json").get("monsterTemplate", []):
        if same(t.get("name"), ref.get("name")) and same(t.get("source"), ref.get("source")):
            apply = t.get("apply") or {}
            entry.update(copy_of(apply.get("_root") or {}))
            apply_mods(entry, apply.get("_mod") or {})
            return
    raise Failure(7, f"the template '{ref.get('name')}' ({ref.get('source')}) is not in the Trusted Source.")


def apply_mods(entry, mods):
    for field, infos in mods.items():
        for info in infos if isinstance(infos, list) else [infos]:
            if field == "_":
                unsupported(f"'{info.get('mode') if isinstance(info, dict) else info}' (on the whole entry)")
            if field == "*":
                if not isinstance(info, dict) or info.get("mode") != "replaceTxt":
                    unsupported(f"'{info.get('mode') if isinstance(info, dict) else info}' on '*'")
                for f in TEXT_FIELDS:
                    if f in entry:
                        apply_mod(entry, f, info)
            else:
                apply_mod(entry, field, info)


def js_regex(pattern):
    pattern = re.sub(r"\(\?<([A-Za-z_]\w*)>", r"(?P<\1>", pattern)
    return re.sub(r"\\k<([A-Za-z_]\w*)>", r"(?P=\1)", pattern)


def js_replace(template):
    """A function applying a JavaScript replacement string ($1, $<name>, $&, $$)."""
    def repl(m):
        out, i = "", 0
        while i < len(template):
            c = template[i]
            nxt = template[i + 1] if i + 1 < len(template) else ""
            if c == "$" and nxt == "$":
                out, i = out + "$", i + 2
            elif c == "$" and nxt == "&":
                out, i = out + m.group(0), i + 2
            elif c == "$" and nxt.isdigit():
                two = template[i + 1:i + 3]
                if len(two) == 2 and two.isdigit() and 0 < int(two) <= len(m.groups()):
                    out, i = out + (m.group(int(two)) or ""), i + 3
                elif 0 < int(nxt) <= len(m.groups()):
                    out, i = out + (m.group(int(nxt)) or ""), i + 2
                else:  # no such group: JavaScript keeps the text as is
                    out, i = out + c, i + 1
            elif c == "$" and nxt == "<" and ">" in template[i:]:
                j = template.index(">", i)
                out, i = out + (m.group(template[i + 2:j]) or ""), j + 1
            else:
                out, i = out + c, i + 1
        return out
    return repl


def replace_text(value, regex, repl):
    """Replace in every string of value, outside 5etools tags, never in a `type`."""
    if isinstance(value, str):
        parts, i = [], 0
        for m in re.finditer(r"\{@[^{}]*(?:\{[^{}]*\}[^{}]*)*\}", value):
            parts.append(regex.sub(repl, value[i:m.start()]))
            parts.append(m.group(0))
            i = m.end()
        return "".join(parts) + regex.sub(repl, value[i:])
    if isinstance(value, list):
        return [replace_text(v, regex, repl) for v in value]
    if isinstance(value, dict):
        return {k: v if k == "type" else replace_text(v, regex, repl) for k, v in value.items()}
    return value


def position(items, target):
    if isinstance(target, dict) and "index" in target:
        return target["index"]
    if isinstance(target, dict) and "regex" in target:
        rx = re.compile(js_regex(target["regex"]))
        test = lambda x: rx.search(x if isinstance(x, str) else str(x.get("name", "")))
    else:
        test = lambda x: x == target or isinstance(x, dict) and x.get("name") == target
    for i, x in enumerate(items):
        if test(x):
            return i
    return None


def apply_mod(entry, field, info):
    if info == "remove":
        entry.pop(field, None)
        return
    mode = info.get("mode") if isinstance(info, dict) else info
    if mode == "replaceTxt":
        if field not in entry:
            return
        flags = 0
        for f in info.get("flags", ""):
            flags |= REGEX_FLAGS.get(f, 0)
        regex, repl = re.compile(js_regex(info["replace"]), flags), js_replace(info.get("with", ""))
        props = info.get("props") or [None, "entries", "headerEntries", "footerEntries"]
        value = entry[field]
        if isinstance(value, str):
            entry[field] = replace_text(value, regex, repl) if None in props else value
            return
        for i, item in enumerate(value):
            if isinstance(item, str):
                if None in props:
                    value[i] = replace_text(item, regex, repl)
            elif isinstance(item, dict):
                for p in props:
                    if p and p in item:
                        item[p] = replace_text(item[p], regex, repl)
        return
    if mode == "setProp":
        steps = [field] + (info["prop"].split(".") if info.get("prop") else [])
        target = entry
        for step in steps[:-1]:
            target = target.setdefault(step, {})
        target[steps[-1]] = copy_of(info.get("value"))
        return
    array_modes = ("appendArr", "prependArr", "insertArr", "replaceArr", "replaceOrAppendArr",
                   "removeArr", "appendIfNotExistsArr")
    if mode not in array_modes:
        unsupported(f"'{mode}' on '{field}'")
    items = info.get("items")
    items = copy_of(items if isinstance(items, list) else [items]) if items is not None else []
    current = entry.setdefault(field, [])
    if not isinstance(current, list):
        raise Failure(7, f"'{mode}' on '{field}', which is not a list.")
    if mode == "appendArr":
        current.extend(items)
    elif mode == "prependArr":
        current[0:0] = items
    elif mode == "insertArr":
        i = info.get("index", 0)
        current[i:i] = items
    elif mode == "appendIfNotExistsArr":
        current.extend(x for x in items if x not in current)
    elif mode in ("replaceArr", "replaceOrAppendArr"):
        i = position(current, info.get("replace"))
        if i is None and mode == "replaceOrAppendArr":
            current.extend(items)
        elif i is None:
            raise Failure(7, f"'{field}' has no '{info.get('replace')}' to replace.")
        else:
            current[i:i + 1] = items
    elif mode == "removeArr":
        targets = info.get("names", info.get("items"))
        for target in targets if isinstance(targets, list) else [targets]:
            i = position(current, target)
            if i is None and not info.get("force"):
                raise Failure(7, f"'{field}' has no '{target}' to remove.")
            if i is not None:
                del current[i]


# --- Rendering -----------------------------------------------------------------------

def malformed(where):
    raise Failure(7, f"malformed entry: {where}.")


ABILITIES = {"str": "Strength", "dex": "Dexterity", "con": "Constitution",
             "int": "Intelligence", "wis": "Wisdom", "cha": "Charisma"}
ATTACKS = {"mw": "Melee Weapon Attack", "rw": "Ranged Weapon Attack",
           "mw,rw": "Melee or Ranged Weapon Attack", "ms": "Melee Spell Attack",
           "rs": "Ranged Spell Attack", "ms,rs": "Melee or Ranged Spell Attack",
           "m": "Melee Attack", "r": "Ranged Attack", "m,r": "Melee or Ranged Attack"}
ATTACK_ROLLS = {"m": "Melee Attack Roll", "r": "Ranged Attack Roll", "m,r": "Melee or Ranged Attack Roll"}
ORDINALS = ["", "First", "Second", "Third", "Fourth", "Fifth"]
# Tags whose display text is not the third part: tag -> index of the display part.
DISPLAY_PART = {"classFeature": 5, "subclassFeature": 7, "deity": 3, "card": 3, "quickref": 4,
                "scaledice": 4, "scaledamage": 4}
DISPLAY_PART.update({t: 0 for t in (
    "filter", "book", "adventure", "link", "5etools", "footnote", "homebrew", "area", "tip",
    "help", "font", "color", "style", "highlight", "note", "u", "underline", "sup", "sub", "kbd")})
LABELS = {"h": "Hit:", "m": "Miss:", "hom": "Hit or Miss:", "actSaveSuccess": "Success:",
          "actSaveSuccessOrFail": "Failure or Success:", "actTrigger": "Trigger:",
          "actResponse": "Response:"}


def signed(n):
    n = str(n).strip()
    return n if n.startswith(("-", "+", "−")) else f"+{n}"


def split_top(s, sep):
    """Split on sep outside nested {…}."""
    parts, depth, cur = [], 0, ""
    for c in s:
        if c == "{":
            depth += 1
        elif c == "}":
            depth -= 1
        if c == sep and depth == 0:
            parts.append(cur)
            cur = ""
        else:
            cur += c
    return parts + [cur]


def tag_text(tag, body):
    parts = [plain(p) for p in split_top(body, "|")]
    first = parts[0].strip()
    shown = parts[1] if len(parts) > 1 and parts[1] else None
    if tag in ("b", "bold"):
        return f"**{first}**"
    if tag in ("i", "italic"):
        return f"*{first}*"
    if tag in ("s", "strike", "s2", "strikeDouble"):
        return f"~~{first}~~"
    if tag == "code":
        return f"`{first}`"
    if tag == "dc":
        return f"DC {shown or first}"
    if tag in ("hit", "d20", "initiative"):
        return shown or signed(first)
    if tag in ("dice", "damage", "autodice"):
        return shown or first
    if tag == "chance":
        return shown or f"{first} percent"
    if tag == "recharge":
        return "(Recharge 6)" if first in ("", "6") else f"(Recharge {first}–6)"
    if tag == "atk":
        return f"*{ATTACKS.get(first, first)}:*"
    if tag == "atkr":
        return f"*{ATTACK_ROLLS.get(first, first)}:*"
    if tag in LABELS:
        return f"*{LABELS[tag]}*" + (" " if tag in ("h", "m", "hom") else "")
    if tag == "actSave":
        return f"*{ABILITIES.get(first, first)} Saving Throw:*"
    if tag == "actSaveFail":
        return f"*{ORDINALS[int(first)]} Failure:*" if first.isdigit() and 0 < int(first) < 6 else "*Failure:*"
    if tag == "actSaveFailBy":
        return f"*Failure by {first} or More:*"
    if tag == "dcYourSpellSave":
        return first or "your spell save DC"
    if tag == "hitYourSpellAttack":
        return first or "your spell attack modifier"
    if tag == "coinflip":
        return first or "flip a coin"
    if tag in ("savingThrow", "skillCheck"):
        return signed(first.split()[-1]) if first.split() else first
    if tag in ("scaledice", "scaledamage"):
        i = DISPLAY_PART[tag]
        return parts[i] if len(parts) > i and parts[i] else (parts[2] if len(parts) > 2 else first)
    i = DISPLAY_PART.get(tag, 2)
    return parts[i] if len(parts) > i and parts[i] else parts[0]


def plain(s):
    """s with every 5etools tag ({@tag …}) rendered as plain text."""
    s = str(s)
    out, i = "", 0
    while i < len(s):
        start = s.find("{@", i)
        if start < 0:
            out += s[i:]
            break
        out += s[i:start]
        depth, j = 0, start
        while j < len(s):
            if s[j] == "{":
                depth += 1
            elif s[j] == "}":
                depth -= 1
                if depth == 0:
                    break
            j += 1
        if j >= len(s):
            malformed(f"unclosed tag in '{s[start:start + 40]}'")
        inner = s[start + 2:j]
        tag, _, body = inner.partition(" ")
        out += tag_text(tag, body)
        i = j + 1
    return out


def render_entries(entries, depth=0):
    if not isinstance(entries, list):
        malformed("'entries' is not a list")
    blocks = []
    for entry in entries:
        blocks.extend(render_entry(entry, depth))
    return blocks


def code(value):
    """The first part of a 5etools reference (`longsword|xphb` -> `longsword`)."""
    return str(value).split("|")[0]


def uid_name(uid):
    return plain(code(uid))


def with_period(name):
    name = plain(name).strip()
    return name if name.endswith((".", ":", "!", "?")) else name + "."


def children(entry):
    """An entry's content as a list: its `entries`, or its single `entry`."""
    if "entries" in entry:
        content = entry["entries"]
    elif "entry" in entry:
        content = [entry["entry"]]
    else:
        content = []
    if not isinstance(content, list):
        malformed(f"'entries' of '{entry.get('name', entry.get('type'))}' is not a list")
    return content


def named_blocks(name, content, depth):
    """A named block: its name inline before a leading paragraph, else as a heading."""
    if content and isinstance(content[0], str) and name:
        return [f"***{with_period(name)}*** {plain(content[0])}"] + render_entries(content[1:], depth + 1)
    heading = [f"{'#' * min(depth + 2, 6)} {plain(name)}"] if name else []
    return heading + render_entries(content, depth + 1 if name else depth)


def quoted(blocks):
    return "\n>\n".join("\n".join(f"> {line}" if line else ">" for line in b.split("\n")) for b in blocks)


def inline(entry):
    if isinstance(entry, (str, int, float)):
        return plain(entry)
    if not isinstance(entry, dict):
        malformed(f"unexpected {json.dumps(entry)[:80]}")
    kind = entry.get("type")
    if kind == "link":
        return plain(entry.get("text", ""))
    if kind in ("inline", "inlineBlock"):
        return "".join(inline(e) for e in children(entry))
    if kind == "bonus":
        return signed(entry.get("value"))
    if kind == "bonusSpeed":
        return f"{signed(entry.get('value'))} ft."
    if kind == "dice":
        return "+".join(f"{d.get('number', 1)}d{d.get('faces')}" for d in entry.get("toRoll", []))
    if kind == "cell":
        roll = entry.get("roll")
        if roll:
            pad = (lambda n: str(n).zfill(2)) if roll.get("pad") else str
            if "exact" in roll:
                return pad(roll["exact"])
            return f"{pad(roll.get('min'))}–{pad(roll.get('max'))}"
        return inline(entry.get("entry", ""))
    return " ".join(render_entry(entry, 3))


def list_lines(items, pad=""):
    if not isinstance(items, list):
        malformed("'items' of a list is not a list")
    lines = []
    for item in items:
        if isinstance(item, dict) and item.get("type") == "list":
            lines.extend(list_lines(item.get("items"), pad + "  "))
            continue
        if isinstance(item, dict) and item.get("type") in ("item", "itemSub", "itemSpell"):
            content = children(item)
            name = f"**{with_period(item['name'])}** " if item.get("name") else ""
            head = name + (plain(content[0]) if content and isinstance(content[0], str) else "")
            rest = content[1:] if content and isinstance(content[0], str) else content
        else:
            blocks = render_entry(item, 3)
            head = blocks[0] if blocks else ""
            rest = [{"type": "_rendered", "text": b} for b in blocks[1:]]
        lines.append(f"{pad}- {head}".rstrip())
        for c in rest:
            if isinstance(c, dict) and c.get("type") == "list":
                lines.extend(list_lines(c.get("items"), pad + "  "))
                continue
            blocks = [c["text"]] if isinstance(c, dict) and c.get("type") == "_rendered" else render_entry(c, 3)
            for b in blocks:
                lines.append("")
                lines.extend(f"{pad}  {line}" if line else "" for line in b.split("\n"))
    return lines


def cell(value):
    return inline(value).replace("|", "\\|").replace("\n", "<br>")


def table_blocks(table):
    rows = table.get("rows")
    if not isinstance(rows, list):
        malformed(f"table '{table.get('caption', '')}' has no rows")
    rows = [r.get("row") if isinstance(r, dict) else r for r in rows]
    if not all(isinstance(r, list) for r in rows):
        malformed(f"a row of table '{table.get('caption', '')}' is not a list")
    labels = table.get("colLabels") or []
    width = max([len(labels)] + [len(r) for r in rows])
    labels = labels + [""] * (width - len(labels))
    lines = ["| " + " | ".join(cell(c) for c in labels) + " |", "|" + " --- |" * width]
    for r in rows:
        r = r + [""] * (width - len(r))
        lines.append("| " + " | ".join(cell(c) for c in r) + " |")
    blocks = [f"**{plain(table['caption'])}**"] if table.get("caption") else []
    return blocks + ["\n".join(lines)] + [plain(f) for f in table.get("footnotes", [])]


def attributes(entry):
    return " or ".join(ABILITIES.get(a, a) for a in entry.get("attributes", []))


def render_entry(entry, depth):
    if isinstance(entry, (str, int, float)):
        return [plain(entry)]
    if not isinstance(entry, dict):
        malformed(f"unexpected {json.dumps(entry)[:80]}")
    kind = entry.get("type", "entries")
    if kind in ("entries", "section"):
        return named_blocks(entry.get("name"), children(entry), depth)
    if kind == "list":
        return ["\n".join(list_lines(entry.get("items")))]
    if kind == "options":
        return ["\n".join(list_lines(children(entry)))]
    if kind in ("item", "itemSub", "itemSpell"):
        return ["\n".join(list_lines([entry]))[2:]]
    if kind == "table":
        return table_blocks(entry)
    if kind == "tableGroup":
        return [b for t in entry.get("tables", []) for b in table_blocks(t)]
    if kind in ("inset", "insetReadaloud", "variant", "variantInner", "variantSub"):
        label = "Variant: " if kind == "variant" else ""
        head = [f"**{label}{plain(entry['name'])}**"] if entry.get("name") else []
        return [quoted(head + render_entries(children(entry), depth + 1))]
    if kind == "quote":
        by = ", ".join(x for x in (plain(entry.get("by", "")),
                                   f"*{plain(entry['from'])}*" if entry.get("from") else "") if x)
        return [quoted(render_entries(children(entry), depth) + ([f"— {by}"] if by else []))]
    if kind in ("inline", "inlineBlock", "link", "cell"):
        return [inline(entry)]
    if kind == "abilityDc":
        return [f"**{plain(entry['name'])} save DC** = 8 + your proficiency bonus + your {attributes(entry)} modifier"]
    if kind == "abilityAttackMod":
        return [f"**{plain(entry['name'])} attack modifier** = your proficiency bonus + your {attributes(entry)} modifier"]
    if kind == "abilityGeneric":
        name = f"**{plain(entry['name'])}** = " if entry.get("name") else ""
        return [name + plain(entry.get("text", ""))]
    if kind == "hr":
        return ["---"]
    if kind in ("image", "gallery"):
        return []  # images are out of scope
    if kind in ("refOptionalfeature", "refFeat"):
        return [uid_name(entry.get("optionalfeature" if kind == "refOptionalfeature" else "feat", ""))]
    if kind in ("refClassFeature", "refSubclassFeature"):
        feature = class_feature(entry.get(kind[3].lower() + kind[4:]), kind == "refSubclassFeature")
        return named_blocks(feature["name"], feature.get("entries", []), depth)
    if kind in ("statblock", "statblockInline"):
        data = entry.get("data") or {}
        return [plain(entry.get("displayName") or entry.get("name") or data.get("name", ""))]
    if "entries" in entry or "entry" in entry:
        return named_blocks(entry.get("name"), children(entry), depth)
    if "items" in entry:
        return ["\n".join(list_lines(entry["items"]))]
    malformed(f"unknown entry type '{kind}'")


def render_generic(key, entry):
    return [f"# {entry['name']}"] + render_entries(entry.get("entries", []))


SCHOOLS = {"A": "Abjuration", "C": "Conjuration", "D": "Divination", "E": "Enchantment",
           "V": "Evocation", "I": "Illusion", "N": "Necromancy", "T": "Transmutation", "P": "Psionic"}
TIME_UNITS = {"bonus": "bonus action"}
AREAS = ("radius", "sphere", "cone", "line", "cube", "hemisphere", "cylinder", "emanation")
ENDS = {"dispel": "dispelled", "trigger": "triggered", "discharge": "discharged"}


def plural(amount, unit):
    return f"{amount} {unit}" if amount == 1 else f"{amount} {unit}s"


def casting_time(times):
    out = []
    for t in times or []:
        unit = TIME_UNITS.get(t.get("unit"), t.get("unit", ""))
        s = plural(t.get("number", 1), unit)
        out.append(s + (f", {plain(t['condition'])}" if t.get("condition") else ""))
    return " or ".join(out)


SINGULAR = {"feet": "foot", "miles": "mile"}


def distance(d):
    kind, amount = d.get("type"), d.get("amount")
    if kind in SINGULAR:
        return f"{amount} {SINGULAR[kind] if amount == 1 else kind}"
    return str(kind).capitalize()


def spell_range(r):
    kind, d = r.get("type"), r.get("distance", {})
    if kind == "point":
        return distance(d)
    if kind in AREAS:
        unit = SINGULAR.get(d.get("type"), d.get("type"))
        return f"Self ({d.get('amount')}-{unit} {kind})"
    return str(kind).capitalize()


def components(c):
    out = [label for key, label in (("v", "V"), ("s", "S")) if c.get(key)]
    m = c.get("m")
    if m:
        m = m.get("text") if isinstance(m, dict) else m
        out.append(f"M ({plain(m)})" if isinstance(m, str) else "M")
    if c.get("r"):
        out.append("R")
    return ", ".join(out)


def durations(ds):
    out = []
    for d in ds or []:
        kind = d.get("type")
        if kind == "instant":
            out.append("Instantaneous")
        elif kind == "timed":
            span = d.get("duration", {})
            s = plural(span.get("amount", 1), span.get("type", ""))
            out.append(f"Concentration, up to {s}" if d.get("concentration")
                       else f"Up to {s}" if span.get("upTo") else s)
        elif kind == "permanent":
            ends = " or ".join(ENDS.get(e, e) for e in d.get("ends", []))
            out.append(f"Until {ends}" if ends else "Permanent")
        else:
            out.append(str(kind).capitalize())
    return ", or ".join(out)


def render_spell(key, spell):
    if not isinstance(spell.get("level"), int):
        malformed(f"spell '{spell['name']}' has no level")
    school = SCHOOLS.get(spell.get("school"), spell.get("school", ""))
    kind = f"{school} Cantrip" if spell["level"] == 0 else f"Level {spell['level']} {school}"
    if spell.get("meta", {}).get("ritual"):
        kind += " (Ritual)"
    stats = "\n".join([
        f"**Casting Time:** {casting_time(spell.get('time'))}",
        f"**Range:** {spell_range(spell.get('range', {}))}",
        f"**Components:** {components(spell.get('components', {}))}",
        f"**Duration:** {durations(spell.get('duration'))}",
    ])
    return [f"# {spell['name']}", f"*{kind}*", stats] + render_entries(spell.get("entries", [])) \
        + render_entries(spell.get("entriesHigherLevel", []))


SIZES = {"T": "Tiny", "S": "Small", "M": "Medium", "L": "Large", "H": "Huge", "G": "Gargantuan"}
ALIGNMENTS = {"L": "lawful", "N": "neutral", "NX": "neutral", "NY": "neutral", "C": "chaotic",
              "G": "good", "E": "evil", "U": "unaligned", "A": "any alignment"}
ALIGNMENT_SETS = {
    frozenset("L NX C E".split()): "any evil alignment",
    frozenset("L NX C G".split()): "any good alignment",
    frozenset("C G NY E".split()): "any chaotic alignment",
    frozenset("L G NY E".split()): "any lawful alignment",
    frozenset("NX C G NY E".split()): "any non-lawful alignment",
    frozenset("L NX C NY E".split()): "any non-good alignment",
    frozenset("L NX C G NY".split()): "any non-evil alignment",
    frozenset("L NX NY G E".split()): "any non-chaotic alignment",
}
XP = {"0": 10, "1/8": 25, "1/4": 50, "1/2": 100, "1": 200, "2": 450, "3": 700, "4": 1100,
      "5": 1800, "6": 2300, "7": 2900, "8": 3900, "9": 5000, "10": 5900, "11": 7200, "12": 8400,
      "13": 10000, "14": 11500, "15": 13000, "16": 15000, "17": 18000, "18": 20000, "19": 22000,
      "20": 25000, "21": 33000, "22": 41000, "23": 50000, "24": 62000, "25": 75000, "26": 90000,
      "27": 105000, "28": 120000, "29": 135000, "30": 155000}
SPEEDS = ("walk", "burrow", "climb", "fly", "swim")
SECTIONS = (("trait", "Traits"), ("action", "Actions"), ("bonus", "Bonus Actions"),
            ("reaction", "Reactions"), ("legendary", "Legendary Actions"), ("mythic", "Mythic Actions"))
SPELL_LEVELS = ["Cantrips", "1st level", "2nd level", "3rd level", "4th level", "5th level",
                "6th level", "7th level", "8th level", "9th level"]


def modifier(score):
    return (score - 10) // 2


def proficiency_bonus(cr):
    try:
        value = eval_cr(cr)
    except ValueError:
        return None
    return 2 + max(0, (int(value) - 1) // 4) if value >= 1 else 2


def eval_cr(cr):
    num, _, den = str(cr).partition("/")
    return float(num) / float(den) if den else float(num)


def and_join(items):
    items = list(items)
    if len(items) < 3:
        return " and ".join(items)
    return ", ".join(items[:-1]) + ", and " + items[-1]


def alignment(values):
    if not values:
        return ""
    if all(isinstance(v, str) for v in values):
        if frozenset(values) in ALIGNMENT_SETS:
            return ALIGNMENT_SETS[frozenset(values)]
        words = []
        for v in values:
            word = ALIGNMENTS.get(v, v)
            if word not in words:
                words.append(word)
        return " ".join(words)
    out = []
    for v in values:
        if isinstance(v, dict) and v.get("special"):
            out.append(plain(v["special"]))
        elif isinstance(v, dict):
            s = alignment(v.get("alignment", []))
            out.append(f"{s} ({v['chance']}%)" if v.get("chance") else s)
        else:
            out.append(ALIGNMENTS.get(v, v))
    return " or ".join(out)


def creature_type(t):
    if isinstance(t, str):
        return t
    base = t.get("type")
    if isinstance(base, dict):
        base = " or ".join(base.get("choose", []))
    if t.get("swarmSize"):
        base = f"swarm of {SIZES.get(t['swarmSize'], t['swarmSize'])} {base}s"
    tags = [f"{g['prefix']} {g['tag']}" if isinstance(g, dict) else g for g in t.get("tags", [])]
    return base + (f" ({', '.join(tags)})" if tags else "")


def armor_class(acs):
    out = []
    for ac in acs or []:
        if isinstance(ac, dict) and ac.get("special"):
            out.append(plain(ac["special"]))
        elif isinstance(ac, dict):
            s = str(ac.get("ac"))
            if ac.get("from"):
                s += f" ({', '.join(plain(f) for f in ac['from'])})"
            if ac.get("condition"):
                s += f" {plain(ac['condition'])}"
            out.append(s)
        else:
            out.append(str(ac))
    return ", ".join(out)


def hit_points(hp):
    if hp.get("special"):
        return plain(hp["special"])
    return f"{hp.get('average')} ({hp.get('formula')})"


def speed(speeds):
    out = []
    for mode in SPEEDS:
        v = speeds.get(mode)
        if v is None:
            continue
        if v is True:
            s = "equal to its walking speed"
        elif isinstance(v, dict):
            s = f"{v.get('number')} ft." + (f" {plain(v['condition'])}" if v.get("condition") else "")
        else:
            s = f"{v} ft."
        out.append(s if mode == "walk" else f"{mode} {s}")
    return ", ".join(out)


def title_words(s):
    small = ("of", "and", "the")
    return " ".join(w if w in small and i else w.capitalize() for i, w in enumerate(s.split()))


def bonuses(values, names):
    return ", ".join(f"{names(k)} {v}" for k, v in values.items() if isinstance(v, str))


def damage_list(items, key):
    groups, simple = [], []
    for it in items or []:
        if isinstance(it, str):
            simple.append(plain(it))
        elif it.get("special"):
            groups.append(plain(it["special"]))
        else:
            inner = and_join(plain(x) for x in it.get(key, []) if isinstance(x, str))
            groups.append(" ".join(x for x in (plain(it.get("preNote", "")), inner,
                                               plain(it.get("note", ""))) if x))
    return "; ".join(([", ".join(simple)] if simple else []) + groups)


def challenge(cr):
    def one(value):
        xp = XP.get(str(value))
        return f"{value} (XP {xp:,})" if xp is not None else str(value)
    if isinstance(cr, dict):
        pb = proficiency_bonus(cr.get("cr"))
        s = one(cr.get("cr"))
        s = s[:-1] + f"; PB +{pb})" if pb and s.endswith(")") else s
        if cr.get("lair"):
            s += f", or {one(cr['lair'])} in its lair"
        if cr.get("coven"):
            s += f", or {one(cr['coven'])} when part of a coven"
        return s
    s, pb = one(cr), proficiency_bonus(cr)
    return s[:-1] + f"; PB +{pb})" if pb and s.endswith(")") else s


def initiative_bonus(monster):
    """The initiative bonus the entry states (2024), else None."""
    init = monster.get("initiative")
    if isinstance(init, (int, float)):
        return int(init)
    if isinstance(init, dict):
        if "initiative" in init:
            return int(init["initiative"])
        cr = monster.get("cr", {})
        pb = proficiency_bonus(cr.get("cr") if isinstance(cr, dict) else cr) or 2
        return modifier(monster.get("dex", 10)) + init.get("proficiency", 0) * pb
    return None


def initiative(monster):
    bonus = initiative_bonus(monster)
    return None if bonus is None else f"{signed(bonus)} ({10 + bonus})"


def gear(items):
    out = []
    for g in items:
        if isinstance(g, dict):
            out.append(uid_name(g.get("item", "")) + (f" ({g['quantity']})" if g.get("quantity") else ""))
        else:
            out.append(uid_name(g))
    return ", ".join(out)


def spell_names(spells):
    return ", ".join(plain(s["entry"] if isinstance(s, dict) else s) for s in spells)


def frequency(label, per):
    lines = []
    for k in sorted(per, key=lambda x: -int(x.rstrip("e"))):
        each = " each" if k.endswith("e") else ""
        lines.append(f"- {k.rstrip('e')}/{label}{each}: {spell_names(per[k])}")
    return lines


def spell_lines(sc):
    """A spellcasting block's spells, one line per frequency or level."""
    lines = []
    if sc.get("will"):
        lines.append(f"- At will: {spell_names(sc['will'])}")
    for field, per in (("daily", "day"), ("rest", "rest"), ("weekly", "week"),
                       ("monthly", "month"), ("yearly", "year")):
        if sc.get(field):
            lines.extend(frequency(per, sc[field]))
    for level, spells in sorted((sc.get("spells") or {}).items(), key=lambda x: int(x[0])):
        if level == "0":
            label = "Cantrips (at will)"
        elif spells.get("slots") is not None:
            label = f"{SPELL_LEVELS[int(level)]} ({plural(spells['slots'], 'slot')})"
        else:
            label = SPELL_LEVELS[int(level)]
        lines.append(f"- {label}: {spell_names(spells.get('spells', []))}")
    if sc.get("ritual"):
        lines.append(f"- Rituals: {spell_names(sc['ritual'])}")
    return ["\n".join(lines)] if lines else []


def spellcasting_blocks(sc):
    blocks = named_blocks(sc.get("name", "Spellcasting"), sc.get("headerEntries", []), 3)
    return blocks + spell_lines(sc) + render_entries(sc.get("footerEntries", []), 3)


def render_monster(key, m):
    for field in ("size", "type", "ac", "hp"):
        if field not in m:
            malformed(f"monster '{m['name']}' has no {field}")
    kind = f"{' or '.join(SIZES.get(s, s) for s in m['size'])} {creature_type(m['type'])}"
    align = alignment(m.get("alignment"))
    if m.get("alignmentPrefix"):
        align = plain(m["alignmentPrefix"]) + align
    core = [f"**Armor Class** {armor_class(m['ac'])}", f"**Hit Points** {hit_points(m['hp'])}",
            f"**Speed** {speed(m.get('speed', {}))}"]
    init = initiative(m)
    if init:
        core.append(f"**Initiative** {init}")
    abilities = ["STR", "DEX", "CON", "INT", "WIS", "CHA"]
    scores = [m.get(a.lower(), 10) for a in abilities]
    table = "\n".join(["| " + " | ".join(abilities) + " |", "|" + " --- |" * 6,
                       "| " + " | ".join(f"{s} ({signed(modifier(s))})" for s in scores) + " |"])
    details = []
    if m.get("save"):
        details.append(f"**Saving Throws** {bonuses(m['save'], lambda k: k.capitalize())}")
    if m.get("skill"):
        details.append(f"**Skills** {bonuses(m['skill'], title_words)}")
    for field, label, inner in (("vulnerable", "Damage Vulnerabilities", "vulnerable"),
                                ("resist", "Damage Resistances", "resist"),
                                ("immune", "Damage Immunities", "immune"),
                                ("conditionImmune", "Condition Immunities", "conditionImmune")):
        if m.get(field):
            details.append(f"**{label}** {damage_list(m[field], inner)}")
    if m.get("gear"):
        details.append(f"**Gear** {gear(m['gear'])}")
    senses = [plain(s) for s in m.get("senses") or []] + [f"passive Perception {m.get('passive', 10)}"]
    details.append(f"**Senses** {', '.join(senses)}")
    details.append(f"**Languages** {', '.join(plain(x) for x in m.get('languages') or []) or '—'}")
    if m.get("cr") is not None:
        details.append(f"**Challenge** {challenge(m['cr'])}")

    blocks = [f"# {m['name']}", "## Stat Block", f"*{kind}{', ' + align if align else ''}*",
              "\n".join(core), table, "\n".join(details)]
    casting = {}
    for sc in m.get("spellcasting", []):
        casting.setdefault(sc.get("displayAs", "trait"), []).extend(spellcasting_blocks(sc))
    for field, title in SECTIONS:
        section = render_entries(m.get(f"{field}Header", []), 3)
        if field == "legendary" and m.get("legendary") and not section:
            uses = str(m.get("legendaryActions", 3))
            if m.get("legendaryActionsLair"):
                uses += f" ({m['legendaryActionsLair']} in Lair)"
            section = [f"**Legendary Action Uses:** {uses}"]
        for item in m.get(field) or []:
            section.extend(render_entry(item, 3))
        section.extend(casting.get(field, []))
        if m.get(field) or casting.get(field):
            blocks.extend([f"### {title}"] + section)
    return blocks


# --- Stat block fence (Fantasy Statblocks): keys in English, values to translate ------

# The layout of each Edition's monsters; an Off-Edition monster names its own.
MONSTER_LAYOUTS = {"2014": "DM Realm Monster 2014", "2024": "DM Realm Monster 2024"}
FENCE_SECTIONS = (("trait", "traits"), ("action", "actions"), ("bonus", "bonus_actions"),
                  ("reaction", "reactions"), ("legendary", "legendary_actions"), ("mythic", "mythic_actions"))
PLAIN_SCALAR = re.compile(r"[^\W_][\w ,.()/;'’+–—-]*(?<! )")
YAML_AMBIGUOUS = re.compile(r"(?i)(true|false|yes|no|on|off|null|~|0x[\da-f_]+|0o?[0-7_]+|[-+]?(\d[\d_]*)?(\.\d*)?([e][-+]?\d+)?)")


def yaml_scalar(value):
    """A YAML scalar: numbers as they are, strings plain when that is unambiguous, else quoted."""
    if isinstance(value, bool) or not isinstance(value, (int, str)):
        malformed(f"a stat block value is not text or a number: {value!r}")
    if isinstance(value, int):
        return str(value)
    if PLAIN_SCALAR.fullmatch(value) and not YAML_AMBIGUOUS.fullmatch(value):
        return value
    return json.dumps(value, ensure_ascii=False)


def bonus_value(value):
    """A bonus such as "+4" as the number 4, for the table tools; any other text as it is."""
    text = str(value).strip().replace("−", "-")
    return int(text) if re.fullmatch(r"[-+]?\d+", text) else plain(value)


def fence_items(items):
    out = []
    for item in items:
        if isinstance(item, dict) and "name" in item:
            out.append({"name": plain(item["name"]),
                        "desc": "\n\n".join(render_entries(children(item), 3))})
        else:
            out.append({"name": "", "desc": "\n\n".join(render_entry(item, 3))})
    return out


def fence_ac(acs):
    """The Armor Class as a number, and what the stat block says about it besides."""
    first, rest = (acs or [None])[0], (acs or [])[1:]
    notes = [armor_class([a]) for a in rest]
    if isinstance(first, dict) and not first.get("special"):
        ac = first.get("ac")
        extra = ", ".join(plain(f) for f in first.get("from") or [])
        if first.get("condition"):
            extra = " ".join(x for x in (extra, plain(first["condition"])) if x)
        notes = ([extra] if extra else []) + notes
    elif isinstance(first, int):
        ac = first
    else:
        ac = armor_class([first]) if first is not None else None
    return ac, "; ".join(notes)


def statblock_fence(m, workspace_edition=None):
    """The monster as a Fantasy Statblocks fence (```statblock), for the note's stat block."""
    fields = [("name", m["name"])]
    edition = edition_of(m.get("source"))
    if workspace_edition and edition and edition != workspace_edition:
        fields.append(("layout", MONSTER_LAYOUTS[edition]))
    align = alignment(m.get("alignment"))
    if m.get("alignmentPrefix"):
        align = plain(m["alignmentPrefix"]) + align
    ac, ac_class = fence_ac(m["ac"])
    fields += [("size", " or ".join(SIZES.get(s, s) for s in m["size"])),
               ("type", creature_type(m["type"])), ("alignment", align), ("ac", ac), ("ac_class", ac_class)]
    hp = m["hp"]
    if hp.get("special"):
        fields.append(("hp", plain(hp["special"])))
    else:
        fields += [("hp", hp.get("average")), ("hit_dice", hp.get("formula"))]
    bonus = initiative_bonus(m)
    fields += [("speed", speed(m.get("speed", {}))),
               ("initiative", modifier(m.get("dex", 10)) if bonus is None else bonus),
               ("stats", [m.get(a, 10) for a in ABILITIES])]
    fields.append(("saves", [{ABILITIES.get(k, k): bonus_value(v)} for k, v in (m.get("save") or {}).items()
                             if isinstance(v, str)]))
    fields.append(("skillsaves", [{title_words(k): bonus_value(v)} for k, v in (m.get("skill") or {}).items()
                                  if isinstance(v, str)]))
    for field, key in (("vulnerable", "damage_vulnerabilities"), ("resist", "damage_resistances"),
                       ("immune", "damage_immunities"), ("conditionImmune", "condition_immunities")):
        fields.append((key, damage_list(m.get(field), field)))
    if m.get("gear"):
        fields.append(("gear", gear(m["gear"])))
    senses = [plain(s) for s in m.get("senses") or []] + [f"passive Perception {m.get('passive', 10)}"]
    fields += [("senses", ", ".join(senses)),
               ("languages", ", ".join(plain(x) for x in m.get("languages") or []) or "—")]
    if m.get("cr") is not None:
        cr = m["cr"]
        fields.append(("cr", str(cr.get("cr") if isinstance(cr, dict) else cr)))
    casting = {}
    for sc in m.get("spellcasting", []):
        desc = render_entries(sc.get("headerEntries", []), 3) + spell_lines(sc) \
            + render_entries(sc.get("footerEntries", []), 3)
        casting.setdefault(sc.get("displayAs", "trait"), []).append(
            {"name": plain(sc.get("name", "Spellcasting")), "desc": "\n\n".join(desc)})
    for field, key in FENCE_SECTIONS:
        header = "\n\n".join(render_entries(m.get(f"{field}Header", []), 3))
        if field == "legendary" and m.get("legendary") and not header:
            uses = str(m.get("legendaryActions", 3))
            if m.get("legendaryActionsLair"):
                uses += f" ({m['legendaryActionsLair']} in Lair)"
            header = f"Legendary Action Uses: {uses}"
        items = fence_items(m.get(field) or []) + casting.get(field, [])
        if field in ("legendary", "mythic"):
            fields.append((f"{field}_description", header if items else ""))
        elif header:
            items = [{"name": "", "desc": header}] + items
        fields.append((key, items))
    return fence(fields)


def fence(fields):
    lines = ["```statblock"]
    for key, value in fields:
        if value in (None, "", []):
            continue
        if key == "stats":
            lines.append(f"stats: [{', '.join(yaml_scalar(v) for v in value)}]")
        elif isinstance(value, list):
            lines.append(f"{key}:")
            for item in value:
                pairs = list(item.items())
                if key in ("saves", "skillsaves"):
                    (name, v), = pairs
                    lines.append(f"  - {yaml_scalar(name)}: {yaml_scalar(v)}")
                else:
                    lines.append(f"  - {pairs[0][0]}: {yaml_scalar(pairs[0][1])}")
                    lines.extend(f"    {k}: {yaml_scalar(v)}" for k, v in pairs[1:])
        else:
            lines.append(f"{key}: {yaml_scalar(value)}")
    return "\n".join(lines + ["```"])


ITEM_TYPES = {
    "A": "Ammunition", "AF": "Ammunition", "AT": "Artisan's Tools", "EXP": "Explosive",
    "FD": "Food and Drink", "G": "Adventuring Gear", "GS": "Gaming Set", "HA": "Heavy Armor",
    "INS": "Instrument", "LA": "Light Armor", "M": "Melee Weapon", "MA": "Medium Armor",
    "MNT": "Mount", "OTH": "Other", "P": "Potion", "R": "Ranged Weapon", "RD": "Rod", "RG": "Ring",
    "S": "Shield", "SC": "Scroll", "SCF": "Spellcasting Focus", "SHP": "Vessel", "T": "Tools",
    "TAH": "Tack and Harness", "TG": "Trade Good", "VEH": "Vehicle", "WD": "Wand",
    "$": "Treasure", "$A": "Art Object", "$C": "Coinage", "$G": "Gemstone"}
DAMAGE_TYPES = {"A": "acid", "B": "bludgeoning", "C": "cold", "F": "fire", "O": "force",
                "L": "lightning", "N": "necrotic", "P": "piercing", "I": "poison", "Y": "psychic",
                "R": "radiant", "S": "slashing", "T": "thunder"}
PROPERTIES = {"A": "Ammunition", "AF": "Ammunition", "BF": "Burst Fire", "F": "Finesse", "H": "Heavy",
              "L": "Light", "LD": "Loading", "R": "Reach", "RLD": "Reload", "S": "Special",
              "T": "Thrown", "2H": "Two-Handed", "V": "Versatile"}
NOT_MAGIC = (None, "none", "unknown")


def generic_variant(variant):
    """A magic variant as an entry: its book, page and text are those it passes on."""
    inherits = variant.get("inherits") or {}
    noun = "item"
    for req in variant.get("requires") or []:
        noun = "weapon" if req.get("weapon") else "armor" if req.get("armor") else noun
    values = {k: str(v) for k, v in inherits.items() if isinstance(v, (str, int, float))}
    values.update(baseName=noun)

    def fill(s):
        out, i = "", 0
        while True:
            j = s.find("{=", i)
            if j < 0:
                return out + s[i:]
            k = s.find("}", j)
            name, _, mode = s[j + 2:k].partition("/")
            v = values.get(name, "this item")
            out += s[i:j] + {"l": v.lower(), "u": v.upper(), "t": v.title()}.get(mode, v)
            i = k + 1

    def walk(x):
        if isinstance(x, str):
            return fill(x)
        if isinstance(x, list):
            return [walk(e) for e in x]
        if isinstance(x, dict):
            return {k: walk(v) for k, v in x.items()}
        return x

    entry = {k: v for k, v in variant.items() if k != "inherits"}
    entry.update({k: inherits[k] for k in ("source", "page", "rarity", "reqAttune") if k in inherits})
    entry["entries"] = walk(inherits.get("entries", []))
    return entry


def is_magic(key, item):
    return key == "magicvariant" or key == "item" and item.get("rarity") not in NOT_MAGIC


def cost(cp):
    for unit, size in (("gp", 100), ("sp", 10)):
        if cp >= size and cp % size == 0:
            return f"{cp // size:,} {unit}"
    return f"{cp:,} cp"


def weapon_property(p, item):
    note = ""
    if isinstance(p, dict):
        p, note = p.get("uid", ""), plain(p.get("note", ""))
    name = PROPERTIES.get(code(p), code(p))
    extra = []
    if code(p) == "V" and item.get("dmg2"):
        extra.append(item["dmg2"])
    if code(p) in ("T", "A", "AF") and item.get("range"):
        extra.append(f"range {item['range']}")
    if note:
        extra.append(note)
    return name + (f" ({'; '.join(extra)})" if extra else "")


def item_kind(key, item):
    if key == "magicvariant":
        label = "Generic variant"
    elif item.get("wondrous"):
        label = "Wondrous item"
    elif item.get("staff"):
        label = "Staff"
    else:
        label = ITEM_TYPES.get(code(item.get("type", "")), "Item")
    if item.get("weaponCategory"):
        label = f"{item['weaponCategory'].capitalize()} {label}"
    if item.get("baseItem"):
        label += f" ({uid_name(item['baseItem'])})"
    if is_magic(key, item):
        label += f", {item['rarity']}"
    attune = item.get("reqAttune")
    if attune:
        label += " (requires attunement" + (f" {plain(attune)}" if isinstance(attune, str) else "") + ")"
    return label


def render_item(key, item):
    stats = []
    if item.get("dmg1"):
        stats.append(f"**Damage:** {item['dmg1']} {DAMAGE_TYPES.get(item.get('dmgType'), '')}".rstrip())
    if item.get("property"):
        stats.append(f"**Properties:** {', '.join(weapon_property(p, item) for p in item['property'])}")
    elif item.get("range"):
        stats.append(f"**Range:** {item['range']}")
    if item.get("mastery"):
        stats.append(f"**Mastery:** {', '.join(uid_name(m) for m in item['mastery'])}")
    if item.get("ac") is not None:
        kind = code(item.get("type", ""))
        ac = {"LA": f"{item['ac']} + Dex modifier", "MA": f"{item['ac']} + Dex modifier (max 2)",
              "S": f"+{item['ac']}"}.get(kind, str(item["ac"]))
        stats.append(f"**Armor Class:** {ac}")
    if item.get("strength"):
        stats.append(f"**Strength:** {item['strength']}")
    if item.get("stealth"):
        stats.append("**Stealth:** Disadvantage")
    if item.get("weight"):
        stats.append(f"**Weight:** {item['weight']} lb.")
    if item.get("value"):
        stats.append(f"**Cost:** {cost(item['value'])}")
    if key == "magicvariant":
        applies = []
        for req in item.get("requires") or []:
            for k, v in req.items():
                applies.append(plain(v) if k == "name" else f"any {k}" if v is True else f"{k} {plain(v)}")
        stats.append(f"**Applies to:** {' or '.join(applies) or 'any item'}")
    return [f"# {item['name']}", f"*{item_kind(key, item)}*", "\n".join(stats)] \
        + render_entries(item.get("entries", []))


FEAT_CATEGORIES = {"O": "Origin Feat", "G": "General Feat", "FS": "Fighting Style Feat",
                   "EB": "Epic Boon Feat"}
OPTION_KINDS = {  # featureType -> (one option, the kind's folder name)
    "EI": ("Eldritch Invocation", "Eldritch Invocations"), "MM": ("Metamagic", "Metamagic"),
    "MV": ("Maneuver", "Maneuvers"), "MV:B": ("Maneuver", "Maneuvers"),
    "FS:F": ("Fighting Style", "Fighting Styles"), "FS:R": ("Fighting Style", "Fighting Styles"),
    "FS:P": ("Fighting Style", "Fighting Styles"), "FS:B": ("Fighting Style", "Fighting Styles"),
    "PB": ("Pact Boon", "Pact Boons"), "AS": ("Arcane Shot", "Arcane Shots"),
    "AI": ("Artificer Infusion", "Artificer Infusions"), "ED": ("Elemental Discipline", "Elemental Disciplines"),
    "RN": ("Rune", "Runes"), "AF": ("Alchemical Formula", "Alchemical Formulas")}


def option_kind(entry):
    for t in entry.get("featureType", []):
        if t in OPTION_KINDS:
            return OPTION_KINDS[t]
    return ("Class Option", None)


def ability_increase(abilities):
    out = []
    for a in abilities or []:
        if "choose" in a:
            c = a["choose"]
            names = " or ".join(ABILITIES.get(x, x) for x in c.get("from", []))
            count = f"{c['count']} of " if c.get("count", 1) > 1 else ""
            out.append(f"+{c.get('amount', 1)} to {count}{names}")
        out.extend(f"{ABILITIES[k]} {signed(v)}" for k, v in a.items() if k in ABILITIES)
    return ", ".join(out)


def prerequisite(alternatives):
    out = []
    for alt in alternatives or []:
        parts = []
        for k, v in alt.items():
            if k == "level":
                level = v if isinstance(v, int) else v.get("level")
                cls = v.get("class", {}).get("name") if isinstance(v, dict) else None
                parts.append(f"Level {level}+" + (f" {cls}" if cls else ""))
            elif k == "ability":
                parts.append(" or ".join(f"{ABILITIES.get(a, a)} {n} or higher" for d in v for a, n in d.items()))
            elif k in ("race", "background"):
                parts.append(" or ".join(plain(r.get("displayEntry") or r.get("name", "")) for r in v))
            elif k == "feat":
                parts.append(" or ".join(uid_name(f) for f in v))
            elif k == "spellcasting":
                parts.append("the ability to cast at least one spell")
            elif k == "spellcasting2020":
                parts.append("Spellcasting or Pact Magic feature")
            elif k == "proficiency":
                parts.append(" or ".join(f"proficiency with {w} {kind}" for d in v for kind, w in d.items()))
            elif k in ("other", "otherSummary"):
                parts.append(plain(v.get("entry", "") if isinstance(v, dict) else v))
            elif k == "campaign":
                parts.append(" or ".join(f"{c} Campaign" for c in v))
            elif k == "note":
                continue
            elif isinstance(v, str):
                parts.append(plain(v))
            elif isinstance(v, list) and all(isinstance(x, str) for x in v):
                parts.append(" or ".join(uid_name(x) for x in v))
        if alt.get("note"):
            parts.append(plain(alt["note"]))
        out.append(", ".join(parts))
    return "; or ".join(out)


def mentions_increase(entries):
    return "Ability Score Increase" in json.dumps(entries)


def render_feat(key, feat):
    blocks = [f"# {feat['name']}"]
    if key == "optionalfeature":
        blocks.append(f"*{option_kind(feat)[0]}*")
    elif feat.get("category") in FEAT_CATEGORIES:
        blocks.append(f"*{FEAT_CATEGORIES[feat['category']]}*")
    if feat.get("prerequisite"):
        blocks.append(f"**Prerequisite:** {prerequisite(feat['prerequisite'])}")
    if feat.get("ability") and not mentions_increase(feat.get("entries", [])):
        blocks.append(f"**Ability Score Increase:** {ability_increase(feat['ability'])}")
    return blocks + render_entries(feat.get("entries", []))


def subrace_title(sub):
    race, name = sub.get("raceName", ""), sub.get("name", "")
    return name if race.lower() in name.lower() else f"{name} {race}"


def render_race(key, race, data=None):
    stats = []
    if race.get("ability"):
        stats.append(f"**Ability Scores:** {ability_increase(race['ability'])}")
    if race.get("creatureTypes"):
        stats.append(f"**Creature Type:** {' or '.join(t.capitalize() for t in race['creatureTypes'])}")
    if race.get("size"):
        stats.append(f"**Size:** {' or '.join(SIZES.get(s, s) for s in race['size'])}")
    if race.get("speed") is not None:
        v = race["speed"]
        stats.append(f"**Speed:** {speed(v) if isinstance(v, dict) else speed({'walk': v})}")
    entries = list(race.get("entries", []))
    if key == "race":  # an unnamed subrace is part of its race
        for sub in (data or {}).get("subrace", []):
            if not sub.get("name") and same(sub.get("raceName"), race["name"]) \
                    and same(sub.get("raceSource"), race["source"]):
                entries.extend(sub.get("entries", []))
    title = subrace_title(race) if key == "subrace" else race["name"]
    return [f"# {title}", "\n".join(stats)] + render_entries(entries)


# Class and subclass features, looked up by uid: those of the file being rendered and
# of any file a copied entry came from.
_features = {"classFeature": [], "subclassFeature": []}


def add_features(data):
    for k in _features:
        _features[k].extend(f for f in data.get(k, []) if isinstance(f, dict))


def unpack_feature_uid(uid, subclass):
    """A class feature's uid (name|class|classSource|level|source) or a subclass feature's
    (name|class|classSource|subclassShortName|subclassSource|level|source), with defaults."""
    parts = str(uid).split("|")
    fields = (["name", "className", "classSource", "subclassShortName", "subclassSource", "level", "source"]
              if subclass else ["name", "className", "classSource", "level", "source"])
    ref = dict(zip(fields, parts + [""] * (len(fields) - len(parts))))
    ref["classSource"] = ref["classSource"] or "PHB"
    if subclass:
        ref["subclassSource"] = ref["subclassSource"] or "PHB"
    ref["source"] = ref["source"] or ref["subclassSource" if subclass else "classSource"]
    return ref


def class_feature(uid, subclass=False):
    ref = unpack_feature_uid(uid, subclass)
    for feature in _features["subclassFeature" if subclass else "classFeature"]:
        if all(same(feature.get(k), v) for k, v in ref.items()):
            return feature
    raise Failure(7, f"the {'subclass ' if subclass else ''}feature '{uid}' is not in the file.")


def proficiency_list(items):
    return ", ".join(plain(i.get("full") or i.get("proficiency", "")) if isinstance(i, dict) else plain(i)
                     for i in items)


def skill_choice(skills):
    out = []
    for s in skills:
        if "choose" in s:
            c = s["choose"]
            out.append(f"Choose {c.get('count', 1)}: {', '.join(title_words(x) for x in c.get('from', []))}")
        elif "any" in s:
            out.append(f"Choose any {s['any']}")
        else:
            out.append(", ".join(title_words(k) for k, v in s.items() if v is True))
    return "; ".join(out)


def feature_heading(feature, owner_source):
    suffix = ""
    if not same(feature.get("source"), owner_source):
        where = f"{feature['source']}" + (f" p. {feature['page']}" if feature.get("page") else "")
        suffix = f" (optional; {where})" if feature.get("isClassFeatureVariant") else f" ({where})"
    return f"### {feature['name']}{suffix}"


def features_by_level(uids, subclass, owner_source):
    blocks, level = [], None
    for uid in uids:
        uid = uid.get("classFeature") or uid.get("subclassFeature") if isinstance(uid, dict) else uid
        feature = class_feature(uid, subclass)
        if feature.get("level") != level:
            level = feature.get("level")
            blocks.append(f"## Level {level}")
        blocks.append(feature_heading(feature, owner_source))
        blocks.extend(render_entries(feature.get("entries", []), 2))
    return blocks


def class_table(cls):
    groups = cls.get("classTableGroups", [])
    features = {}
    for uid in cls.get("classFeatures", []):
        uid = uid.get("classFeature") if isinstance(uid, dict) else uid
        feature = class_feature(uid)
        if same(feature.get("source"), cls["source"]):
            features.setdefault(feature.get("level"), []).append(feature["name"])
    labels = ["Level", "Proficiency Bonus", "Features"]
    columns = []
    for g in groups:
        labels.extend(g.get("colLabels", []))
        rows = g.get("rows") or [[c if c else "—" for c in r] for r in g.get("rowsSpellProgression", [])]
        columns.append(rows)
    levels = max([len(c) for c in columns] or [20])
    rows = []
    for i in range(levels):
        row = [str(i + 1), f"+{2 + i // 4}", ", ".join(features.get(i + 1, [])) or "—"]
        for c in columns:
            row.extend(c[i] if i < len(c) else [])
        rows.append(row)
    return table_blocks({"colLabels": labels, "rows": rows})


def render_class(key, cls):
    if key == "subclass":
        return [f"# {cls['name']}", f"*{cls['className']} subclass*"] \
            + features_by_level(cls.get("subclassFeatures", []), True, cls["source"])
    stats = []
    if cls.get("hd"):
        stats.append(f"**Hit Die:** d{cls['hd'].get('faces')}")
    if cls.get("primaryAbility"):
        stats.append("**Primary Ability:** " + " or ".join(
            " and ".join(ABILITIES[k] for k in p if k in ABILITIES) for p in cls["primaryAbility"]))
    if cls.get("proficiency"):
        stats.append(f"**Saving Throws:** {', '.join(ABILITIES.get(a, a) for a in cls['proficiency'])}")
    start = cls.get("startingProficiencies", {})
    for field, label in (("armor", "Armor"), ("weapons", "Weapons"), ("tools", "Tools")):
        if start.get(field):
            stats.append(f"**{label}:** {proficiency_list(start[field])}")
    if start.get("skills"):
        stats.append(f"**Skills:** {skill_choice(start['skills'])}")
    equipment = cls.get("startingEquipment", {})
    if equipment.get("entries"):
        stats.append(f"**Starting Equipment:** {' '.join(inline(e) for e in equipment['entries'])}")
    elif equipment.get("default"):
        stats.append("**Starting Equipment:** " + "; ".join(plain(e) for e in equipment["default"]))
    return [f"# {cls['name']}", "\n".join(stats), "## Class Table"] + class_table(cls) \
        + features_by_level(cls.get("classFeatures", []), False, cls["source"])


RENDERERS = {"spell": render_spell, "monster": render_monster,
             "class": render_class, "subclass": render_class,
             "feat": render_feat, "optionalfeature": render_feat,
             "baseitem": render_item, "item": render_item, "magicvariant": render_item}


# --- Description: the entry's fluff, a section of the note, never of its stat block ----

# Kinds whose fluff is another kind's; every other key's is `<key>Fluff`.
FLUFF_OF = {"baseitem": "item", "magicvariant": "item", "subrace": "race"}
# Data files whose fluff is not in `fluff-<file name>` beside them.
FLUFF_FILES = {"data/items-base.json": "data/fluff-items.json",
               "data/magicvariants.json": "data/fluff-items.json"}
# What a fluff entry may hold besides its text; its images are out of scope.
FLUFF_FIELDS = {"name", "source", "page", "shortName", "className", "classSource", "type",
                "entries", "images", "_meta"}
# Flags that append a text the fluff file shares, from `<prop>Meta` (the 2014 PHB's sidebars
# on uncommon and monstrous races), as 5etools shows it.
FLUFF_SHARED = ("uncommon", "monstrous")


def unsupported_fluff(what, name):
    raise Failure(6, f"unsupported {what} in the description of '{name}': "
                     f"this helper cannot render the entry.")


def fluff_file(path):
    folder, base = os.path.split(path)
    return FLUFF_FILES.get(path, f"{folder}/fluff-{base}")


def fluff_ref(key, entry):
    """The fields that name an entry's fluff: a subrace's is its merged name, "Race (Subrace)"."""
    if key == "subrace":
        race = entry.get("raceName") or ""
        name = f"{race[:-1]}; {entry['name']})" if race.endswith(")") else f"{race} ({entry['name']})"
        return {"name": name, "source": entry.get("source")}
    ref = {"name": entry.get("name"), "source": entry.get("source")}
    if key == "subclass":
        ref.update(className=entry.get("className"), classSource=entry.get("classSource"))
    return ref


def fluff_entries(prop, path, ref):
    for f in load_optional(path).get(prop, []):
        if isinstance(f, dict) and all(same(f.get(k), v) for k, v in ref.items()):
            f = resolve(prop, f, path)
            unknown = sorted(k for k in f if k not in FLUFF_FIELDS and k not in FLUFF_SHARED)
            if unknown:
                unsupported_fluff(", ".join(unknown), ref["name"])
            entries = f.get("entries") or []
            if not isinstance(entries, list):
                malformed(f"the description of '{ref['name']}' is not a list")
            shared = load_optional(path).get(f"{prop}Meta") or {}
            for flag in FLUFF_SHARED:
                if f.get(flag):
                    if flag not in shared:
                        malformed(f"the description of '{ref['name']}' appends a missing '{flag}' text")
                    entries = entries + [shared[flag]]
            return entries
    return []


def description(key, entry, path):
    """The entry's description (its fluff), as entries: [] when it has none, or only images."""
    if key == "subrace" and not entry.get("name"):
        return []
    prop = FLUFF_OF.get(key, key) + "Fluff"
    own = entry.get("fluff")
    if isinstance(own, dict):
        for k in own:
            if k not in FLUFF_FIELDS and k not in (f"_{prop}", f"_append{prop[0].upper()}{prop[1:]}"):
                unsupported_fluff(f"'{k}'", entry.get("name"))
        entries = list(own.get("entries") or [])
        if own.get(f"_{prop}"):
            entries = fluff_entries(prop, fluff_file(path), own[f"_{prop}"]) or entries
        appended = own.get(f"_append{prop[0].upper()}{prop[1:]}")
        if appended:
            entries += fluff_entries(prop, fluff_file(path), appended)
        return entries
    if not entry.get("hasFluff"):
        return []
    entries = fluff_entries(prop, fluff_file(path), fluff_ref(key, entry))
    if key == "subrace":  # a subrace's note holds only what it adds to its race's
        race = fluff_entries(prop, fluff_file(path), {"name": entry.get("raceName"),
                                                      "source": entry.get("raceSource")})
        entries = [e for e in entries if e not in race]
    return entries


def render(key, entry, path, edition=None):
    data = load(path)
    add_features(data)
    if key in ("race", "subrace"):
        blocks = render_race(key, entry, data)
    else:
        blocks = RENDERERS.get(key, render_generic)(key, entry)
    about = render_entries(description(key, entry, path), 1)
    if about:
        # A monster's comes before its stat lines, as in the Monster Manual; any other
        # entry's text has no heading of its own, so its description closes the note.
        at = blocks.index("## Stat Block") if key == "monster" else len(blocks)
        blocks[at:at] = ["## Description"] + about
    if key == "monster":
        blocks.insert(1, statblock_fence(entry, edition))
    return "\n\n".join(b for b in blocks if b) + "\n"


# --- Meta ----------------------------------------------------------------------------

def published(source, path, key):
    for book in load_optional(path).get(key, []):
        if isinstance(book, dict) and same(book.get("id") or book.get("source"), source):
            return book.get("published")
    return None


def edition_of(source):
    """The Edition of a book or Adventure, by its date against the 2024 Player's Handbook."""
    date = published(source, "data/books.json", "book") \
        or published(source, "data/adventures.json", "adventure")
    if not date:
        return None
    threshold = published(EDITION_2024_BOOK, "data/books.json", "book") or EDITION_2024_FALLBACK_DATE
    return "2024" if date >= threshold else "2014"


def meta(key, entry):
    release = source_cache("release")
    page = f" p. {entry['page']}" if entry.get("page") else ""
    facts = {
        "key": key,
        "name": entry["name"],
        "source": entry["source"],
        "page": entry.get("page"),
        "release": release,
        "source_property": f"{entry['source']}{page}, {release}",
        "edition": edition_of(entry["source"]),
        "reprinted_as": entry.get("reprintedAs", []),
    }
    if key == "spell":
        facts["level"] = entry.get("level")
    if key in ("item", "baseitem", "magicvariant"):
        facts["magic"] = is_magic(key, entry)
    if key == "magicvariant":
        facts["generic_variant"] = True
    if key == "subrace":
        facts.update(race=entry.get("raceName"), race_source=entry.get("raceSource"), title=subrace_title(entry))
    if key == "class":
        facts.update({"class": entry["name"], "class_source": entry["source"]})
    if key == "subclass":
        facts.update({"class": entry.get("className"), "class_source": entry.get("classSource"),
                      "short_name": entry.get("shortName")})
    if key == "optionalfeature":
        facts["option_kind"] = option_kind(entry)[1]
    return facts


# --- CLI -----------------------------------------------------------------------------

def main(argv):
    args, opts, flags = [], {}, set()
    i = 0
    while i < len(argv):
        a = argv[i]
        if a in ("--key", "--class-source", "--edition"):
            if i + 1 >= len(argv):
                raise Failure(2, f"{a} needs a value.")
            opts[a] = argv[i + 1]
            i += 2
        elif a == "--meta":
            flags.add(a)
            i += 1
        else:
            args.append(a)
            i += 1
    if len(args) != 3 or not args[0].startswith("data/") \
            or opts.get("--edition", "2024") not in MONSTER_LAYOUTS:
        raise Failure(2, "usage: render-entry.py data/<file> <name> <source> "
                         "[--key <key>] [--class-source <source>] [--edition 2014|2024] [--meta]")
    path, name, source = args
    key, entry = find(path, name, source, opts.get("--key"), opts.get("--class-source"))
    if "--meta" in flags:
        return json.dumps(meta(key, entry), indent=2, ensure_ascii=False) + "\n"
    return render(key, entry, path, opts.get("--edition"))


if __name__ == "__main__":
    try:
        sys.stdout.write(main(sys.argv[1:]))
    except Failure as e:
        print(f"render-entry: {e}", file=sys.stderr)
        sys.exit(e.code)
    except (re.error, KeyError, IndexError, TypeError, ValueError, AttributeError) as e:
        print(f"render-entry: cannot render the entry ({type(e).__name__}: {e}).", file=sys.stderr)
        sys.exit(7)
