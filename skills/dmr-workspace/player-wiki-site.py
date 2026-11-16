#!/usr/bin/env python3
"""The Player Wiki as a website: the Markdown Player Wiki built with Quartz into static HTML.

  player-wiki-site.py node
      Print the Node.js found and whether it can build the site, as one JSON object:
      {"node": "v24.11.1" or null, "ok": true|false, "needs": 22}. Exit 0 when it can,
      7 when Node is missing or older than 22. Writes nothing.

  player-wiki-site.py build <workspace> --locale <code>
      Build the Workspace's Player Wiki (the Markdown folder `player_wiki.output`, which
      player-wiki.py writes first) into the site folder `player_wiki.site`, as structure.md's
      "Player Wiki" says:
        - Quartz is the pinned release (QUARTZ below), kept in $DMR_QUARTZ/<version>,
          downloaded and installed once (its npm dependencies and plugins included);
        - its quartz.config.yaml is written at every build from Quartz's own default: the
          locale given (an `xx-YY` code Quartz has, else en-US), the Workspace folder's name
          as the title, no analytics, only the files the notes use, self-hosted fonts, no
          social images, no CNAME;
        - each Character Sheet the Markdown wiki holds is put where Quartz links it: Quartz
          publishes the sheet, which a note links to, as a file without its .html; the sheet
          takes that path plus .html, as Quartz's own pages do, with its stylesheet and
          Portrait at the paths it names and its link back to the Character's page;
        - the site is built into a temporary folder beside the site folder, and replaces it
          only when the build succeeds; the site folder's dot-entries are kept, and it is
          marked by a .dm-realm-player-wiki-site file.
      Prints what it did and the command to preview the site.

$DMR_QUARTZ is the folder that holds the Quartz installs (the skill passes
${CLAUDE_PLUGIN_DATA}/quartz); EVAL_DMR_QUARTZ overrides it, and EVAL_DMR_NODE names the
`node` to use, for evals only.

Exit 2: bad usage, not a Workspace, no `player_wiki` key, no `site`, no $DMR_QUARTZ, or the
Markdown Player Wiki not written yet. Exit 3: the site folder is not an absolute path
outside the Workspace and the Markdown folder. Exit 5: the site folder holds files DM Realm
did not write. Exit 6: the pinned Quartz's default configuration is not as DM Realm
expects. Exit 7: no Node 22 or later. Exit 8: Quartz could not be downloaded or installed.
Exit 9: the build failed; the previous site is as it was. Nothing is deleted on any error.
"""
import importlib.util
import hashlib
import json
import os
import posixpath
import re
import shutil
import subprocess
import sys
import tarfile
import tempfile
import urllib.request

HERE = os.path.dirname(os.path.abspath(__file__))
_spec = importlib.util.spec_from_file_location("player_wiki", os.path.join(HERE, "player-wiki.py"))
player_wiki = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(player_wiki)
Failure = player_wiki.Failure

QUARTZ = "5.1.0"
QUARTZ_TARBALL = f"https://github.com/jackyzha0/quartz/archive/refs/tags/v{QUARTZ}.tar.gz"
NODE_MAJOR = 22
INSTALLED = ".dm-realm-installed"
SITE_MARKER = ".dm-realm-player-wiki-site"
CLI = os.path.join("quartz", "bootstrap-cli.mjs")


# --- Node ------------------------------------------------------------------------------

def node_binary():
    fake = os.environ.get("EVAL_DMR_NODE")
    return os.path.expanduser(fake) if fake else shutil.which("node")


def node_status():
    node = node_binary()
    version = None
    if node:
        try:
            version = subprocess.run([node, "--version"], capture_output=True, text=True,
                                     timeout=30).stdout.strip() or None
        except (OSError, subprocess.SubprocessError):
            version = None
    m = re.match(r"v?(\d+)", version or "")
    return {"node": version, "ok": bool(m and int(m.group(1)) >= NODE_MAJOR), "needs": NODE_MAJOR}


def require_node():
    status = node_status()
    if not status["ok"]:
        found = f"Node {status['node']} was found" if status["node"] else "Node.js was not found"
        raise Failure(7, f"{found}; building the site needs Node {NODE_MAJOR} or later. Install it "
                         "(macOS: `brew install node` or the installer from nodejs.org; Linux: the "
                         "package manager or nodejs.org; Windows: the installer from nodejs.org), "
                         "then update the Player Wiki again. The Markdown wiki is not affected.")
    return node_binary()


# --- Quartz ----------------------------------------------------------------------------

def quartz_home():
    home = os.environ.get("EVAL_DMR_QUARTZ") or os.environ.get("DMR_QUARTZ")
    if not home:
        raise Failure(2, "DMR_QUARTZ is not set: pass the folder that holds the Quartz installs.")
    return os.path.join(os.path.expanduser(home), f"v{QUARTZ}")


