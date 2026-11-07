#!/usr/bin/env python3
"""Render one Part of an official Adventure as English notes, for an Import.

  render-adventure.py <adventure id>
  render-adventure.py <adventure id> --part <index> --list [--edition 2014|2024]
  render-adventure.py <adventure id> --part <index> --plan <plan.json> --links <links.json>
                      [--edition 2014|2024] [--attachments <folder>] [--check]

<adventure id> is the Adventure's id in `data/adventures.json` (`SLC`); its text is
`data/adventure/adventure-<id lowercased>.json`, fetched through the Source Cache helper
like every file render-entry.py reads, so DMR_SOURCE_CACHE applies as it does there.
--edition is the Workspace's Edition (2024 by default).

With no other argument, prints JSON about the Adventure: its title, book, date, Edition
and level range, and its Parts — one per top-level division of the book (CONTEXT.md's
Part), in book order, each with its index, name, section id, page and ordinal.

--list prints JSON about one Part, fetching nothing: its word count; its headings (each
named block with a section id: id, name, type, depth under the Part, page); its images
(the size of each cached one, null for one not cached); the notes it links to (each
`links` target: a key, its kind, the entry in the Workspace's Edition, the entries the
book `tagged` that it stands for — itself, or the older entry it reprints — and the key
of the folder it lives in: `reference.monsters`, `reference.magic_items`,
`reference.equipment`, `adventures.<adventure>.items`, or `adventures.<adventure>.parts`
for another Part); and the `unresolved` tags, left as plain text. It fetches no image;
the data files a link needs (bestiaries, items) come through the Source Cache as usual.

--plan and --links render the Part. The split plan is
`{"part_note": "<path>", "sections": [{"id": "<section id>", "note": "<path>"}, …]}`, each
path a note's, from the Workspace root, without `.md`, its name with the name rules
applied; a section also has `"item": true` when it is an item described under its own
heading, whose note goes in the Adventure's Items. Each planned heading becomes its own
note, with everything under it but the planned headings inside it, and the Part note
holds the rest; where a planned heading
stood, its parent note links to it. The links file maps every target key --list gives
to its note's path (`{"monster|Goblin Warrior|XMM": "Reference/Monsters/Goblin_Warrior"}`);
a link is written whether or not that note exists yet (ADR 0013). A creature or item
tag links to its target, an area tag to the note that holds that section (with a heading
anchor when it is not the note's own) or, in another Part, to that Part's note; every
other tag is plain text. Every named block is a heading. Prints JSON: `notes`, the Part
note first, each with its `note` path, `section` id, `source_property`
(`SLC p. 5, v2.36.1, #012`), English Markdown `text`, `images` (as render-entry.py's
--images lists them, named after that note), and `item` (true for an item note). An item
note also has its `portrait`, as render-entry.py's --meta gives an item's: the `image:`
value naming its first image in --attachments (the Adventure's Attachments folder, from
the Workspace root, which a plan with an item note needs), null without one. --check
renders the same and prints nothing, fetching no image: exit 0 means the Part renders;
it needs no --attachments.

Exit codes are render-entry.py's; exit 2 also refuses a plan naming a section not in the
Part or not a heading, a section twice, or two notes of the same name (an Adventure's
note names are unique in it), an `item` neither true nor false, a plan with an item note
but no --attachments (unless --check), and a links file without a target the Part needs.
A Part that does not render (6, 7) is named, with its deepest section that does not.
Nothing is printed on stdout on any error.
"""
import importlib.util
import json
import os
import re
import sys

_spec = importlib.util.spec_from_file_location("render_entry", os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "render-entry.py"))
entry = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(entry)
Failure = entry.Failure


