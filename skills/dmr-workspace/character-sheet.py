#!/usr/bin/env python3
"""A Character Sheet: a Character's stat block laid out as a page of its own, for its player
to read in the Player Wiki (ADR 0019, structure.md's "Player Wiki"). player-wiki.py loads
this module and writes, for every Character it copies, the page and the one stylesheet all
the pages share.

The page is rendered from the Character's ```statblock fence alone (layout
`DM Realm Character`), never from the Build's Markdown: the same numbers, nothing spent in
play. It is static HTML in DM Realm's own design, in the D&D character sheet's conventions:
no script, nothing loaded from another server, system fonts, light and dark following the
reader's system, one column on a phone and two from a tablet up. The Workspace's Edition
arranges it: in 2024 each ability shows its saving throw, as that sheet does; in 2014 the
saving throws are a list of their own.

Labels are the layout's English labels translated by the Translation Glossary; a label the
Glossary lacks is written in English, and missing() lists it for the report.
"""
import html
import json
import re

DOT = "●"
MINUS = "−"

# The English labels a sheet uses: the Character layout's, and two of its own.
LABELS = ("Character Sheet", "Level", "Player", "Armor Class", "Hit Point Maximum", "Hit Dice",
          "Initiative", "Speed", "Proficiency Bonus", "STR", "DEX", "CON", "INT", "WIS", "CHA",
          "SAVE", "Saving Throws", "Skills", "Senses", "Languages", "Attacks", "Spellcasting",
          "Features and Traits")
ABBREVIATIONS = ("STR", "DEX", "CON", "INT", "WIS", "CHA")


class Labels:
    """The Glossary's translations of the labels, remembering the ones it lacked."""

    def __init__(self, terms):
        self.terms, self.lacking = terms, []

    def __call__(self, english):
        if english in self.terms:
            return self.terms[english]
        if english not in self.lacking:
            self.lacking.append(english)
        return english


def names(title):
    """(the sheet's file name word, its stylesheet's file name), from the sheet's name in the
    Workspace Language with the name rules applied."""
    word = re.sub(r"[#^\[\]|\\/:*?\"<>]", "", title.replace("'", "_").replace("’", "_"))
    word = re.sub(r"\s+", "_", word.strip()) or "Character_Sheet"
    return word, f"{word}.css"


def file_name(note_path, word):
    """`Durga_Scheda_del_Personaggio.html` for `…/Durga/Durga.md`."""
    return note_path.rsplit("/", 1)[-1][:-3] + f"_{word}.html"


def signed(value):
    if isinstance(value, int):
        return f"+{value}" if value >= 0 else f"{MINUS}{-value}"
    text = str(value).strip()
    return MINUS + text[1:] if text.startswith("-") else text


def modifier(score):
    return (score - 10) // 2 if isinstance(score, int) else None


def proficiency_bonus(level):
    """The proficiency bonus by total level: the same table in both Editions."""
    return 2 + (level - 1) // 4 if isinstance(level, int) and 1 <= level <= 20 else None


def unquote(line):
    """A spellcasting line as the fence writes it, quoted or not."""
    line = str(line).strip()
    if len(line) >= 2 and line[0] == line[-1] == '"':
        try:
            return json.loads(line)
        except ValueError:
            return line[1:-1]
    return line


def esc(value):
    return html.escape(str(value), quote=True)


def split_saves(saves):
    """[(ability name, proficient, bonus)] from `- Saggezza ●: 6` items."""
    out = []
    for item in saves or []:
        (name, bonus), = item.items()
        name = str(name)
        proficient = name.rstrip().endswith(DOT)
        out.append((name.replace(DOT, "").strip(), proficient, bonus))
    return out


def box(label, value, extra=""):
    return (f'<div class="stat{extra}"><span class="stat-label">{esc(label)}</span>'
            f'<span class="stat-value">{esc(value)}</span></div>')


def card(title, inner, cls=""):
    return f'<section class="card{(" " + cls) if cls else ""}"><h2>{esc(title)}</h2>{inner}</section>'


def entries(items):
    rows = []
    for item in items or []:
        name, desc = item.get("name", ""), item.get("desc", "")
        rows.append(f'<li><span class="entry-name">{esc(name)}</span>'
                    + (f' <span class="entry-desc">{esc(desc)}</span>' if desc != "" else "") + "</li>")
    return f'<ul class="entries">{"".join(rows)}</ul>'