def run(cmd, cwd, what, code=8):
    try:
        done = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True, timeout=1800)
    except (OSError, subprocess.SubprocessError) as e:
        raise Failure(code, f"{what} failed: {e}")
    if done.returncode != 0:
        tail = "\n".join((done.stdout + done.stderr).strip().splitlines()[-15:])
        raise Failure(code, f"{what} failed (exit {done.returncode}):\n{tail}")
    return done.stdout


def extract(archive, into):
    """Unpack a tarball, refusing any member that would land outside `into` or is a link."""
    root = os.path.realpath(into)
    with tarfile.open(archive) as tar:
        members = tar.getmembers()
        for m in members:
            target = os.path.realpath(os.path.join(root, m.name))
            if not (target == root or target.startswith(root + os.sep)) or m.issym() or m.islnk() \
                    or not (m.isfile() or m.isdir()):
                if m.issym() or m.islnk():
                    continue  # Quartz needs none; links are never unpacked
                raise Failure(8, f"the Quartz download holds an unsafe entry ({m.name}); nothing was installed.")
        tar.extractall(root, members=[m for m in members if m.isfile() or m.isdir()])


def install(node, home, config_text_for):
    """Quartz at home, downloaded and installed when it is not there yet. (home, installed now?)"""
    if os.path.isfile(os.path.join(home, INSTALLED)):
        return False
    os.makedirs(os.path.dirname(home), exist_ok=True)
    work = tempfile.mkdtemp(prefix=f"v{QUARTZ}.", dir=os.path.dirname(home))
    try:
        archive = os.path.join(work, "quartz.tar.gz")
        try:
            with urllib.request.urlopen(QUARTZ_TARBALL, timeout=120) as r, open(archive, "wb") as f:
                shutil.copyfileobj(r, f)
        except OSError as e:
            raise Failure(8, f"Quartz {QUARTZ} could not be downloaded from {QUARTZ_TARBALL}: {e}")
        extract(archive, work)
        tops = [d for d in os.listdir(work) if os.path.isdir(os.path.join(work, d))]
        if len(tops) != 1:
            raise Failure(8, "the Quartz download is not the archive DM Realm expects.")
        source = os.path.join(work, tops[0])
        npm = shutil.which("npm", path=os.path.dirname(node)) or shutil.which("npm")
        if not npm:
            raise Failure(8, "npm was not found next to Node; reinstall Node.js with npm.")
        run([npm, "ci", "--no-audit", "--no-fund"], source, "Installing Quartz's dependencies (npm ci)")
        with open(os.path.join(source, "quartz.config.yaml"), "w", encoding="utf-8") as f:
            f.write(config_text_for(source))
        run([node, CLI, "plugin", "install"], source, "Installing Quartz's plugins")
        with open(os.path.join(source, INSTALLED), "w", encoding="utf-8") as f:
            f.write(f"Quartz {QUARTZ}, installed by DM Realm for the Player Wiki.\n")
        if os.path.exists(home):  # an earlier, unfinished install
            shutil.rmtree(home)
        os.rename(source, home)
        return True
    finally:
        shutil.rmtree(work, ignore_errors=True)


def locale_for(home, locale):
    """(the locale Quartz has, a note when it fell back)."""
    if re.fullmatch(r"[a-z]{2}-[A-Z]{2}", locale or "") and \
            os.path.isfile(os.path.join(home, "quartz", "i18n", "locales", f"{locale}.ts")):
        return locale, None
    return "en-US", f"Quartz has no locale {locale!r}; the site's own words are in English (en-US)."


def config_text(home, title, locale):
    """Quartz's default configuration with DM Realm's settings."""
    with open(os.path.join(home, "quartz.config.default.yaml"), encoding="utf-8") as f:
        text = f.read()
    changes = [
        (r"(?m)^  pageTitle: .*$", f"  pageTitle: {json.dumps(title, ensure_ascii=False)}"),
        (r"(?m)^  analytics:\n    provider: plausible\n", "  analytics: null\n"),
        (r"(?m)^  locale: .*$", f"  locale: {locale}"),
        (r"(?m)^  baseUrl: .*$", "  baseUrl: localhost\n  publishAssets: referenced"),
        (r"(?m)^  ignorePatterns:\n(    - .*\n)+",
         "  ignorePatterns:\n    - .obsidian\n    - .git\n    - .dm-realm-player-wiki\n"),
        (r"(?m)^    fontOrigin: .*$", "    fontOrigin: selfHosted"),
        # The Fonts plugin has its own fontOrigin, Google's CDN by default: serve them from the site.
        (r'(?m)^(  - source: "@quartz-community/quartz-fonts"\n    enabled: true\n)',
         r"\1    options:\n      fontOrigin: selfHosted\n"),
        (r'(?m)^(  - source: "@quartz-community/og-image"\n    enabled: )true', r"\1false"),
        (r'(?m)^(  - source: "@quartz-community/cname"\n    enabled: )true', r"\1false"),
        # No formulas in a D&D wiki: KaTeX would load its files from a CDN on every page.
        (r'(?m)^(  - source: "@quartz-community/latex"\n    enabled: )true', r"\1false"),
        # The footer links to Quartz's own GitHub and Discord: none for the players.
        (r'(?m)^(  - source: "@quartz-community/footer"\n    enabled: true\n    options:\n)      links:\n(        .*\n)+',
         r"\1      links: {}\n"),
    ]
    for pattern, replacement in changes:
        text, n = re.subn(pattern, replacement, text, count=1)
        if n != 1:
            raise Failure(6, f"Quartz {QUARTZ}'s default configuration has no line DM Realm sets "
                             f"({pattern}); nothing was built.")
    return text


