# The Table Record keeps moves, and a fight in play order

The DM reads the Table Record in the Live Notes to remember how the evening went, and a fight's notes and rolls only make sense in the order they were played: a saving throw belongs between the spell that called for it and the note that says what it did. So a fight's notes, rolls and moves are written as one list in play order, each with its round. A Correction's entries go right after the Turn it targets, as MapForge folds it. Moves are written too, but grouped so they do not bury the DM's comments. Outside a fight, all the moves between two other events make one line, with each Pawn's total. Inside a fight, a Combatant's moves in a row within a Turn make one item. A distance is written in whole squares, half rounding up, converted to the unit the official books in the Workspace Language use: 5 feet a square in English, 1.5 metres in a language whose books use metres. This amends [ADR 0012](0012-the-table-record-enters-a-session-as-its-live-notes.md), which left moves out.

## Considered Options

- **Every move as MapForge logs it.** Rejected: an evening logs up to about 200 moves outside fights against about 50 comments and rolls, and dragging a Pawn often logs several moves for one step. Grouped, the same evening gives 26 lines.
- **A Pawn's consecutive moves only** outside fights. Rejected: a party moves in turn, so the runs barely shorten (196 to 176 on the same evening).
- **Notes and rolls in separate lists** (as before). Rejected: with the order gone, a roll no longer sits next to what called for it.
- **Squares as the unit.** Rejected: the Live Notes are read with the game's own terms, and the books give distances in feet or metres.

## Consequences

- A Session's Live Notes get longer, by one line per group of moves and one item per Combatant's step in a fight; Consolidation still reads them as it did.
- The Table Records already written stay as they are (Live Notes are never rewritten). Only logs written from now on have moves and play order.
- `table-record.py read` gives a fight's `entries` in place of its `notes` and `rolls`, and a `moves` event outside fights.
