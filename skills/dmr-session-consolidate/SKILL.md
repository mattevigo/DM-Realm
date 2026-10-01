---
name: dmr-session-consolidate
description: Consolidate a played Session of a Campaign in a DM Realm Workspace — close it from its Live Notes ("consolidate session 13", "close the last session"): its Recap, Loose threads and title, the Campaign's Party State and Diary, and the lasting changes to its Characters' Builds.
argument-hint: <the Session to close, e.g. the last session of Heroes>
allowed-tools: Read, Glob, Grep, Write, Edit, Skill, Bash(ls:*), Bash(mv:*), Bash(mkdir:*)
---

# Consolidate a Session

Close one played Session from its Live Notes. The rules — what a Session is, Live Notes, its name, the Diary, Party State, what of a Character a Campaign keeps, Promotion, Templates, links, translation and names — are the `dmr-workspace` skill's structure.md; the Session note's format is the Workspace's Session Template; the Character note and how it changes are the `dmr-character` skill's. This skill is the procedure that applies them. Speak to the DM in the Workspace Language.

1. **Load the rules.** Invoke `dmr-workspace` (read its structure.md in full), and find the Workspace Language in use as its "Fixed after Setup" reads it.
2. **The Campaign** is the one the request names, or the Workspace's only one. With several and none named: ask which, and write nothing.
3. **Read the Campaign**: its README, every note in its Sessions folder, its Diary and its Party State, when they exist.
4. **Which Session**: the one the request names, or the latest Session with Live Notes and no Diary entry (with none, the latest with no Diary entry). When that leaves several or none: say which Sessions exist, ask, and write nothing.
   - **One the Diary already has** is consolidated: say so, ask what the DM wants changed, and write nothing.
5. **Its Live Notes are the source**, and the only one: Prep is what was planned.
   - **Empty Live Notes**: ask the DM what happened, and write nothing. The DM's answer — or the account the request already gives — is written into the note's Live Notes section in the DM's words, before anything else, and is the source from then on.
6. **Work out [what the Session changes](#what-a-session-changes)**, reading each Character present and each note the Live Notes name.
7. **Preview, then a yes.** Show the DM every change in one message — the table's rows, each as its own line the DM can drop — and end your turn with nothing written. A go-ahead the request already gives ("apply everything without asking") is the yes, and a line it drops is dropped; a title it does not pick leaves the note untitled, with the titles offered in the report.
8. **Apply** what the DM kept, in this order, so that an interrupted run still reads as not consolidated:
   1. **Imports**, through the `dmr-import` skill.
   2. **New Campaign notes**, each from its Template in use, as structure.md's "Templates" says, holding what the Live Notes say of it and nothing more.
   3. **Promotions**, as structure.md's "Promotion" does them.
   4. **Builds.** Invoke `dmr-character` and run its update job for each Character, asking for the change itself ("Wren gains a Ward Lantern, attuned, and 35 gp"): the note's numbers and stat block follow, with no past Build.
   5. **Quests** the Live Notes show as finished: their notes say so.
   6. **Party State**, created when missing: the section of each Character present and the Party treasure, overwritten. Every other section stays byte for byte.
   7. **The Session note**: the Present line as the Live Notes show who played; the [Recap](#the-recap) and the Loose threads — what the Live Notes leave open, one line each; the title in its heading (`# Session 3: <Title>`). Its Live Notes and its Prep stay byte for byte. Then its name, as structure.md's Session name rule gives it: an untitled note is renamed and the links to it rewritten, a note the DM named keeps its name.
   8. **The Diary, last**: this Session's entry, as structure.md's Diary rule and the entries already there shape it, at its place by date. Created when missing.
9. **Report** what was written: the Session's new name; each Character's changes, with every number that changed; Party State; each note created, imported or promoted; each line the DM dropped; and each level gained, with the offer below.

Done when the Diary has the Session's entry and every change the DM kept is written, or the DM has the one question that stopped it and nothing was written.

## What a Session changes

Every row is read from the Live Notes: what they do not say did not happen. A row with nothing to show is left out of the preview.

| The Live Notes show | Change |
| --- | --- |
| Who played | The Present line. A Character who was absent is in no other row |
| A Character present gained, lost, spent or attuned something of its own — an item, coins, attunement | Its Build, one line per Character with each change and the numbers that follow |
| Coins or items taken with no owner named | The Party treasure in Party State, under the same condition as the row below; no Character note |
| Where each Character present stands when the Session ends — hit points, spent spell slots, spent class uses, conditions, every rest in the Live Notes applied | Its section in Party State — when no later Session is consolidated. Party State is the party now: a Session closed after a later one leaves it as it is, and the report says what was left out |
| An NPC, Place, Faction or Quest named, with no note in the Workspace | A new Campaign note of that kind |
| An official monster, item or spell named, with no Reference note | An Import |
| A Character now holding Campaign homebrew | The Promotion question of structure.md's "A Character gaining Campaign homebrew" |
| A Quest finished | That Quest's note |
| A level, a milestone or experience gained | The Recap records it. The Character's level stays: the level-up is the `dmr-character` skill's, offered in the report and run when the DM asks |
| A note with no title | Two to four titles to pick from |

## The Recap

Written from the DM's point of view and faithful to the Live Notes: what the party did and how it ended, real outcomes only, about as long as the previous Sessions' Recaps. Names that have a note are linked, as the Campaign's Scope allows.