# --- The Character Sheets --------------------------------------------------------------

SHEET_MARK = b'<meta name="generator" content="DM Realm">'
REF = re.compile(r'(href|src)="([^"]*)"')


def digest(path):
    with open(path, "rb") as f:
        return hashlib.sha256(f.read()).hexdigest()


def site_files(root):
    for top, dirs, files in os.walk(root):
        for name in files:
            yield os.path.relpath(os.path.join(top, name), root).replace(os.sep, "/")


def local(ref):
    return ref and not re.match(r"[a-z][a-z0-9+.-]*:|//|#", ref, re.I)


def place_sheets(wiki, built):
    """Put each Character Sheet of the Markdown wiki where the site links it.
    (sheets placed, notes for the report)."""
    sheets = []
    for rel in site_files(wiki):
        if rel.endswith(".html") and not rel.split("/")[-1].startswith("."):
            with open(os.path.join(wiki, rel), "rb") as f:
                if SHEET_MARK in f.read(2048):
                    sheets.append(rel)
    if not sheets:
        return 0, []
    by_digest = {}
    pages = []
    for rel in site_files(built):
        by_digest.setdefault(digest(os.path.join(built, rel)), []).append(rel)
        if rel.endswith(".html"):
            pages.append(rel)
    notes, placed = [], 0
    for rel in sorted(sheets):
        source = os.path.join(wiki, rel)
        published = [p for p in by_digest.get(digest(source), []) if not p.endswith(".html")]
        if not published:
            notes.append(f"Quartz did not publish {rel}; the site has no page for it.")
            continue
        at = published[0]
        for p in published:
            os.remove(os.path.join(built, p))
        target = at + ".html"
        here = posixpath.dirname(target)
        with open(source, encoding="utf-8") as f:
            text = f.read()
        back = character_page(built, pages, at)

        def rewrite(m):
            attr, ref = m.group(1), m.group(2)
            if not local(ref):
                return m.group(0)
            plain = player_wiki.unquote(ref)
            if plain.endswith(".md"):
                return f'{attr}="{back}"' if back else m.group(0)
            wanted = posixpath.normpath(posixpath.join(here, plain))
            src = os.path.normpath(os.path.join(os.path.dirname(source), plain))
            if not wanted.startswith("..") and os.path.isfile(src):
                dest = os.path.join(built, wanted)
                os.makedirs(os.path.dirname(dest), exist_ok=True)
                shutil.copy2(src, dest)
            return m.group(0)
        text = REF.sub(rewrite, text)
        if not back:
            notes.append(f"{rel}: no page of the site links it, so its link back leads nowhere.")
        os.makedirs(os.path.join(built, here), exist_ok=True)
        with open(os.path.join(built, target), "w", encoding="utf-8") as f:
            f.write(text)
        placed += 1
    return placed, notes


ANCHOR = re.compile(r"<a\b[^>]*>")
OPT_OUT = ' data-router-ignore data-no-popover="true"'


def character_page(built, pages, sheet):
    """The href, from the sheet's folder, of the first site page that links to the sheet.
    Every link to it opts out of Quartz's in-page navigation and preview, which would load
    the sheet inside the wiki's own page."""
    here, back = posixpath.dirname(sheet), None
    for page in pages:
        path = os.path.join(built, page)
        with open(path, encoding="utf-8", errors="replace") as f:
            text = f.read()
        base = posixpath.dirname(page)

        def links_sheet(tag):
            m = re.search(r'\bhref="([^"]*)"', tag)
            ref = player_wiki.unquote(m.group(1).split("#")[0].split("?")[0]) if m else ""
            return local(ref) and posixpath.normpath(posixpath.join(base, ref)) == sheet

        def opt_out(m):
            tag = m.group(0)
            if not links_sheet(tag) or "data-router-ignore" in tag:
                return tag
            return tag[:-1] + OPT_OUT + ">"
        patched = ANCHOR.sub(opt_out, text)
        if patched == text:
            continue
        with open(path, "w", encoding="utf-8") as f:
            f.write(patched)
        if back is None:
            if posixpath.basename(page) == "index.html":
                rel = posixpath.relpath(base or ".", here or ".")
                back = "./" if rel == "." else rel + "/"
            else:
                back = player_wiki.quote(posixpath.relpath(page[:-len(".html")], here or "."))
    return back