def bonus_list(rows):
    """Saves or skills: a dot when proficient, the name, the bonus."""
    out = []
    for name, proficient, bonus in rows:
        mark = f'<span class="dot{" on" if proficient else ""}" aria-hidden="true"></span>'
        out.append(f'<li>{mark}<span class="row-name">{esc(name)}</span>'
                   f'<span class="row-value">{esc(signed(bonus))}</span></li>')
    return f'<ul class="rows">{"".join(out)}</ul>'


def render(fields, edition, label, back, portrait=None, stylesheet="", title_word=""):
    """The sheet's HTML. fields: the fence's (key, value) pairs; back: the href of the
    Character's own page; portrait: the href of its Portrait, or None."""
    v = dict(fields)
    name = v.get("name", "")
    level = v.get("level")
    saves = split_saves(v.get("saves"))
    stats = v.get("stats") if isinstance(v.get("stats"), list) else []

    kind = ", ".join(str(v[k]) for k in ("size", "species", "class") if v.get(k) not in (None, ""))
    who = []
    if level not in (None, ""):
        who.append(f'<span class="chip"><span class="chip-label">{esc(label("Level"))}</span> {esc(level)}</span>')
    if v.get("player") not in (None, ""):
        who.append(f'<span class="chip"><span class="chip-label">{esc(label("Player"))}</span> {esc(v["player"])}</span>')
    head = (f'<header class="head">'
            + (f'<img class="portrait" src="{esc(portrait)}" alt="">' if portrait else "")
            + f'<div class="head-text"><p class="eyebrow">{esc(title_word)}</p><h1>{esc(name)}</h1>'
            + (f'<p class="kind">{esc(kind)}</p>' if kind else "")
            + (f'<p class="who">{"".join(who)}</p>' if who else "")
            + "</div></header>")

    combat = []
    if v.get("ac") not in (None, ""):
        ac = str(v["ac"]) + (f' ({v["ac_class"]})' if v.get("ac_class") else "")
        combat.append(box(label("Armor Class"), ac, " stat-ac"))
    if v.get("hp") not in (None, ""):
        combat.append(box(label("Hit Point Maximum"), v["hp"], " stat-hp"))
    if v.get("hit_dice") not in (None, ""):
        combat.append(box(label("Hit Dice"), v["hit_dice"]))
    if v.get("initiative") not in (None, ""):
        combat.append(box(label("Initiative"), signed(v["initiative"])))
    if v.get("speed") not in (None, ""):
        combat.append(box(label("Speed"), v["speed"]))
    pb = proficiency_bonus(level)
    if pb is not None:
        combat.append(box(label("Proficiency Bonus"), signed(pb)))
    combat_html = f'<section class="combat">{"".join(combat)}</section>' if combat else ""

    abilities = []
    for i, abbr in enumerate(ABBREVIATIONS):
        if i >= len(stats):
            break
        score = stats[i]
        mod = modifier(score)
        save = saves[i] if i < len(saves) else None
        full = save[0] if save else ""
        inner = (f'<span class="ability-abbr">{esc(label(abbr))}</span>'
                 + (f'<span class="ability-name">{esc(full)}</span>' if full else "")
                 + f'<span class="ability-mod">{esc(signed(mod) if mod is not None else "")}</span>'
                 + f'<span class="ability-score">{esc(score)}</span>')
        if edition == "2024" and save:
            inner += (f'<span class="ability-save"><span class="dot{" on" if save[1] else ""}" aria-hidden="true"></span>'
                      f'{esc(label("SAVE"))} <strong>{esc(signed(save[2]))}</strong></span>')
        abilities.append(f'<div class="ability">{inner}</div>')
    abilities_html = f'<section class="abilities">{"".join(abilities)}</section>' if abilities else ""

    left = [abilities_html]
    if saves and edition != "2024":
        left.append(card(label("Saving Throws"), bonus_list(saves)))
    skills = [(str(k), True, b) for item in v.get("skillsaves") or [] for k, b in item.items()]
    if skills:
        left.append(card(label("Skills"), bonus_list(skills)))
    facts = []
    for key, word in (("senses", "Senses"), ("languages", "Languages")):
        if v.get(key) not in (None, ""):
            facts.append(f'<div class="fact"><h3>{esc(label(word))}</h3><p>{esc(v[key])}</p></div>')
    if facts:
        left.append(f'<section class="card facts">{"".join(facts)}</section>')

    right = []
    if v.get("actions"):
        right.append(card(label("Attacks"), entries(v["actions"])))
    spells = [unquote(s) for s in v.get("spells") or []]
    if spells:
        first, slots = spells[0], spells[1:]
        inner = f'<p class="spell-line">{esc(first)}</p>'
        if slots:
            inner += '<ul class="slots">' + "".join(f"<li>{esc(s)}</li>" for s in slots) + "</ul>"
        right.append(card(label("Spellcasting"), inner))
    if v.get("traits"):
        right.append(card(label("Features and Traits"), entries(v["traits"])))

    sheet_title = f"{name} — {title_word}" if title_word else str(name)
    return f"""<!doctype html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<meta name="color-scheme" content="light dark">
<meta name="generator" content="DM Realm">
<title>{esc(sheet_title)}</title>
<link rel="stylesheet" href="{esc(stylesheet)}">
</head>
<body class="edition-{esc(edition or "2024")}">
<main class="sheet">
<nav class="back"><a href="{esc(back)}">← {esc(name)}</a></nav>
{head}
{combat_html}
<div class="columns">
<div class="column">{"".join(left)}</div>
<div class="column">{"".join(right)}</div>
</div>
</main>
</body>
</html>
"""


