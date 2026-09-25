# Issue tracker: Trello

Issues and specs for this repo live as **cards** on the Trello board **`DM Realm`** — https://trello.com/b/LsoFRUO2/dm-realm (board ARI `ari:cloud:trello::board/workspace/60d3afb18e9c90173f526fb8/6ab525353b9b49dc6a4fb3c0`). Use the tools of the `trello` MCP server for all operations. It is registered for this project in local scope (`claude mcp add --scope local --transport http trello https://mcp.trello.com/v1`), never in a checked-in `.mcp.json`: the repository is the `dm-realm` plugin, and a root `.mcp.json` would ship Trello to every DM who installs it. Reference a card by its URL (or short link); write tools need the card's ARI, so resolve it with `trelloReadCard` `get` first.

## Board layout

- **Lists = workflow state**: `Backlog` → `Ready` → `In progress` → `Done`.
- **Labels = triage roles** (see `triage-labels.md`), plus `wayfinder:*` labels used by `/wayfinder`.
- New cards go into `Backlog` unless a skill says otherwise.

## What the MCP server can't do

- **Create or rename labels.** Labels are managed by a human in the Trello UI; the agent can only attach/detach existing ones (find their ARIs with `trelloReadBoard` `list_labels`). If a label a skill needs is missing, stop and ask the user to create it.
- **Assign members.** Claiming a card is done by moving it to `In progress`.

## Conventions

- **Create an issue**: `trelloWriteCard` `create` in `Backlog`; name = issue title, desc = issue body (markdown).
- **Read an issue**: `trelloReadCard` `get` — description, labels, list and comments. Add `trelloReadChecklist` for checklists.
- **List issues**: `trelloReadCard` `list_by_board` (grouped by list) or `list_by_list`; `trelloSearch` `search_cards` with `label:` / `list:` qualifiers for filtering.
- **Comment on an issue**: `trelloWriteCard` `add_comment` on the card. Older cards may also carry description-level comments under a `## Comments` heading; leave them as they are.
- **Apply / remove labels**: `trelloWriteCard` `attach_label` / `detach_label`.
- **Close**: add the outcome as a comment, then `move` the card to `Done` and `mark_done`. For `wontfix`, attach the label, add the reason as a comment, and `archive` the card.

## Blocking

Trello has no native blocking links. Record them as a line at the top of the card description:

    Blocked by: <card URL>, <card URL>

A card is unblocked when every card it lists is in `Done`.

## When a skill says "publish to the issue tracker"

Create a card on the `DM Realm` board in `Backlog`.

## When a skill says "fetch the relevant ticket"

`trelloReadCard` `get` on the card URL, including its comments and description-level `## Comments`.

## Wayfinding operations

Used by `/wayfinder`. The **map** is a single card with **child** cards as tickets.

- **Map**: a card labelled `wayfinder:map`, holding the Notes / Decisions-so-far / Fog body in its description, and a checklist `Tickets` with one item per child card URL.
- **Child ticket**: a card with `Part of: <map URL>` at the top of its description, added to the map's `Tickets` checklist (`trelloWriteChecklist` `add_item`). Labels: `wayfinder:<type>` (`research`/`prototype`/`grilling`/`task`).
- **Blocking**: the `Blocked by:` line described above.
- **Frontier query**: the map's child cards in `Backlog` or `Ready` with no unfinished blocker; first in checklist order wins.
- **Claim**: move the card to `In progress`. This is the session's first write.
- **Resolve**: add the answer as a comment, move the card to `Done`, tick its item in the map's checklist (`update_item` `checked: true`), then append a context pointer (gist + link) to the map's Decisions-so-far.
