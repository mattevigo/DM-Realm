---
name: dmr-ask
description: Answer the DM's questions about DM Realm and a DM Realm Workspace, changing nothing — how to start or do something and what to do next ("how do I start?", "what should I do now?", "how do I bring in my old vault?"), what happened in a Campaign or where it stands ("what happened with Tessa?", "how hurt is Brom?"), rules and official material ("can Durga grapple the ogre from last session?"), and running the game. Only questions: a request to do something ("prepare the next session") is its own skill's.
argument-hint: <your question>
allowed-tools: Read, Glob, Grep, Skill, Bash(ls:*), Bash(sh:*), Bash(DMR_SOURCE_CACHE=*)
---

# Answer the DM's questions

Answer the DM's question from what DM Realm's skills, the Workspace and the Trusted Source hold. **Write, move and delete nothing** — no note, no Translation Glossary row, no Config — whatever the question finds missing or wrong: say so and name the skill that would fix it. Speak to the DM in the Workspace Language, or outside a Workspace in the language they wrote in.

1. **Where you are.** A folder with `workspace-config.yml` at its root is a Workspace: invoke `dmr-workspace` (read its structure.md in full) and find the Workspace Language and Edition in use as its "Fixed after Setup" reads them. Anywhere else, only [using DM Realm](#using-dm-realm) is answered: a question about a Workspace, a Campaign or official material is met by saying it needs a Workspace — rules follow its Edition — and offering `/dm-realm:dmr-setup`. Never ask for an Edition to answer a question.
2. **Sort the question** into the parts below; one question may need several, answered together. When it is a request to do something rather than a question, it is not this skill's: invoke the skill that does it.
3. **Answer**, then **hand off only on a yes.** When the answer recommends a skill and the DM then says to go ahead ("yes, do it"), invoke that skill with what the DM asked for; from there it runs as it always does, with its own questions and previews. Never invoke it on your own.

Done when every part of the question is answered, each fact naming where it came from, and nothing in the Workspace has changed.

## Using DM Realm

How to start, how to do something, what to do next.

- **The skills**: read the frontmatter of each `dmr-` skill in the folders next to this skill's own, leaving out every one marked `user-invocable: false`: its `name` and `description` say what it does. Read a skill's SKILL.md body only when the DM asks how it goes about it. **How they fit together** — their order, and what has no skill yet — is [workflows.md](workflows.md), next to this file.
- **What to do next** comes from the Workspace as it stands: its Campaigns, their latest Session by `date`, whether it was played (its Live Notes or Recap hold something), whether it is consolidated as structure.md's Diary rule tells it, and whether the Chronicle tells it. A played Session not yet consolidated comes first.
- **Name the command** for each skill recommended — `/dm-realm:<skill>` and what to give it (`/dm-realm:dmr-session-consolidate session 3 of Ashfall`) — and say it can also be asked for in plain words.
- **A job no skill does**, as workflows.md lists them: say no skill does it, then name the skills that do a part of it and which part. Never describe a procedure for the rest.

## The Workspace and its Campaigns

What a note says, what happened at the table, where things stand. The reader is the DM: every note may be read and told, the Prep of a Session not yet played and an Adventure's unplayed chapters included.

- **The Campaign** is the one the question names, or the Workspace's only one. With several and none named, answer from each that has it, or ask which.
- **What happened** comes from the Sessions' Live Notes and Recaps, weighed as structure.md's Live Notes and Chronicle rules weigh them; a Session not yet consolidated has its Live Notes alone. The Diary is the index for finding the Session. Prep is never a source for what happened.
- **Where things stand now** comes from the Party State (hit points, spent resources, the party's treasure) and the Characters' current Builds.
- **The Chronicle** is never a source for what happened: its telling is invented, as structure.md's Chronicle rule says. Read it only for a question about the Chronicle itself ("what did chapter 2 say?").
- **Name the notes** each fact came from, by their names in the Workspace.

## Official material

What structure.md calls Research. Invoke `dmr-trusted-source` and answer as structure.md's Research says: nothing here adds to it or replaces it. A Reference entry the Workspace has not imported is offered as an Import (`dmr-import`); an Adventure's text cannot be imported yet, as workflows.md says.

## Running the game

Pacing, a chase, an improvised NPC, a fight for this party. Give your own advice, presented as advice, never as what a book says. Every mechanical claim in it — a CR, an XP budget, a DC, a rule — is [official material](#official-material), answered and cited from the Trusted Source; one the Trusted Source does not hold is left out.
