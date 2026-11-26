---
name: dmr-campaign
description: Campaigns in a DM Realm Workspace — start a new one ("start a new campaign called Heroes of the Border", "a campaign in my world Orsenna, based on The Sunken Keep"): its folder, its core subfolders and a README with its pitch, world, Adventures run, party, starting level, tone and table limits, truths and opening; change that README as the Campaign goes on ("the tone of Heroes gets darker", "add a truth: the moon is hollow", "we'll run Tomb of Annihilation next", "Ayla joins Heroes", "Brom leaves the party"); and change where its party stands between Sessions, in its Party State ("Brom drank a potion on the way home, he's at 30", "Ayla used her last wand charge"), or rewrite an older Party State into the current format ("update the Party State to the new format").
argument-hint: <the Campaign to start or change, e.g. Heroes of the Border>
allowed-tools: Read, Glob, Grep, Write, Edit, Skill, Bash(mkdir:*), Bash(ls:*)
---

# Campaigns

Start a Campaign — its folder, its core and its README — and change its README afterwards. The rules — where a Campaign lives, what it may link to, how its README is kept current, folder creation, translation and names — are the `dmr-workspace` skill's structure.md; this skill holds the procedures and the README's format. Speak to the DM in the Workspace Language.

A request that names a Campaign already in the Workspace and says what to change in it is a [change](#change-the-readme) — of [Party State](#change-party-state) when it is where a Character stands (its hit points, slots, uses, charges, conditions, an effect on it) or the Party treasure, or a rewrite of Party State into its current format; any other is a start.

## Start a Campaign

1. **Load the rules.** Invoke `dmr-workspace` (read its structure.md in full), and find the Workspace Language in use as its "Fixed after Setup" reads it.
2. **The name** is the only thing a Campaign needs. A request with none: ask for it, and write nothing. The folder is the name with the name rules applied. When a Campaign folder of that name already exists, write nothing: name that folder, and ask for another name or offer to [change that Campaign's README](#change-the-readme) instead. A new Campaign never replaces or merges into one.
3. **Take what the request gives** for each [README section](#the-readme), and check it against the Workspace:
   - **World**: look for it both where structure.md keeps an official Setting and where it keeps the DM's own world.
   - **Adventures Run**: each is an Adventure folder, or not in the Workspace.
   - **Party**: each Character is a Character folder. One who is not — "a new character for Baldu" — is not in the party yet: it is [offered](#new-characters).
4. **Write the Campaign**: create its folder and the core structure.md's Campaigns table lists, and the README with every section the request answered. Nothing else: no Session, Place or NPC notes, and nothing outside the Campaign folder.
5. **Ask once, then stop.** In one message, ask every section the request left open, each marked as optional — the DM may answer any of them, or none. With the questions, say that you can suggest ideas for the pitch, the truths and the opening; and offer each new Character. A request that answered every section asks nothing.
6. **The DM's answers** fill the README's sections: write each answered one in its place, checked as in step 3. Ask only about an answer that does not fit (a Character not in the Workspace, a seventh truth), and nothing again that the DM skipped.
7. **Report**: the Campaign's path; each Adventure named without a link, saying that it is not in the Workspace yet, and that `dmr-import-adventure` can import it, which links it here; each world named without a folder; and each Character offered.

Done when the Campaign folder, its core and its README exist, the README holds exactly the sections the DM answered, and nothing outside the Campaign folder changed.

## Change the README

A change the DM states to a Campaign that has started: any section, as structure.md's "The README is kept current" leaves it to this skill.

1. **Load the rules**, as for a start.
2. **The Campaign** is the one the request names, or the Workspace's only one. With several and none named: ask which, and write nothing. One the Workspace does not have: say so, offer to start it, and write nothing.
3. **Read its README.**
4. **Which section.** Each change goes to the section the request names or plainly means: a darker tone or a new line to the Tone and Table Limits, a new truth to the Truths, the next Adventure to Adventures Run, a Character joining or leaving to the Party, where the story now stands to Current State. When the request does not say which section, or whether it adds to a section or replaces what it holds, ask, and write nothing.
5. **Check it** as step 3 of a start does: a world, an Adventure, a Character — one not a Character yet is [offered](#new-characters), not linked. Ask about a change that does not fit (a seventh truth), and write nothing until it does.
6. **Write it** in the DM's words, with no preview:
   - **A changed section** holds the new text in its place; **a new one** — a section the DM skipped at the start — goes in its place in the [README's order](#the-readme); **a removed one** goes with its heading. Current State is never removed: a request to remove it is offered a new Current State instead.
   - **Adventures Run**: a new Adventure is a new line, after the others unless the DM says where, its Parts run and its status as the table below gives them; a status or Parts run changes as the DM says.
   - **Party**: a Character joining gets its link; one leaving loses its line, with no mark kept — what happened is the Sessions'.
   - **Current State** is replaced whole, as structure.md's Current State rule keeps it: a Session or a number in the DM's words is left out, and the report says so.
   - Every other section stays byte for byte, and nothing outside the README changes.
7. **Report** each section changed, with its text before and after; each Adventure named without a link and each world named without a folder, as a start reports them; and each Character offered.

Done when the README holds the change in the DM's words and every other section is as it was, or the DM has the one question that stopped it and nothing was written.

## Change Party State

A change the DM states to where the party stands, outside a Session's Consolidation, or a rewrite of an older Party State. The rules are structure.md's "Party State's lines".

1. **Load the rules**, as for a start.
2. **The Campaign** is found as for a README change. One with no Party State yet gets one, at its root, holding only the updated-at line and the sections the change needs.
3. **Read its Party State**, and the Character notes it links to.
4. **An older Party State**, one with no updated-at line, is rewritten first, as structure.md's "Party State's lines" says: each value moved to its known line, every other word kept where it was as the DM's own, and the updated-at line naming the last consolidated Session. Show the rewrite in one message, and end your turn with nothing written: the whole note as it will read, then the list of what is the Build's (each item count, attunement, what is worn or wielded, damage) next to what each Character's Build says, and the list of each value it could not place. A request that already gives the go-ahead is the yes. On a yes, write it, and add a Glossary row for each label new to it; the Builds stay as they are, and the report hands each difference to `dmr-character`. A request that asks only for the rewrite stops here. On a no, write nothing in Party State.
5. **The change.** Which Character, which line, and the value: in the request ("Brom is at 30" is Brom's Hit Points: `30 of 44`, the maximum from his Build). A change that is a Build's — an item gained or lost, coins, attunement — is not Party State's: say so and offer the `dmr-character` skill, and write nothing. When the request leaves the Character, the line or the value unclear, ask, and write nothing.
6. **Preview, then a yes**: each line before and after, in one message, and end your turn with nothing written. A request that gives the exact value ("Brom is at 30", "Ayla has no Inspiration left") is the go-ahead.
7. **Write it**: only those known lines of that Character's section, and the updated-at line, which keeps its Session and gains "then changed by the DM" (in the Workspace Language) once. Every other line, the DM's own words and every other section stay byte for byte. Party State keeps no history: the old value is not kept, and nothing in a Session note changes.
8. **Report** each line changed, with its value before and after, and what was handed to `dmr-character`.

Done when Party State holds the change and every other line is as it was, or the DM has the one question that stopped it and nothing was written.

## The README

`<campaigns folder>/<Campaign>/README.md`. It starts with `# <Campaign name>`, in the DM's words, then these sections in this order, each a `##` heading in the Workspace Language (the English names below are the ones to translate). A section the DM did not answer is left out, except Current State:

| Section | Holds |
| --- | --- |
| Pitch | The premise, in one to three sentences |
| World | The world the Campaign is set in: an official Setting, the DM's own world, or both (the DM's additions to an official Setting). One line each: the world's name, then where it lives — `Orsenna — World › Orsenna`, `Forgotten Realms — Reference › Setting › Forgotten_Realms`. A world with no folder yet is named alone |
| Adventures Run | The Adventures the Campaign runs, one line each in the order they are run: the Adventure, the Parts run (`whole`, or its Parts as the book names them: `chapters 1–2`) and its status (`planned`, `running` or `finished`). An Adventure folder is linked by its README, `[[<adventures folder>/<Adventure>/README\|<Adventure title>]]`; one not in the Workspace is named, not linked. The part is `whole` and the status `planned` unless the DM says otherwise. The Parts run are the plan — how much of the Adventure the Campaign means to run — never how far the party has got, which is Current State's and the Recaps' |
| Party | Each Character, a link to its note (`[[Ayla]]`). Empty until a Character joins |
| Starting Level | The level the Characters start at |
| Tone and Table Limits | The themes and the tone; the lines — what never happens at this table; the veils — what happens only off-screen. One line each |
| Truths | Up to six short statements that make this Campaign's world its own ("The gods are silent"), a numbered list |
| Current State | Where the story stands, as structure.md's Current State rule keeps it. It starts as the opening — the first scene, and the hook that draws the party in — or, with none, says the Campaign has not started |

Every value is the DM's words, or, for the lines Consolidation proposes, the words the DM kept. The headings, `whole`, the Parts' names and the statuses are translated as structure.md's "Translating a term" says. A place or NPC the opening names stays text: it becomes a note in the Campaign's Places or NPCs when the DM asks for one.

The README names no Session. A plot the DM writes, and a change the DM makes to an Adventure, are this Campaign's own notes, as structure.md's Campaigns section says; the Adventures' notes stay as they are.

## Ideas

Only the DM's words are written. When the DM asks for ideas — "suggest a pitch", "give me some truths", "how could it open?", "a new truth for Heroes?" — offer two or three, in chat, and end your turn; write only the one the DM picks or edits. Never fill or change a section on your own.

## New Characters

A party member who is not a Character yet is never written by this skill. Offer to create it with the `dmr-character` skill; on a yes, invoke it, telling it the Campaign's starting level as the Character's level unless the DM says otherwise, and that this skill links it in the Party, and follow its procedure. Once the Character note exists, link it in the Party section.