def adventure(adventure_id):
    """The Adventure's record in adventures.json, and its text's Parts."""
    for record in entry.load("data/adventures.json").get("adventure", []):
        if isinstance(record, dict) and entry.same(record.get("id"), adventure_id):
            break
    else:
        raise Failure(5, f"no Adventure with the id '{adventure_id}' in data/adventures.json.")
    parts = entry.load(f"data/adventure/adventure-{record['id'].lower()}.json").get("data")
    if not isinstance(parts, list):
        raise Failure(7, f"the Adventure '{record['id']}' has no Parts.")
    return record, parts


def ordinal(content):
    o = (content or {}).get("ordinal") or {}
    return f"{o['type']} {o['identifier']}" if o.get("type") and "identifier" in o else None


def parts_listing(record, parts):
    contents = record.get("contents") or []
    if len(contents) != len(parts):
        contents = [{}] * len(parts)  # no way to pair them: no ordinals
    return {
        "title": record.get("name"),
        "id": record["id"],
        "source": record.get("source"),
        "published": record.get("published"),
        "edition": entry.edition_of(record["id"]),
        "level": record.get("level"),
        "parts": [{"index": i, "name": p.get("name"), "id": p.get("id"), "page": p.get("page"),
                   "ordinal": ordinal(contents[i])} for i, p in enumerate(parts)],
    }


def nodes(node):
    """Every dict in node's tree, in book order."""
    if isinstance(node, dict):
        yield node
        for v in node.values():
            yield from nodes(v)
    elif isinstance(node, list):
        for v in node:
            yield from nodes(v)


def headings(node, depth=0, page=None):
    """Every named node with a section id, its depth under the Part and its page (its
    own, else the nearest one above it)."""
    found = []
    if isinstance(node, dict):
        page = node.get("page", page)
        if node.get("id") and node.get("name"):
            found.append({"id": node["id"], "name": entry.plain(node["name"]),
                          "type": node.get("type", "entries"), "depth": depth, "page": page})
            depth += 1
        for v in node.values():
            found += headings(v, depth, page)
    elif isinstance(node, list):
        for v in node:
            found += headings(v, depth, page)
    return found


# Keys whose strings are not text the reader sees.
NOT_TEXT = {"type", "id", "page", "href", "path", "source", "imageType", "style", "credit", "tag",
            "prop", "hrefThumbnail", "mapRegions", "grid", "area", "colStyles", "width", "height"}


def words(node):
    if isinstance(node, str):
        return len(entry.plain(node).split())
    if isinstance(node, list):
        return sum(words(v) for v in node)
    if isinstance(node, dict):
        return sum(words(v) for k, v in node.items() if k not in NOT_TEXT)
    return 0


def cached_size(path):
    """The size of an image's cached copy, or None when it is not cached; never fetches."""
    try:
        return os.path.getsize(entry.source_cache("cached-image", path))
    except Failure as e:
        if e.code == 4:
            return None
        raise


def part_listing(record, parts, index, edition):
    part = parts[index]
    links = collect_links(Links(record, edition, parts, index), part)
    images = [n["href"]["path"] for n in nodes(part)
              if n.get("type") == "image" and (n.get("href") or {}).get("type") == "internal"]
    return {
        "name": part.get("name"),
        "id": part.get("id"),
        "page": part.get("page"),
        "words": words(part),
        "headings": headings(part.get("entries", [])),
        "images": [{"image": p, "size": cached_size(p)} for p in images],
        "links": sorted(links.targets.values(), key=lambda t: t["key"]),
        "unresolved": list(dict.fromkeys(links.unresolved)),
    }


def load_json(path, what):
    try:
        with open(path, encoding="utf-8") as f:
            return json.load(f)
    except (OSError, ValueError) as e:
        raise Failure(2, f"cannot read the {what} {path}: {e}")


def by_id(node):
    """Each node with a section id, by its id."""
    return {n["id"]: n for n in nodes(node) if n.get("id")}


def link(path, name):
    return f"[[{path}|{entry.plain(name)}]]"


