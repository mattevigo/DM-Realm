---
name: dmr-table-record
description: Bring MapForge's Table Record of a played Session into its Live Notes in a DM Realm Workspace ("bring MapForge's record into session 21", "add what MapForge recorded to the last session") — the DM's comments, the Maps and each fight as it ended. It does not consolidate the Session.
argument-hint: <the Session, e.g. the last session of Heroes>
allowed-tools: Read, Glob, Grep, Edit, Skill, Bash(python3:*), Bash(ls:*)
---

# Bring a Table Record into the Live Notes

Write what MapForge recorded of one played Session — its Table Record — into that Session's Live Notes ([ADR 0012](../../docs/adr/0012-the-table-record-enters-a-session-as-its-live-notes.md)). The rules — what a Session is, Live Notes, MapForge's files, translation and names — are the `dmr-workspace` skill's structure.md; the Session note's format is the Workspace's Session Template. This skill only adds to the Live Notes: Consolidation is the `dmr-session-consolidate` skill's, on a request of its own. Speak to the DM in the Workspace Language.

1. **Load the rules.** Invoke `dmr-workspace` (read its structure.md in full), and find the Workspace Language in use as its "Fixed after Setup" reads it.
2. **The Campaign** is the one the request names, or the Workspace's only one. With several and none named: ask which, and write nothing.
3. **Find its Session Logs**, from the Workspace root:

   ```sh
   python3 "<this skill's base directory>/table-record.py" find . "<the Campaign's folder>"
   ```

   It prints MapForge's Session Logs, each with its local `date` and `time`, whether it is `running`, whose it is (`belongs`: `this`, `other` — another Campaign's — or `none` — no Campaign's Map) and the notes it is already `written_in`. No `.mapforge/` or no log: say MapForge recorded nothing, and write nothing.
4. **Which Session**: the one the request names, or the latest Session of the Campaign, by its `date`, that has a log on that date to write. A Session with no `date`: ask the DM for it, and write nothing. When that leaves none: say which logs exist by date and which are written already, and write nothing.
5. **Its logs** are those whose `date` is the Session's and whose `belongs` is not `other`, in start order. Each is written unless:
   - **already written** — `written_in` names a note: it stays there; say where;
   - **running** — MapForge has not closed that evening: say so, and write it only when the DM's request says to write it as it stands;
   - **whose it is is unclear** — its `belongs` is `none` and another Campaign has a Session on that date: ask the DM whose it is, and write nothing for it.
6. **Read each log** to write:

   ```sh
   python3 "<this skill's base directory>/table-record.py" read . "<its file>"
   ```

   It prints the evening's events in order: each Map, each comment, each fight as MapForge folds it.
7. **Write each** into the Session note's Live Notes, where and under the marker structure.md's Live Notes rule gives it, in [this shape](#the-shape), after any written there before. The rest of the note stays byte for byte — the DM's own Live Notes above all — and no other file is written. MapForge's files are only read (structure.md's MapForge rule).
8. **Report**: for each log written, its time, how many comments and fights it brought in; each log left out, and why; and that the Session is ready to consolidate when the DM asks ("consolidate session 3").

Done when every log of the Session that can be written is in its Live Notes, or the DM has the one question that stopped it and nothing was written.

## The shape

One subsection per log, its heading `### MapForge, <date> <time>` (the log's local date and time), then structure.md's marker with the log's file name, then one list, in the order the events happened, its words in the Workspace Language except where said:

- **A Map**: `- **<Map>: <name>**`, the word Map in the Workspace Language and the Map's `name` as it is.
- **A comment**: `- <text>`, the DM's words exactly as MapForge has them, never translated, corrected or summarised.
- **A fight**: `- **Fight** <time>–<end time>, <rounds> rounds` (in the Workspace Language), then one sub-item per Combatant, under its MapForge label as it is, a Creature's `monster` in brackets after it (`GG1 (Gnoll Warrior)`):
  - its hit points at the end as `<hp>/<max_hp>` and the word for hit points, its temporary hit points, its conditions, its exhaustion level and concentration — each only when there is one, and the hit points only when typed;
  - `down` when its hit points end at 0 or fewer; `dropped to 0` when they did during the fight and ended above; `left the fight` when it is `benched`.

  Then, when the fight has `notes`, a sub-item `Notes` with one item each, `<name>: <text>`, the text as MapForge has it. A fight with no rounds and no notes is left out. A fight not `found` is one line, its time and that its Combat Log is not in the Workspace; one not `ended`, that MapForge has not closed it.

Moves and rolls are not written.
