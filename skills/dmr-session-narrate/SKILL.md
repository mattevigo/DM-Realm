---
name: dmr-session-narrate
description: Tell a consolidated Session of a Campaign in a DM Realm Workspace as a Chapter of the Campaign's Chronicle — prose for the players ("narrate session 5", "write the chapter of the last session", "tell it as a bard would, and keep that style"), faithful to its Live Notes and Recap, in the voice the DM sets for the Campaign.
argument-hint: <the Session to tell, e.g. the last session of Heroes, with any narration instruction>
allowed-tools: Read, Glob, Grep, Write, Edit, Skill, Bash(ls:*)
---

# Tell a Session as a Chapter

Write one Chapter of a Campaign's Chronicle from one consolidated Session. The rules — what a Session is, Live Notes, the Diary, the Chronicle, its Chapters and Voice, links, translation and names — are the `dmr-workspace` skill's structure.md; this skill is the procedure that applies them, and the [default telling](#the-default-telling). Speak to the DM in the Workspace Language.

1. **Load the rules.** Invoke `dmr-workspace` (read its structure.md in full), and find the Workspace Language in use as its "Fixed after Setup" reads it.
2. **The Campaign** is the one the request names, or the Workspace's only one. With several and none named: ask which, and write nothing.
3. **Which Session**: the one the request names, or the latest Session, by its `date`, that is consolidated and has no Chapter. When that leaves several or none: say which Sessions exist and which have a Chapter, ask, and write nothing.
   - **Not consolidated**, as structure.md's Diary rule tells it: say so, say to consolidate it first (the `dmr-session-consolidate` skill), and write nothing.
   - **A Chapter already at its path**: say so, warn that writing it again replaces the note and every edit made to it by hand, ask whether to replace it, and write nothing. Only a yes given after that warning replaces it.
4. **Read the sources**, and nothing else of the Campaign:
   - **The Session note**: its Present line, its Live Notes — what happened — and its Recap — what mattered. Where they disagree, the Live Notes win. Its Prep is what was planned, not what was played: never a source.
   - **The notes its Live Notes and Recap link to**, for how a place, an NPC or a thing looks and sounds.
   - **The previous Chapter**: the Chapter of the latest Session, by `date`, played before this one and told in the Chronicle — where the story was left, and its tone. Not its length, which is [the default telling](#the-default-telling)'s unless the Voice sets one. No other Chapter.
   - **The Voice**, when the Chronicle has one, and any instruction in the request.
5. **Sort what the party knows.** Every fact in the sources is one the party saw or learned, or one it did not. One the sources mark as unknown to the party ("they didn't notice", "secretly"), and one you cannot tell the party learned, is held back — unless the Voice or the request opens up what only the DM knows.
6. **Write the Chapter** in the Chronicle, as structure.md's Chapter name rule names it, creating the folder with the first Chapter. The word "Chapter" and the names of the Chronicle and the Voice are translated as structure.md's "Translating a term" says, the Translation Glossary first:
   - **Heading**: the word "Chapter" in the Workspace Language and the Session's number, then `: <Title>` when the Session has one (`# Chapter 3: The Gatehouse`); a Side Session's Chapter is headed with its name.
   - **The line under it** links to the Session note, labelled as the Session's heading reads (`[[Session_03_The_Gatehouse|Session 3: The Gatehouse]]`).
   - **Then the prose**, told as the Voice and the request say and, where they say nothing, as [the default telling](#the-default-telling) does. Every instruction gives way to the [faithfulness rules](#what-is-never-invented).

   The Chapter, the Voice when step 7 keeps an instruction, and the Translation Glossary rows a new term needs are the only files written: the Session note, the other Chapters and every other note stay as they are.
7. **Keep an instruction** only when the request says to ("from now on", "keep that style", "for every chapter"): add it to the Voice in the DM's words, one line each, creating the note (headed with its name) when it does not exist. An instruction the request gives without saying so applies to this Chapter alone, and the Voice stays as it is.
8. **Report**: the Chapter's path; the previous Chapter it read, or that it had none; each Session played between that one and this with no Chapter, as a gap in the Chronicle; each fact held back, one line each, with the offer to tell it again with the ones the party did learn; each instruction kept in the Voice. Offer to keep any one-off instruction the request gave.

Done when the Chapter is written and reported, or the DM has the one question that stopped it and nothing was written.

## What is never invented

The Chapter is faithful to its sources, whatever the Voice or the request asks:

- **No event or outcome** the Live Notes and Recap do not give: no fight, find, meeting, wound or death, and none ending differently.
- **Nothing a Character decides, thinks or feels** that its player did not give it at the table, as the notes record. What a Character does and says is the notes'; the telling may only word it.
- **A Character missing from the Present line** is not in the Chapter, and its absence is explained only as the Live Notes explain it.

What is invented is the telling: the setting, light and sound, the mood, the pace, and the wording of a line the notes record.

## The default telling

What the Voice and the request do not say is told this way:

- **In the Workspace Language**, in the past tense and the third person, following the party: the telling goes only where the party went.
- **No game mechanics**: no rolls, DCs, hit points, spell slots, levels or rule names. "The blade nearly felled her", not "she took 14 damage".
- **Names** as the notes give them. A thing that has a note is linked at its first mention, as the Campaign's Scope allows; the rest stays text.
- **It opens where the previous Chapter ended**, or with the party as the Recap first finds it, and **ends where the Session ended**.
- **About 800 to 1500 words**, longer for an eventful Session, however short its notes or the previous Chapter.
