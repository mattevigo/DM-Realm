#!/usr/bin/env python3
"""The Player Wiki of a DM Realm Workspace: the parts the DM chose, copied for the players.

  player-wiki.py write <workspace>
      Write the Player Wiki that the Workspace Config's `player_wiki` key describes, as
      structure.md's "Player Wiki" defines it, into its `output` folder, rewritten from
      scratch: every note of the parts included, at its own path, with
        - a link to a note left out made plain text (its alias, else its name), an embed of
          one dropped, and every file a note links to or embeds copied, at its own path;
        - a monster's or an NPC's stat block fence written as DM Realm's Markdown, its labels
          the Translation Glossary's, and a Character's fence dropped (its Build is Markdown);
        - in World and Homebrew notes, each section headed by one of `dm_only_headings` and
          every `%% … %%` comment removed;
        - its `#` heading moved into a frontmatter `title:`;
      and an `index.md` home page linking each part. The Workspace is never changed. Prints
      a report: what was written, the links made plain text, the sections removed by note.

The Config's key, read by this script alone (keys never translated):

  player_wiki:
    output: /absolute/path/outside/the/Workspace
    include: [reference, homebrew, world, characters]   # any of these four
    chronicles: [<Campaign folder>, …]                  # each Campaign whose Chronicle goes in
    dm_only_headings: [<heading>, …]                    # in the Workspace Language

Folder names come from the Workspace Config and the Translation Glossary (rows "Chronicle",
"Voice", "Past_Builds", "House_Rules", "Spells"; in an English Workspace, those words).

Exit 2: bad usage, not a Workspace, no or bad `player_wiki` key. Exit 3: `output` is not an
absolute path outside the Workspace (nor one holding it). Exit 5: `output` holds files and
is not a Player Wiki DM Realm wrote (no marker file); nothing is deleted.
"""
import importlib.util
import json
import os
import re
import shutil
import sys
import unicodedata
from urllib.parse import unquote

HERE = os.path.dirname(os.path.abspath(__file__))
_spec = importlib.util.spec_from_file_location("statblock", os.path.join(HERE, "statblock.py"))
statblock = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(statblock)
_spec = importlib.util.spec_from_file_location("spell_index", os.path.join(HERE, "spell-index.py"))
spell_index = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(spell_index)

CONFIG = "workspace-config.yml"
MARKER = ".dm-realm-player-wiki"
PARTS = ("reference", "homebrew", "world", "characters")
FILTERED = ("homebrew", "world")  # the DM's own notes that may hold secrets
FRONTMATTER = re.compile(r"---\n(.*?\n)?---\n", re.S)
CODE_FENCE = re.compile(r"^[ \t]*(```|~~~)")
HEADING = re.compile(r"^(#{1,6})[ \t]+(.*?)[ \t#]*$")
WIKILINK = re.compile(r"(!?)\[\[([^\]\n]*)\]\]")
MDLINK = re.compile(r"(!?)\[([^\]\n]*)\]\(<?([^)\s>]+)>?(?:[ \t]+\"[^\"\n]*\")?\)")
INLINE = re.compile(r"`[^`\n]+`|" + WIKILINK.pattern + "|" + MDLINK.pattern)
COMMENT = re.compile(r"%%.*?(?:%%|\Z)", re.S)


class Failure(Exception):
    def __init__(self, code, message):
        super().__init__(message)
        self.code = code


# --- The Config ------------------------------------------------------------------------

def scalar(text):
    text = re.sub(r"\s+#.*$", "", text).strip()
    return text[1:-1] if len(text) >= 2 and text[0] == text[-1] and text[0] in "\"'" else text


def player_wiki(workspace):
    """The `player_wiki` key: {output, include, chronicles, dm_only_headings}."""
    with open(os.path.join(workspace, CONFIG), encoding="utf-8") as f:
        lines = f.read().splitlines()
    start = next((i for i, l in enumerate(lines) if re.match(r"player_wiki:\s*(#.*)?$", l)), None)
    if start is None:
        raise Failure(2, f"the Workspace Config has no player_wiki key; nothing was written.")
    found, key = {}, None
    for line in lines[start + 1:]:
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        if not line.startswith(" "):
            break
        item = re.match(r"\s+-\s+(.*)$", line)
        if item and key:
            found[key].append(scalar(item.group(1)))
            continue
        pair = re.match(r"\s+([a-z_]+):\s*(.*)$", line)
        if not pair:
            raise Failure(2, f"player_wiki: cannot read the line {line.strip()!r}.")
        key, value = pair.group(1), re.sub(r"\s+#.*$", "", pair.group(2)).strip()
        if value.startswith("["):
            inner = value.strip("[]").strip()
            found[key] = [scalar(v) for v in inner.split(",")] if inner else []
        elif value:
            found[key] = scalar(value)
        else:
            found[key] = []
    output = found.get("output")
    if not isinstance(output, str) or not output:
        raise Failure(2, "player_wiki has no output folder.")
    config = {"output": output}
    for name in ("include", "chronicles", "dm_only_headings"):
        value = found.get(name, [])
        config[name] = [value] if isinstance(value, str) else [v for v in value if v]
    wrong = [p for p in config["include"] if p not in PARTS]
    if wrong:
        raise Failure(2, f"player_wiki cannot include {', '.join(wrong)}: only {', '.join(PARTS)} "
                         "and the Chronicles of the Campaigns named in chronicles can go in.")
    return config


