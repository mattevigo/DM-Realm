---
name: dmr-adventure
description: Design an Adventure of the DM's own in a DM Realm Workspace — start one ("let's design an adventure called The Drowned Bell"), shape its premise and its Parts, fill a Part with its places, NPCs, encounters and items ("add a flooded crypt to The Drowned Bell", "draft chapter 2's rooms"), or review it against adventure-design practice ("review my adventure"). Not for an official Adventure: importing one is dmr-import-adventure's, a question about one dmr-ask's.
argument-hint: <the Adventure, and what to design in it, e.g. The Drowned Bell: its second Part>
allowed-tools: Read, Glob, Grep, Write, Edit, Skill, Bash(mkdir:*), Bash(ls:*), Bash(sh:*), Bash(python3:*), Bash(DMR_SOURCE_CACHE=*)
---

# Design an Adventure

Design an Adventure the DM writes for any table to run. The rules — where a designed Adventure lives, its README, its Part notes, its items and monsters, its links, Ideas, translation and names — are the `dmr-workspace` skill's structure.md, its "Designed Adventures" above all; this skill is the procedure that applies them, stage by stage. Speak to the DM in the Workspace Language.

## Every request

1. **Load the rules.** Invoke `dmr-workspace` (read its structure.md in full), and find the Workspace Language and the Edition in use as its "Fixed after Setup" reads them.
2. **Which Adventure.** The one the request names, among the Adventure folders whose README has no source property. With none named, the Workspace's only designed Adventure; with several, ask which and write nothing.
   - **A new one** — the request starts one, or names one not in the Workspace: [Start](#start).
   - **An official Adventure** is never changed here. Say so: a change the DM makes to one is the Campaign's that runs it, a question about it is `dmr-ask`'s.
   - **A Campaign's plot to become an Adventure** ("make the Heroes' crypt an adventure of its own") is a Promotion, as structure.md's "Promotion to an Adventure" says; do it by those rules, then design on from here.
3. **Read the Adventure, whole**: its README, every Part note, and every note they link — its Places, NPCs, Encounters and Items, its Homebrew monsters, the World notes of the world its README names.
4. **The stage**: the one the request asks for — [Premise](#premise), [Structure](#structure), [Content](#content) or [Review](#review). A request may ask for several; take them in that order. Each may be asked for again at any time: editing what exists is the same stage again.
5. **Write**, as [Authorship](#authorship) says.
6. **Report**: each note written or changed, by its path; each Idea or draft offered and waiting for the DM; what was offered for Import; and the stage the DM might take next — after a Premise, Structure; after a Structure, a Part's Content; once Parts have Content, a Review.

Done when every note the stage writes, of what the DM gave or kept, is written as structure.md's "Designed Adventures" says — or the DM has the options, the draft or the one question that stopped it, and nothing was written.

## Authorship

Only the DM's words, and what the DM keeps, are written.

- **The DM's own content** in the request ("the Old Pier is in Porto Ladro", "Part 2 is the sunken temple") is written as given, in its place.
- **Options**, when the request asks for ideas or the stage needs something the DM has not given: offer two or three Ideas in chat, each made, checked and shown as structure.md's Ideas rule says for a designed Adventure, and end your turn. Write only the one the DM picks or edits, its new things no longer marked, without its "Checked against" list.
- **A draft**, when the DM asks for one ("draft Part 2", "fill in the crypt's rooms"): draft the whole of it — every note it needs, each by its path, each invented thing marked new — show it as a preview, and end your turn. Write what the DM keeps, as they edit it; a line they drop is not written.

Never fill a section on your own, and never write an Idea or a draft before the DM's yes.

## Start

1. **The title** is the only thing a new Adventure needs. A request with none: ask for it, and write nothing. Its folder, and a clash with an existing Adventure folder, are structure.md's "Designed Adventures".
2. **Write the README** with the title and every section the request already gives ([Premise](#premise) checks them).
3. **Ask once, then stop.** In one message, ask the README sections the request left open, each optional; say you can suggest a pitch and a hook; and name the next stage, Structure. A request that answered every section asks nothing.

## Premise

The README's sections, as structure.md lists them. Each is written only once the DM gives it, or picks it among Options.

- **World**: look for it where structure.md keeps the DM's worlds and where it keeps an official Setting; one with no folder yet is named alone, and the report says so.
- **Level Range**: two levels, or one for a single-level Adventure.
- **Options** for a pitch or a hook follow the Edition's DMG on laying out a premise and drawing in the players ([practice.md](practice.md)).

## Structure

Its Parts and how they connect.

- **A Part note** is made from the Adventure_Part Template in use, as structure.md's "Templates" says a note is made from one, in the Adventure's Parts folder, named after the Part in the DM's words. It holds what the DM gave of its Summary, Structure, Clues and Ways out; a section with nothing yet stays as the Template has it.
- **The README's Parts** list every Part note, numbered in play order, each linked with its one line; adding, renaming, reordering or removing a Part updates the list.
- **A shape** — a chain of scenes, a web of nodes, a site to explore — is the DM's choice; Options offer the ones [practice.md](practice.md) describes when the DM asks.
- **Names in a Part** — a place, an NPC, an encounter — stay text until Content gives them a note.

## Content

The notes of one Part: its Places, NPCs, Encounters and Items.

- **A place or an NPC** is made from its Template in use, in the Adventure's Places or NPCs; its secrets go in the Template's Secrets section.
- **An encounter** is a note in the Adventure's Encounters, in this format: `# <name>`, a line linking where it happens, then the sections Situation (what is there and why), Creatures (each linked to its monster note, with how many), Difficulty, Tactics, Treasure (each item linked) and Afterwards (what follows from each way it ends) — `##` headings in the Workspace Language, a section with nothing to hold left out. **Difficulty** comes from the Edition's encounter-building rules, read through `dmr-trusted-source` and cited, for the README's Level Range and a party of four unless the DM says otherwise, with each House Rule that changes them named.
- **An item** it introduces is made from the Homebrew_Item Template in use, in the Adventure's Items, an item note as structure.md says. An official item is linked where Reference has it.
- **A monster** it introduces is a Homebrew monster, made from the Homebrew_Monster Template in use in Homebrew › Monsters, with no word of the Adventure; its statistics are the DM's, or an official monster's it `extends` with the changes the DM keeps, and its name is checked as structure.md's "Names in the bestiary" says. An official monster is linked in Reference Monsters.
- **Official material missing** from the Workspace — a monster an encounter names, an item — is offered for Import through `dmr-import`, in the report. On the DM's yes, invoke it, then link what it wrote. Until then the note names it as text.
- **Each note** is linked from the Part note where the Part names it, and links back to the Part only where it says something of it.
- **A map or an image** the DM gives goes in the Adventure's Attachments, named after the note that embeds it, and is embedded there.

## Review

Read every note of the Adventure, and check it against the [practice](practice.md) and the rules. Writing nothing, report each finding in chat — the note, what it lacks, and the practice or rule it breaks, cited:

- **Clues**: each conclusion of a Part's Clues with fewer than three notes giving it.
- **Ways out**: each Part with none, but the last one meant to be played.
- **Difficulty**: each encounter outside the README's Level Range, or with no Difficulty, by the Edition's encounter-building rules, cited.
- **Missing notes**: each name in a Part note that its Content has no note for, and each link that leads nowhere.
- **The link rules**: each link or mention that structure.md's link rules forbid a designed Adventure, a Campaign or a Character above all.
- **The README**: each section left empty, and a Parts list that disagrees with the Part notes.

End with the stage that would fix each finding. A Review that finds nothing says so.