def cut(node, notes, root):
    """node's tree with each planned section under it — but not root itself — replaced by
    a link to its note, where it stood."""
    if isinstance(node, dict):
        if node is not root and node.get("id") in notes:
            return link(notes[node["id"]], node.get("name", ""))
        return {k: cut(v, notes, root) for k, v in node.items()}
    if isinstance(node, list):
        return [cut(v, notes, root) for v in node]
    return node


# --- Links (ADR 0013): to Reference, to the Adventure's Items, to another Part ------------

DEFAULT_SOURCES = {"creature": "MM", "item": "DMG"}


def find_monster(name, source):
    index = entry.load_optional("data/bestiary/index.json")
    file = next((f for s, f in index.items() if entry.same(s, source)), None)
    if not file:
        return None
    for m in entry.load(f"data/bestiary/{file}").get("monster", []):
        if isinstance(m, dict) and entry.same(m.get("name"), name) and entry.same(m.get("source"), source):
            return m
    return None


def find_in(path, key, name, source):
    for e in entry.load_optional(path).get(key, []):
        if isinstance(e, dict) and entry.same(e.get("name"), name) and entry.same(e.get("source"), source):
            return e
    return None


def requirement_met(variant, base):
    return any(all(base.get(k) == v for k, v in req.items()) for req in variant.get("requires") or [])


def find_item(name, source):
    """The item entry a tag names, and whether it is magic. A specific magic item the
    Trusted Source builds from a generic variant and a base item ("+1 Longsword") is no
    entry: it is its generic variant, as an Import brings it in (ADR 0007)."""
    found = find_in("data/items.json", "item", name, source)
    if found:
        return found, found.get("rarity") not in entry.NOT_MAGIC
    found = find_in("data/items-base.json", "baseitem", name, source)
    if found:
        return found, False
    for variant in entry.load_optional("data/magicvariants.json").get("magicvariant", []):
        generic = entry.generic_variant(variant)
        inherits = variant.get("inherits") or {}
        prefix, suffix = inherits.get("namePrefix", ""), inherits.get("nameSuffix", "")
        if not (prefix or suffix) or not entry.same(generic.get("source"), source):
            continue
        low = name.lower()
        if low.startswith(prefix.lower()) and low.endswith(suffix.lower()):
            base_name = name[len(prefix):len(name) - len(suffix)]
            for base in entry.load_optional("data/items-base.json").get("baseitem", []):
                if isinstance(base, dict) and entry.same(base.get("name"), base_name) \
                        and requirement_met(variant, base):
                    return generic, True
    return None, False


def adventure_sources(record):
    """The book codes an Adventure's own entries carry: its own, and, for one Adventure of
    an anthology (`TftYP-ToH`), the anthology's when that is no book of its own."""
    sources = {record["id"].lower(), str(record.get("source", "")).lower()}
    anthology = record["id"].split("-")[0]
    books = {str(b.get("id")).lower() for b in entry.load_optional("data/books.json").get("book", [])}
    if "-" in record["id"] and anthology.lower() not in books:
        sources.add(anthology.lower())
    return sources


def in_edition(found, edition):
    """The (name, source) a link names: the Edition's reprint of a 2014 entry in a 2024
    Workspace, when the Trusted Source records one, else the entry itself."""
    reprints = found.get("reprintedAs") or []
    if edition == "2024" and reprints and entry.edition_of(found["source"]) == "2014":
        first = reprints[0]
        name, _, source = (first.get("uid", "") if isinstance(first, dict) else str(first)).partition("|")
        if name and source:
            return name, source
    return found["name"], found["source"]