# --- The site --------------------------------------------------------------------------

def swap(built, site):
    """Put the built site in place of the old one, keeping the old one's dot-entries."""
    with open(os.path.join(built, SITE_MARKER), "w", encoding="utf-8") as f:
        f.write("A Player Wiki site built by DM Realm with Quartz. It is rebuilt from scratch at "
                "every update: do not edit it here.\n")
    if not os.path.isdir(site):
        os.rename(built, site)
        return
    for name in os.listdir(site):
        if name.startswith(".") and name != SITE_MARKER and not os.path.exists(os.path.join(built, name)):
            os.rename(os.path.join(site, name), os.path.join(built, name))
    old = site + ".dmr-old"
    shutil.rmtree(old, ignore_errors=True)
    os.rename(site, old)
    os.rename(built, site)
    shutil.rmtree(old, ignore_errors=True)


def build(workspace, locale):
    if not os.path.isfile(os.path.join(workspace, player_wiki.CONFIG)):
        raise Failure(2, f"{workspace} is not a DM Realm Workspace (no {player_wiki.CONFIG}); nothing was built.")
    config = player_wiki.player_wiki(workspace)
    if not config["site"]:
        raise Failure(2, "player_wiki has no site folder; nothing was built.")
    wiki = os.path.realpath(os.path.expanduser(config["output"]))
    if not os.path.isfile(os.path.join(wiki, player_wiki.MARKER)):
        raise Failure(2, f"the Markdown Player Wiki is not written yet in {wiki}: write it first.")
    site = player_wiki.check_output(workspace, config["site"], SITE_MARKER)
    if site == wiki or site.startswith(wiki + os.sep) or wiki.startswith(site + os.sep):
        raise Failure(3, f"the site folder {site} and the Markdown Player Wiki {wiki} must be "
                         "separate folders, neither inside the other.")
    node = require_node()
    home = quartz_home()
    title = player_wiki.words(os.path.basename(os.path.realpath(workspace)))
    notes = []
    chosen = {}

    def text_for(root):
        chosen["locale"], note = locale_for(root, locale)
        if note:
            notes.append(note)
        return config_text(root, title, chosen["locale"])
    installed = install(node, home, text_for)
    text = text_for(home) if not installed else None
    if text is not None:
        with open(os.path.join(home, "quartz.config.yaml"), "w", encoding="utf-8") as f:
            f.write(text)
    os.makedirs(os.path.dirname(site), exist_ok=True)
    built = tempfile.mkdtemp(prefix=os.path.basename(site) + ".dmr-building.", dir=os.path.dirname(site))
    try:
        run([node, CLI, "build", "-d", wiki, "-o", built], home, "Building the site with Quartz", code=9)
        sheets, sheet_notes = place_sheets(wiki, built)
        notes.extend(sheet_notes)
        pages = sum(1 for _, _, files in os.walk(built) for n in files if n.endswith(".html")) - sheets
        swap(built, site)
    finally:
        shutil.rmtree(built, ignore_errors=True)
    lines = [f"Player Wiki site built in {site}: {pages} pages, with Quartz {QUARTZ} "
             f"(locale {chosen['locale']})" + (f", and {sheets} Character Sheets." if sheets else ".")]
    if installed:
        lines.append(f"Quartz {QUARTZ} was downloaded and installed in {home}, once for every Workspace.")
    lines.append(f'Preview: python3 -m http.server --directory "{site}" 8080, then open http://localhost:8080')
    lines.extend(f"Note: {n}" for n in notes)
    return "\n".join(lines) + "\n"


def main(argv):
    if argv[1:] == ["node"]:
        status = node_status()
        print(json.dumps(status))
        return 0 if status["ok"] else 7
    if len(argv) == 5 and argv[1] == "build" and argv[3] == "--locale":
        sys.stdout.write(build(argv[2], argv[4]))
        return 0
    print(__doc__, file=sys.stderr)
    return 2


if __name__ == "__main__":
    try:
        sys.exit(main(sys.argv))
    except Failure as e:
        print(f"player-wiki-site: {e}", file=sys.stderr)
        sys.exit(e.code)
