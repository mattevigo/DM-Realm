#!/usr/bin/env python3
"""Build the DM Realm guide site: no dependencies, standard library only.

    python3 site/build.py [output folder]      # default: _site at the repo root

Each page in site/pages/ is an HTML fragment that starts with a header comment:

    <!--
    title: Set up your Workspace
    description: One sentence, used under the title and in <meta>.
    -->

The build wraps it in the layout (header, sidebar, table of contents, previous
and next links), writes pages/<path>.html to <output>/<path>/index.html so URLs
end in a slash, and copies site/assets/. In a page, `{{root}}` is the relative
path to the site root, so the site works under any base URL (GitHub Pages
serves it under /DM-Realm/). The build fails when a page in NAV is missing, or
when a link or asset inside the site does not resolve.
"""

import html
import json
import re
import shutil
import sys
from pathlib import Path

SITE = Path(__file__).resolve().parent
REPO = SITE.parent
PAGES = SITE / "pages"
ASSETS = SITE / "assets"
GITHUB = "https://github.com/mattevigo/DM-Realm"

# The sidebar, in reading order. Each entry: (page path without .html, short label).
NAV = [
    ("Guide", [
        ("guide/index", "Overview"),
        ("guide/install", "Install DM Realm"),
        ("guide/setup", "Set up your Workspace"),
        ("guide/workspace", "Tour the Workspace"),
        ("guide/import", "Bring in official material"),
        ("guide/campaign", "Start a Campaign"),
        ("guide/characters", "Create the party"),
        ("guide/prepare", "Prepare a Session"),
        ("guide/play", "At the table"),
        ("guide/consolidate", "Close the Session"),
        ("guide/narrate", "Tell the story"),
        ("guide/ask", "When you are stuck"),
    ]),
    ("Skills", [
        ("skills/index", "All skills"),
        ("skills/dmr-setup", "dmr-setup"),
        ("skills/dmr-ask", "dmr-ask"),
        ("skills/dmr-import", "dmr-import"),
        ("skills/dmr-campaign", "dmr-campaign"),
        ("skills/dmr-character", "dmr-character"),
        ("skills/dmr-session-prepare", "dmr-session-prepare"),
        ("skills/dmr-mapforge-import", "dmr-mapforge-import"),
        ("skills/dmr-session-consolidate", "dmr-session-consolidate"),
        ("skills/dmr-session-narrate", "dmr-session-narrate"),
    ]),
    ("Reference", [
        ("concepts", "Concepts"),
    ]),
]

LESSONS = [p for p, _ in NAV[0][1] if p != "guide/index"]


def url_of(page):
    """Site-relative URL of a page: '' for the home page, 'guide/setup/' otherwise."""
    if page == "index":
        return ""
    if page.endswith("/index"):
        return page[: -len("index")]
    return page + "/"


def root_of(page):
    return "../" * url_of(page).count("/") or "./"


def read_page(page):
    path = PAGES / (page + ".html")
    if not path.is_file():
        sys.exit(f"build: {path.relative_to(REPO)} is missing")
    text = path.read_text(encoding="utf-8")
    m = re.match(r"\s*<!--(.*?)-->\s*", text, re.S)
    if not m:
        sys.exit(f"build: {path.relative_to(REPO)} has no header comment")
    meta = {}
    for line in m.group(1).strip().splitlines():
        key, _, value = line.partition(":")
        meta[key.strip()] = value.strip()
    for key in ("title", "description"):
        if not meta.get(key):
            sys.exit(f"build: {path.relative_to(REPO)} has no {key}")
    return meta, text[m.end():]


def slug(text):
    text = re.sub(r"<[^>]+>", "", text)
    text = re.sub(r"['’]", "", html.unescape(text).lower())
    return re.sub(r"[^a-z0-9]+", "-", text).strip("-")


def add_heading_ids(body):
    """Give every h2 an id (unless it has one) and return the body and its table of contents."""
    toc = []

    def repl(m):
        attrs, inner = m.group(1), m.group(2)
        found = re.search(r'id="([^"]+)"', attrs)
        hid = found.group(1) if found else slug(inner)
        if not found:
            attrs += f' id="{hid}"'
        toc.append((hid, re.sub(r"<[^>]+>", "", inner)))
        return f'<h2{attrs}><a class="anchor" href="#{hid}" aria-hidden="true">#</a>{inner}</h2>'

    return re.sub(r"<h2([^>]*)>(.*?)</h2>", repl, body, flags=re.S), toc


