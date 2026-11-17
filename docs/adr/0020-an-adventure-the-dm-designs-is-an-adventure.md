# An Adventure the DM designs is an Adventure

An Adventure is no longer only official. One the DM designs — a story any table could run, with no table in it — lives in the Adventures folder beside the published ones, is kept apart from every Campaign in the same way, and a Campaign runs it the same way: whole or in part, down to a single Part, listed in its README's Adventures Run. What a Campaign changes or adds while running either kind stays that Campaign's own content. The two kinds are told apart by the source property: an official Adventure's notes record their book and release, a designed one's record none. This reverses the rule, in CONTEXT.md and structure.md, that a plot the DM writes is never an Adventure but always its Campaign's.

A designed Adventure's notes may link to Reference, to their own Adventure, to Homebrew and to World; never to another Adventure (official ones included), a Character, a Campaign or DM Tools, and they never mention one. Knowledge still follows links: the Adventure knows the rules, the DM's material and the world it is set in, and no table. World and Homebrew notes still never link to an Adventure.

## Considered Options

- **Keep the DM's plot in its Campaign**, reusable only by Promotion into Homebrew or World, piece by piece. Rejected: an adventure the DM writes before knowing which table will play it, or runs at two tables, had no home, and Promotion would scatter it across Scopes.
- **A sub-kind of Homebrew** (Homebrew › Adventures). Rejected: Homebrew is game material with mechanics and may not link to World, so an adventure set in the DM's world would break its link rules.
- **Under a world** (World › `<world>` › Adventures). Rejected: it ties each adventure to one world, against reuse, and World may not hold mechanics.
- **A new top-level Scope.** Rejected: one more row and column in the link rules, a Setup folder and Config key, for content that behaves as an Adventure does everywhere a Campaign, Session prep or MapForge reads it.

## Consequences

- **The official-only rules become rules of an official Adventure**: the Import, the update check, a README holding only what the Trusted Source gives, and "not meant to be edited by the DM". A designed Adventure is the DM's to edit at any time, and nothing re-imports it.
- **The link rules gain a row**: an official Adventure links to Reference and itself; a designed one also to Homebrew and World.
- **What reads the Adventures folder keeps working unchanged** — a Campaign README's Adventures Run, Session prep, MapForge's bestiary and the Portrait backfill already read it without regard to where its notes came from.
- **Which plot is an Adventure is the DM's call**, by how they ask: one designed as an Adventure is one; a plot written for one table (a Quest, a rival Faction, their own dungeon in place of chapter 3) stays its Campaign's. Promotion gains a third destination: a Campaign's plot moves into a new Adventure, with every mention of the Campaign removed.
- **A designed Adventure's mechanics follow the official split**: an item it introduces is in its own Items, an item note like any other; a monster it introduces is a Homebrew monster, linked from its NPC and Encounter notes, so a stat block still lives outside every Adventure.
- **Ideas reach Adventures**: the agent may invent story content for a designed Adventure, checked against its own notes, the rules and its world, and written only when the DM keeps it.