class Links:
    """Resolves the tags an Adventure note links, and records the ones it cannot."""

    def __init__(self, record, edition, parts, index):
        self.record, self.edition, self.parts, self.index = record, edition, parts, index
        self.part_of = {i: n for n, p in enumerate(parts) for i in by_id(p)}
        self.local = {}  # a section id of this Part -> the link target holding it
        self.targets, self.unresolved = {}, []

    def target(self, tag, body):
        fields = entry.split_top(body, "|")
        name = entry.plain(fields[0]).strip()
        source = (fields[1] if len(fields) > 1 else "").strip() or DEFAULT_SOURCES.get(tag)
        if tag == "creature":
            found = find_monster(name, source)
            if found is None:
                return None
            name, source = in_edition(found, self.edition)
            return {"key": f"monster|{name}|{source}", "kind": "monster", "name": name, "source": source,
                    "tagged": [f"{found['name']}|{found['source']}"], "folder": "reference.monsters"}
        if tag == "item":
            found, magic = find_item(name, source)
            if found is None:
                return None
            if str(found["source"]).lower() in adventure_sources(self.record):
                # An Adventure is not tied to an Edition: its own item stays its own.
                folder, (name, source) = "adventures.<adventure>.items", (found["name"], found["source"])
            else:
                folder = "reference.magic_items" if magic else "reference.equipment"
                name, source = in_edition(found, self.edition)
            return {"key": f"item|{name}|{source}", "kind": "item", "name": name, "source": source,
                    "tagged": [f"{found['name']}|{found['source']}"], "folder": folder}
        if tag == "area":
            section = fields[1].strip() if len(fields) > 1 else ""
            n = self.part_of.get(section)
            if n is None:
                return None
            if n == self.index:  # in this Part: the note the split plan gives it
                return {"key": None, "kind": "area", "id": section}
            return {"key": f"part|{n}", "kind": "part", "name": entry.plain(self.parts[n].get("name", "")),
                    "index": n, "folder": "adventures.<adventure>.parts"}
        return None

    def collect(self, tag, body):
        """A LINK_TAG that records each target, writing no link."""
        if tag in ("creature", "item", "area"):
            found = self.target(tag, body)
            if not found:
                self.unresolved.append("{@" + f"{tag} {body}" + "}")
            elif found["key"]:
                listed = self.targets.setdefault(found["key"], found)
                for t in found.get("tagged", []):  # every entry the book tags, reprinted as this one
                    if t not in listed["tagged"]:
                        listed["tagged"].append(t)
        return None

    def linker(self, paths):
        """A LINK_TAG writing each target's link, with the path the caller gave it."""
        def link_tag(tag, body):
            found = self.target(tag, body) if tag in ("creature", "item", "area") else None
            if not found:
                return None
            path = paths[found["key"]] if found["key"] else self.local[found["id"]]
            return f"[[{path}|{entry.tag_text(tag, body)}]]"
        return link_tag

    def place(self, part, notes, part_note):
        """Where each section of this Part ends up: its own note, or a heading of the note
        that holds it (a named block is always a heading there), or just that note."""
        def walk(node, owner):
            if isinstance(node, dict):
                section = node.get("id")
                if section in notes:
                    owner = notes[section]
                    self.local[section] = owner
                elif section:
                    named = node.get("name") and node.get("type", "entries") in ("entries", "section")
                    anchor = "".join(c for c in entry.plain(node["name"]) if c not in "#|^[]") if named else ""
                    self.local[section] = f"{owner}#{anchor}" if anchor else owner
                for v in node.values():
                    walk(v, owner)
            elif isinstance(node, list):
                for v in node:
                    walk(v, owner)
        walk(part, part_note)
        self.local[part.get("id")] = part_note


def strings(node):
    """Every text string in node's tree, in book order."""
    if isinstance(node, str):
        yield node
    elif isinstance(node, list):
        for v in node:
            yield from strings(v)
    elif isinstance(node, dict):
        for k, v in node.items():
            if k not in NOT_TEXT:
                yield from strings(v)


def collect_links(links, part):
    entry.LINK_TAG = links.collect
    try:
        for s in strings(part):
            entry.plain(s)
    finally:
        entry.LINK_TAG = None
    return links