D20 = (
    '<svg class="logo-mark" viewBox="0 0 32 32" aria-hidden="true">'
    '<path d="M16 2 28.1 9v14L16 30 3.9 23V9Z" fill="none" stroke="currentColor" stroke-width="2" stroke-linejoin="round"/>'
    '<path d="M16 2 9.5 12h13Z M9.5 12 16 23l6.5-11 M3.9 9l5.6 3 M28.1 9l-5.6 3 M3.9 23 9.5 12 M28.1 23 22.5 12 M3.9 23H28.1 M16 23v7" '
    'fill="none" stroke="currentColor" stroke-width="1.3" stroke-linejoin="round" opacity=".7"/></svg>'
)

ICON_SUN = '<svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="4.5"/><path d="M12 2v2.5M12 19.5V22M2 12h2.5M19.5 12H22M4.9 4.9l1.8 1.8M17.3 17.3l1.8 1.8M4.9 19.1l1.8-1.8M17.3 6.7l1.8-1.8"/></svg>'
ICON_MOON = '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M20.5 14.5A8.5 8.5 0 0 1 9.5 3.5a8.5 8.5 0 1 0 11 11Z"/></svg>'
ICON_GITHUB = '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 .5a11.5 11.5 0 0 0-3.6 22.4c.6.1.8-.3.8-.6v-2c-3.2.7-3.9-1.5-3.9-1.5-.5-1.3-1.3-1.7-1.3-1.7-1-.7.1-.7.1-.7 1.2.1 1.8 1.2 1.8 1.2 1 1.8 2.8 1.3 3.5 1 .1-.8.4-1.3.7-1.6-2.6-.3-5.3-1.3-5.3-5.7 0-1.3.5-2.3 1.2-3.1-.1-.3-.5-1.5.1-3.1 0 0 1-.3 3.2 1.2a11 11 0 0 1 5.8 0C17.3 4.3 18.3 4.6 18.3 4.6c.6 1.6.2 2.8.1 3.1.8.8 1.2 1.8 1.2 3.1 0 4.4-2.7 5.4-5.3 5.7.4.4.8 1.1.8 2.2v3.2c0 .3.2.7.8.6A11.5 11.5 0 0 0 12 .5Z"/></svg>'


def header(root, active, version):
    def item(href, label, key):
        cur = ' aria-current="page"' if key == active else ""
        return f'<a href="{root}{href}"{cur}>{label}</a>'

    return f"""<header class="topbar">
  <div class="topbar-inner">
    <a class="brand" href="{root}">{D20}<span>DM Realm</span></a>
    <span class="version">v{version}</span>
    <nav class="topnav" aria-label="Main">
      {item("guide/", "Guide", "guide")}
      {item("skills/", "Skills", "skills")}
      {item("concepts/", "Concepts", "concepts")}
    </nav>
    <div class="topbar-actions">
      <a class="icon-btn" href="{GITHUB}" aria-label="DM Realm on GitHub">{ICON_GITHUB}</a>
      <button class="icon-btn theme-toggle" type="button" aria-label="Switch colour theme">{ICON_SUN}{ICON_MOON}</button>
    </div>
  </div>
</header>"""


FOOTER = """<footer class="footer">
  <div class="footer-inner">
    <p><strong>DM Realm</strong> is open source under the MIT licence. <a href="{github}">Source on GitHub</a> · <a href="{github}/issues">Report a problem</a></p>
    <p class="legal">DM Realm is unofficial Fan Content permitted under the Fan Content Policy. Not approved/endorsed by Wizards. Portions of the materials used are property of Wizards of the Coast. ©Wizards of the Coast LLC.</p>
  </div>
</footer>""".format(github=GITHUB)


def sidebar(root, current):
    parts = ['<nav class="sidebar" id="sidebar" aria-label="Guide and skills">']
    for section, pages in NAV:
        parts.append(f'<p class="sidebar-title">{section}</p><ol class="sidebar-list">')
        for page, label in pages:
            cur = ' aria-current="page"' if page == current else ""
            num = ""
            if page in LESSONS:
                num = f'<span class="num">{LESSONS.index(page) + 1:02d}</span>'
            cls = ' class="mono"' if label.startswith("dmr-") else ""
            parts.append(f'<li><a href="{root}{url_of(page)}"{cur}>{num}<span{cls}>{label}</span></a></li>')
        parts.append("</ol>")
    parts.append("</nav>")
    return "\n".join(parts)


def neighbours(page):
    order = [p for _, pages in NAV for p, _ in pages]
    labels = {p: label for _, pages in NAV for p, label in pages}
    i = order.index(page)
    prev = order[i - 1] if i > 0 else None
    nxt = order[i + 1] if i + 1 < len(order) else None
    return prev, nxt, labels