def check_output(workspace, output):
    if not os.path.isabs(os.path.expanduser(output)):
        raise Failure(3, f"the Player Wiki's output must be an absolute path: {output}")
    out = os.path.realpath(os.path.expanduser(output))
    root = os.path.realpath(workspace)
    if out == root or out.startswith(root + os.sep):
        raise Failure(3, f"the Player Wiki cannot be inside the Workspace ({out}): Obsidian would "
                         "index every note twice. Choose a folder outside it.")
    if root.startswith(out + os.sep):
        raise Failure(3, f"the Player Wiki's output {out} holds the Workspace; choose a folder outside it.")
    if os.path.exists(out) and not os.path.isdir(out):
        raise Failure(3, f"the Player Wiki's output {out} is a file, not a folder.")
    if os.path.isdir(out):
        visible = [n for n in os.listdir(out) if not n.startswith(".")]
        if visible and not os.path.isfile(os.path.join(out, MARKER)):
            raise Failure(5, f"{out} holds files and is not a Player Wiki DM Realm wrote (no {MARKER}); "
                             "nothing was deleted. Choose an empty or new folder.")
    return out


# --- The Workspace's files -------------------------------------------------------------

def walk(base):
    """Every file under base, as paths relative to base with `/`, dot-folders left out."""
    for top, dirs, files in os.walk(base):
        dirs[:] = sorted(d for d in dirs if not d.startswith("."))
        for name in sorted(files):
            if not name.startswith("."):
                yield os.path.relpath(os.path.join(top, name), base).replace(os.sep, "/")


class Files:
    """The Workspace's files, and Obsidian's resolution of a link to one."""

    def __init__(self, workspace):
        self.all = [f for f in walk(workspace) if "/" in f]  # the root holds no note
        self.exact = {f: f for f in self.all}
        self.lower, self.names = {}, {}
        for f in self.all:
            self.lower.setdefault(f.casefold(), []).append(f)
            base = f.rsplit("/", 1)[-1]
            for key in {base, base[:-3] if base.endswith(".md") else None} - {None}:
                self.names.setdefault(key.casefold(), []).append(f)

    def resolve(self, target, here=None):
        """(file, why): the file a link names, or None and 'missing' or 'ambiguous'."""
        target = target.strip().lstrip("/")
        if not target:
            return None, "missing"
        candidates = [target, target + ".md"]
        if here:
            joined = os.path.normpath(os.path.join(os.path.dirname(here), target)).replace(os.sep, "/")
            candidates = [joined, joined + ".md"] + candidates
        for c in candidates:
            if c in self.exact:
                return c, None
        for c in candidates:
            hits = self.lower.get(c.casefold(), [])
            if len(hits) == 1:
                return hits[0], None
        if "/" in target:
            ends = [f for f in self.all if f.casefold().endswith("/" + target.casefold())
                    or f.casefold().endswith("/" + target.casefold() + ".md")]
            return (ends[0], None) if len(ends) == 1 else (None, "ambiguous" if ends else "missing")
        hits = self.names.get(target.casefold(), [])
        if len(hits) == 1:
            return hits[0], None
        return None, "ambiguous" if hits else "missing"


