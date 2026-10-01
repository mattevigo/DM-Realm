---
name: dmr-session-prepare
description: Prepare a Session of a Campaign in a DM Realm Workspace — create its note and fill its Prep ("prepare the next session", "prep session 12", "a side session for Ayla and Brom called The Mystery of Ambika") from the previous Session's loose threads, the DM's idea, the Adventure the Campaign runs and where the party stands.
argument-hint: <the Session to prepare, e.g. the next session of Heroes, with your idea for it>
allowed-tools: Read, Glob, Grep, Write, Skill, Bash(ls:*)
---

# Prepare a Session

Create one Session note and fill its Prep. The rules — what a Session is, its number and name, Side Sessions, the Diary, Party State, the Template, links, translation and names — are the `dmr-workspace` skill's structure.md, and the note's format is the Workspace's Session Template; this skill is the procedure that applies them. Speak to the DM in the Workspace Language.

1. **Load the rules.** Invoke `dmr-workspace` (read its structure.md in full), and find the Workspace Language in use as its "Fixed after Setup" reads it.
2. **The Campaign** is the one the request names, or the Workspace's only one. With several and none named: ask which, and write nothing.
3. **Read the Campaign**: its README, every note in its Sessions folder (the properties of each, and the whole of each [previous Session](#the-previous-sessions)), its Diary and its Party State, when they exist.
4. **Which Session.** Its number and its name are structure.md's — the Side Session rule and the Session name rule; this step only picks the case:
   - **The next one**, unless the DM says otherwise.
   - **A number the DM names** is used when it is the next one. One already in use, or one that leaves a gap in the run ("session 7" after 04): say which Sessions exist, ask what the DM wants, and write nothing.
   - **A Side Session**, when the DM asks for one outside the numbered run or gives a name with no number ("Spin Off The Mystery of Ambika").
   - **A name or naming scheme the DM gives** ("12b", "name it by its date").

   A note already at the new note's path: say so, ask, and write nothing.
5. **Check each previous Session is consolidated**, as structure.md's Diary rule tells it. For one that is not, write nothing in this turn: warn the DM, say what is missing (its Diary entry, and its Recap and Loose threads when they are empty), and ask whether to consolidate it first or to prepare anyway. On "prepare anyway", go on with what it holds.
6. **Gather the Prep** from its [sources](#prep-sources).
7. **Write the note**, from the Session Template in use, as structure.md's "Templates" says a note is made from one, in the Campaign's Sessions folder:
   - **Heading**: the word "Session" in the Workspace Language and the number (`# Session 4`), then `: <Title>` when it has one; a Side Session's is its name in the DM's words.
   - **Properties**: the number, and the date the request gives, as `YYYY-MM-DD`. A request with no date leaves it empty.
   - **Present**: the party in the README, each Character linked as the README links it. A request that says who plays (typical of a Side Session) lists those Characters instead.
   - **Prep**: as [Prep sources](#prep-sources) places it. A sub-section with nothing to hold stays empty.
   - **Everything after Prep** stays as the Template has it: empty.

   This note is the only file written or changed: the Diary, Party State, the README, the other Sessions and every Character stay as they are.
8. **Report**: the note's path; what was carried over — each thread, the idea, each Adventure note linked, where the party stands; each thing offered for Import; and, when the date is empty, ask for it — "not decided yet" leaves it empty.

Done when the one Session note exists with its Prep filled from the sources that had something to give, or the DM has the one question that stopped it and nothing was written.

## The previous Sessions

The Sessions whose Loose threads the new one inherits: the numbered Session played last, and every Side Session played after it, by their dates. A Session whose Live Notes and Recap are both empty is prepared, not played: it is passed over here. With no played Session — a Campaign's first — step 5 and the Loose threads are skipped.

## Prep sources

Prep holds what the DM, the Campaign's notes and the Adventure's notes already say, arranged for the table. Every fact in it comes from one of these sources; when the DM asks for ideas, offer two or three in chat and write only the one the DM picks.

| Source | Goes |
| --- | --- |
| **Party State**, when the Campaign has one: who is wounded, who has spent slots or uses, who has a condition, in a line or two. A party at full strength, or no Party State, is said in the report instead | Directly under the Prep heading, first |
| **The previous Sessions' Loose threads**, every one, each in its Session's words, as a list introduced by a link to that Session | Directly under the Prep heading, after where the party stands |
| **The DM's idea** in the request, in the DM's words | The Prep sub-section each part fits: the opening scene in the first, an NPC among the NPCs |
| **The Adventure**: for each Adventure the README lists as running, the notes in its Workspace folder for the part the party has reached (as the previous Sessions' Recaps, the Diary and the README's current state tell it). Each is a link to the Adventure note with a line on why it matters now; the Adventure's text stays in its note | The Prep sub-section of its kind: a place among the places, an encounter among the encounters |

Material the Prep needs that is not in the Workspace — a monster an encounter names, the next chapter of the Adventure — is named in the report with an offer to import it through the `dmr-import` skill. On the DM's yes, invoke `dmr-import`, then link what it wrote from the Prep. Until then the Prep holds only what the Workspace has.

A place, NPC or quest the Prep names that has no note yet stays text: it becomes a note when the DM asks for one.
