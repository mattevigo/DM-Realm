# A Character Sheet is a page the Player Wiki writes from the stat block

At every update, `player-wiki.py` writes a Character Sheet for every Character it copies: a static HTML page of its own, beside the Character's note in the Player Wiki folder, rendered from the Character's stat block fence alone. It uses an original layout in the D&D character sheet's conventions, in the Workspace Language, and shows only maximums. All the sheets share one stylesheet. The Character's wiki page gains one link line to its sheet and nothing else. With the site chosen, `player-wiki-site.py` copies the sheets and their stylesheet into the built site itself, after Quartz. Nothing of a sheet is kept in the Workspace.

*Amends [ADR 0017](0017-the-player-wiki-is-a-copy-written-outside-the-workspace.md): a Character's fence is still dropped from its page, and it is now also rendered as the Character Sheet. Amends [ADR 0018](0018-the-player-wiki-site-is-built-with-a-pinned-quartz.md): the sheets reach the site by DM Realm's copy, not through Quartz.*

## Why

- **It is for the players, so it belongs where the players read.** The DM already has the Character note and its stat block in Obsidian.
- **It can never be stale.** The Player Wiki is rewritten from scratch at every update, so the sheet always shows the current Build, and no skill has to remember to refresh it.
- **A script renders it, from structured data.** The fence holds every number the sheet shows, as YAML that `statblock.py` already parses. Reading the Build's Markdown sections would mean parsing headings in the Workspace Language. A script also gives the same page for the same note, which a test can check (ADR 0017).
- **The layout is DM Realm's own.** Copying the official sheet's look would reproduce Wizards of the Coast's design. Filling the official fillable PDF would be English-only, would need a different form per Edition and a PDF library.
- **A page of its own, outside Quartz's pipeline.** The Character's page stays a plain Markdown note that any wiki generator reads. A sheet copied after the build does not depend on how a Quartz release treats an HTML file in its content, or on `publishAssets: referenced`.
- **Maximums only.** What is spent in play is the Campaign's Party State (ADR 0010). A tracker in a shared site would keep a separate truth in each player's browser.

## Considered Options

- **A printable PDF, rendered with headless Chrome.** Rejected: the sheet is read on screen, in the site, and Chrome would become a second requirement after Node.
- **A file in the Character's Attachments, written by `dmr-character` and kept in sync after every Build change.** Rejected: Obsidian cannot open an HTML file, and every skill that changes a Build would have to rewrite it.
- **The sheet as an HTML block inside the Character's wiki page, styled through Quartz's `custom.scss`.** Rejected: the Character's page would no longer be plain Markdown, and the sheet would exist only in the site.
- **A Quartz component or transformer.** Rejected: it ties the sheet to the pinned release's internals.
- **Opt-in per Character.** Rejected: the wiki's parts are chosen whole (ADR 0017), and a Character the players can read can have its sheet.

## Consequences

- **The Player Wiki folder now holds HTML besides Markdown:** one sheet per Character and one shared stylesheet.
- **A Character whose fence is missing or unreadable gets no sheet and no link line.** The report names it.
- **Labels come from the Translation Glossary**, in English where one is missing, and the report lists them. The script never writes the Glossary.
- **The sheet loads nothing from outside the site:** no scripts, no CDN, system fonts (ADR 0018's "no reader is tracked").
- **The sheets are not in Quartz's search or navigation.** They are reached from the link on the Character's page, which opts out of Quartz's in-page navigation and previews, since those would load the sheet inside the wiki's own page.
- **A sheet's file is named by the name rules**, `<Character>_<Character Sheet>.html`, and its place in the site is where Quartz links it, plus `.html`, as Quartz's own pages are.