def doc_page(page, meta, body, version):
    root = root_of(page)
    body, toc = add_heading_ids(body)
    section = next(s for s, pages in NAV if any(p == page for p, _ in pages))
    if page in LESSONS:
        eyebrow = f"Guide · Lesson {LESSONS.index(page) + 1} of {len(LESSONS)}"
    else:
        eyebrow = section
    prev, nxt, labels = neighbours(page)
    pager = '<nav class="pager" aria-label="Previous and next">'
    if prev:
        pager += f'<a class="pager-prev" href="{root}{url_of(prev)}"><span>Previous</span>{labels[prev]}</a>'
    else:
        pager += "<span></span>"
    if nxt:
        pager += f'<a class="pager-next" href="{root}{url_of(nxt)}"><span>Next</span>{labels[nxt]}</a>'
    pager += "</nav>"
    toc_html = ""
    if len(toc) > 1:
        items = "".join(f'<li><a href="#{hid}">{text}</a></li>' for hid, text in toc)
        toc_html = f'<aside class="toc" aria-label="On this page"><p class="toc-title">On this page</p><ol>{items}</ol></aside>'
    active = {"Guide": "guide", "Skills": "skills", "Reference": "concepts"}[section]
    main = f"""<div class="doc-layout">
  <button class="sidebar-toggle" type="button" aria-controls="sidebar" aria-expanded="false">Menu</button>
  {sidebar(root, page)}
  <main class="doc" id="main">
    <p class="eyebrow">{eyebrow}</p>
    <h1>{meta["title"]}</h1>
    <p class="lede">{meta["description"]}</p>
    <div class="prose">
{body.strip()}
    </div>
    {pager}
  </main>
  {toc_html}
</div>"""
    return shell(page, meta, header(root, active, version) + main + FOOTER)


def home_page(meta, body, version):
    root = root_of("index")
    return shell("index", meta, header(root, "", version) + f'<main id="main" class="home">{body}</main>' + FOOTER)


def shell(page, meta, inner):
    root = root_of(page)
    title = "DM Realm" if page == "index" else f'{meta["title"]} · DM Realm'
    return f"""<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{title}</title>
<meta name="description" content="{html.escape(meta["description"])}">
<meta property="og:title" content="{html.escape(title)}">
<meta property="og:description" content="{html.escape(meta["description"])}">
<link rel="icon" href="{root}assets/favicon.svg" type="image/svg+xml">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,500;9..144,600;9..144,700&family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap">
<link rel="stylesheet" href="{root}assets/style.css">
<script>try{{var t=localStorage.getItem("dmr-theme");if(t)document.documentElement.dataset.theme=t}}catch(e){{}}</script>
</head>
<body>
<a class="skip" href="#main">Skip to content</a>
{inner}
<script src="{root}assets/site.js" defer></script>
</body>
</html>
"""


def check_links(out):
    """Every href/src that stays inside the site must point at a file the build wrote."""
    broken = []
    for file in out.rglob("*.html"):
        text = file.read_text(encoding="utf-8")
        for target in re.findall(r'(?:href|src)="([^"]+)"', text):
            if re.match(r"[a-z]+:|//|#", target):
                continue
            path, _, fragment = target.partition("#")
            resolved = (file.parent / path.split("?")[0]).resolve()
            if resolved.is_dir():
                resolved = resolved / "index.html"
            if not resolved.is_file():
                broken.append(f"{file.relative_to(out)} → {target}")
            elif fragment and f'id="{fragment}"' not in resolved.read_text(encoding="utf-8"):
                broken.append(f"{file.relative_to(out)} → {target} (no such anchor)")
    return broken


def build(out):
    version = json.loads((REPO / ".claude-plugin" / "plugin.json").read_text())["version"]
    if out.exists():
        shutil.rmtree(out)
    out.mkdir(parents=True)
    shutil.copytree(ASSETS, out / "assets")
    pages = ["index"] + [p for _, ps in NAV for p, _ in ps]
    on_disk = {str(p.relative_to(PAGES).with_suffix("")) for p in PAGES.rglob("*.html")}
    orphans = sorted(on_disk - set(pages))
    if orphans:
        sys.exit("build: pages not in NAV: " + ", ".join(orphans))
    for page in pages:
        meta, body = read_page(page)
        body = body.replace("{{root}}", root_of(page)).replace("{{version}}", version)
        result = home_page(meta, body, version) if page == "index" else doc_page(page, meta, body, version)
        target = out / url_of(page) / "index.html"
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(result, encoding="utf-8")
    (out / ".nojekyll").write_text("")
    broken = check_links(out)
    if broken:
        sys.exit("build: broken links:\n  " + "\n  ".join(broken))
    print(f"build: {len(pages)} pages written to {out}")


if __name__ == "__main__":
    build(Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else REPO / "_site")