def source_property(record, node, page, release):
    page = node.get("page", page)
    return f"{record['source']}{f' p. {page}' if page else ''}, {release}, #{node['id']}"


def failing_section(part):
    """The deepest section of the Part that does not render on its own."""
    found = part
    for node in nodes(part):
        if node.get("id") and node.get("name"):
            try:
                entry.render_entries(entry.children(node))
            except Failure:
                found = node
    return found


def check_plan(part, plan):
    """Refuse a split plan that names no heading of this Part, a heading twice, or two
    notes with the same name: an Adventure's note names are unique in it."""
    sections = plan.get("sections") if isinstance(plan, dict) else None
    if not isinstance(sections, list) or not isinstance(plan.get("part_note"), str) \
            or not all(isinstance(s, dict) and isinstance(s.get("id"), str) and isinstance(s.get("note"), str)
                       for s in sections):
        raise Failure(2, 'a split plan is {"part_note": "<path>", "sections": [{"id": "<section id>", '
                         '"note": "<path>"}, …]}, each path from the Workspace root without .md.')
    found, problems = by_id(part), []
    for path in [plan["part_note"]] + [s["note"] for s in sections]:
        folder, _, name = path.rpartition("/")
        if not entry.valid_note(name) or folder and not entry.valid_folder(folder):
            problems.append(f"'{path}' is not a note path with the name rules applied")
    for s in sections:
        if not isinstance(s.get("item", False), bool):
            problems.append(f"section {s['id']}'s item is neither true nor false")
        node = found.get(s["id"])
        if node is None:
            problems.append(f"section {s['id']} is not in this Part")
        elif node is part or not node.get("name") or node.get("type", "entries") not in ("entries", "section"):
            problems.append(f"section {s['id']} is not a heading of this Part")
    ids = [s["id"] for s in sections]
    problems += [f"section {i} is planned twice" for i in sorted({i for i in ids if ids.count(i) > 1})]
    names = [p.rpartition("/")[2] for p in [plan["part_note"]] + [s["note"] for s in sections]]
    same_name = {n for n in names if [m.lower() for m in names].count(n.lower()) > 1}
    problems += [f"two notes are named {n}" for n in sorted({n.lower(): n for n in same_name}.values())]
    if problems:
        raise Failure(2, "the split plan cannot be rendered: " + "; ".join(problems) + ".")


def render_plan(record, parts, index, plan, paths, edition, check=False, attachments=None):
    """The Part note and one note per planned section, each with its images; with check,
    the same rendering with no image fetched, and nothing returned."""
    part = parts[index]
    check_plan(part, plan)
    if not check and not attachments and any(s.get("item") for s in plan["sections"]):
        raise Failure(2, "the split plan has an item note, whose Portrait needs --attachments "
                         "(the Adventure's Attachments folder, from the Workspace root).")
    try:
        try:
            return render_notes(record, parts, index, plan, paths, edition, check, attachments)
        except Failure as e:
            if e.code not in (6, 7):
                raise
            entry.FETCH_IMAGES = False
            where = failing_section(part)
            section = f", section {where['id']} ({entry.plain(where['name'])})" if where is not part else ""
            raise Failure(e.code, f"Part {index} ({part.get('name')}){section}: {e}")
    finally:  # render-entry.py's own rendering, for whatever renders next
        entry.ALWAYS_HEADINGS, entry.LINK_TAG, entry.FETCH_IMAGES = False, None, True