def selection(workspace, config, terms):
    """{note path: part} of every note going into the Player Wiki, and the warnings."""
    notes, warnings = {}, []
    past_builds = terms.get("Past_Builds", "Past_Builds")
    for part in config["include"]:
        name = spell_index.folder(workspace, part)
        base = os.path.join(workspace, name or "")
        if not name or not os.path.isdir(base):
            warnings.append(f"{part}: no {name or part} folder in the Workspace yet.")
            continue
        for f in walk(base):
            if not f.endswith(".md"):
                continue
            if part == "characters" and f.split("/")[1:2] == [past_builds]:
                continue
            notes[f"{name}/{f}"] = part
    campaigns = spell_index.folder(workspace, "campaigns")
    chronicle = terms.get("Chronicle", "Chronicle")
    voice = terms.get("Voice", "Voice") + ".md"
    for campaign in config["chronicles"]:
        base = os.path.join(workspace, campaigns or "", campaign, chronicle)
        if not campaigns or not os.path.isdir(base):
            warnings.append(f"chronicles: {campaign} has no {chronicle} folder; left out.")
            continue
        for f in walk(base):
            if f.endswith(".md") and f != voice:
                notes[f"{campaigns}/{campaign}/{chronicle}/{f}"] = "chronicle"
    return notes, warnings


# --- A note's text ---------------------------------------------------------------------

def split_frontmatter(text):
    m = FRONTMATTER.match(text)
    return (m.group(1) or "", text[m.end():]) if m else (None, text)


def outside_code(text, change):
    """The text with change() applied to every part that is not a fenced code block."""
    out, prose, fence = [], [], None
    for line in text.splitlines(keepends=True):
        m = CODE_FENCE.match(line)
        if fence is None and m:
            out.append(change("".join(prose)))
            prose, fence = [], m.group(1)
            out.append(line)
        elif fence is not None:
            out.append(line)
            if m and m.group(1) == fence:
                fence = None
        else:
            prose.append(line)
    out.append(change("".join(prose)))
    return "".join(out)


def words(path):
    name = path.rsplit("/", 1)[-1]
    return (name[:-3] if name.endswith(".md") else name).replace("_", " ")


def stat_blocks(text, labels, report, path):
    """The note with each monster's fence as Markdown and each Character's fence dropped."""
    changed = False
    for m in reversed(list(statblock.FENCE.finditer(text))):
        try:
            fields = statblock.parse_fence(m.group(1))
            if dict(fields).get("layout") == statblock.CHARACTER_LAYOUT:
                text = text[:m.start()] + text[m.end():].lstrip("\n")
            else:
                text = text[:m.start()] + statblock.markdown(fields, labels) + text[m.end():]
            changed = True
        except statblock.Failure as e:
            report["kept_fences"].append(f"{path}: {e}")
    return statblock.set_flag(text, False) if changed else text


def strip_dm_only(body, headings):
    """(the body without the DM-only sections and %% comments, the headings removed)."""
    wanted = {h.strip().casefold() for h in headings}
    kept, removed, skipping, fence = [], [], None, None
    for line in body.splitlines(keepends=True):
        m = CODE_FENCE.match(line)
        if m and fence is None:
            fence = m.group(1)
        elif m and m.group(1) == fence:
            fence = None
            if skipping is not None:
                continue
        heading = HEADING.match(line.rstrip("\n")) if fence is None and not m else None
        if heading and skipping is not None and len(heading.group(1)) <= skipping:
            skipping = None
        if heading and skipping is None and heading.group(2).strip().casefold() in wanted:
            skipping = len(heading.group(1))
            removed.append(heading.group(2).strip())
        if skipping is None:
            kept.append(line)
    text = "".join(kept)
    comments = []

    def drop(match):
        comments.append(match.group(0))
        return ""
    text = outside_code(text, lambda prose: COMMENT.sub(drop, prose))
    if comments:
        removed.append(f"{len(comments)} %% comment{'s' if len(comments) > 1 else ''}")
    return text, removed


def take_title(front, body):
    """(frontmatter, body): the first `#` heading moved into `title:`."""
    lines = body.splitlines(keepends=True)
    fence = None
    for i, line in enumerate(lines):
        m = CODE_FENCE.match(line)
        if m:
            fence = m.group(1) if fence is None else (None if m.group(1) == fence else fence)
            continue
        h = HEADING.match(line.rstrip("\n"))
        if fence is None and h and len(h.group(1)) == 1:
            title = h.group(2).strip()
            rest = lines[i + 1:]
            if rest and not rest[0].strip():
                rest = rest[1:]
            body = "".join(lines[:i] + rest)
            if front is None:
                front = ""
            if not re.search(r"^title:", front, re.M):
                front = f"title: {json.dumps(title, ensure_ascii=False)}\n" + front
            return front, body
    return front, body