CSS = """/* The Character Sheets of a Player Wiki, written by DM Realm at every update. */
:root {
  --bg: #f4efe4; --card: #fffdf8; --ink: #1f1a14; --muted: #6b5f50; --line: #ddd1bc;
  --accent: #8a1c1c; --accent-soft: #f3e2dc; --shadow: 0 1px 2px rgb(60 40 20 / 0.08);
  --serif: "Iowan Old Style", "Palatino Linotype", Palatino, "Book Antiqua", Georgia, serif;
  --sans: system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
}
@media (prefers-color-scheme: dark) {
  :root {
    --bg: #15120e; --card: #201b16; --ink: #efe6d8; --muted: #a99b87; --line: #3b3229;
    --accent: #e0806c; --accent-soft: #3a2420; --shadow: none;
  }
}
* { box-sizing: border-box; }
html { -webkit-text-size-adjust: 100%; text-size-adjust: 100%; }
body {
  margin: 0; background: var(--bg); color: var(--ink);
  font: 16px/1.45 var(--sans); overflow-wrap: break-word;
}
.sheet {
  max-width: 1040px; margin: 0 auto;
  padding: 12px max(16px, env(safe-area-inset-right)) max(24px, env(safe-area-inset-bottom)) max(16px, env(safe-area-inset-left));
}
h1, h2, h3 { font-family: var(--serif); font-weight: 600; margin: 0; }
.back a {
  display: inline-flex; align-items: center; min-height: 44px; padding: 0 4px;
  color: var(--accent); text-decoration: none; font-weight: 600;
}
.back a:hover, .back a:focus-visible { text-decoration: underline; }
.head {
  display: flex; gap: 14px; align-items: center; padding: 4px 0 14px;
  border-bottom: 3px double var(--line); margin-bottom: 14px;
}
.portrait {
  width: 84px; height: 84px; flex: none; object-fit: cover; border-radius: 50%;
  border: 3px solid var(--accent); background: var(--card);
}
.head-text { min-width: 0; }
.eyebrow { margin: 0; color: var(--muted); font-size: 0.75rem; letter-spacing: 0.08em; text-transform: uppercase; }
h1 { font-size: clamp(1.6rem, 6vw, 2.4rem); line-height: 1.1; }
.kind { margin: 4px 0 0; color: var(--muted); font-style: italic; }
.who { margin: 8px 0 0; display: flex; flex-wrap: wrap; gap: 6px; }
.chip {
  display: inline-block; padding: 2px 10px; border: 1px solid var(--line); border-radius: 999px;
  background: var(--card); font-size: 0.9rem;
}
.chip-label { color: var(--muted); }
.combat {
  display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 8px; margin-bottom: 12px;
}
.stat {
  display: flex; flex-direction: column; align-items: center; justify-content: center; text-align: center;
  min-height: 76px; padding: 8px 4px; background: var(--card); border: 1px solid var(--line);
  border-radius: 10px; box-shadow: var(--shadow);
}
.stat-label { order: 2; font-size: 0.7rem; line-height: 1.2; color: var(--muted); text-transform: uppercase; letter-spacing: 0.04em; }
.stat-value { order: 1; font-family: var(--serif); font-size: 1.35rem; font-weight: 600; line-height: 1.2; }
.stat-ac { border: 2px solid var(--accent); border-radius: 10px 10px 40% 40% / 10px 10px 24px 24px; }
.stat-hp .stat-value { color: var(--accent); }
.columns { display: grid; grid-template-columns: minmax(0, 1fr); gap: 12px; }
.column { display: grid; gap: 12px; align-content: start; min-width: 0; }
.abilities { display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 8px; }
.ability {
  position: relative; display: flex; flex-direction: column; align-items: center; text-align: center;
  padding: 8px 4px 18px; background: var(--card); border: 1px solid var(--line); border-radius: 12px;
  box-shadow: var(--shadow); margin-bottom: 10px;
}
.ability-abbr { font-weight: 700; font-size: 0.8rem; letter-spacing: 0.08em; }
.ability-name { font-size: 0.7rem; color: var(--muted); line-height: 1.2; }
.ability-mod { font-family: var(--serif); font-size: 1.8rem; font-weight: 600; line-height: 1.15; }
.ability-score {
  position: absolute; bottom: -11px; left: 50%; transform: translateX(-50%);
  min-width: 2.4em; padding: 0 8px; background: var(--card); border: 1px solid var(--line);
  border-radius: 999px; font-size: 0.85rem; line-height: 20px;
}
.edition-2024 .ability { padding-bottom: 8px; margin-bottom: 0; }
.edition-2024 .ability-score { position: static; transform: none; margin: 2px 0 6px; }
.ability-save {
  display: flex; align-items: center; gap: 5px; width: 100%; justify-content: center;
  border-top: 1px solid var(--line); padding-top: 6px; font-size: 0.8rem; color: var(--muted);
}
.ability-save strong { color: var(--ink); }
.card {
  background: var(--card); border: 1px solid var(--line); border-radius: 12px;
  padding: 12px 14px; box-shadow: var(--shadow); min-width: 0;
}
.card h2 {
  font-size: 0.8rem; letter-spacing: 0.08em; text-transform: uppercase; color: var(--accent);
  padding-bottom: 6px; margin-bottom: 8px; border-bottom: 1px solid var(--line);
}
.rows, .entries, .slots { list-style: none; margin: 0; padding: 0; }
.rows li {
  display: flex; align-items: center; gap: 8px; min-height: 32px;
  border-bottom: 1px dotted var(--line);
}
.rows li:last-child { border-bottom: 0; }
.row-name { flex: 1; min-width: 0; }
.row-value { font-weight: 700; font-variant-numeric: tabular-nums; }
.dot {
  width: 10px; height: 10px; flex: none; border-radius: 50%; border: 1.5px solid var(--muted);
}
.dot.on { background: var(--accent); border-color: var(--accent); }
.entries li { padding: 8px 0; border-bottom: 1px dotted var(--line); }
.entries li:first-child { padding-top: 0; }
.entries li:last-child { border-bottom: 0; padding-bottom: 0; }
.entry-name { font-weight: 700; font-family: var(--serif); }
.entry-desc { display: block; color: var(--ink); }
.facts { display: grid; gap: 10px; }
.fact h3 { font-size: 0.8rem; letter-spacing: 0.08em; text-transform: uppercase; color: var(--accent); }
.fact p { margin: 2px 0 0; }
.spell-line { margin: 0 0 8px; }
.slots { display: flex; flex-wrap: wrap; gap: 6px; }
.slots li {
  padding: 4px 10px; border-radius: 8px; background: var(--accent-soft); font-size: 0.9rem;
}
@media (min-width: 560px) {
  .combat { grid-template-columns: repeat(6, minmax(0, 1fr)); }
  .portrait { width: 104px; height: 104px; }
}
@media (min-width: 760px) {
  .sheet { padding-top: 20px; }
  .columns { grid-template-columns: minmax(0, 5fr) minmax(0, 7fr); gap: 16px; }
  .column { gap: 16px; }
  .abilities { grid-template-columns: repeat(2, minmax(0, 1fr)); }
}
@media print {
  :root { --bg: #fff; --card: #fff; --shadow: none; }
  .back { display: none; }
}
"""


