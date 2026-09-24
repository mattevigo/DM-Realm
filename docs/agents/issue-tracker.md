# Issue tracker: Trello

Issues and specs for this repo live as **cards** on the Trello board **`DM-Realm`**. Use the tools of the `trello` MCP server (configured in `.mcp.json`) for all operations. Reference a card by its URL (or short link).

## Board layout

- **Lists = workflow state**: `Backlog` → `Ready` → `In progress` → `Done`.
- **Labels = triage roles** (see `triage-labels.md`), plus `wayfinder:*` labels used by `/wayfinder`.
- New cards go into `Backlog` unless a skill says otherwise.

## Conventions

- **Create an issue**: create a card in `Backlog`; title = issue title, description = issue body (markdown).
- **Read an issue**: fetch the card with its description, labels, list, members, checklists and comments.
- **List issues**: list the cards on the board, filtered by list and/or label.
- **Comment on an issue**: add a comment to the card.
- **Apply / remove labels**: add or remove the Trello label on the card (create the label on the board first if it doesn't exist).
- **Close**: comment with the outcome, then move the card to `Done`. For `wontfix`, apply the label, comment the reason, and archive the card.

## Blocking

Trello has no native blocking links. Record them as a line at the top of the card description:

    Blocked by: <card URL>, <card URL>

A card is unblocked when every card it lists is in `Done`.

## When a skill says "publish to the issue tracker"

Create a card on the `DM-Realm` board in `Backlog`.

## When a skill says "fetch the relevant ticket"

Fetch the card (by URL or short link) including its comments.

## Wayfinding operations

Used by `/wayfinder`. The **map** is a single card with **child** cards as tickets.

- **Map**: a card labelled `wayfinder:map`, holding the Notes / Decisions-so-far / Fog body in its description, and a checklist `Tickets` with one item per child card URL.
- **Child ticket**: a card with `Part of: <map URL>` at the top of its description, added to the map's `Tickets` checklist. Labels: `wayfinder:<type>` (`research`/`prototype`/`grilling`/`task`).
- **Blocking**: the `Blocked by:` line described above.
- **Frontier query**: the map's child cards not in `Done`, with no unfinished blocker and no members; first in checklist order wins.
- **Claim**: add yourself as a member of the card and move it to `In progress`. This is the session's first write.
- **Resolve**: comment the answer, move the card to `Done`, tick its item in the map's checklist, then append a context pointer (gist + link) to the map's Decisions-so-far.