class Links:
    """Rewrites a note's links for the Player Wiki, collecting the files to copy."""

    def __init__(self, files, notes, report):
        self.files, self.notes, self.report = files, notes, report
        self.copy = set()

    def wikilink(self, m, here):
        bang, inner = m.group(1), m.group(2)
        target, _, alias = inner.partition("|")
        file_part = re.split(r"[#^]", target, 1)[0]
        if not file_part.strip():  # a link inside the note itself
            return m.group(0)
        found, why = self.files.resolve(file_part)
        if found and (found in self.notes or not found.endswith(".md")):
            if not found.endswith(".md"):
                self.copy.add(found)
            return m.group(0)
        self.count(here, why)
        if bang:
            return ""
        return alias.strip() if alias.strip() else words(file_part.strip())

    def mdlink(self, m, here):
        bang, text, url = m.group(1), m.group(2), m.group(3)
        if re.match(r"[a-z][a-z0-9+.-]*:", url, re.I) or url.startswith("#"):
            return m.group(0)
        found, why = self.files.resolve(unquote(url.split("#", 1)[0]), here)
        if found and (found in self.notes or not found.endswith(".md")):
            if not found.endswith(".md"):
                self.copy.add(found)
            return m.group(0)
        self.count(here, why)
        return "" if bang else text

    def count(self, here, why):
        self.report["plain"] += 1
        self.report["plain_notes"].add(here)
        if why == "ambiguous":
            self.report["ambiguous"].add(here)

    def rewrite(self, text, here):
        def one(m):
            if m.group(0).startswith("`"):
                return m.group(0)
            if m.group(0).lstrip("!").startswith("[["):
                return self.wikilink(WIKILINK.match(m.group(0)), here)
            return self.mdlink(MDLINK.match(m.group(0)), here)
        return outside_code(text, lambda prose: INLINE.sub(one, prose))


def note_for_wiki(text, path, part, config, labels, links, report):
    text = stat_blocks(text, labels, report, path)
    front, body = split_frontmatter(text)
    if part in FILTERED:
        body, removed = strip_dm_only(body, config["dm_only_headings"])
        if removed:
            report["removed"].append((path, removed))
    front, body = take_title(front, body)
    if front is not None:
        front = links.rewrite(front, path)
    body = re.sub(r"\n{3,}", "\n\n", links.rewrite(body, path)).strip("\n") + "\n"
    return (f"---\n{front}---\n\n" if front else "") + body


# --- The home page ---------------------------------------------------------------------

def sort_key(text):
    plain = unicodedata.normalize("NFKD", text)
    return "".join(c for c in plain if not unicodedata.combining(c)).casefold()


def link_to(path, files):
    """A wikilink to a note: by name when no other file shares it, else by path."""
    name = path.rsplit("/", 1)[-1][:-3]
    target = name if len(files.names.get(name.casefold(), [])) == 1 else path[:-3]
    shown = name.replace("_", " ")
    return f"[[{target}]]" if shown == target else f"[[{target}|{shown}]]"


def home_page(workspace, config, notes, files, terms):
    """index.md: a section per part, linking its front doors."""
    title = words(os.path.basename(os.path.realpath(workspace)))
    blocks = [f"---\ntitle: {json.dumps(title, ensure_ascii=False)}\n---"]

    def section(heading, paths, level=2):
        paths = sorted(paths, key=lambda p: sort_key(words(p)))
        if paths:
            blocks.append(f"{'#' * level} {heading}\n\n" + "\n".join(f"- {link_to(p, files)}" for p in paths))

    def under(folder, depth):
        """The notes going in whose path is folder/ plus depth more parts."""
        return [p for p in notes if p.startswith(folder + "/") and p.count("/") == folder.count("/") + depth]

    for part in config["include"]:
        name = spell_index.folder(workspace, part)
        if not name:
            continue
        if part == "reference":
            spells = spell_index.spells_folder(workspace, terms)
            front = under(os.path.relpath(spells, workspace).replace(os.sep, "/"), 1) if spells else []
        elif part == "homebrew":
            front = under(f"{name}/{terms.get('House_Rules', 'House_Rules')}", 1)
        elif part == "world":  # each world's overview notes, else all its notes
            worlds = sorted({p.split("/")[1] for p in notes if p.startswith(name + "/") and p.count("/") >= 2})
            front = []
            for world in worlds:
                mine = [p for p in notes if p.startswith(f"{name}/{world}/")]
                front += [p for p in mine if p.count("/") == 2] or mine
        else:
            front = [p for p in notes if p.startswith(name + "/") and p.count("/") == 2
                     and p.split("/")[1] == p.split("/")[2][:-3]]
        if not front and part in FILTERED:  # no front door: the DM's few notes, all of them
            front = [p for p in notes if p.startswith(name + "/")]
        section(words(name), front)
    campaigns = spell_index.folder(workspace, "campaigns")
    chronicle = terms.get("Chronicle", "Chronicle")
    chapters = {c: under(f"{campaigns}/{c}/{chronicle}", 1) for c in config["chronicles"]}
    if any(chapters.values()):
        blocks.append(f"## {words(campaigns)}")
        for campaign, paths in chapters.items():
            section(f"{words(campaign)} — {words(chronicle)}", paths, 3)
    return "\n\n".join(blocks) + "\n"