def render_notes(record, parts, index, plan, paths, edition, check, attachments):
    part = parts[index]
    notes = {s["id"]: s["note"] for s in plan["sections"]}
    items = {s["note"] for s in plan["sections"] if s.get("item")}
    pages = {h["id"]: h["page"] for h in headings(part, 0, part.get("page"))}
    sections = by_id(part)
    links = collect_links(Links(record, edition, parts, index), part)
    links.place(part, notes, plan["part_note"])
    missing = sorted(k for k in links.targets if k not in paths)
    if missing:
        raise Failure(2, f"the links file gives no note for: {', '.join(missing)}.")
    release = entry.source_cache("release")
    entry.ALWAYS_HEADINGS = True
    entry.LINK_TAG = links.linker(paths)
    entry.FETCH_IMAGES = not check
    rendered = []
    for node, path in [(part, plan["part_note"])] + [(sections[i], p) for i, p in notes.items()]:
        body = cut(node, notes, node)
        text = "\n\n".join(b for b in [f"# {entry.plain(node['name'])}"]
                           + entry.render_entries(entry.children(body)) if b) + "\n"
        text, images = entry.embed_images(text, path.rsplit("/", 1)[-1])
        note = {"note": path, "section": node["id"],
                "source_property": source_property(record, node, pages.get(node["id"]), release),
                "text": text, "images": images, "item": path in items}
        if path in items:  # its Portrait, for its frontmatter's `image:`: its first image
            note["portrait"] = f"[[{attachments}/{images[0]['file']}]]" if images else None
        rendered.append(note)
    return None if check else {"adventure": record["id"], "notes": rendered}


USAGE = ("usage: render-adventure.py <adventure id> [--edition 2014|2024] [--part <index> "
         "(--list | --plan <plan.json> --links <links.json> [--attachments <folder>] [--check])]")


def main(argv):
    args, opts, flags = [], {}, set()
    i = 0
    while i < len(argv):
        a = argv[i]
        if a in ("--part", "--plan", "--links", "--edition", "--attachments"):
            if i + 1 >= len(argv):
                raise Failure(2, f"{a} needs a value.")
            opts[a] = argv[i + 1]
            i += 2
        elif a in ("--list", "--check"):
            flags.add(a)
            i += 1
        else:
            args.append(a)
            i += 1
    rendering = "--plan" in opts and "--links" in opts
    if len(args) != 1 or "--part" not in opts and (flags or set(opts) - {"--edition"}) \
            or "--part" in opts and ("--list" in flags) == rendering \
            or "--check" in flags and not rendering \
            or ("--plan" in opts) != ("--links" in opts) \
            or "--attachments" in opts and not (rendering and entry.valid_folder(opts["--attachments"])) \
            or opts.get("--edition", "2024") not in entry.MONSTER_LAYOUTS:
        raise Failure(2, USAGE)
    record, parts = adventure(args[0])
    if "--part" not in opts:
        return json.dumps(parts_listing(record, parts), indent=2, ensure_ascii=False) + "\n"
    index = opts["--part"]
    if not index.isdigit() or int(index) >= len(parts):
        raise Failure(2, f"the Adventure '{record['id']}' has no Part {index}: its Parts are 0 to {len(parts) - 1}.")
    part = parts[int(index)]
    if "--list" in flags:
        return json.dumps(part_listing(record, parts, int(index), opts.get("--edition", "2024")),
                          indent=2, ensure_ascii=False) + "\n"
    plan = load_json(opts["--plan"], "split plan")
    paths = load_json(opts["--links"], "links file")
    rendered = render_plan(record, parts, int(index), plan, paths, opts.get("--edition", "2024"),
                           "--check" in flags, opts.get("--attachments"))
    return "" if rendered is None else json.dumps(rendered, indent=2, ensure_ascii=False) + "\n"


if __name__ == "__main__":
    try:
        sys.stdout.write(main(sys.argv[1:]))
    except (Failure, entry.statblock.Failure) as e:
        print(f"render-adventure: {e}", file=sys.stderr)
        sys.exit(e.code)
    except (re.error, KeyError, IndexError, TypeError, ValueError, AttributeError) as e:
        print(f"render-adventure: cannot render the Adventure ({type(e).__name__}: {e}).", file=sys.stderr)
        sys.exit(7)