# --- Writing ---------------------------------------------------------------------------

def clear(out):
    """Empty the output folder, keeping its dot-entries (a .git, the generator's settings)."""
    for name in os.listdir(out):
        if name.startswith("."):
            continue
        path = os.path.join(out, name)
        if os.path.isdir(path) and not os.path.islink(path):
            shutil.rmtree(path)
        else:
            os.remove(path)


def write(workspace):
    if not os.path.isfile(os.path.join(workspace, CONFIG)):
        raise Failure(2, f"{workspace} is not a DM Realm Workspace (no {CONFIG}); nothing was written.")
    config = player_wiki(workspace)
    out = check_output(workspace, config["output"])
    terms = spell_index.glossary(workspace)
    english = [l for group in (statblock.MONSTER_LINES, statblock.MONSTER_DETAILS, statblock.MONSTER_SECTIONS)
               for _, l in group] + list(statblock.ABILITIES)
    labels = {l: terms[l] for l in english if l in terms}
    notes, warnings = selection(workspace, config, terms)
    files = Files(workspace)
    report = {"plain": 0, "plain_notes": set(), "ambiguous": set(), "removed": [], "kept_fences": []}
    links = Links(files, notes, report)
    written = {}
    for path, part in notes.items():
        with open(os.path.join(workspace, path), encoding="utf-8") as f:
            written[path] = note_for_wiki(f.read(), path, part, config, labels, links, report)
    os.makedirs(out, exist_ok=True)
    clear(out)
    with open(os.path.join(out, MARKER), "w", encoding="utf-8") as f:
        f.write("A Player Wiki written by DM Realm from the Workspace at\n"
                f"{os.path.realpath(workspace)}\nIt is rewritten from scratch at every update: "
                "do not edit it here.\n")
    for path, text in written.items():
        target = os.path.join(out, path)
        os.makedirs(os.path.dirname(target), exist_ok=True)
        with open(target, "w", encoding="utf-8") as f:
            f.write(text)
    for path in sorted(links.copy):
        target = os.path.join(out, path)
        os.makedirs(os.path.dirname(target), exist_ok=True)
        shutil.copy2(os.path.join(workspace, path), target)
    with open(os.path.join(out, "index.md"), "w", encoding="utf-8") as f:
        f.write(home_page(workspace, config, notes, files, terms))
    return summary(out, config, notes, links.copy, report, warnings)


def summary(out, config, notes, copied, report, warnings):
    parts = config["include"] + [f"the Chronicle of {c}" for c in config["chronicles"]]
    lines = [f"Player Wiki written to {out}: {len(notes)} notes and {len(copied)} files, "
             f"from {', '.join(parts) or 'nothing'}, and index.md."]
    if report["plain"]:
        lines.append(f"Links made plain text (their note is not in the wiki): {report['plain']}, "
                     f"in {len(report['plain_notes'])} notes.")
    if report["ambiguous"]:
        lines.append("Links whose name several files share, made plain text: in "
                     + ", ".join(sorted(report["ambiguous"])) + ".")
    if report["removed"]:
        lines.append("Removed from World and Homebrew notes:")
        lines.extend(f"- {path}: {', '.join(what)}" for path, what in report["removed"])
    elif any(p in config["include"] for p in FILTERED):
        lines.append("Removed from World and Homebrew notes: nothing.")
    if report["kept_fences"]:
        lines.append("Stat blocks left as code (they could not be read):")
        lines.extend(f"- {k}" for k in report["kept_fences"])
    lines.extend(f"Note: {w}" for w in warnings)
    return "\n".join(lines) + "\n"


def main(argv):
    if len(argv) == 3 and argv[1] == "write":
        sys.stdout.write(write(argv[2]))
        return 0
    print(__doc__, file=sys.stderr)
    return 2


if __name__ == "__main__":
    try:
        sys.exit(main(sys.argv))
    except Failure as e:
        print(f"player-wiki: {e}", file=sys.stderr)
        sys.exit(e.code)
